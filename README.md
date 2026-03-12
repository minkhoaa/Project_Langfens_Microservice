<h1 align="center">LANGFENS</h1>

<p align="center">
  <strong>Study IELTS Smarter. Score Higher. Save Time.</strong>
</p>

<p align="center">
  <em>A comprehensive IELTS preparation platform with instant AI evaluation — Turning studying into an experience, not just coursework.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/.NET-8.0%2F9.0-512BD4?style=for-the-badge&logo=dotnet&logoColor=white" alt=".NET">
  <img src="https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Redis-7.4-DC382D?style=for-the-badge&logo=redis&logoColor=white" alt="Redis">
  <img src="https://img.shields.io/badge/RabbitMQ-3.x-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white" alt="RabbitMQ">
  <img src="https://img.shields.io/badge/Elasticsearch-8.19-005571?style=for-the-badge&logo=elasticsearch&logoColor=white" alt="Elasticsearch">
  <img src="https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/OpenAI-GPT--4o-412991?style=for-the-badge&logo=openai&logoColor=white" alt="OpenAI">
</p>

---

## Executive Summary

### The Problem

The current IELTS preparation market is facing **3 serious bottlenecks**:

| Problem | Consequence |
|--------|---------|
| **High cost of Writing/Speaking grading** | Students must pay $50–100 per submission, or wait 5–7 days to receive feedback from a teacher |
| **Lack of a realistic exam environment** | Students feel overwhelmed when entering the real exam hall because they are not accustomed to time pressure |
| **Forgetting vocabulary after 1 week** | 90% of crammed vocabulary disappears due to the absence of a scientific spaced-repetition system |

> **Existing solutions fail** because they rely on human resources (manual grading), or only provide practice tests without meaningful feedback.

### The Solution

**Langfens** is the first IELTS preparation platform to combine:

- **Instant AI evaluation** for Writing & Speaking — receive feedback in seconds, not days.
- **100% real-exam simulation environment** — time pressure, exam interface, autosave to protect your work.
- **Permanent vocabulary retention system** — the SM2 (Spaced Repetition) algorithm helps retain vocabulary in long-term memory.

> **USP (Unique Selling Proposition):** Langfens is the only platform that provides **high-quality AI evaluation + Gamification + Spaced Repetition** within ONE seamless ecosystem.

---

## Key Value Propositions

| # | Value | Meaning for Users |
|---|---------|------------------------|
| **1** | **Save 80% on costs** | No need to pay for manual grading — AI grades with accuracy aligned to official IELTS criteria |
| **2** | **Learn 3x faster** | Instant feedback = correct mistakes immediately = progress faster than traditional learning |
| **3** | **Remember vocabulary 5x longer** | The SM2 algorithm has been proven effective by millions of Anki users |
| **4** | **Fun learning, no dropout** | Gamification with XP, Streaks, and Achievements keeps motivation consistently high |

---

## Feature Highlights

### 1. 100% Real Exam Simulation
> *"If you win in practice, you will win in the real exam."*

- **All 4 skills:** Listening, Reading, Writing, Speaking — all with time limits matching the real exam.
- **Work protection:** Autosave runs in the background — lost connection, browser crash? Your work is still safe.
- **Fixed exam version:** When you start a test, the exam content is "frozen" — admin updates will not affect your results.

### 2. AI Assessment Engine
> *"From submission to score: 30 seconds, not 3 days."*

| Skill | Technology | Response Speed |
|---------|-----------|-----------------|
| **Reading & Listening** | Smart Pattern Matching (handles case, plurals, whitespace) | **< 1 second** |
| **Writing** | GPT-4o evaluates against 4 official IELTS criteria (Task Response, Coherence, Lexical Resource, Grammar) | **< 30 seconds** |
| **Speaking** | Whisper STT → AI analyzes fluency, pronunciation, content | **< 60 seconds** |

### 3. Vocabulary Mastery
> *"Don't memorize. Remember LONG-TERM."*

- **Spaced Repetition System (SM2):** Algorithm calculates optimal review timing — study less, remember longer.
- **Ultra-fast dictionary lookup:** Elasticsearch delivers results in < 50ms.
- **AI-enriched context:** Automatically adds examples, collocations, and usage notes for each word.

### 4. Gamification
> *"Turn every lesson into a game."*

- **XP & Level System:** Complete a test = earn XP = level up.
- **Achievements & Badges:** Unlock badges when reaching milestones (complete 10 tests, 7-day streak...).
- **Leaderboard:** Compete with friends to maintain motivation.

### 5. AI Chatbot 24/7 Support
> *"Got a question? AI answers immediately — no need to wait for a teacher."*

- **Runs Local LLM (Qwen 2.5):** Reduces operational costs while maintaining quality.
- **Support & explanations:** Explains grammar, vocabulary, and test-taking tips.

---

## Target Audience

| Audience | Need | How Langfens Helps |
|-----------|---------|---------------------|
| **Students** | Need to prepare for IELTS on a limited budget | Free AI grading, study anytime anywhere |
| **Working professionals** | Limited time, need maximum learning efficiency | Spaced Repetition + instant feedback saves time |
| **English language centers** | Need to reduce grading costs, improve service quality | API integration, student progress dashboard |
| **IELTS teachers** | Need tools to help manage assignments | Create & assign tasks, AI-assisted preliminary grading |

