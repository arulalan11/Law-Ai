# ⚖️🤖 Law.Ai — AI-Powered Legal Assistant for India

**Law.Ai** is a localized, accessible, and intelligent legal assistant designed specifically for Indian law. It leverages **AI + Retrieval-Augmented Generation (RAG)** to deliver accurate, grounded, and multilingual legal guidance to everyday citizens.

---

## 📌 Overview

Navigating legal systems in India can be complex due to language barriers, lack of awareness, and high consultation costs.

**Law.Ai solves this by:**
- Providing **AI-driven legal assistance**
- Supporting **regional languages**
- Ensuring **fact-based answers using RAG**
- Enabling **voice-based interaction (TTS + STT)**

---

## 🏛️ Problem Statement

- Legal language is difficult to understand  
- Access to lawyers is expensive  
- Lack of awareness about rights  
- Difficulty in finding correct legal sections  
- Limited accessibility for non-English speakers  

---

## 💡 Solution

Law.Ai acts as a **digital legal companion** that:
- Simplifies Indian law using AI  
- Provides **instant, reliable answers**  
- Enables **voice-based legal interaction**  
- Guides users with **step-by-step legal actions**  

---

## 🛠️ Technology Stack

### 📱 Frontend (Mobile & Web)
- **Framework:** Flutter (Dart)
- **UI/UX:** Custom Material Design
- **Accessibility:** Multilingual support (Tamil, Hindi, Malayalam, English)
- **Voice Features:**
  - Speech-to-Text (STT) for query input  
  - Text-to-Speech (TTS) for AI responses  
  - Markdown stripping for clean voice output  

---

### ⚙️ Backend (API & Logic)
- **Framework:** FastAPI (Python)
- **Database & Auth:** Supabase (PostgreSQL)
- **Validation:** Pydantic
- **Architecture:** Asynchronous APIs for fast processing  

---

### 🧠 AI & RAG Infrastructure

- **Vector Database:** ChromaDB  
- **Embeddings:** `gemini-embedding-001`  
- **LLM Engine:**  
  - `gemini-2.5-flash`  
  - `gemini-1.5-pro`  

---

## ⚙️ RAG Pipeline Methodology

Law.Ai avoids hallucinations by grounding every response in real legal data.

> 💡 The system behaves like a lawyer referencing law books — not guessing answers.

### 🔹 1. Ingestion Phase
- Loads `indian_law_dataset.json`
- Contains:
  - Indian Constitution  
  - IPC Sections  
  - Consumer Laws  
- Adds metadata:
  - `category`, `act`, `section`, `keywords`
- Stores embeddings in **ChromaDB**

---

### 🔹 2. Retrieval Phase
- User submits query (any supported language)
- Query is converted into embeddings
- Top 5 relevant legal chunks are retrieved

---

### 🔹 3. Generation Phase
- Injects retrieved laws into LLM prompt
- Generates:
  - Context-aware legal answer  
  - Real law citations  
  - Translated output  
  - Follow-up suggestions  

---

## ✨ Core Features

### 🎤 Multilingual Voice Interaction
- Speech-to-Text (STT) for voice queries  
- Text-to-Speech (TTS) for spoken responses  
- Supports:
  - Tamil  
  - Hindi  
  - Malayalam  
  - English  

---

### 📚 Context-Grounded Legal Answers
- Answers strictly from legal dataset  
- Prevents AI hallucinations  
- Includes real Act & Section references  

---

### 🆘 Emergency Support
- Instant legal help in critical situations  
- Minimal interaction required  
- Designed for real-world use  

---

### 💬 Conversation Memory
- Stored using Supabase  
- Enables continuous conversations  
- Maintains legal context  

---

### 📝 Step-by-Step Legal Guidance
- Actionable legal advice  
- Simplified explanations  
- Helps users take correct next steps  

---

## 📂 Project Structure
```
Law.Ai/
├── mobile_app/ # Flutter app (UI + Voice + Chat)
├── backend/ # FastAPI APIs + RAG pipeline
├── knowledge_base/ # Legal dataset (JSON + embeddings)
├── vector_db/ # ChromaDB storage
├── voice_module/ # TTS + STT integration
└── architecture_ui/ # UI/UX design assets
```
## 🚀 Key Advantages

- ✅ Multilingual accessibility  
- ✅ Voice-enabled interface  
- ✅ Accurate legal responses (RAG)  
- ✅ Fast and scalable backend  
- ✅ User-friendly design  

---

## 🔮 Future Roadmap

- [ ] Offline RAG support  
- [ ] More regional languages  
- [ ] Voice-based document filling  
- [ ] Real-time voice AI conversation  
- [ ] Lawyer consultation integration  

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository  
2. Create a new branch  
3. Commit your changes  
4. Open a Pull Request  

---

## 📜 License

This project is licensed under the **MIT License**.

---

## ⭐ Support

If you found this project useful, give it a ⭐ on GitHub!
