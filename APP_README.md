# TAG Analytics - Talk to Data Application

A modern analytics interface for The Aspen Group that allows natural language queries against the dbt Semantic Layer.

## Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌────────────────────┐
│  Next.js        │         │  Flask Backend   │         │  dbt Semantic      │
│  Frontend       │ ──────> │  + OpenAI        │ ──────> │  Layer (CLI)       │
│  (Port 3000)    │         │  (Port 5000)     │         │  + Snowflake       │
└─────────────────┘         └──────────────────┘         └────────────────────┘
```

### Components

1. **Frontend (Next.js + React + Tailwind)**
   - Modern, TAG-branded UI
   - Natural language chat interface
   - Data visualization with charts
   - Located in `/app`

2. **Backend (Flask + Python)**
   - REST API for semantic layer queries
   - OpenAI integration for NL to SQL translation
   - dbt CLI integration
   - Located in `/backend`

3. **dbt Semantic Layer**
   - Metrics and dimensions definitions
   - Direct connection to Snowflake
   - dbt Cloud CLI for query execution

## Setup Instructions

### Prerequisites

- Node.js 18+ and npm
- Python 3.9+
- dbt Cloud CLI configured (already done)
- OpenAI API key

### 1. Backend Setup

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY
```

### 2. Frontend Setup

```bash
cd app

# Install dependencies (already done)
npm install

# No .env needed - backend URL is hardcoded to localhost:5000
```

## Running the Application

### Start Backend (Terminal 1)

```bash
cd backend
source venv/bin/activate
python app.py
```

Backend will start on `http://localhost:5000`

### Start Frontend (Terminal 2)

```bash
cd app
npm run dev
```

Frontend will start on `http://localhost:3000`

### Access the Application

Open your browser to `http://localhost:3000`

## Usage

### Natural Language Queries

The application accepts natural language questions like:

- "Show me revenue by brand for 2024"
- "What's the no-show rate by facility?"
- "Show new patient visits by month"
- "Compare gross profit across all brands"
- "What was total revenue for ClearChoice last year?"

### Available Metrics

**Revenue Metrics:**
- `revenue` - Total revenue
- `gross_profit` - Gross profit
- `insurance_revenue` - Insurance revenue
- `patient_revenue` - Patient revenue
- `revenue_per_visit` - Avg revenue per visit
- `gross_margin_pct` - Gross margin %

**Patient Visit Metrics:**
- `appointments` - Total appointments
- `completed_visits` - Completed visits
- `new_patients` - New patient visits
- `no_shows` - No-show count
- `cancellations` - Cancellation count
- `no_show_rate` - No-show %
- `cancellation_rate` - Cancellation %

**Cumulative Metrics:**
- `cumulative_revenue` - Running revenue total
- `cumulative_new_patients` - Running patient total

### Available Dimensions

**Time Dimensions:**
- `metric_time__day` - Daily
- `metric_time__week` - Weekly
- `metric_time__month` - Monthly
- `metric_time__quarter` - Quarterly
- `metric_time__year` - Yearly

**Brand/Facility Dimensions:**
- `facility__brand_name` - Brand name
- `facility__brand_category` - Brand category
- `facility__region` - Region
- `facility__facility_name` - Facility name
- `facility__facility_city` - City
- `facility__facility_state` - State

## API Endpoints

### GET /api/health
Health check endpoint

### GET /api/metrics
Returns available metrics and dimensions

### POST /api/query
Direct semantic layer query
```json
{
  "metrics": ["revenue"],
  "dimensions": ["facility__brand_name"],
  "limit": 100
}
```

### POST /api/chat
Natural language query
```json
{
  "query": "Show me revenue by brand"
}
```

## Features

✅ Natural language query interface with OpenAI  
✅ Direct integration with dbt Semantic Layer  
✅ TAG-branded modern UI  
✅ Interactive data visualizations  
✅ Real-time query execution  
✅ Multiple chart types  
✅ Responsive design  

## Tech Stack

- **Frontend:** Next.js 15, React, TypeScript, Tailwind CSS, Recharts
- **Backend:** Flask, OpenAI API, Python
- **Data Layer:** dbt Semantic Layer, Snowflake
- **AI:** GPT-4 for natural language understanding

## Troubleshooting

### Backend not connecting to dbt
- Ensure dbt Cloud CLI is configured (`dbt debug`)
- Check that you're in the correct directory
- Verify Snowflake connection in dbt Cloud

### OpenAI errors
- Verify your API key in `.env`
- Check API rate limits
- Ensure you have credits in your OpenAI account

### CORS errors
- Backend must be running on port 5000
- Frontend must be running on port 3000
- Check Flask-CORS is installed

## Next Steps

- [ ] Add authentication
- [ ] Implement saved queries
- [ ] Add more chart types
- [ ] Export data functionality
- [ ] Real-time metrics dashboard
- [ ] Mobile responsive improvements
- [ ] Add filters and date range pickers

## Support

For issues with:
- **dbt Semantic Layer:** Check dbt Cloud CLI configuration
- **Frontend:** Check console logs in browser
- **Backend:** Check Flask server logs

---

Built with ❤️ for The Aspen Group

