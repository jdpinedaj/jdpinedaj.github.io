# Sources

Verified claim lines the system cards may use. Copied verbatim from
docs/cv_master.md and docs/pitch_bank.md in the ai-job-hunt repo on
2026-09-29. check.py requires every card sentence to appear here.
Edit index.html to match this file, never the other way round.

## ARIA (pitch bank Tier 2, Tier 3, CV master)

ARIA automates J&J's Architecture Review Board. Four domain architect agents (Business, Technology, Information, Data Science & AI) run on a shared quality-agent engine orchestrated through LangGraph state machines, and only the domains the deck flags as architecturally impacted actually run. The agents negotiate missing evidence over an A2A protocol (batched star topology, each peer answers once instead of N-by-N) and revise their own findings with what comes back. Reasoning is grounded in the LeanIX enterprise architecture inventory (Neo4j graph backend) plus a pgvector store over the standards library; the agents assess slide diagrams directly as multimodal image input. Every finding must cite catalog source IDs; citations are resolved against the catalog and ungrounded rows are dropped or flagged. A review that took a reviewer a full working day now takes about ten minutes.

ARIA, ARB Intake Verifier: multi-agent system that automates J&J's Architecture Review Board. It ingests solution-architecture submissions (PPTX, PDF, DOCX and diagrams), reviews them against the enterprise standards library and returns a scored, fully cited report, cutting a review that took a reviewer a full working day down to roughly 10 minutes.

LLM Safety Framework: Designed and implemented 19 production guardrails at every graph node: prompt injection, PII/PHI redaction (Presidio), data-exfiltration and prompt-leakage detection, schema and citation validation, per-run cost and token ceilings, among others.

Engineering & Delivery: Async FastAPI service with PostgreSQL, connectors for SharePoint/O365, LeanIX and Atlassian, and Arize Phoenix / OpenTelemetry tracing with per-run cost tracking.

Tech stack: Python, LangGraph, LangChain, OpenAI Agents SDK, Azure OpenAI (GPT-5.x), FastAPI, Pydantic, Neo4j, PostgreSQL + pgvector, SQLAlchemy, Docker

## EVA (CV master Iberia block, pitch bank)

Development of EVA (Enhanced Virtual Assistant), a multi-agent conversational ecosystem powered by LLMs to automate Iberia's customer service operations.

LLM Engineering & Model Optimization: Designed, tuned and deployed OpenAI and AWS Bedrock models for production-grade airline assistants handling check-in, cancellations, flight status, flight documentation and other customer processes.

Multi-Agent Architecture: Built modular, hexagonal-architecture-based agents (Check-in, Cancellation, Flight Status, Translator, Tone, Booking, Guardrail) using LangChain and FastAPI with structured I/O through Pydantic schemas.

API Integration: Integrated multiple Iberia APIs and implemented secure, scalable interaction via internal tools and custom MCP servers for external system access.

Security & Guardrails: Created prompt-injection and data-exfiltration detectors ensuring compliant and safe interactions.

Evaluation & Monitoring: Developed internal evaluation tools for LLM cost tracking, token efficiency, latency and output quality.

Tech stack: Python, LangChain, OpenAI, AWS Bedrock (Nova Pro), FastAPI, Pydantic, DynamoDB, structlog, pytest, GitLab CI/CD

## TPP Text2SQL (CV master TPP block, pitch bank)

TPP Text2SQL: production conversational analytics platform over US foot-traffic and mobility data, letting business users run their own analyses in natural language instead of queueing for a data analyst who can write SQL.

Pipeline Architecture: Four-stage hexagonal pipeline (query extraction, context-aware SQL generation, secure execution, natural-language transformation) with session memory and multi-turn follow-up resolution, plus FAISS semantic example selection for few-shot SQL generation.

Defence in depth: regex input guard, a parallel LLM safety classifier adding no perceptible latency, a hardened read-only SQL backstop. Every turn persisted to a PostgreSQL audit table.

Quality & Auditability: A case regression suite combining deterministic oracles with an LLM judge, pre-flight validation of extracted entities against the real catalogs, and every turn persisted to a PostgreSQL audit table.

Earlier work for the same client: scalable algorithms to map US mobility trends and identify home locations, an EMR-based processing pipeline over large geolocation datasets, and the first text2SQL agents (AWS Bedrock Titan, later OpenAI).

Tech stack: Python, LangChain, OpenAI, FAISS, LangSmith, PostgreSQL, BigQuery, GCS, Streamlit, Docker, Bitbucket Pipelines, PySpark, AWS (EMR, EC2, S3, RDS, Athena, Bedrock), GCP (Dataproc, Dataflow, Cloud Storage, Cloud SQL), Gemini

## Enterprise Text2SQL (CV master, pitch bank)

Enterprise Text2SQL Agent: self-serve natural-language querying of enterprise databases, so business users get answers without depending on a SQL-fluent data analyst.

Agent Design: A single tool-calling agent that discovers the schema at runtime, writes read-only SQL and recovers from its own errors by receiving database failures back as tool results; onboarding a new database is a connection-string change, with zero schema-specific prompt engineering.

Hexagonal Architecture & Guardrails: The agent depends only on LLMPort and DatabasePort contracts, so switching LLM vendor or database platform means writing an adapter; read-only SQL validation, step budget and row caps, plus a full offline regression suite driven by a scripted mock LLM (no API spend).

Tech stack: Python, Azure OpenAI, LangChain, SQLAlchemy, Pydantic, structlog, pytest
