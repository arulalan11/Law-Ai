<div align="center">

# ⚖️ **AI-BASED MULTILINGUAL LEGAL INFORMATION CHATBOT** 🤖

> Built to break barriers — linguistic, economic, and educational — so every Indian citizen can access the law that protects them.

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=flat-square&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=flat-square&logo=supabase&logoColor=white)](https://supabase.com)
[![ChromaDB](https://img.shields.io/badge/ChromaDB-FF6F00?style=flat-square&logo=databricks&logoColor=white)](https://www.trychroma.com)
[![Gemini](https://img.shields.io/badge/Gemini_2.5_Flash-4285F4?style=flat-square&logo=google&logoColor=white)](https://ai.google.dev)

[![Languages](https://img.shields.io/badge/Languages-English%20%7C%20Hindi%20%7C%20Tamil%20%7C%20Malayalam%20%7C%20Kannada%20%7C%20Telugu-orange?style=flat-square)]()
[![Domain](https://img.shields.io/badge/Domain-Indian%20Constitutional%20%26%20Criminal%20Law-1a237e?style=flat-square)]()
[![Architecture](https://img.shields.io/badge/Architecture-LLM%20%2B%20RAG-success?style=flat-square)]()

</div>

---

## 🚨 Problem Statement

> *How might we develop a user-friendly digital assistant that provides legal information in multiple languages — enhancing accessibility and improving legal awareness among marginalized communities in India?*

In a country of 1.4 billion people speaking hundreds of languages, access to legal knowledge remains one of the most persistent and invisible forms of inequality. Millions of Indians — daily wage workers, rural communities, first-generation literates, and non-English speakers — face real legal crises every day with no trusted, affordable, or understandable source of guidance. They cannot afford lawyers for basic queries. Government legal aid is understaffed and geographically inaccessible. Online resources are either too technical, English-only, or riddled with AI-generated content that confidently cites laws that don't exist.

Language is not the only barrier. It is compounded by digital literacy gaps, fear of the legal system, and the complete absence of tools designed with marginalized users in mind. A rural woman unaware of the Domestic Violence Act cannot seek protection. A factory worker who doesn't know the Minimum Wages Act cannot challenge exploitation. An arrest victim who doesn't know Article 22 of the Constitution cannot demand a lawyer.

**The gap is not a lack of law — it is a lack of access to it.**

---

## 💡 What Law.Ai Solves

Law.Ai is a localized, grounded, and accessible AI legal assistant built to close exactly this gap — for real people, in their own language, with answers they can trust and act on.

- **🌐 Language Barrier** — Law.Ai supports Tamil, Hindi, Malayalam, Kannada, Telugu, and English with native voice input and output. A user can speak their question and hear the answer — no typing, no reading required.

- **🤥 AI Hallucination** — Unlike generic chatbots, Law.Ai uses a RAG pipeline anchored to a curated database of authentic Indian law. It cannot fabricate legal sections. Every answer cites the real Act and Section it was drawn from.

- **💸 Affordability** — No lawyer fees. No consultation charges. A user in a village in Tamil Nadu gets the same quality of legal information as someone in a Delhi law firm.

- **🚨 Crisis Accessibility** — An Emergency Screen provides hardcoded, offline-accessible guidance for critical situations like police harassment or road accidents — no internet connection required.

- **🧠 Contextual Understanding** — Rather than returning textbook definitions, Law.Ai delivers step-by-step, situation-specific legal guidance tailored to the user's exact query, with follow-up question suggestions to deepen the consultation.

- **💬 Memory Across Sessions** — Conversations are persisted via Supabase, allowing users to return to ongoing legal consultations across multiple sessions without losing context.

---

## 🏛️ About the Project

**Law.Ai** is an LLM + RAG powered mobile application that answers Indian legal queries in four languages, cites real Acts and Sections, and speaks the answer aloud. It was built as a final year project at Excel Engineering College with the conviction that **legal knowledge is not a privilege — it is a right.**

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 🎙️ **Multilingual Voice I/O** | Speech-to-Text input and native TTS output in Tamil, Hindi, Malayalam, Kannada, Telugu & English |
| 🧠 **RAG-Grounded Accuracy** | All responses are strictly anchored to ingested Indian law — no hallucinations |
| 🚨 **Emergency Screen** | Hardcoded, offline-accessible UI for critical situations (police harassment, accidents) |
| 💬 **Conversational Memory** | Supabase-persisted chat history enabling multi-session legal consultations |
| 📑 **Document Guidance** | Step-by-step, actionable legal guidance — not abstract definitions |
| 🔍 **Follow-up Suggestions** | AI suggests 3 contextual follow-up questions after every response |
| 🌐 **Multilingual Translation** | Real-time translation of legal answers into the user's preferred regional language |
| 📖 **Act & Section Citations** | Every answer cites the real Act name and Section number from Indian law |

---

## 🏗️ Architecture Overview

```
+------------------------------------------------------------------+
|                      FLUTTER APP (Client)                        |
|                                                                  |
|  +--------------+   +----------------+   +--------------------+ |
|  |  Voice I/O   |   |   Chat UI      |   |  Emergency Screen  | |
|  |  (STT / TTS) |   |  (History)     |   |  (Offline-Ready)   | |
|  +------+-------+   +-------+--------+   +--------------------+ |
|         +-------------------+                                    |
+-------------------------------+----------------------------------+
                                |
                         REST API (JSON)
                                |
+-------------------------------v----------------------------------+
|                     FASTAPI BACKEND (Python)                     |
|                                                                  |
|  +------------------------------------------------------------+  |
|  |               RAG ORCHESTRATION LAYER                     |  |
|  |                                                            |  |
|  |  [1] Embed Query  ->  [2] Search ChromaDB  ->  [3] Prompt |  |
|  |  (Gemini Embed)       (Top-5 Chunks)       (Legal Context)|  |
|  +-------+----------------------+-----------------------------+  |
|          |                      |                               |
|  +-------v--------+   +---------v-----------+                  |
|  |   ChromaDB     |   |  Gemini 2.5 Flash   |                  |
|  | (Vector Store) |   |  (LLM Generation)   |                  |
|  +-------+--------+   +---------------------+                  |
|          |                                                      |
|  +-------v--------+                                            |
|  |   Supabase     |                                            |
|  | (Auth + Memory)|                                            |
|  +----------------+                                            |
+------------------------------------------------------------------+
```

---

## ⚙️ RAG Pipeline Deep Dive

Law.Ai uses a three-phase RAG pipeline to ensure every answer is grounded in real Indian law — not model hallucination.

```
+------------------------------------------------------------------+
|                    PHASE 1 — INGESTION                          |
|                                                                  |
|  indian_law_dataset.json                                        |
|      |                                                           |
|      +--  66 law chunks across 10 legal categories             |
|      +--  Rich metadata: category, act, section, keywords      |
|      |                                                           |
|      v                                                           |
|  gemini-embedding-001  -->  ChromaDB ( law_ai_db_gemini/ )      |
+------------------------------------------------------------------+
                                |
                                v
+------------------------------------------------------------------+
|                    PHASE 2 — RETRIEVAL                          |
|                                                                  |
|  User Query (any supported language)                            |
|      |                                                           |
|      v                                                           |
|  Embed query  -->  Semantic search in ChromaDB                  |
|      |                                                           |
|      +-->  Top 5 most relevant legal chunks returned            |
+------------------------------------------------------------------+
                                |
                                v
+------------------------------------------------------------------+
|                    PHASE 3 — GENERATION                         |
|                                                                  |
|  Hidden "LEGAL CONTEXT" block injected into Gemini prompt       |
|      |                                                           |
|      +--  AI analyzes situation against strict legal context   |
|      +--  Translates response to requested regional language   |
|      +--  Cites real Acts and Section numbers                  |
|      +--  Suggests 3 follow-up questions                       |
+------------------------------------------------------------------+
```

> **Why RAG over a standard LLM?**
> A generic chatbot *guesses* legal answers from training data and can confidently cite laws that don't exist. Law.Ai forces the AI to consult a verified law book on every query — making hallucination structurally impossible for in-scope legal topics.

---

## 🛠️ Technology Stack

### Frontend
| Technology | Purpose |
|---|---|
| **Flutter (Dart)** | Cross-platform mobile & web UI |
| **Material Design (Custom)** | Accessible UI with multilingual support |
| **flutter_tts** | Native Text-to-Speech (Tamil, Hindi, Malayalam, Kannada, Telugu, English) |
| **speech_to_text** | Real-time voice query input |

### Backend
| Technology | Purpose |
|---|---|
| **FastAPI (Python)** | Async REST API & RAG orchestration |
| **Pydantic** | JSON schema validation & data models |
| **Supabase (PostgreSQL)** | User auth + persistent conversation memory |

### AI & RAG Infrastructure
| Technology | Purpose |
|---|---|
| **ChromaDB** | Persistent local vector store |
| **`gemini-embedding-001`** | Maps queries & laws into semantic vectors |
| **`gemini-2.5-flash`** | Primary LLM for grounded response generation |
| **`gemini-1.5-pro`** | Complex summarization & multilingual generation |

---

## 📁 Project Structure

```
law-ai/
|
+-- backend/
|   +-- main.py                     # Entry point, API routes
|   +-- rag_pipeline.py             # RAG retrieval + prompt construction
|   +-- ingest.py                   # ChromaDB ingestion script
|   +-- models.py                   # Pydantic request/response models
|   +-- supabase_client.py          # Supabase auth & DB integration
|   +-- law_ai_db_gemini/           # ChromaDB persistent storage
|   +-- data/
|   |   +-- indian_law_dataset.json # Curated Indian law dataset (66 chunks)
|   +-- requirements.txt
|
+-- frontend/
|   +-- lib/
|   |   +-- main.dart
|   |   +-- screens/
|   |   |   +-- chat_screen.dart
|   |   |   +-- emergency_screen.dart
|   |   |   +-- auth_screen.dart
|   |   +-- services/
|   |   |   +-- api_service.dart
|   |   |   +-- tts_service.dart
|   |   |   +-- stt_service.dart
|   |   +-- widgets/
|   |       +-- message_bubble.dart
|   +-- pubspec.yaml
|
+-- docs/
|   +-- project_report.pdf
|
+-- README.md
```

---

## 🚀 Getting Started

### Prerequisites

- Python 3.10+
- Flutter SDK 3.x
- A [Google AI Studio](https://aistudio.google.com) API key (Gemini)
- A [Supabase](https://supabase.com) project (free tier works)

---

### Backend Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-username/law-ai.git
cd law-ai/backend

# 2. Create and activate virtual environment
python -m venv venv
source venv/bin/activate      # macOS/Linux
venv\Scripts\activate         # Windows

# 3. Install dependencies
pip install -r requirements.txt

# 4. Set up environment variables
cp .env.example .env
# Edit .env with your API keys

# 5. Start the FastAPI server
uvicorn main:app --reload --port 8000
```

---

### Frontend Setup

```bash
cd law-ai/frontend

flutter pub get
flutter run

# Build release APK
flutter build apk --release
```

---

### ChromaDB Ingestion

> Run this **once** to populate the vector database before starting the backend.

```bash
cd law-ai/backend

python ingest.py

# Expected output:
# Loaded 66 chunks from indian_law_dataset.json
# Embedding and storing in ChromaDB...
# Ingestion complete --> law_ai_db_gemini/
```

---

## 🔐 Environment Variables

Create a `.env` file in `backend/` with the following:

```env
# Google Gemini
GEMINI_API_KEY=your_gemini_api_key_here

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key_here

# ChromaDB
CHROMA_DB_PATH=./law_ai_db_gemini
CHROMA_COLLECTION_NAME=indian_law

# RAG Config
TOP_K_RESULTS=5
EMBEDDING_MODEL=models/gemini-embedding-001
LLM_MODEL=gemini-2.5-flash
```

---

## 📡 API Reference

### `POST /chat`
Submit a legal query and receive a grounded, multilingual response.

**Request Body:**
```json
{
  "user_id": "uuid-string",
  "query": "What are my rights if I am arrested?",
  "language": "tamil",
  "session_id": "optional-session-uuid"
}
```

**Response:**
```json
{
  "response": "...(legal answer in Tamil)...",
  "citations": [
    { "act": "Code of Criminal Procedure", "section": "Section 41" },
    { "act": "Indian Constitution", "section": "Article 22" }
  ],
  "follow_up_questions": [
    "Can police detain me without FIR?",
    "What is bail and how do I apply?",
    "Can I demand a lawyer immediately after arrest?"
  ],
  "language": "tamil"
}
```

### `GET /history/{user_id}`
Retrieve a user's full conversation history from Supabase.

### `DELETE /history/{user_id}`
Clear all chat history for a user.

---

## 📚 Dataset

The `indian_law_dataset.json` contains **66 structured law chunks** across **10 legal categories**:

| Category | Examples |
|---|---|
| Constitutional Rights | Articles 14, 19, 21, 22 |
| Criminal Law (IPC) | Sections 299, 354, 375, 420, 498A |
| Consumer Protection | Consumer Protection Act 2019 |
| Arrest & Detention | CrPC Sections 41, 50, 57 |
| Women's Rights | Domestic Violence Act, POSH Act |
| Labor Law | Factories Act, Minimum Wages Act |
| Land & Property | Transfer of Property Act |
| Cyber Law | IT Act 2000, Sections 66A-66F |
| RTI | Right to Information Act 2005 |
| Child Rights | POCSO Act, Juvenile Justice Act |

Each chunk follows this schema:

```json
{
  "id": "ipc_section_354",
  "category": "Women's Rights",
  "act": "Indian Penal Code",
  "section": "Section 354",
  "title": "Assault or criminal force to woman with intent to outrage her modesty",
  "content": "...",
  "keywords": ["assault", "modesty", "women", "harassment"]
}
```

---
