# Moodle LMS Deployment

This project provides a Docker-based deployment solution (bitnami images) for Moodle Learning Management System (LMS) using MariaDB as the database backend. It includes optional reverse proxy configuration with Nginx for production deployments.

## Prerequisites

Before deploying Moodle, ensure the following prerequisites are met:

- Docker and Docker Compose installed on the system
- At least 4GB of available RAM
- At least 10GB of free disk space
- Internet connection for downloading Docker images

## Installation and Setup

1. Clone this repository to your local machine:

   ```
   git clone https://github.com/mfazrinizar/moodle-lms-deployment.git
   cd moodle-lms-deployment
   ```

2. Copy the environment configuration file:

   ```
   cp .env.example .env
   ```

3. Edit the `.env` file to configure your deployment settings. At minimum, update the following variables with secure values:

   - `DB_PASSWORD`: Database password for the Moodle user
   - `DB_ROOT_PASSWORD`: Root password for MariaDB
   - `MOODLE_ADMIN_PASSWORD`: Password for the Moodle administrator account
   - `MOODLE_ADMIN_EMAIL`: Email address for the Moodle administrator
   - `MOODLE_SITE_NAME`: Name of your Moodle site

4. Run the deployment script:

   ```
   ./deploy.sh
   ```

   This script will:

   - Create necessary data directories
   - Set appropriate permissions for Bitnami containers
   - Pull the latest Docker images
   - Start the Moodle and MariaDB containers

## Configuration

The deployment is configured through the `.env` file. Key configuration options include:

### Database Settings

- `DB_USER`: MariaDB user for Moodle (default: bn_moodle)
- `DB_PASSWORD`: Password for the Moodle database user
- `DB_NAME`: Name of the Moodle database (default: bitnami_moodle)
- `DB_ROOT_PASSWORD`: Root password for MariaDB

### Moodle Settings

- `MOODLE_ADMIN_USER`: Username for the Moodle administrator (default: admin)
- `MOODLE_ADMIN_PASSWORD`: Password for the Moodle administrator
- `MOODLE_ADMIN_EMAIL`: Email address for the Moodle administrator
- `MOODLE_SITE_NAME`: Display name for the Moodle site

### Network Settings

- `MOODLE_PORT`: Port exposed on the host for HTTP access (default: 3009)
- `MOODLE_SSL_PORT`: Port exposed on the host for HTTPS access (default: 3443)
- `MOODLE_HOST`: Hostname or IP address for Moodle (default: localhost)

### Reverse Proxy Settings

- `MOODLE_REVERSEPROXY`: Enable reverse proxy support (yes/no)
- `MOODLE_SSLPROXY`: Enable SSL termination at reverse proxy (yes/no)

## Usage

After successful deployment, access Moodle at:

```
http://localhost:3009
```

Or replace `localhost` with your server's IP address or domain name.

The first time you access Moodle, you will be prompted to complete the installation wizard. Use the administrator credentials defined in your `.env` file.

## Reverse Proxy Setup (Optional)

For production deployments behind a reverse proxy:

1. Ensure Nginx is installed on your system.

2. Run the reverse proxy setup script:

   ```
   sudo ./reverse-proxy.sh
   ```

3. Follow the prompts to:
   - Enter your domain name
   - Optionally set up SSL certificates with Certbot

The script will create an Nginx configuration file and enable the site.

## Data Persistence

The deployment uses Docker volumes for data persistence:

- `mariadb_data/`: MariaDB database files
- `moodle_data/`: Moodle application files
- `moodledata_data/`: Moodle user data (courses, files, etc.)

These directories are created automatically by the deployment script.

## Maintenance

### Updating Moodle

To update to the latest version:

```
docker-compose pull
docker-compose up -d
```

### Backup

Regular backups of the data directories (`mariadb_data`, `moodle_data`, `moodledata_data`) are recommended.

### Logs

Container logs can be viewed with:

```
docker-compose logs -f
```

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure the deployment script is run with appropriate permissions. It uses `sudo` for setting file permissions.

2. **Port Conflicts**: If port 3009 is already in use, modify `MOODLE_PORT` in the `.env` file.

3. **Database Connection Issues**: Verify database credentials in the `.env` file match between containers.

4. **Memory Issues**: Ensure sufficient RAM is available. Moodle recommends at least 4GB.

### Support

For Moodle-specific issues, refer to the official Moodle documentation at https://docs.moodle.org/.

For deployment-specific issues, check Docker and Docker Compose logs for detailed error messages.
