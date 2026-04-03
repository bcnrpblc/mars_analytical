# Deployment Guide - LibreChat on Hostinger

## Prerequisites
- Docker installed
- Node.js v20+
- MongoDB instance (local or cloud)
- All environment variables configured

## Building the Docker Image

### 1. Build locally for testing:
```bash
docker build -f Dockerfile.prod -t librechat:latest .
```

### 2. Test the image locally:
```bash
docker run -p 3080:3080 \
  -e MONGO_URI="mongodb://localhost:27017/librechat" \
  -e NODE_ENV="production" \
  -e PORT=3080 \
  librechat:latest
```

### 3. Push to Docker Registry (Docker Hub, GitHub Container Registry, etc.):

**Docker Hub:**
```bash
docker tag librechat:latest YOUR_USERNAME/librechat:latest
docker push YOUR_USERNAME/librechat:latest
```

**GitHub Container Registry:**
```bash
docker tag librechat:latest ghcr.io/YOUR_USERNAME/librechat:latest
docker push ghcr.io/YOUR_USERNAME/librechat:latest
```

## Environment Variables (Required for Production)

Create a `.env` file with these values:

```env
# Server
NODE_ENV=production
PORT=3080
HOST=0.0.0.0

# Database
MONGO_URI=mongodb://your-mongo-instance:27017/librechat

# Domain
DOMAIN_CLIENT=https://your-domain.com
DOMAIN_SERVER=https://your-domain.com

# Authentication
JWT_SECRET=your-secret-key-here
JWT_REFRESH_SECRET=your-refresh-secret-here

# API Keys (configure based on your endpoints)
ANTHROPIC_API_KEY=your-key
OPENAI_API_KEY=your-key
GOOGLE_KEY=your-key

# Search
MEILI_HOST=http://meilisearch:7700
MEILI_MASTER_KEY=your-key

# Other required settings
CREDS_KEY=your-encryption-key
CREDS_IV=your-iv
```

## Hostinger Deployment Options

### Option 1: Using Hostinger's Docker Support (Recommended)
1. Push image to Docker Hub or GitHub Container Registry
2. In Hostinger dashboard, configure container deployment
3. Set environment variables in Hostinger panel
4. Deploy

### Option 2: Traditional Node.js Deployment
1. SSH into Hostinger server
2. Clone repository
3. Install dependencies: `npm ci --legacy-peer-deps`
4. Build: `npm run build`
5. Set PM2 or similar process manager to run `npm start`

### Option 3: Docker Compose on Hostinger
If Hostinger supports docker-compose:
```bash
docker-compose -f docker-compose.yml up -d
```

## Post-Deployment Checklist

- [ ] Health check passes: `curl http://your-domain/api/auth/session`
- [ ] Database connection verified
- [ ] Environment variables set correctly
- [ ] SSL/HTTPS configured
- [ ] Logs are being captured
- [ ] Backups configured

## Monitoring & Logs

### View logs:
```bash
docker logs <container-id>
```

### Check health:
```bash
curl http://localhost:3080/api/auth/session
```

## Troubleshooting

**Container won't start:**
- Check MongoDB connection: `MONGO_URI` must be accessible
- Verify all required environment variables are set
- Check logs: `docker logs <container-id>`

**Slow builds:**
- The build uses multi-stage compilation (optimized)
- First build takes ~3-5 minutes, subsequent builds are cached
- Use `docker build --no-cache` only if needed

**Permission issues:**
- Docker image runs as non-root user (nodejs:1001)
- Mount volumes with correct permissions if needed

## Size Optimization

- **Builder image**: ~500MB
- **Final image**: ~380MB (only runtime dependencies)
- **Compression**: Already using alpine base
