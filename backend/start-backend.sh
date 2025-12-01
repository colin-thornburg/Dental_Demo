#!/bin/bash

# Navigate to backend directory
cd "$(dirname "$0")"

# Activate virtual environment
source venv/bin/activate

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "Creating .env file - please add your OPENAI_API_KEY"
    echo "OPENAI_API_KEY=your_key_here" > .env
    echo ""
    echo "Please edit backend/.env and add your OpenAI API key, then restart."
    exit 1
fi

# Start Flask app
echo "🚀 Starting Flask backend on http://localhost:5000"
python app.py

