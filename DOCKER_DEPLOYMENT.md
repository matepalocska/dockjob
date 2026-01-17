# DockJob Docker Deployment Guide

## Required Environment Variables

The DockJob container requires several environment variables to be set for proper operation:

### Required Variables:
- `APIAPP_TRIGGERAPIURL` - URL for the trigger API (e.g., `http://localhost:8301/triggerapi`)
- `DOCKJOB_EXTERNAL_TRIGGER_SYS_PASSWORD` - Password for external trigger system

### Optional Variables (with defaults):
- `APIAPP_APIURL` - API URL (default: `http://localhost:8301/api`)
- `APIAPP_APIDOCSURL` - API documentation URL (default: `http://localhost:8301/apidocs`)
- `APIAPP_FRONTENDURL` - Frontend URL (default: `http://localhost:8301/frontend`)
- `APIAPP_COMMON_ACCESSCONTROLALLOWORIGIN` - CORS origins (default: `http://localhost:8301`)

## Docker Run Command

```bash
docker run -d \
  -p 8301:80 \
  --name dockjob \
  --env APIAPP_APIURL=http://your-server:8301/api \
  --env APIAPP_TRIGGERAPIURL=http://your-server:8301/triggerapi \
  --env APIAPP_APIDOCSURL=http://your-server:8301/apidocs \
  --env APIAPP_FRONTENDURL=http://your-server:8301/frontend \
  --env APIAPP_COMMON_ACCESSCONTROLALLOWORIGIN="http://your-server:8301" \
  --env DOCKJOB_EXTERNAL_TRIGGER_SYS_PASSWORD="your-secure-password" \
  matepalocska/dockjob:latest
```

## TrueNAS SCALE Deployment

When deploying on TrueNAS SCALE, make sure to:

1. **Set Environment Variables**: In the container configuration, add all required environment variables
2. **Port Mapping**: Map container port 80 to your desired host port (e.g., 8301)
3. **Replace URLs**: Update all URLs to match your TrueNAS server's IP/hostname

### Example for TrueNAS:
If your TrueNAS server IP is `192.168.1.100` and you want to use port `8301`:

```
APIAPP_APIURL=http://192.168.1.100:8301/api
APIAPP_TRIGGERAPIURL=http://192.168.1.100:8301/triggerapi
APIAPP_APIDOCSURL=http://192.168.1.100:8301/apidocs
APIAPP_FRONTENDURL=http://192.168.1.100:8301/frontend
APIAPP_COMMON_ACCESSCONTROLALLOWORIGIN=http://192.168.1.100:8301
DOCKJOB_EXTERNAL_TRIGGER_SYS_PASSWORD=your-secure-password
```

## Persistent Data Storage

By default, job data is stored inside the container and will be lost when the container is recreated. To make your job data persistent, you need to:

### 1. Mount Data Volume
Mount a local directory to `/app/data` in the container:

```bash
# Create local data directory
mkdir -p ./dockjob-data

# Docker run with volume mount
docker run -d \
  -p 8301:80 \
  --name dockjob \
  -v $(pwd)/dockjob-data:/app/data \
  --env APIAPP_OBJECTSTORECONFIG='{"Type":"SimpleFileStore", "BaseLocation": "/app/data"}' \
  --env APIAPP_TRIGGERAPIURL=http://your-server:8301/triggerapi \
  --env DOCKJOB_EXTERNAL_TRIGGER_SYS_PASSWORD="your-secure-password" \
  matepalocska/dockjob:latest
```

### 2. Optional: Log Persistence
To also persist application logs:

```bash
mkdir -p ./dockjob-logs
# Add to docker run command:
# -v $(pwd)/dockjob-logs:/var/log/uwsgi
```

### 3. Using Docker Compose
The included `docker-compose.yml` already has persistent data configured:

```yaml
volumes:
  - ./data:/app/data          # Job data persistence
  - ./logs:/var/log/uwsgi     # Log persistence
```

Simply run:
```bash
docker-compose up -d
```

### TrueNAS SCALE Persistent Data
In TrueNAS SCALE container settings:

1. **Host Path Storage**: Create a dataset (e.g., `/mnt/pool/dockjob-data`)
2. **Volume Mount**: Mount to `/app/data` in the container
3. **Environment Variable**: Add `APIAPP_OBJECTSTORECONFIG={"Type":"SimpleFileStore", "BaseLocation": "/app/data"}`

This ensures your jobs, schedules, and execution history survive container restarts and updates.

## Accessing the Application

Once running successfully:
- **Frontend**: `http://your-server:8301/frontend/`
- **API**: `http://your-server:8301/api/serverinfo`
- **API Documentation**: `http://your-server:8301/apidocs`

## Troubleshooting

### Common Issues:

1. **Missing Environment Variables**: Check logs for `InvalidEnvVarParamaterExecption` errors
2. **Port Conflicts**: Ensure port 8301 (or your chosen port) is available
3. **CORS Issues**: Update `APIAPP_COMMON_ACCESSCONTROLALLOWORIGIN` with your server's URL
4. **Health Check Failures**: The container has built-in health checks that verify both frontend and API endpoints