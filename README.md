# 💰 Budgetly

A modern budget management application built with Laravel and Filament.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker Build](https://github.com/holiq/budgetly/actions/workflows/docker-build.yml/badge.svg)](https://github.com/holiq/budgetly/actions/workflows/docker-build.yml)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue.svg)](https://github.com/holiq/budgetly/pkgs/container/budgetly%2Fapp)

## ✨ Features

- 💳 Expense tracking and categorization
- 📊 Budget planning and monitoring
- 📈 Financial reports and analytics
- 🔐 Secure authentication
- 🎨 Beautiful and intuitive UI with Filament

## 🚀 Quick Start

### Option 1: Using Pre-built Docker Image (Recommended)

```bash
# Download configuration files
wget https://raw.githubusercontent.com/holiq/budgetly/main/docker-compose.prod.yml
wget https://raw.githubusercontent.com/holiq/budgetly/main/.env.example

# Configure environment
cp .env.example .env
nano .env  # Edit APP_KEY and other settings

# Start the application
docker compose -f docker-compose.prod.yml up -d

# Generate application key (first time only)
docker compose -f docker-compose.prod.yml exec app php artisan key:generate

# Run migrations
docker compose -f docker-compose.prod.yml exec app php artisan migrate --force

# Create admin user
docker compose -f docker-compose.prod.yml exec app php artisan make:filament-user
```

Visit http://localhost:8000

### Option 2: Build from Source

```bash
# Clone repository
git clone https://github.com/holiq/budgetly.git
cd budgetly

# Configure environment
cp .env.example .env
nano .env  # Edit configuration

# Build and start
docker compose up -d

# Setup application (first time only)
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate --force
docker compose exec app php artisan make:filament-user
```

Visit http://localhost:8000

## 🔧 Configuration

### Environment Variables

Key variables in `.env`:

```env
APP_NAME=Budgetly
APP_ENV=production
APP_KEY=                    # Generate with: php artisan key:generate
APP_DEBUG=false
APP_URL=http://localhost:8000
APP_PORT=8000              # Port to expose the application

# Database (SQLite by default, no configuration needed)
DB_CONNECTION=sqlite

# For MySQL/PostgreSQL:
# DB_CONNECTION=mysql
# DB_HOST=your-db-host
# DB_PORT=3306
# DB_DATABASE=budgetly
# DB_USERNAME=your-username
# DB_PASSWORD=your-password
```

### Using Specific Version

```bash
# Use specific release version
IMAGE_TAG=v1.0.0 docker compose -f docker-compose.prod.yml up -d
```

### Enable Queue Worker (Optional)

Uncomment the `queue` service in `docker-compose.yml` or `docker-compose.prod.yml`, then:

```bash
docker compose up -d
```

### Enable Redis Cache (Optional)

1. Uncomment the `redis` service in docker-compose file
2. Update `.env`:
    ```env
    CACHE_STORE=redis
    QUEUE_CONNECTION=redis
    REDIS_HOST=redis
    REDIS_PASSWORD=your-secure-password
    ```
3. Restart: `docker compose up -d`

## 📦 Production Deployment

### With Reverse Proxy (Nginx/Caddy/Traefik)

Example Nginx configuration:

```nginx
server {
    listen 80;
    server_name budgetly.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Update `.env`:

```env
APP_URL=https://budgetly.yourdomain.com
```

### Update to Latest Version

```bash
# Pull latest image
docker compose -f docker-compose.prod.yml pull

# Restart with new image
docker compose -f docker-compose.prod.yml up -d

# Run migrations if needed
docker compose -f docker-compose.prod.yml exec app php artisan migrate --force
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is open-sourced software licensed under the [MIT license](LICENSE).

## 🐛 Issues & Support

Found a bug or need help? Please [open an issue](https://github.com/holiq/budgetly/issues).
