# LiteKite

[![Live Demo](https://img.shields.io/badge/Live_Demo-lite--kite--1hag.vercel.app-blue?style=for-the-badge&logo=vercel)](https://lite-kite-1hag.vercel.app/)

LiteKite is an end-to-end mock stock exchange application. Users can trade stocks according to real-time prices with added AI support using the Gemini API.

## Project Structure

This repository contains the full LiteKite codebase, separated into three main directories:

- `frontend/`: The React (Vite) frontend application.
- `backend/`: The Flask/Python backend server.

## Getting Started

To run the application locally, you will need to start both the backend and frontend servers.

### 1. Backend Setup

The backend requires Python 3.8+ and PostgreSQL.

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
pip install -r requirements.txt
```

Set up your `.env` file in the `backend/` directory with required keys (see `backend/README.md` for details), then run:

```bash
flask db init
flask db migrate
flask db upgrade
flask --app api/index.py run
```
The backend will run on `http://127.0.0.1:5000`.

### 2. Frontend Setup

The frontend requires Node.js.

```bash
cd frontend
npm install
```

Set up your `.env` file in the `frontend/` directory (e.g., `VITE_BACKEND_URL=http://127.0.0.1:5000/api`), then run:

```bash
npm run dev
```
The frontend will run on `http://localhost:5173`.

## Deployment

The application is deployed live and can be accessed at:
**[https://lite-kite-1hag.vercel.app/](https://lite-kite-1hag.vercel.app/)**

The project is hosted on Vercel, utilizing Vercel's serverless functions for the Python Flask backend and standard static site hosting for the React (Vite) frontend.
