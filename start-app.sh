#!/bin/bash

# TAG Analytics Startup Script
# This script starts both the backend and frontend servers

echo "🚀 Starting TAG Analytics Application..."
echo ""

# Check if backend/.env exists
if [ ! -f "backend/.env" ]; then
    echo "⚠️  Warning: backend/.env not found!"
    echo "Please create backend/.env with your OPENAI_API_KEY"
    echo "You can copy backend/.env.example and add your key"
    echo ""
    read -p "Press Enter to continue anyway or Ctrl+C to exit..."
fi

# Start backend in background
echo "Starting Flask backend on port 5000..."
cd backend
source venv/bin/activate 2>/dev/null || python3 -m venv venv && source venv/bin/activate
pip install -q -r requirements.txt
python app.py &
BACKEND_PID=$!
cd ..

# Wait for backend to start
sleep 3

# Start frontend
echo "Starting Next.js frontend on port 3000..."
cd app
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ Application started!"
echo ""
echo "Frontend: http://localhost:3000"
echo "Backend:  http://localhost:5000"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Wait for Ctrl+C
trap "echo ''; echo 'Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT

# Keep script running
wait

