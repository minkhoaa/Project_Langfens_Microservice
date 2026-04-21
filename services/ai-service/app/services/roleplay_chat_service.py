import logging

from langchain_google_genai import ChatGoogleGenerativeAI

from app.config import settings
from app.schemas import RoleplayScenario

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


def _fallback_reply(scenario: RoleplayScenario, turn_count: int) -> str:
    if scenario.suggested_topics:
        topic = scenario.suggested_topics[turn_count % len(scenario.suggested_topics)]
        return f"Thanks for sharing that. Could you give a bit more detail about {topic}?"
    return "Thanks for your response. Could you explain that in a bit more detail?"


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
        "- Keep the language clear for IELTS practice.\n"
        "Conversation history:\n"
        f"{history}\n"
        f"Current learner utterance: {user_utterance}\n"
        "Respond now as the roleplay partner only."
    )


async def generate_agent_reply(scenario: RoleplayScenario, turns: list[dict], user_utterance: str) -> str:
    if not settings.gemini_api_key:
        return _fallback_reply(scenario, len(turns))

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
        text = _normalize_llm_text(result.content)
        if text:
            return text
    except Exception as exc:
        logger.warning("Gemini roleplay generation failed: %s", exc)

    return _fallback_reply(scenario, len(turns))
