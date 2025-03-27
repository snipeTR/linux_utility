#!/bin/bash

# =======================
# ⚠️ WARNING MESSAGE ⚠️
# =======================

# Print warning message with dark red text and blue background
echo -e "\e[48;5;17m\e[38;5;88m#############################################################################\e[0m"
echo -e "\e[48;5;17m\e[38;5;88m# ⚠️  WARNING: The selected database contents will be exported to a TXT file!  #\e[0m"
echo -e "\e[48;5;17m\e[38;5;88m#                                                                             #\e[0m"
echo -e "\e[48;5;17m\e[38;5;88m# 🔒 Please destroy this file after reviewing the contents.                    #\e[0m"
echo -e "\e[48;5;17m\e[38;5;88m# 🛑 You are responsible for the security of this file!                        #\e[0m"
echo -e "\e[48;5;17m\e[38;5;88m#                                                                             #\e[0m"
echo -e "\e[48;5;17m\e[38;5;88m# 🗑️  To securely delete this file on Ubuntu, run:                             #\e[0m"
echo -e "\e[48;5;17m\e[38;5;88m#    shred -u -z <filename>                                                   #\e[0m"
echo -e "\e[48;5;17m\e[38;5;88m#############################################################################\e[0m"
echo ""

# ========================
# 📚 DATABASE INFORMATION
# ========================
# Ask for database name with case sensitivity warning
read -p "Enter database name (case-sensitive!): " DB_NAME
read -p "Enter MySQL username: " DB_USER
read -s -p "Enter password (press ENTER for no password): " DB_PASS
echo ""  # Newline for better formatting

# If password is empty, connect without password
if [ -z "$DB_PASS" ]; then
    MYSQL_CMD="mysql -u $DB_USER"
else
    MYSQL_CMD="mysql -u $DB_USER -p$DB_PASS"
fi

# Define output file name
OUTPUT_FILE="${DB_NAME}_structure.txt"

# Add header to output file
echo "Database: $DB_NAME" > "$OUTPUT_FILE"
echo "==========================" >> "$OUTPUT_FILE"

# Get all tables and iterate over them
tables=$($MYSQL_CMD -e "SHOW TABLES FROM $DB_NAME;" -s -N)

# Check if there are no tables
if [ -z "$tables" ]; then
    echo "⚠️ Error: No tables found in '$DB_NAME'!" >&2
    exit 1
fi

# Loop through each table
for table in $tables; do
    echo "" >> "$OUTPUT_FILE"
    echo "📂 Table: $table" >> "$OUTPUT_FILE"
    echo "--------------------------" >> "$OUTPUT_FILE"

    # Get column structure
    echo "🗂️ Columns:" >> "$OUTPUT_FILE"
    $MYSQL_CMD -e "DESCRIBE $DB_NAME.$table;" -s -N | while IFS=$'\t' read -r field type null key default extra; do
        echo "   └── $field ($type)" >> "$OUTPUT_FILE"
    done

    echo "" >> "$OUTPUT_FILE"

    # Get first 2 rows
    echo "📄 First 2 Rows:" >> "$OUTPUT_FILE"
    rows=$($MYSQL_CMD -e "SELECT * FROM $DB_NAME.$table LIMIT 2;" -s -N)
    if [ -z "$rows" ]; then
        echo "   └── (Table is empty)" >> "$OUTPUT_FILE"
    else
        echo "$rows" | while IFS=$'\t' read -r row; do
            echo "   └── $row" >> "$OUTPUT_FILE"
        done
    fi
done

# =======================
# 📝 CHECK IF NANO EXISTS
# =======================
if ! command -v nano &>/dev/null; then
    echo "⚠️  'nano' is not installed!"
    read -p "Do you want to install 'nano'? (Y/N): " INSTALL_NANO
    if [[ $INSTALL_NANO =~ ^[Yy]$ ]]; then
        sudo apt update && sudo apt install -y nano
    else
        echo "❌ 'nano' not installed. You can manually review the file: $OUTPUT_FILE"
        exit 0
    fi
fi

# =======================
# 📂 OPEN FILE IN NANO
# =======================
read -p "Do you want to open the file with 'nano'? (Y/N): " OPEN_FILE
if [[ $OPEN_FILE =~ ^[Yy]$ ]]; then
    nano "$OUTPUT_FILE"
else
    echo "✅ File saved as '$OUTPUT_FILE'. Review it manually."
fi

# 🎯 Completion message
echo "🔒 Please review and securely delete the file using:"
echo "   shred -u -z $OUTPUT_FILE"
