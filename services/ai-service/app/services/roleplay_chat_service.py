import json
import logging
import re

from langchain_google_genai import ChatGoogleGenerativeAI

from app.config import settings
from app.schemas import RoleplayLLMOutput, RoleplayScenario

logger = logging.getLogger(__name__)


def _normalize_llm_text(content) -> str:
    if isinstance(content, str):
        return content.strip()
    if isinstance(content, list):
        chunks = []
        for item in content:
            if isinstance(item, dict) and "text" in item:
                chunks.append(str(item["text"]))
            else:
                chunks.append(str(item))
        return " ".join(chunks).strip()
    return str(content).strip()


def _fallback_output(scenario: RoleplayScenario, turn_count: int) -> RoleplayLLMOutput:
    if scenario.suggested_topics:
        topic = scenario.suggested_topics[turn_count % len(scenario.suggested_topics)]
        reply = f"Thanks for sharing that. Could you give a bit more detail about {topic}?"
    else:
        reply = "Thanks for your response. Could you explain that in a bit more detail?"
    return RoleplayLLMOutput(agent_reply=reply)


def _build_prompt(scenario: RoleplayScenario, turns: list[dict], user_utterance: str) -> str:
    history = "\n".join(f"{turn['speaker'].upper()}: {turn['text']}" for turn in turns[-8:])
    target_vocab = ", ".join(scenario.target_vocabulary)
    target_grammar = ", ".join(scenario.target_grammar)

    return (
        "You are an IELTS speaking roleplay partner.\n"
        f"Scenario: {scenario.title} ({scenario.slug})\n"
        f"Context: {scenario.context}\n"
        f"Your role: {scenario.agent_role}\n"
        f"Learner role: {scenario.user_role}\n"
        f"Target vocabulary: {target_vocab}\n"
        f"Target grammar focus: {target_grammar}\n"
        "Rules:\n"
        "- Stay in character for this scenario.\n"
        "- Reply in 1-3 natural spoken sentences.\n"
        "- Ask a follow-up question when useful to keep conversation going.\n"
        "- If the learner says something completely unrelated to the scenario, acknowledge it briefly but IMMEDIATELY steer the conversation back to the task.\n"
        "- Keep the language clear for IELTS practice.\n"
        "Conversation history:\n"
        f"{history}\n"
        f"Current learner utterance: {user_utterance}\n"
        "You MUST respond with a valid JSON object exactly matching this structure:\n"
        "{\n"
        '  "agent_reply": "Your conversational reply here",\n'
        '  "feedback": {\n'
        '    "content": "Short feedback on relevance (state clearly if off-topic)",\n'
        '    "grammar": "Short grammar tip if needed, otherwise empty",\n'
        '    "lexical": "Short vocabulary tip if needed, otherwise empty",\n'
        '    "fluency": "Short fluency tip if needed, otherwise empty"\n'
        '  },\n'
        '  "content_score": 0.0,\n'
        '  "grammar_score": 0.0,\n'
        '  "fluency_score": 0.0,\n'
        '  "lexical_score": 0.0,\n'
        '  "off_topic": false\n'
        "}\n"
        "SCORING RUBRIC (STRICT - follow exactly):\n"
        "content_score (0.0-1.0) = RELEVANCE to the active scenario task:\n"
        "  0.0-0.2: Completely unrelated to the scenario. MUST use this range when off_topic=true.\n"
        "  0.3-0.5: Partially related, mostly tangential.\n"
        "  0.6-0.8: Mostly relevant with reasonable depth.\n"
        "  0.9-1.0: Fully on-topic, directly answers the task.\n"
        "  STRICT RULE: If off_topic=true, content_score MUST be <= 0.25. No exceptions.\n"
        "grammar_score (0.0-1.0) = grammatical accuracy and range. Independent of topic relevance.\n"
        "fluency_score (0.0-1.0) = flow, coherence, naturalness. Independent of topic relevance.\n"
        "lexical_score (0.0-1.0) = vocabulary range and precision. Independent of topic relevance.\n"
        "off_topic = true if the response has NO meaningful connection to the scenario.\n"
        "CALIBRATION: Scores of 1.0 are RARE — reserved for truly exceptional, native-like responses. "
        "Typical IELTS B2 learners score 0.55-0.75. Even clear non-native speech rarely exceeds 0.85. "
        "Grammatically correct sentences alone do NOT warrant a 1.0 grammar score.\n"
        "Do not include any markdown outside the JSON block."
    )


async def generate_agent_reply(scenario: RoleplayScenario, turns: list[dict], user_utterance: str) -> RoleplayLLMOutput:
    if not settings.gemini_api_key:
        return _fallback_output(scenario, len(turns))

    prompt = _build_prompt(scenario, turns, user_utterance)
    model = ChatGoogleGenerativeAI(
        model=settings.gemini_chat_model,
        google_api_key=settings.gemini_api_key,
        temperature=settings.gemini_chat_temperature,
        max_output_tokens=min(settings.gemini_chat_max_tokens, 512),
        timeout=settings.gemini_chat_timeout,
    )

    try:
        result = await model.ainvoke(prompt)
        raw = _normalize_llm_text(result.content)
        if raw:
            # Extract JSON block
            json_str = raw
            match = re.search(r'\{.*\}', raw, re.DOTALL)
            if match:
                json_str = match.group(0)
            try:
                data = json.loads(json_str)
                return RoleplayLLMOutput.model_validate(data)
            except Exception as parse_exc:
                logger.warning("Gemini JSON parsing failed: %s. Raw: %r", parse_exc, raw[:200])
                return RoleplayLLMOutput(agent_reply=raw)
    except Exception as exc:
        logger.warning("Gemini roleplay generation failed: %s", exc)

    return _fallback_output(scenario, len(turns))

