# Sources

Verified claim lines the system cards may use. Copied verbatim from
docs/cv_master.md and docs/pitch_bank.md in the ai-job-hunt repo on
2026-09-29, after the realistic pass of both files against the code of each
system. check.py requires every card sentence to appear here.
Edit index.html to match this file, never the other way round.

## ARIA (pitch bank Tier 2, Tier 3, CV master)

ARIA automates J&J's Architecture Review Board. Four domain architect agents (Business, Technology, Information, Data Science & AI) run on a shared quality-agent engine orchestrated through LangGraph state machines, and only the domains the deck flags as architecturally impacted actually run. The agents negotiate missing evidence over an A2A protocol (batched star topology, each peer answers once instead of N-by-N) and revise their own findings with what comes back. Reasoning is grounded in the LeanIX enterprise architecture inventory (Neo4j graph backend, text-to-Cypher retrieval) plus a pgvector store over the standards library; the agents assess slide diagrams directly as multimodal image input. Every finding cites catalog source IDs; citations are resolved against the catalog and unresolved ones are flagged. A review that took a reviewer a full working day now takes about ten minutes.

ARIA, ARB Intake Verifier: multi-agent system that automates J&J's Architecture Review Board. It ingests solution-architecture submissions (PPTX, PDF, DOCX and diagrams), reviews them against the enterprise standards library and returns a scored, fully cited report, cutting a review that took a reviewer a full working day down to roughly 10 minutes.

Multi-Agent Architecture: Four domain architect agents (Business, Technology, Information, Data Science & AI) running on a shared quality-agent engine, orchestrated through a LangGraph state machine, with an in-process agent-to-agent (A2A) protocol in which each peer answers once and agents revise their findings with the evidence returned. Built on LangGraph and LangChain.

LLM Safety Framework: Designed and implemented 19 production guardrails at graph-node boundaries and targeted points, non-blocking by design (warn and audit, human in the loop): prompt injection, PII/PHI redaction (Presidio), data-exfiltration and prompt-leakage detection, schema and citation validation, per-run LLM-call and token ceilings, SHA-256 hashed audit trail, among others.

Engineering & Delivery: Async FastAPI service with PostgreSQL and Alembic, connectors for SharePoint, LeanIX and Confluence, Arize Phoenix / OpenTelemetry tracing with per-call cost tracking, a run-consistency judge, and an offline regression suite of about 590 tests driven by mock LLMs.

Tech stack: Python, LangGraph, LangChain, Azure OpenAI (GPT-5.x), FastAPI, Pydantic, Neo4j, PostgreSQL + pgvector, SQLAlchemy, Alembic, Docker, Kubernetes, Helm

## EVA (CV master Iberia block, pitch bank)

Development of EVA (Enhanced Virtual Assistant), a multi-agent conversational ecosystem powered by LLMs to automate Iberia's customer service operations. Built four of its agents (Translator, Check-in, Tone, Flight Status) and contributed to the guardrail agent.

LLM Engineering & Model Optimization: Built, tuned and deployed the Translator, Check-in, Tone and Flight Status agents on Azure OpenAI and OpenAI models (GPT-4.1, GPT-5.x) with AWS Bedrock (Nova Pro, Claude) as circuit-breaker fallback, and benchmarked candidate models on cost, latency and output quality.

Multi-Agent Architecture: Built modular, hexagonal-architecture agents (ports and adapters, dependency injection) within an ecosystem of about fourteen agents (intent classification, guardrail, conversation manager, check-in, cancellation, flight status, flight documents, translator, tone, RAG) using LangChain and FastAPI with structured I/O through Pydantic schemas and DynamoDB conversation memory.

API Integration: Integrated Iberia's check-in and flight-status APIs as LangChain structured tools, including an eleven-step check-in flow over eleven Iberia APIs, from reservation validation to boarding pass.

Security & Guardrails: Tuned the prompt and multi-model configuration of the guardrail agent and built a red-team harness with prompt-injection, data-exfiltration, prompt-leakage and jailbreak datasets against the assistant platform.

