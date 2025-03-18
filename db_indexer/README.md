# MySQL Database Indexing Tool

This Python script is a terminal-based tool that helps you easily create indexes on your MySQL databases. It provides an interactive menu interface using the `curses` library and manages database connections via `mysql.connector`. The `rich` library is used to display colorful output in the summary section.

## Requirements

1. **Python 3.6+**: This script requires Python 3.6 or newer. You can download Python from the [official Python download page](https://www.python.org/downloads/).
2. **MySQL Server**: A running MySQL server and access credentials (host, username, password) are required.
3. **Required Python Packages**: Install the necessary packages using the following command:

    ```bash
    pip3 install mysql-connector-python rich
    ```
    The `curses` package usually comes with Python, but if you encounter any errors, check for system-specific installation instructions.

## Installation

### 1. Install Python 3
For detailed installation instructions, visit the [official Python download page](https://www.python.org/downloads/).

### 2. Download the Script

You can download the script using one of the following methods:

**Download Only:**

Download the script from the following link:

[https://github.com/snipeTR/linux_utility/blob/main/db_indexer/all_index.sh](https://github.com/snipeTR/linux_utility/blob/main/db_indexer/all_index.sh)

After downloading, open the script in a text editor to configure your database connection details. Then, run it using the following command:

```bash
python3 all_index.sh
```

**Download and Execute (One Command):**

You can download, install required packages, manually configure database credentials, and execute the script with a single command. **WARNING:** This command directly downloads and runs the script. Ensure that it comes from a trusted source and configure your database credentials inside the script first.

```bash
wget -O all_index.sh https://raw.githubusercontent.com/snipeTR/linux_utility/main/db_indexer/all_index.sh && chmod +x all_index.sh && nano all_index.sh
```

## Recommendation for Long-Running Processes

Depending on the size of your database, the indexing process may take a long time. To ensure uninterrupted execution, you can use tools like `tmux` or `screen`. These tools allow terminal sessions to run in the background and persist even if your connection drops.

### **Using tmux**

1. Start a new `tmux` session:
    ```bash
    tmux new -s my_session
    ```
2. Run the script:
    ```bash
    python3 all_index.sh
    ```
3. To detach from the `tmux` session:
    ```bash
    Ctrl + B, then D
    ```
4. To reattach to the session:
    ```bash
    tmux attach -t my_session
    ```

### **Using screen**

1. Start a new `screen` session:
    ```bash
    screen -S my_session
    ```
2. Run the script:
    ```bash
    python3 all_index.sh
    ```
3. To detach from the `screen` session:
    ```bash
    Ctrl + A, then D
    ```
4. To reattach to the session:
    ```bash
    screen -r my_session
    ```

By using these methods, the indexing process will continue even if your connection is lost. This is especially recommended when working with large databases.

