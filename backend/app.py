from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import subprocess
import json
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

app = Flask(__name__)
# Allow CORS from both port 3000 and 3001 for development
CORS(app, resources={r"/api/*": {"origins": ["http://localhost:3000", "http://localhost:3001"]}})

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# Available metrics from semantic layer
AVAILABLE_METRICS = {
    "revenue": "Total revenue across all services and facilities",
    "gross_profit": "Total gross profit (revenue minus direct costs)",
    "insurance_revenue": "Revenue received from insurance payers",
    "patient_revenue": "Revenue received directly from patients",
    "appointments": "Total number of appointments scheduled",
    "completed_visits": "Number of appointments that were completed",
    "new_patients": "Number of new patient visits (first-time patients)",
    "no_shows": "Number of appointments where patient did not show up",
    "cancellations": "Number of cancelled appointments",
    "no_show_rate": "Percentage of appointments that resulted in no-shows",
    "cancellation_rate": "Percentage of appointments that were cancelled",
    "revenue_per_visit": "Average revenue per completed patient visit",
    "gross_margin_pct": "Gross profit as a percentage of revenue",
    "cumulative_revenue": "Running total of revenue over time",
    "cumulative_new_patients": "Running total of new patient acquisitions"
}

AVAILABLE_DIMENSIONS = {
    "metric_time__day": "Daily time period",
    "metric_time__week": "Weekly time period",
    "metric_time__month": "Monthly time period",
    "metric_time__quarter": "Quarterly time period",
    "metric_time__year": "Yearly time period",
    "facility__brand_name": "Brand name (Aspen Dental, ClearChoice, WellNow, Chapter, Lovet)",
    "facility__brand_category": "Brand category (dental, dental_implants, urgent_care, etc.)",
    "facility__region": "Geographic region (Midwest, Southwest, Southeast, Northeast, Mountain)",
    "facility__facility_name": "Individual facility name",
    "facility__facility_city": "City where facility is located",
    "facility__facility_state": "State where facility is located"
}

def execute_dbt_query(metrics, dimensions, where_clause=None, limit=100):
    """Execute a dbt semantic layer query"""
    try:
        # Build command
        cmd = ['dbt', 'sl', 'query']
        
        # Add metrics
        if metrics:
            cmd.extend(['--metrics', ','.join(metrics)])
        
        # Add dimensions
        if dimensions:
            cmd.extend(['--group-by', ','.join(dimensions)])
        
        # Add where clause if provided
        if where_clause:
            cmd.extend(['--where', where_clause])
        
        # Add limit
        cmd.extend(['--limit', str(limit)])
        
        # Execute command
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=os.path.join(os.path.dirname(__file__), '..')
        )
        
        if result.returncode != 0:
            return {'error': result.stderr, 'success': False}
        
        # Parse output - this is a simplified parser
        # In production, you'd want more robust parsing
        return {
            'success': True,
            'output': result.stdout,
            'command': ' '.join(cmd)
        }
    except Exception as e:
        return {'error': str(e), 'success': False}

