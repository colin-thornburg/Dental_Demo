# Setup Notes - Issues Fixed

## Issues Resolved

### 1. Port Conflicts
**Problem:** macOS uses port 5000 for AirPlay Receiver  
**Solution:** Changed backend to port 5001

### 2. CORS Error
**Problem:** Frontend on port 3001, CORS was only allowing 3000  
**Solution:** Updated CORS to accept both ports 3000 and 3001

### 3. Virtual Environment
**Problem:** Python packages not found  
**Solution:** Must activate venv before running backend

## Current Setup

### Backend (Flask API)
- **URL:** http://localhost:5001
- **Status:** ✅ Running in terminal 8
- **Location:** `/Users/colinthornburg/tag_demo/backend`

### Frontend (Next.js)
- **URL:** http://localhost:3001  
- **Status:** Should be running
- **Location:** `/Users/colinthornburg/tag_demo/app`

## How to Start

### Backend
```bash
cd /Users/colinthornburg/tag_demo/backend
source venv/bin/activate
python app.py
```

Backend will start on **http://localhost:5001**

### Frontend
```bash
cd /Users/colinthornburg/tag_demo/app
npm run dev
```

Frontend will start on **http://localhost:3000** or **http://localhost:3001**

## Important Files Updated

1. `backend/app.py`
   - Changed port from 5000 → 5001
   - Updated CORS to allow both port 3000 and 3001

2. `app/app/page.tsx`
   - Updated API endpoint from 5000 → 5001

## Next Steps

### ⚠️ Add Your OpenAI API Key

Create `backend/.env` with:
```
OPENAI_API_KEY=sk-your-actual-key-here
```

Without this key, natural language queries won't work, but you can still test:
- Health check: http://localhost:5001/api/health
- Available metrics: http://localhost:5001/api/metrics

### Test the Application

1. Open http://localhost:3001 (or 3000)
2. Try a query like "Show me revenue by brand for 2024"
3. The backend will parse it and query the dbt semantic layer

## Troubleshooting

### "Module not found" errors
```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
```

### Port already in use
- Backend: Change port in `backend/app.py`
- Frontend: Kill process on port 3001 or let Next.js pick another port

### CORS errors
- Verify backend is running on port 5001
- Check frontend is using correct port in `app/app/page.tsx`
- Both ports are now allowed in CORS config

### OpenAI errors
- Add your API key to `backend/.env`
- Restart the backend after adding the key
- Check you have credits in your OpenAI account

