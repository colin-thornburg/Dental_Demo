# Migration to dbt Semantic Layer SDK

## What Changed

We've migrated from using **dbt Cloud CLI** (development) to the **dbt Semantic Layer Python SDK** (production-ready).

### Before (CLI):
- Used `dbt sl query` command
- Required dbt CLI installed locally
- Used personal development credentials
- Queried Development environment

### After (SDK):
- Uses `dbt-semantic-layer` Python package
- Direct API connection to dbt Cloud
- Uses Service Token (production credentials)
- Can query any environment (Production recommended)

## Setup Instructions

### 1. Install New Dependency

The correct package is `dbt-sl-sdk` (not `dbt-semantic-layer`).

```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
```

This installs:
- `dbt-sl-sdk[sync]` - The official dbt Semantic Layer Python SDK
- `pyarrow` - Required for handling query results

### 2. Update Your .env File

Add these new variables to `backend/.env`:

```bash
# dbt Semantic Layer Configuration
DBT_SERVICE_TOKEN=your_service_token_here
DBT_ENVIRONMENT_ID=your_environment_id
DBT_HOST=semantic-layer.cloud.getdbt.com
```

**How to get these values:**

**Service Token:**
1. Go to dbt Cloud → Account Settings → Service Tokens
2. Create new token with "Semantic Layer Only" permissions
3. Copy the token (starts with `dbtc_`)

**Environment ID:**
1. Go to Deploy → Environments → Production
2. Copy the ID from the URL or environment details

### 3. Switch to SDK Version

**Option A: Replace the old file**
```bash
cd backend
mv app.py app_cli.py  # Backup old version
mv app_sdk.py app.py  # Use new SDK version
```

**Option B: Run SDK version directly**
```bash
python app_sdk.py
```

### 4. Restart Backend

```bash
cd backend
source venv/bin/activate
python app.py  # or python app_sdk.py
```

## Benefits

✅ **Production-Ready**: Queries production data with service token  
✅ **More Reliable**: Direct API connection, no CLI dependency  
✅ **Better Performance**: Optimized SDK queries  
✅ **Easier Deployment**: No need to install dbt CLI on server  
✅ **Secure**: Service token with limited permissions  

## Testing

Test that it works:

```bash
# Health check (should show mode: 'SDK')
curl http://localhost:5001/api/health

# Test query
curl -X POST http://localhost:5001/api/query \
  -H "Content-Type: application/json" \
  -d '{"metrics": ["revenue"], "limit": 1}'
```

## Rollback

If you need to go back to CLI version:

```bash
cd backend
mv app.py app_sdk.py  # Save SDK version
mv app_cli.py app.py  # Restore CLI version
python app.py
```

## Environment Configuration

Your current setup:
- **Environment ID**: 70403104008263
- **Host**: semantic-layer.cloud.getdbt.com
- **Service Token**: Set in .env file

The SDK will query your configured environment (Development or Production based on Environment ID).

