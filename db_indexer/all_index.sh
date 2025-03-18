#!/bin/bash

# Create a temporary MySQL configuration file
config_file="$HOME/my_mysql.cnf"
echo "[client]" > "$config_file"
echo "user=dbuser" >> "$config_file"
echo "password=dbpass" >> "$config_file"  # Add the password here if applicable

# Ensure the file is readable only by the user
chmod 600 "$config_file"

# Database information
db_name="mydb"

# Retrieve all tables and index information from MySQL in a single query
query="SELECT TABLE_NAME, COLUMN_NAME 
       FROM INFORMATION_SCHEMA.COLUMNS 
       WHERE TABLE_SCHEMA='$db_name';"

# Test the connection
mysql --defaults-extra-file="$config_file" -e "USE $db_name;" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Failed to connect to MySQL or select the database. Please check your credentials."
    exit 1
fi

# Retrieve all tables and columns
tables_and_columns=$(mysql --defaults-extra-file="$config_file" -D "$db_name" -s -N -e "$query")

if [ -z "$tables_and_columns" ]; then
    echo "No tables or columns found in the database."
    exit 1
fi

echo "Scanning all tables and columns..."

# Check and add indexes for each table and column
while read -r table column; do
    index_name="idx_${table}_${column}"

    echo "📌 Checking: Table = '$table', Column = '$column'"

    # Check if the index already exists
    index_exists=$(mysql --defaults-extra-file="$config_file" -D "$db_name" -s -N -e "SHOW INDEX FROM \`$table\` WHERE Key_name = '$index_name';")

    if [ -n "$index_exists" ]; then
        echo "✅ Already exists: Skipping index '$index_name' for column '$column' in table '$table'."
    else
        echo "➕ Adding index: Table = '$table', Column = '$column'..."
        mysql --defaults-extra-file="$config_file" -D "$db_name" -e "ALTER TABLE \`$table\` ADD INDEX \`$index_name\` (\`$column\`);"
        
        if [ $? -eq 0 ]; then
            echo "🎯 Success: Index '$index_name' created for column '$column' in table '$table'."
        else
            echo "❌ Error: Failed to create index for column '$column' in table '$table'."
        fi
    fi

    echo "----------------------"  # Add a separator for better readability

done <<< "$tables_and_columns"

# Remove the temporary configuration file (for security)
rm -f "$config_file"

echo "🎉 All indexing operations are complete!"
