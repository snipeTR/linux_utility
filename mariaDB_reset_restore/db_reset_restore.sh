#!/bin/bash

echo "📌 Please enter the following information for the operation:"

read -p "Database name (DB_NAME): " DB_NAME
read -p "Backup folder (DB_BACKUP_PATH): " DB_BACKUP_PATH
read -p "MySQL username (MYSQL_USER): " MYSQL_USER

DB_NAME=${DB_NAME:-mydatabase}
DB_BACKUP_PATH=${DB_BACKUP_PATH:-/root/mydatabase_backup}
MYSQL_USER=${MYSQL_USER:-mydbuser}
DB_PATH="/var/lib/mysql/$DB_NAME"

echo
echo "📋 Your input:"
echo "🔹 Database name       : $DB_NAME"
echo "🔹 Backup folder       : $DB_BACKUP_PATH"
echo "🔹 MySQL username      : $MYSQL_USER"
echo "🔹 Database directory  : $DB_PATH"
echo

# WARNING
echo
echo "============================================="
echo "⚠️  WARNING! WHAT DOES THIS SCRIPT DO?"
echo " - Deletes ALL TABLES in the '$DB_NAME' database."
echo " - Completely drops and recreates the '$DB_NAME' database."
echo " - Cleans the '$DB_PATH' directory."
echo " - Restores backup files from '$DB_BACKUP_PATH'."
echo " - Stops and starts the MariaDB service multiple times."
echo " - YOU MAY LOSE ALL YOUR DATA AFTER THIS OPERATION."
echo "❌ THIS ACTION IS IRREVERSIBLE! ARE YOU SURE?"
echo "============================================="

# Disk speed and estimated time
echo "🔍 Testing disk read speed (256MB)..."
DISK_TEST_OUTPUT=$(dd if=/dev/zero bs=1M count=256 of=/dev/null 2>&1)
READ_SPEED=$(echo "$DISK_TEST_OUTPUT" | grep copied | awk -F, '{print $3}' | xargs)

if [[ "$READ_SPEED" =~ ([0-9]+(\.[0-9]+)?)\ MB/s ]]; then
    AVG_SPEED_MB=${BASH_REMATCH[1]}
else
    echo " - COULD NOT DETECT SPEED, DEFAULTING TO 200MB/s."
    AVG_SPEED_MB=200
fi

echo "💽 Average disk read speed: $AVG_SPEED_MB MB/s"

BACKUP_SIZE_MB=$(du -sm "$DB_BACKUP_PATH" | cut -f1)
ESTIMATED_TIME_SEC=$(echo "$BACKUP_SIZE_MB / $AVG_SPEED_MB" | bc)

echo "📦 Backup size: $BACKUP_SIZE_MB MB"
echo "⏳ Estimated copy time: $ESTIMATED_TIME_SEC seconds"

# Allow user to review the info
echo
echo "⌛ Please review the above information before continuing..."
sleep 3

read -p "Do you want to proceed? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ Operation cancelled."
    exit 1
fi

echo "1. Deleting tables..."
echo "============================================="
mysql -u "$MYSQL_USER" -e "USE \`$DB_NAME\`; SET FOREIGN_KEY_CHECKS=0; \
    SET @tables = (SELECT GROUP_CONCAT(table_name) FROM information_schema.tables WHERE table_schema = '$DB_NAME'); \
    SET @query = CONCAT('DROP TABLE IF EXISTS ', @tables); \
    PREPARE stmt FROM @query; EXECUTE stmt; DEALLOCATE PREPARE stmt; \
    SET FOREIGN_KEY_CHECKS=1;"

echo "2. Dropping database '$DB_NAME'..."
echo "============================================="
mysql -u "$MYSQL_USER" -e "DROP DATABASE IF EXISTS \`$DB_NAME\`;"

echo "3. Stopping MariaDB service..."
echo "============================================="
systemctl stop mariadb

echo "4. Cleaning old database folder..."
echo "============================================="
rm -rf "$DB_PATH"

echo "5. Restarting MariaDB service..."
echo "============================================="
systemctl start mariadb

echo "6. Recreating database '$DB_NAME'..."
echo "============================================="
mysql -u "$MYSQL_USER" -e "CREATE DATABASE \`$DB_NAME\`;"

echo "7. Stopping MariaDB service again (for file copy)..."
echo "============================================="
systemctl stop mariadb

echo "8. Copying backup files (~${ESTIMATED_TIME_SEC} seconds expected)..."
echo "============================================="

USE_CP=false

# Check and install rsync if necessary
if ! command -v rsync &> /dev/null; then
    echo "🔍 'rsync' is not installed. Attempting to install..."
    apt-get update && apt-get install -y rsync
    if ! command -v rsync &> /dev/null; then
        echo "⚠️  'rsync' could not be installed. Falling back to 'cp'."
        USE_CP=true
    fi
fi

# Perform copy
if [ "$USE_CP" = false ]; then
    echo "🚀 Copying with rsync (with progress bar):"
    rsync -ah --info=progress2 "$DB_BACKUP_PATH/" "$DB_PATH/"
else
    echo "📁 Copying with cp (no progress shown):"
    cp -r "$DB_BACKUP_PATH/"* "$DB_PATH/"
fi

# Set ownership
chown -R mysql:mysql "$DB_PATH"

echo "9. Copy operation completed"
echo "============================================="

echo "10. Starting MariaDB service again..."
systemctl start mariadb

echo "✅ Operation complete. Database '$DB_NAME' was successfully restored."
