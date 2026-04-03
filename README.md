# Law-AI: Your Personal Legal Assistant ⚖️🤖

Law-AI is a comprehensive legal assistant application designed to provide users with easy access to legal resources, AI-powered legal guidance, and administrative tools. The project consists of a modern Flutter mobile application and a high-performance FastAPI backend.

## 🌟 Key Features

- **AI Legal Chatbot**: Get instant answers to your legal queries using our specialized AI model.
- **IPC & Legal Acts Explorer**: Browse through the Indian Penal Code (IPC) and other legal acts with ease.
- **Authority Locator**: Find legal authorities and offices near you.
- **Document Templates**: Access and generate common legal document templates.
- **Daily Legal Tips**: Stay informed with daily legal insights and news.
- **Multilingual Support**: Supports multiple languages for better accessibility (English, Tamil, Hindi, Malayalam, etc.).
- **Secure Authentication**: User sign-up and login powered by Supabase.

## 🛠️ Tech Stack

### Frontend (Mobile App)
- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: Dart
- **State Management**: Bloc / Provider
- **Local Services**: Text-to-Speech (TTS) & Speech-to-Text (STT) integration.

### Backend (API)
- **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python)
- **Database**: [Supabase](https://supabase.com/) (PostgreSQL & Auth)
- **AI Integration**: Custom routes for intelligent legal processing.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Python 3.9+
- Supabase Account (for API keys and database)

### Backend Setup
1. Navigate to the `backend` folder:
   ```bash
   cd backend
   ```
2. Create a virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Create a `.env` file from the example and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_url
   SUPABASE_KEY=your_key
   ```
4. Run the server:
   ```bash
   uvicorn main:app --reload
   ```

### Mobile App Setup
1. Navigate to the `mobile_app` folder:
   ```bash
   cd mobile_app
   ```
2. Install Flutter packages:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## 📂 Project Structure

- `/mobile_app`: Flutter source code, including features for chat, auth, and legal resources.
- `/backend`: Python FastAPI code, database models, and API routes.
- `/architecture_ui`: Design assets and UI planning documents.

---

Built with ❤️ for the legal community.
