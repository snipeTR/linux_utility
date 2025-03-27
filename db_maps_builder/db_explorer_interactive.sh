#!/bin/bash

# Check for required packages
if ! command -v dialog &> /dev/null; then
    echo "❗️ 'dialog' package is required but not installed. Installing now..."
    sudo apt update && sudo apt install -y dialog
fi

# Ask for database info
DB_NAME=$(dialog --inputbox "Enter database name (case-sensitive!):" 8 40 --stdout)
DB_USER=$(dialog --inputbox "Enter MySQL username:" 8 40 --stdout)
DB_PASS=$(dialog --insecure --passwordbox "Enter password (leave empty for no password):" 8 40 --stdout)

# Check if password is empty
if [ -z "$DB_PASS" ]; then
    MYSQL_CMD="mysql -u $DB_USER"
else
    MYSQL_CMD="mysql -u $DB_USER -p$DB_PASS"
fi

# Check if the database exists
if ! $MYSQL_CMD -e "USE $DB_NAME;" 2>/dev/null; then
    dialog --msgbox "❌ Database '$DB_NAME' not found or access denied!" 8 40
    exit 1
fi

# Main Menu
main_menu() {
    TABLES=$($MYSQL_CMD -e "SHOW TABLES FROM $DB_NAME;" -s -N)
    if [ -z "$TABLES" ]; then
        dialog --msgbox "⚠️ No tables found in database '$DB_NAME'!" 8 40
        exit 1
    fi

    TABLE_ARRAY=()
    for TABLE in $TABLES; do
        TABLE_ARRAY+=("$TABLE" "$TABLE")
    done

    TABLE_CHOICE=$(dialog --clear --menu "📚 Tables in $DB_NAME" 15 50 10 "${TABLE_ARRAY[@]}" --stdout)
    if [ -n "$TABLE_CHOICE" ]; then
        table_menu "$TABLE_CHOICE"
    else
        exit 0
    fi
}

# Table Menu
table_menu() {
    local TABLE=$1
    COLUMNS=$($MYSQL_CMD -e "DESCRIBE $DB_NAME.$TABLE;" -s -N | awk '{print $1}')

    COLUMN_ARRAY=()
    for COL in $COLUMNS; do
        COLUMN_ARRAY+=("$COL" "$COL")
    done

    COLUMN_CHOICE=$(dialog --clear --menu "🗂️ Columns in $TABLE" 15 50 10 "${COLUMN_ARRAY[@]}" --stdout)
    if [ -n "$COLUMN_CHOICE" ]; then
        column_data "$TABLE" "$COLUMN_CHOICE"
    else
        main_menu
    fi
}

# Column Data Menu
column_data() {
    local TABLE=$1
    local COLUMN=$2
    ROWS=$($MYSQL_CMD -e "SELECT $COLUMN FROM $DB_NAME.$TABLE LIMIT 2;" -s -N)

    if [ -z "$ROWS" ]; then
        dialog --msgbox "📄 No data found in '$TABLE.$COLUMN'" 8 50
    else
        ROW_LIST=$(echo "$ROWS" | awk '{print NR ") " $0}')
        dialog --msgbox "📄 Sample data from $TABLE.$COLUMN:\n\n$ROW_LIST" 12 60
    fi

    table_menu "$TABLE"
}

# Main loop
while true; do
    main_menu
done
clear
