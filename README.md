# Langfens - Intelligent IELTS Preparation Platform

**Phase 1: Foundation & Core Learning Engine**

## Executive Summary

Langfens is a comprehensive online IELTS preparation platform designed to bridge the gap between self-study and professional assessment. By leveraging a distributed Microservices architecture, the platform delivers a high-integrity testing environment and instant, AI-powered feedback across all four IELTS skills.

The system is engineered for scalability and reliability, ensuring that as the user base grows, the quality of service—from exam simulation to automated grading—remains consistent.

## Key Product Capabilities

### 1. Comprehensive Exam Simulation
The core of Langfens is its ability to replicate the strict conditions of an actual IELTS exam, providing users with a realistic practice environment.

*   **Full Skill Coverage:** Users can practice complete tests (Reading, Listening, Writing, Speaking) under strict timed conditions.
*   **Integrity & Consistency:** The system employs rigorous data snapshotting mechanisms. When a user starts an attempt, the specific version of the test is locked to that session, ensuring that subsequent administrative content updates do not affect historical results or current attempts.
*   **Reliability:** An intelligent Autosave feature runs in the background, protecting user progress against browser crashes or connectivity interruptions without disrupting the flow.

### 2. Automated & AI Assessment Engine
We address the bottleneck of traditional manual grading with a hybrid evaluation pipeline that combines deterministic algorithms with Generative AI to provide instant results.

*   **Instant Grading (Reading & Listening):** Our proprietary evaluation engine offers immediate, precise scoring. It utilizes flexible pattern matching (handling case sensitivity, plural variations, and alternative spacing) that mirrors official IELTS marking standards.
*   **AI-Powered Feedback (Writing & Speaking):**
    *   **Writing:** Direct integration with GPT-4o provides users with actionable feedback aligned with official IELTS criteria (Task Response, Coherence, Lexical Resource, Grammatical Range).
    *   **Speaking:** The system automates the evaluation process by processing audio submissions via Whisper (Speech-to-Text) and analyzing transcriptions for fluency and content relevance, effectively democratizing access to speaking evaluation.
*   **Cost-Efficient Assistance:** A local LLM-based chatbot (Ollama/Qwen) handles routine user queries, balancing operational costs with user support needs.

### 3. Accelerated Vocabulary Acquisition
Langfens moves beyond simple rote memorization by integrating evidence-based learning techniques directly into the workflow.

*   **Spaced Repetition System (SRS):** Implementing the industry-standard **SM2 algorithm**, the platform dynamically calculates optimal review intervals for flashcards, maximizing long-term vocabulary retention.
*   **Contextual Learning:** The built-in dictionary offers millisecond-latency lookups (powered by Elasticsearch) and uses AI to automatically enrich definitions with relevant examples, helping users understand word usage in context.

### 4. Engagement & Retention System
To combat learner fatigue, the platform incorporates a robust gamification layer designed to sustain user motivation.

*   **Seamless Feedback Loop:** The system utilizes an Event-Driven architecture to decouple user actions from rewards. When a user completes a task, the achievement system calculates XP and unlocks milestones asynchronously, ensuring the learning experience remains fluid and responsive.

## Technical Foundation

While the business value drives the platform, the underlying engineering ensures its delivery. Langfens operates on a modern **Microservices Architecture** to guarantee **High Availability** and **Fault Isolation**.

*   **Scalability:** Services are decoupled (Core Business Logic, AI Workers, Gamification), allowing independent scaling of resource-intensive AI tasks versus lightweight API requests.
*   **Performance:** Utilizing **.NET 8 / 9** for core logic and **gRPC** for internal communication ensures minimal latency.
*   **Resiliency:** Critical workflows such as exam grading and gamification updates are handled via an Event Bus (RabbitMQ), preventing system bottlenecks during peak traffic.

**Core Technology Stack:** .NET, Python (FastAPI), PostgreSQL, MongoDB, Elasticsearch, Redis, Docker.

