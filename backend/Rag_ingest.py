"""
Law.Ai RAG Ingestion Pipeline
================================
Loads indian_law_dataset.json, prepares chunks, and ingests into
ChromaDB (or any vector DB). Designed for FastAPI + Gemini stack.

Usage:
    pip install chromadb google-generativeai sentence-transformers
    python rag_ingest.py
"""

import json
import os
from typing import List, Dict
from dotenv import load_dotenv

load_dotenv()

# ── Optional: use Gemini embeddings or sentence-transformers ──────────────────
USE_GEMINI_EMBEDDINGS = True   # Set True if you have GEMINI_API_KEY

# ── Load Dataset ──────────────────────────────────────────────────────────────
def load_dataset(path: str = "indian_law_dataset.json") -> List[Dict]:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data["chunks"]


# ── Build RAG-ready text for each chunk ──────────────────────────────────────
def build_chunk_text(chunk: Dict) -> str:
    """
    Combine metadata + content into a single string for embedding.
    This gives the retriever context about what the chunk is about.
    """
    return (
        f"Category: {chunk['category']}\n"
        f"Act: {chunk['act']}\n"
        f"Section/Article: {chunk['section_article']}\n"
        f"Topic: {chunk['title']}\n\n"
        f"{chunk['content']}\n\n"
        f"Keywords: {', '.join(chunk['keywords'])}"
    )


# ── ChromaDB Ingestion ────────────────────────────────────────────────────────
def ingest_to_chromadb(chunks: List[Dict], collection_name: str = "indian_law"):
    """
    Ingests all chunks into a ChromaDB collection.
    Uses sentence-transformers by default.
    """
    try:
        import chromadb
        from chromadb.utils import embedding_functions
    except ImportError:
        print("Install chromadb: pip install chromadb")
        return

    client = chromadb.PersistentClient(path="./law_ai_db")  # saves locally

    # Embedding function (sentence-transformers — free, local)
    ef = embedding_functions.SentenceTransformerEmbeddingFunction(
        model_name="all-MiniLM-L6-v2"
    )

    # Create or get collection
    collection = client.get_or_create_collection(
        name=collection_name,
        embedding_function=ef,
        metadata={"hnsw:space": "cosine"}
    )

    documents = []
    metadatas = []
    ids = []

    for chunk in chunks:
        text = build_chunk_text(chunk)
        documents.append(text)
        metadatas.append({
            "id": chunk["id"],
            "category": chunk["category"],
            "act": chunk["act"],
            "section_article": chunk["section_article"],
            "title": chunk["title"],
            "source": chunk["source"],
            "keywords": ", ".join(chunk["keywords"])
        })
        ids.append(chunk["id"])

    collection.upsert(
        documents=documents,
        metadatas=metadatas,
        ids=ids
    )

    print(f"✅ Ingested {len(chunks)} chunks into ChromaDB collection '{collection_name}'")
    return collection


# ── Gemini Embeddings (optional) ─────────────────────────────────────────────
def ingest_with_gemini_embeddings(chunks: List[Dict]):
    """
    Use Google's gemini-embedding-001 model.
    Set GEMINI_EMBEDDING_API_KEY in your environment.
    """
    try:
        import chromadb
        from chromadb.utils import embedding_functions
    except ImportError:
        print("Install: pip install chromadb")
        return

    client = chromadb.PersistentClient(path="./law_ai_db_gemini")
    
    ef = embedding_functions.GoogleGenerativeAiEmbeddingFunction(
        api_key=os.environ.get("GEMINI_EMBEDDING_API_KEY", ""),
        model_name="models/gemini-embedding-001"
    )

    collection = client.get_or_create_collection(
        name="indian_law_gemini",
        embedding_function=ef,
        metadata={"hnsw:space": "cosine"}
    )
    
    documents = []
    metadatas = []
    ids = []

    for chunk in chunks:
        documents.append(build_chunk_text(chunk))
        metadatas.append({
            "id": chunk["id"],
            "category": chunk["category"],
            "act": chunk["act"],
            "section_article": chunk["section_article"],
            "title": chunk["title"],
            "source": chunk["source"],
            "keywords": ", ".join(chunk["keywords"])
        })
        ids.append(chunk["id"])

    # ChromaDB calls the Gemini Embedding API automatically in batches
    collection.upsert(
        documents=documents,
        metadatas=metadatas,
        ids=ids
    )

    print(f"✅ Ingested {len(chunks)} chunks with Gemini embeddings")