Evaluation & Monitoring: Load and regression testing of the assistant (Locust stress tests, a 1,000-prompt UAT battery), using the platform's per-call token, latency and cost tracking.

Tech stack: Python, LangChain, Azure OpenAI, OpenAI, AWS Bedrock (Nova Pro, Claude), FastAPI, Pydantic, DynamoDB, Kinesis Firehose, structlog, pytest, Locust, GitLab CI/CD, ECS Fargate

## Numetrix (TPP) Text2SQL (CV master TPP block, pitch bank)

Numetrix (TPP) Text2SQL: production conversational analytics platform over US foot-traffic and mobility data, letting business users run their own analyses in natural language instead of queueing for a data analyst who can write SQL.

Pipeline Architecture: Four-stage hexagonal pipeline (query extraction, context-aware SQL generation, secure execution, natural-language transformation) with session memory and multi-turn follow-up resolution, plus FAISS semantic example selection for few-shot SQL generation.

Defence-in-Depth Guardrails: A regex input guard, a parallel LLM safety classifier that adds no perceptible latency, and a read-only SQL validator that blocks DML/DDL, including writes hidden in CTEs; validated with a 25-case adversarial battery (injection, jailbreak, exfiltration, obfuscation).

Quality & Auditability: A 301-case regression suite (301/301 passing) combining deterministic oracles with an LLM judge, an 18-case multi-turn follow-up corpus, pre-flight validation of extracted entities against the catalogs with fuzzy matching, and every turn persisted to a PostgreSQL audit table with per-stage timings.

Earlier work for the same client: a device home-location pipeline over tens of millions of devices a month (night-time location clustering, confidence scoring, demographic enrichment), first on AWS EMR and later on GCP Dataproc, Cloud SQL and BigQuery, and the first text2SQL agents (AWS Bedrock Titan, later OpenAI).

Numetrix (TPP) Text2SQL: production conversational analytics over US foot-traffic and mobility data. Four-stage hexagonal pipeline, session memory and multi-turn follow-up resolution, FAISS semantic example selection. Defence in depth: regex input guard, a parallel LLM safety classifier adding no perceptible latency, a read-only SQL validator. A 301-case regression suite (301/301) plus a 25-case adversarial battery, live and manual, not in CI. Every turn persisted to a PostgreSQL audit table. Tracing is Langfuse (LangSmith was removed in March).

Tech stack: Python, LangChain, OpenAI, FAISS, LangSmith, Langfuse, PostgreSQL, BigQuery, GCS, Streamlit, Docker, Bitbucket Pipelines, PySpark, AWS (EMR, EC2, S3, RDS, Athena, Bedrock), GCP (Dataproc, Dataflow, Cloud Storage, Cloud SQL, Compute Engine)

## SRS Summarizer (CV master, pitch bank)

SRS Summarizer: LLM service that writes persona-specific narrative summaries (CPO, Value Chain Leader, Category Manager) of supply-disruption events for J&J's Supply Risk Sensing dashboards; proof of concept heading to the DEV environment.

Compute first, narrate second: every figure is computed by deterministic read-only SQL into a fact sheet and the model only narrates that fact sheet; null facts are dropped before the call and out-of-scope events return a fixed message with no model call.

Hexagonal Architecture: the service depends only on LLMPort, DatabasePort and TracePort contracts, with interchangeable OpenAI SDK and LangChain adapters and one SQL fact engine that runs on SQLite in tests and Databricks SQL in the target environment.

Contract-first FastAPI API with Pydantic schemas and an OpenAPI export; the panels of a page share one fact sheet and their model calls run in parallel.

Prompts as versioned YAML with a test that fails when a new prompt version is not pinned, and fail-open Langfuse tracing of scope, facts, narrative, model and prompt version for every summary.

98 offline pytest tests that run the real SQL against a synthetic fixture with a mock LLM.

Tech stack: Python, FastAPI, Pydantic, SQLAlchemy, OpenAI, LangChain, Langfuse, Databricks SQL, pytest