def parse_natural_language_query(user_query):
    """Use OpenAI to convert natural language to semantic layer query"""
    try:
        system_prompt = f"""You are a data analyst assistant that converts natural language questions into dbt semantic layer queries.

Available Metrics:
{json.dumps(AVAILABLE_METRICS, indent=2)}

Available Dimensions:
{json.dumps(AVAILABLE_DIMENSIONS, indent=2)}

Convert the user's question into a JSON object with:
- metrics: array of metric names to query
- dimensions: array of dimensions to group by (optional, omit if not needed for grouping)
- where_clause: optional filter using dbt semantic layer syntax

WHERE CLAUSE SYNTAX:
- Use dimension references like: {{"{{ Dimension('facility__brand_name') }} = 'Aspen Dental'"}}
- For time filters: {{"{{ TimeDimension('metric_time', 'year') }} = 2024"}}
- Multiple conditions: {{"{{ Dimension('facility__brand_name') }} = 'Aspen Dental' AND {{ TimeDimension('metric_time', 'year') }} = 2024"}}

Examples:
User: "Show me revenue by brand for 2024"
Response: {{"metrics": ["revenue"], "dimensions": ["facility__brand_name", "metric_time__year"]}}

User: "What is revenue for Aspen Dental?"
Response: {{"metrics": ["revenue"], "where_clause": "{{ Dimension('facility__brand_name') }} = 'Aspen Dental'"}}

User: "Show new patients for ClearChoice in 2024"
Response: {{"metrics": ["new_patients"], "dimensions": ["metric_time__month"], "where_clause": "{{ Dimension('facility__brand_name') }} = 'ClearChoice' AND {{ TimeDimension('metric_time', 'year') }} = 2024"}}

IMPORTANT: 
- Brand names must be exact: "Aspen Dental", "ClearChoice Dental Implant Centers", "WellNow Urgent Care", "Chapter Aesthetic Studio", "Lovet Pet Health Care"
- Do NOT use {% if %} statements or other Jinja control flow
- Only use {{ Dimension() }} and {{ TimeDimension() }} functions

Only return valid JSON, no other text."""

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_query}
            ],
            temperature=0.1
        )
        
        # Parse the JSON response
        query_params = json.loads(response.choices[0].message.content)
        return {'success': True, 'query': query_params}
    except Exception as e:
        return {'success': False, 'error': str(e)}

@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'TAG Analytics API'})

@app.route('/api/metrics', methods=['GET'])
def get_metrics():
    """Return available metrics"""
    return jsonify({
        'metrics': AVAILABLE_METRICS,
        'dimensions': AVAILABLE_DIMENSIONS
    })

@app.route('/api/query', methods=['POST'])
def query_semantic_layer():
    """Execute a semantic layer query"""
    data = request.json
    
    metrics = data.get('metrics', [])
    dimensions = data.get('dimensions', [])
    where_clause = data.get('where')
    limit = data.get('limit', 100)
    
    if not metrics:
        return jsonify({'error': 'At least one metric is required'}), 400
    
    result = execute_dbt_query(metrics, dimensions, where_clause, limit)
    return jsonify(result)

@app.route('/api/chat', methods=['POST'])
def chat():
    """Natural language query endpoint"""
    data = request.json
    user_query = data.get('query', '')
    
    if not user_query:
        return jsonify({'error': 'Query is required'}), 400
    
    # Parse natural language query
    parsed = parse_natural_language_query(user_query)
    
    if not parsed['success']:
        return jsonify({
            'error': 'Failed to parse your query',
            'details': parsed.get('error'),
            'query': user_query
        }), 500
    
    # Execute the query
    query_params = parsed['query']
    result = execute_dbt_query(
        query_params.get('metrics', []),
        query_params.get('dimensions', []),
        query_params.get('where_clause')
    )
    
    # Add helpful error messages
    if not result.get('success', False):
        error_msg = result.get('error', 'Unknown error')
        
        # Provide user-friendly error messages
        if 'brand_name' in error_msg.lower():
            suggestion = "Try using exact brand names: 'Aspen Dental', 'ClearChoice Dental Implant Centers', 'WellNow Urgent Care', 'Chapter Aesthetic Studio', or 'Lovet Pet Health Care'"
            result['suggestion'] = suggestion
        elif 'where filter' in error_msg.lower():
            suggestion = "There was an issue with the filter. Try rephrasing your question or removing specific filters."
            result['suggestion'] = suggestion
    
    return jsonify({
        'query': user_query,
        'parsed_query': query_params,
        'result': result
    })

if __name__ == '__main__':
    # Use port 5001 to avoid conflicts with macOS AirPlay on port 5000
    app.run(debug=True, port=5001, host='0.0.0.0')

