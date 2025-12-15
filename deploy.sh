#!/bin/bash

# 1. Check if .env exists, if not, copy from example
if [ ! -f .env ]; then
    echo "   [!] .env file not found! Creating one from .env.example..."
    cp .env.example .env
    echo "   Default config created. Please check .env (Default port is 3009)."
    echo "   You can run this script again immediately to start with defaults."
    exit 1
fi

# 2. Create data directories
echo "   [.] Ensuring data directories exist..."
mkdir -p mariadb_data
mkdir -p moodle_data
mkdir -p moodledata_data

# 3. Fix Permissions for Bitnami (User ID 1001)
# Bitnami images run as non-root (uid 1001) and need explicit permission for mapped volumes.
echo "   [.] Setting permissions for Bitnami (UID 1001)..."
sudo chown -R 1001:1001 mariadb_data
sudo chown -R 1001:1001 moodle_data
sudo chown -R 1001:1001 moodledata_data
sudo chmod -R 775 mariadb_data moodle_data moodledata_data

# 4. Pull and Start
echo "   [.] Pulling latest images..."
docker-compose pull

echo "   [.] Deploying Moodle on port 3009..."
docker-compose up -d

echo ""
echo "   [OK] Deployment complete!"
echo "   Access Moodle at: http://localhost:3009 (or your server IP:3009)"