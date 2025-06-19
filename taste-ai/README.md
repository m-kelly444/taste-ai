# TASTE.AI - Aesthetic Intelligence Platform

An AI-powered platform that quantifies aesthetic appeal and predicts cultural trends.

## Quick Start

1. **Clone and setup:**
   ```bash
   git clone <repo-url>
   cd taste-ai
   ```

2. **Run with Docker:**
   ```bash
   docker-compose up --build
   ```

3. **Access:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Docs: http://localhost:8000/api/docs

## Development

### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

## Architecture

- **Backend:** FastAPI + PyTorch + PostgreSQL
- **Frontend:** React + Vite + Tailwind CSS
- **ML:** Vision Transformers for aesthetic scoring
- **Infrastructure:** Docker + Kubernetes ready

## Features

- Aesthetic scoring of images
- Trend prediction and analysis
- Portfolio performance tracking
- Real-time dashboard
- RESTful API

## API Endpoints

- `POST /api/v1/aesthetic/score` - Score single image
- `POST /api/v1/aesthetic/batch-score` - Score multiple images
- `GET /api/v1/trends/current` - Get current trends
- `GET /api/v1/trends/predict` - Predict future trends

## License

Proprietary - All rights reserved