# ── Query / Retrieval Helper ──────────────────────────────────────────────────
def query_law_db(question: str, n_results: int = 5, category_filter: str = None):
    """
    Retrieve top-k relevant chunks for a user question.
    Integrate this into your FastAPI endpoint.
    """
    try:
        import chromadb
        from chromadb.utils import embedding_functions
    except ImportError:
        print("Install chromadb")
        return []

    if USE_GEMINI_EMBEDDINGS:
        client = chromadb.PersistentClient(path="./law_ai_db_gemini")
        ef = embedding_functions.GoogleGenerativeAiEmbeddingFunction(
            api_key=os.environ.get("GEMINI_EMBEDDING_API_KEY", ""),
            model_name="models/gemini-embedding-001"
        )
        collection = client.get_collection(name="indian_law_gemini", embedding_function=ef)
    else:
        client = chromadb.PersistentClient(path="./law_ai_db")
        ef = embedding_functions.SentenceTransformerEmbeddingFunction(
            model_name="all-MiniLM-L6-v2"
        )
        collection = client.get_collection(name="indian_law", embedding_function=ef)

    where_clause = {"category": category_filter} if category_filter else None

    results = collection.query(
        query_texts=[question],
        n_results=n_results,
        where=where_clause,
        include=["documents", "metadatas", "distances"]
    )

    retrieved = []
    for i, doc in enumerate(results["documents"][0]):
        retrieved.append({
            "content": doc,
            "metadata": results["metadatas"][0][i],
            "relevance_score": 1 - results["distances"][0][i]  # cosine similarity
        })

    return retrieved


# ── FastAPI RAG Endpoint Template ─────────────────────────────────────────────
RAG_FASTAPI_EXAMPLE = '''
# Add this to your FastAPI backend (main.py)
from fastapi import APIRouter
import google.generativeai as genai

router = APIRouter()

@router.post("/chat")
async def chat_with_rag(question: str, language: str = "en"):
    # 1. Retrieve relevant law chunks
    retrieved_chunks = query_law_db(question, n_results=5)
    
    # 2. Build context from chunks
    context = "\\n\\n---\\n\\n".join([
        f"**{c['metadata']['title']}** ({c['metadata']['act']})\\n{c['content']}"
        for c in retrieved_chunks
    ])
    
    # 3. Build RAG prompt for Gemini
    rag_prompt = f"""You are Law.Ai, a multilingual Indian legal information assistant.
Use ONLY the following legal information to answer the user's question.
If the answer is not in the context, say you don't have information on that topic.
Always mention the relevant Act and Section.

LEGAL CONTEXT:
{context}

USER QUESTION: {question}

Answer in {language} language. Be clear, accurate, and cite the relevant law."""

    # 4. Generate answer with Gemini
    model = genai.GenerativeModel("gemini-2.5-flash")
    response = model.generate_content(rag_prompt)
    
    return {
        "answer": response.text,
        "sources": [c["metadata"]["source"] for c in retrieved_chunks],
        "retrieved_sections": [c["metadata"]["title"] for c in retrieved_chunks]
    }
'''


# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("Law.Ai RAG Dataset Ingestion")
    print("=" * 50)

    chunks = load_dataset("indian_law_dataset.json")
    print(f"Loaded {len(chunks)} law chunks")

    # Print category breakdown
    from collections import Counter
    categories = Counter(c["category"] for c in chunks)
    print("\nCategory Breakdown:")
    for cat, count in categories.most_common():
        print(f"   {cat:30s} -> {count} chunks")

    print("\nStarting ChromaDB ingestion...")
    if USE_GEMINI_EMBEDDINGS:
        ingest_with_gemini_embeddings(chunks)
    else:
        ingest_to_chromadb(chunks)

    print("\nTest Query:")
    test_q = "What are my rights when arrested by police?"
    results = query_law_db(test_q, n_results=3)
    print(f"Query: '{test_q}'")
    for r in results:
        print(f"  → [{r['relevance_score']:.2f}] {r['metadata']['title']}")

    print("\nDone! Your Law.Ai RAG pipeline is ready.")
    print("\n📌 FastAPI Integration Example:")
    print(RAG_FASTAPI_EXAMPLE)
