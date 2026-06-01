import os
import io
import logging
import subprocess
import torch
import torch.nn as nn
import numpy as np
from scipy.io import wavfile
from transformers import Wav2Vec2Model, Wav2Vec2FeatureExtractor
from app.config import settings

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Model architecture definition matching the checkpoint
# ---------------------------------------------------------------------------

class PronunciationScorerModel(nn.Module):
    def __init__(self, model_name="facebook/wav2vec2-base"):
        super().__init__()
        self.wav2vec2 = Wav2Vec2Model.from_pretrained(model_name)
        self.regressor = nn.Sequential(
            nn.Linear(768, 256),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(256, 4)
        )
        
    def forward(self, input_values, attention_mask=None):
        outputs = self.wav2vec2(input_values, attention_mask=attention_mask)
        hidden_states = outputs.last_hidden_state
        
        # Mean pooling across sequence dimension (dim=1)
        if attention_mask is not None:
            active_lengths = attention_mask.sum(dim=1, keepdim=True)
            masked_hidden = hidden_states * attention_mask.unsqueeze(-1)
            pooled = masked_hidden.sum(dim=1) / torch.clamp(active_lengths, min=1.0)
        else:
            pooled = hidden_states.mean(dim=1)
            
        return self.regressor(pooled)


# ---------------------------------------------------------------------------
# Lazy singletons
# ---------------------------------------------------------------------------

_model: getattr(PronunciationScorerModel, "__class__", None) = None
_feature_extractor: getattr(Wav2Vec2FeatureExtractor, "__class__", None) = None


def get_device() -> torch.device:
    """Resolve configured device, falling back to CPU if target is unavailable."""
    dev_str = settings.pronunciation_device.lower()
    if "cuda" in dev_str and not torch.cuda.is_available():
        logger.warning("CUDA requested but not available. Falling back to CPU for pronunciation scoring.")
        return torch.device("cpu")
    if "mps" in dev_str and not torch.backends.mps.is_available():
        logger.warning("MPS requested but not available. Falling back to CPU for pronunciation scoring.")
        return torch.device("cpu")
    return torch.device(dev_str)


def load_model() -> tuple[PronunciationScorerModel, Wav2Vec2FeatureExtractor]:
    """Load model weights and feature extractor once."""
    global _model, _feature_extractor
    if _model is not None and _feature_extractor is not None:
        return _model, _feature_extractor

    checkpoint_path = settings.pronunciation_scorer_path
    if not os.path.exists(checkpoint_path):
        raise FileNotFoundError(f"Pronunciation scorer checkpoint not found at: {checkpoint_path}")

    logger.info(f"Loading pronunciation scorer checkpoint from: {checkpoint_path}")
    checkpoint = torch.load(checkpoint_path, map_location="cpu", weights_only=False)
    
    model_name = checkpoint.get("model_name", "facebook/wav2vec2-base")
    device = get_device()
    
    logger.info(f"Instantiating pronunciation model: {model_name} on device: {device}")
    model = PronunciationScorerModel(model_name=model_name)
    model.load_state_dict(checkpoint["model_state_dict"])
    model.to(device)
    model.eval()
    
    logger.info(f"Loading feature extractor for: {model_name}")
    feature_extractor = Wav2Vec2FeatureExtractor.from_pretrained(model_name)
    
    _model = model
    _feature_extractor = feature_extractor
    return _model, _feature_extractor


def decode_audio_bytes(audio_bytes: bytes, target_sr: int = 16000) -> np.ndarray:
    """
    Decodes audio bytes of any format to raw mono float32 array at target_sr Hz.
    Uses FFmpeg via subprocess, falling back to scipy.io.wavfile.
    """
    # 1. Try to use FFmpeg via subprocess
    cmd = [
        "ffmpeg",
        "-y",
        "-i", "pipe:0",
        "-f", "s16le",
        "-ac", "1",
        "-ar", str(target_sr),
        "pipe:1"
    ]
    try:
        process = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        out, err = process.communicate(input=audio_bytes)
        if process.returncode == 0 and len(out) > 0:
            waveform = np.frombuffer(out, dtype=np.int16).astype(np.float32) / 32768.0
            return waveform
        else:
            err_msg = err.decode("utf-8", errors="ignore")
            logger.warning(f"FFmpeg decoding failed (exit {process.returncode}): {err_msg}")
    except Exception as exc:
        logger.warning(f"Could not execute FFmpeg for audio decoding: {exc}")
        
    # 2. Fallback to scipy (supports standard WAV bytes)
    logger.info("Falling back to SciPy wavfile loader...")
    try:
        sr, waveform = wavfile.read(io.BytesIO(audio_bytes))
        # Mix to mono
        if len(waveform.shape) > 1:
            waveform = waveform.mean(axis=1)
        # Normalize dtype
        if waveform.dtype == np.int16:
            waveform = waveform.astype(np.float32) / 32768.0
        elif waveform.dtype == np.int32:
            waveform = waveform.astype(np.float32) / 2147483648.0
        elif waveform.dtype == np.uint8:
            waveform = (waveform.astype(np.float32) - 128.0) / 128.0
            
        # Resample if needed
        if sr != target_sr:
            num_samples = int(len(waveform) * target_sr / sr)
            waveform = np.interp(
                np.linspace(0, len(waveform), num_samples),
                np.arange(len(waveform)),
                waveform
            ).astype(np.float32)
            
        return waveform
    except Exception as exc:
        logger.exception("Failed to decode audio bytes using SciPy fallback")
        raise ValueError("Unsupported or invalid audio format.") from exc


def evaluate_acoustic_pronunciation(audio_bytes: bytes) -> dict[str, float]:
    """
    Evaluates audio bytes and returns a dictionary of metrics:
    - pronunciation: float
    - accent: float
    - fluency: float
    - prosody: float
    - overall: float (derived using weighted formula from checkpoint)
    """
    model, feature_extractor = load_model()
    device = get_device()
    
    # Preprocess audio (Wav2Vec2 models are trained at 16kHz)
    raw_speech = decode_audio_bytes(audio_bytes, target_sr=16000)
    
    # Feature extraction
    inputs = feature_extractor(
        raw_speech,
        sampling_rate=16000,
        return_tensors="pt"
    )
    
    input_values = inputs.input_values.to(device)
    
    # Predict
    with torch.no_grad():
        outputs = model(input_values)
        
    predictions = outputs[0].cpu().numpy()
    
    # Map predictions to scores dictionary
    score_cols = ["pronunciation", "accent", "fluency", "prosody"]
    scores = {}
    for col, val in zip(score_cols, predictions):
        # Clip to [0.0, 1.0] for safety
        scores[col] = float(np.clip(val, 0.0, 1.0))
        
    # Apply total formula: 0.40*pronunciation + 0.25*accent + 0.20*fluency + 0.15*prosody
    overall = (
        0.40 * scores["pronunciation"] +
        0.25 * scores["accent"] +
        0.20 * scores["fluency"] +
        0.15 * scores["prosody"]
    )
    scores["overall"] = float(np.clip(overall, 0.0, 1.0))
    
    logger.info(f"Acoustic evaluation scores: {scores}")
    return scores
