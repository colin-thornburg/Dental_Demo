# TAG Analytics - Quick Start Guide

## 🚀 Get Started in 3 Steps

### 1. Set Up Backend

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file and add your OpenAI API key
echo "OPENAI_API_KEY=sk-your-key-here" > .env
```

### 2. Install Frontend Dependencies

```bash
# Navigate to app directory (from project root)
cd app

# Dependencies already installed, but if needed:
npm install
```

### 3. Start the Application

**Option A: Use the startup script (Recommended)**
```bash
# From project root
./start-app.sh
```

**Option B: Start manually in separate terminals**

Terminal 1 - Backend:
```bash
cd backend
source venv/bin/activate
python app.py
```

Terminal 2 - Frontend:
```bash
cd app
npm run dev
```

## 📱 Access the App

Open your browser to: **http://localhost:3000**

## 💬 Try These Queries

- "Show me revenue by brand for 2024"
- "What's the no-show rate by facility?"
- "Show new patient visits by month"
- "Compare gross profit across all brands"

## 🔑 Get Your OpenAI API Key

1. Go to [platform.openai.com](https://platform.openai.com/)
2. Sign in or create an account
3. Navigate to API keys section
4. Create a new API key
5. Copy and paste into `backend/.env`

## 🏥 Brands Included

- **Aspen Dental** - Breaking down barriers in dentistry
- **ClearChoice** - Restoring smiles, reviving confidence  
- **WellNow Urgent Care** - Stand-out choice for walk-in care
- **Chapter Aesthetic Studio** - Making everyone's story more beautiful
- **Lovet Pet Health** - Vet care that's easy to love

## 📊 What You Can Query

**Metrics:** revenue, gross_profit, appointments, no_show_rate, new_patients, and more  
**Dimensions:** brand_name, facility, region, time periods (day/week/month/year)

## ❓ Troubleshooting

**"Backend not responding"**
- Check that Flask is running on port 5000
- Verify your OpenAI API key in backend/.env

**"No data returned"**
- Ensure dbt Cloud CLI is configured (`dbt debug`)
- Check Snowflake connection in dbt Cloud

**"Module not found" errors**
- Re-run `pip install -r requirements.txt` in backend
- Re-run `npm install` in app directory

---

For detailed documentation, see [APP_README.md](./APP_README.md)