---

## Technical Architecture

> **Every technology choice serves ONE goal: Deliver the best learning experience for users.**

### Microservices Architecture — Why?

```
┌─────────────────────────────────────────────────────────────────────┐
│                           API GATEWAY                               │
│               (YARP Reverse Proxy + JWT Authentication)             │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────────────┐
│ Auth          │     │ Exam          │     │ Attempt               │
│ Service       │     │ Service       │     │ Service               │
└───────────────┘     └───────────────┘     └───────────────────────┘
        │                     │                       │
        ▼                     ▼                       ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────────────┐
│ Writing       │     │ Speaking      │     │ Vocabulary            │
│ Service       │     │ Service       │     │ Service               │
└───────────────┘     └───────────────┘     └───────────────────────┘
        │                     │                       │
        ▼                     ▼                       ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────────────┐
│ Gamification  │     │ Dictionary    │     │ Chatbot               │
│ Service       │     │ Service       │     │ Service               │
└───────────────┘     └───────────────┘     └───────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
            ┌─────────────┐         ┌─────────────┐
            │ RabbitMQ    │         │ Elastic     │
            │ Event Bus   │         │ Search      │
            └─────────────┘         └─────────────┘
```

### Technology Choices — Why, Not Just What

| Technology | Business Problem Solved |
|-----------|-------------------------------------|
| **Microservices Architecture** | **Independent scaling** — When traffic spikes during exam season, only scale the necessary services (Exam, Attempt), reducing server costs |
| **.NET 8/9 + Minimal API** | **High performance, low latency** — Handles 10,000+ requests/second per service, users feel no delay |
| **PostgreSQL** | **Critical data requires ACID** — Exam scores and student submissions are fully protected |
| **Redis** | **Response < 100ms** — Caching sessions, JWT tokens, and hot data ensures a smooth experience |
| **RabbitMQ (Event-Driven)** | **Non-blocking for users** — Grading, XP calculation processed in the background; users don't have to wait |
| **Elasticsearch** | **Dictionary lookup in 50ms** — Ultra-fast full-text search with fuzzy matching support |
| **Ollama (Qwen 2.5 Local LLM)** | **Save 90% on AI costs** — Chatbot runs locally, no cloud API call costs |
| **GPT-4o (Azure OpenAI)** | **Best evaluation quality** — For critical tasks like Writing grading, the best model is used |
| **Whisper (OpenAI)** | **Accurate STT** — Converts speech to text for AI-based Speaking evaluation |
| **Docker + Compose** | **One-command deployment** — From code to production in minutes, environment-independent |

### Architecture Principles

| Principle | Meaning |
|------------|---------|
| **Fault Isolation** | If the Gamification service goes down, users can still take exams normally |
| **Event-Driven** | Heavy tasks (AI grading, XP calculation) are processed asynchronously via Message Queue |
| **Security First** | JWT authentication, role-based access control, input validation at every endpoint |
| **Horizontal Scaling** | Add instances as needed, load balancer distributes traffic automatically |

---

## Roadmap & Future Vision

### Phase 1: Foundation (Current)
- [x] All 4 complete IELTS skills
- [x] AI Grading Engine for Writing & Speaking
- [x] Spaced Repetition Vocabulary System
- [x] Gamification Core (XP, Levels, Achievements)
- [x] 12+ production-ready Microservices

### Phase 2: Scale (Q2 2026)
- [ ] Mobile App (React Native)
- [ ] Real-time multiplayer practice rooms
- [ ] Advanced analytics dashboard for students
- [ ] Teacher dashboard with batch grading

### Phase 3: Expansion (Q4 2026)
- [ ] TOEFL, PTE, Duolingo English Test support
- [ ] Enterprise API for English language centers
- [ ] White-label solution
- [ ] AI Tutor with personalized learning paths

---

## Services Overview

```
langfens-microservices/
├── gateway/api-gateway        # YARP Reverse Proxy
└── services/
    ├── auth-service           # Authentication & Authorization
    ├── exam-service           # Exam Content Management
    ├── attempt-service        # User Attempts & Submissions
    ├── writing-service        # Writing Assessment (GPT-4o)
    ├── speaking-service       # Speaking Assessment (Whisper + AI)
    ├── vocabulary-service     # Flashcards & Spaced Repetition
    ├── dictionary-service     # Dictionary & Word Lookup
    ├── gamification-service   # XP, Levels, Achievements
    ├── chatbot-service        # AI Assistant (Ollama/Qwen)
    ├── course-service         # Learning Paths & Courses
    └── email-service          # Transactional Emails
```

---

## Quick Start

```bash
# Clone repository
git clone https://github.com/your-org/langfens-microservices.git
cd langfens-microservices

# Start all services with Docker Compose
cd deploy
docker compose up -d

# Access API Gateway at http://localhost:5000
```

---

<p align="center">
  <strong>Langfens — Study IELTS Smarter. Score Higher. Save Time.</strong>
</p>

<p align="center">
  Built with passion by the Langfens Team
</p>
