#!/usr/bin/env bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Laravel Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}ERROR: .env file not found!${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and configure it.${NC}"
    exit 1
fi

source .env

if [ -z "$APP_SLUG" ] || [ -z "$APP_DOMAIN" ] || [ -z "$COMPOSE_PROJECT_NAME" ]; then
    echo -e "${RED}ERROR: Required environment variables not set!${NC}"
    echo -e "${YELLOW}Please set: APP_SLUG, APP_DOMAIN, COMPOSE_PROJECT_NAME${NC}"
    exit 1
fi

if [ -z "$APP_KEY" ]; then
    echo -e "${YELLOW}WARNING: APP_KEY is not set!${NC}"
    read -p "Generate APP_KEY now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose build app
        APP_KEY=$(docker compose run --rm app php artisan key:generate --show | grep -E '^base64:' | tail -n 1)
        sed -i "s|^APP_KEY=.*|APP_KEY=$APP_KEY|" .env
        echo -e "${GREEN}✓ APP_KEY generated and saved to .env${NC}"
    else
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}Deployment Configuration:${NC}"
echo -e "  App Name: ${YELLOW}$APP_NAME${NC}"
echo -e "  App Slug: ${YELLOW}$APP_SLUG${NC}"
echo -e "  Domain: ${YELLOW}$APP_DOMAIN${NC}"
echo -e "  Project: ${YELLOW}$COMPOSE_PROJECT_NAME${NC}"
echo ""

# Ask for confirmation
read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Build images
echo -e "${GREEN}→ Building Docker images...${NC}"
docker compose build # --no-cache

# Stop old containers
echo -e "${GREEN}→ Stopping old containers...${NC}"
docker compose down

# Start new containers
echo -e "${GREEN}→ Starting new containers...${NC}"
docker compose up -d

# Wait for containers to be healthy
echo "→ Waiting for containers to be healthy..."
for i in {1..60}; do
  if ! docker compose ps --format json | grep -q '"Health":"unhealthy"'; then
    break
  fi
  sleep 2
done

# Check health
if docker compose ps | grep -q "unhealthy"; then
    echo -e "${RED}ERROR: Some containers are unhealthy!${NC}"
    docker compose ps
    exit 1
fi

# Run migrations
echo -e "${GREEN}→ Running database migrations...${NC}"
read -p "Run migrations? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker compose exec app php artisan migrate --force
fi

# Cache optimization
echo -e "${GREEN}→ Optimizing caches...${NC}"
docker compose exec app php artisan optimize:clear

source .env

# Test endpoint
echo -e "${GREEN}→ Testing application...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: $APP_DOMAIN" http://127.0.0.1/up)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Application is healthy! (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}✗ Application health check failed! (HTTP $HTTP_CODE)${NC}"
    echo -e "${YELLOW}Check logs: docker compose logs${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Deployment Summary${NC}"
echo -e "${GREEN}========================================${NC}"
docker compose ps
echo ""
echo -e "${GREEN}✓ Deployment completed!${NC}"
echo -e "${YELLOW}Access your app at: $APP_URL${NC}"
echo ""
