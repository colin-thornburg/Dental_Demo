from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import json
from dotenv import load_dotenv
from openai import OpenAI
from dbt_sl import SemanticLayerClient

load_dotenv()

app = Flask(__name__)
# Allow CORS from both port 3000 and 3001 for development
CORS(app, resources={r"/api/*": {"origins": ["http://localhost:3000", "http://localhost:3001"]}})

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# Initialize dbt Semantic Layer client
sl_client = SemanticLayerClient(
    environment_id=int(os.getenv('DBT_ENVIRONMENT_ID')),
    auth_token=os.getenv('DBT_SERVICE_TOKEN'),
    host=os.getenv('DBT_HOST', 'semantic-layer.cloud.getdbt.com')
)

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

def execute_semantic_layer_query(metrics, dimensions=None, where_clause=None, limit=100):
    """Execute a query using the dbt Semantic Layer SDK"""
    try:
        # Build the query
        query_params = {
            'metrics': metrics,
        }
        
        if dimensions:
            query_params['group_by'] = dimensions
        
        if where_clause:
            query_params['where'] = where_clause
        
        query_params['limit'] = limit
        
        # Execute query using SDK
        result = sl_client.query(**query_params)
        
        # Convert result to a format similar to CLI output for consistency
        if result and hasattr(result, 'to_dict'):
            data = result.to_dict()
            return {
                'success': True,
                'data': data,
                'output': format_as_table(data)  # Format for display
            }
        elif result:
            # Handle different result formats
            return {
                'success': True,
                'data': result,
                'output': str(result)
            }
        else:
            return {'error': 'No data returned', 'success': False}
            
    except Exception as e:
        return {'error': str(e), 'success': False}

def format_as_table(data):
    """Format query results as ASCII table for compatibility with frontend parser"""
    if not data or not isinstance(data, dict):
        return str(data)
    
    # Try to extract rows from various possible formats
    rows = []
    if 'rows' in data:
        rows = data['rows']
    elif isinstance(data, list):
        rows = data
    
    if not rows:
        return "No data"
    
    # Get headers
    headers = list(rows[0].keys()) if rows else []
    
    # Build ASCII table
    lines = []
    lines.append('+' + '+'.join(['-' * 25 for _ in headers]) + '+')
    lines.append('| ' + ' | '.join([str(h).upper()[:23].ljust(23) for h in headers]) + ' |')
    lines.append('+' + '+'.join(['-' * 25 for _ in headers]) + '+')
    
    for row in rows:
        values = [str(row.get(h, ''))[:23].ljust(23) for h in headers]
        lines.append('| ' + ' | '.join(values) + ' |')
    
    lines.append('+' + '+'.join(['-' * 25 for _ in headers]) + '+')
    
    return '\n'.join(lines)

def parse_natural_language_query(user_query):
    """Use OpenAI to convert natural language to semantic layer query"""
    try:
        system_prompt = """You are a data analyst assistant that converts natural language questions into dbt semantic layer queries.

Available Metrics:
""" + json.dumps(AVAILABLE_METRICS, indent=2) + """

Available Dimensions:
""" + json.dumps(AVAILABLE_DIMENSIONS, indent=2) + """

Convert the user's question into a JSON object with:
- metrics: array of metric names to query
- dimensions: array of dimensions to group by (optional, omit if not needed for grouping)
- where_clause: optional filter using dbt semantic layer syntax

WHERE CLAUSE SYNTAX:
- Use dimension references like: "{{ Dimension('facility__brand_name') }} = 'Aspen Dental'"
- For time filters: "{{ TimeDimension('metric_time', 'year') }} = 2024"
- Multiple conditions: "{{ Dimension('facility__brand_name') }} = 'Aspen Dental' AND {{ TimeDimension('metric_time', 'year') }} = 2024"

Examples:
User: "Show me revenue by brand for 2024"
Response: {"metrics": ["revenue"], "dimensions": ["facility__brand_name", "metric_time__year"]}

User: "What is revenue for Aspen Dental?"
Response: {"metrics": ["revenue"], "where_clause": "{{ Dimension('facility__brand_name') }} = 'Aspen Dental'"}

User: "Show new patients for ClearChoice in 2024"
Response: {"metrics": ["new_patients"], "dimensions": ["metric_time__month"], "where_clause": "{{ Dimension('facility__brand_name') }} = 'ClearChoice' AND {{ TimeDimension('metric_time', 'year') }} = 2024"}

IMPORTANT: 
- Brand names must be exact: "Aspen Dental", "ClearChoice Dental Implant Centers", "WellNow Urgent Care", "Chapter Aesthetic Studio", "Lovet Pet Health Care"
- Do NOT use Jinja control flow statements
- Only use {{ Dimension() }} and {{ TimeDimension() }} functions for filters

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
    return jsonify({
        'status': 'healthy',
        'service': 'TAG Analytics API',
        'mode': 'SDK',
        'environment': os.getenv('DBT_ENVIRONMENT_ID')
    })

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
    
    result = execute_semantic_layer_query(metrics, dimensions, where_clause, limit)
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
    result = execute_semantic_layer_query(
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

