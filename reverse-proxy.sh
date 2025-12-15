#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo ./reverse-proxy.sh)"
  exit
fi

# 1. Ask for Domain Name
read -p "Enter your Moodle domain name (e.g., moodle.example.com): " DOMAIN_NAME

if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: Domain name cannot be empty."
    exit 1
fi

NGINX_AVAILABLE="/etc/nginx/sites-available/$DOMAIN_NAME"
NGINX_ENABLED="/etc/nginx/sites-enabled/$DOMAIN_NAME"

# 2. Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "   [!] Nginx not found. Installing Nginx..."
    apt update && apt install -y nginx
fi

# 3. Create Nginx Configuration
echo "   [.] Creating Nginx configuration for $DOMAIN_NAME..."

# Note: Proxying to port 3009 based on your deployment script
cat > "$NGINX_AVAILABLE" <<EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;

    location / {
        proxy_pass http://localhost:3009;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Increase upload size for Moodle (Assignments/Restores)
        client_max_body_size 200M;
    }
}
EOF

# 4. Enable the Site (Symlink)
if [ -L "$NGINX_ENABLED" ]; then
    echo "   [!] Symlink already exists. Skipping..."
else
    echo "   [.] Enabling site (creating symlink)..."
    ln -s "$NGINX_AVAILABLE" "$NGINX_ENABLED"
fi

# 5. Test and Reload Nginx
echo "   [.] Testing Nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "   [.] Reloading Nginx..."
    systemctl reload nginx
else
    echo "   [X] Nginx configuration failed! Check $NGINX_AVAILABLE"
    exit 1
fi

# 6. Certbot (SSL) Setup
echo ""
read -p "Do you want to run Certbot now to set up HTTPS? (y/n): " RUN_CERTBOT

if [[ "$RUN_CERTBOT" =~ ^[Yy]$ ]]; then
    if ! command -v certbot &> /dev/null; then
        echo "   [!] Certbot not found. Installing Certbot and Nginx plugin..."
        apt update && apt install -y certbot python3-certbot-nginx
    fi

    echo "   [.] Requesting SSL certificate for $DOMAIN_NAME..."
    # --nginx automatically modifies the config file created above
    certbot --nginx -d "$DOMAIN_NAME"
else
    echo "   [.] Skipping Certbot. You can run it manually later: sudo certbot --nginx -d $DOMAIN_NAME"
fi

echo ""
echo "   [OK] Reverse proxy setup complete!"
echo "   Visit: http://$DOMAIN_NAME (or https://$DOMAIN_NAME if you ran Certbot)"