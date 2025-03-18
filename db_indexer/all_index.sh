import mysql.connector
import curses
from collections import defaultdict
from rich import print

def get_databases(cursor):
    cursor.execute("SHOW DATABASES")
    return [db[0] for db in cursor.fetchall()]

def get_tables(cursor, database):
    cursor.execute(f"SHOW TABLES FROM `{database}`")
    return [table[0] for table in cursor.fetchall()]

def get_columns(cursor, database, table):
    cursor.execute(f"SHOW COLUMNS FROM `{database}`.`{table}`")
    return [col[0] for col in cursor.fetchall()]

def display_menu(stdscr, items, title, selected_indices=None, multi_select=True):
    curses.curs_set(0)
    k = 0
    cursor_pos = 0
    selected = selected_indices if selected_indices else set()
    
    while k != ord('q'):
        stdscr.clear()
        stdscr.addstr(0, 0, title, curses.A_BOLD)
        stdscr.addstr(1, 0, "Use UP/DOWN to navigate, 'y' to select, ENTER to confirm, 'q' to quit")
        
        for idx, item in enumerate(items):
            mode = curses.A_REVERSE if idx == cursor_pos else curses.A_NORMAL
            checkmark = "[X] " if idx in selected else "[ ] "
            stdscr.addstr(idx + 3, 2, checkmark + item, mode)
        
        stdscr.refresh()
        k = stdscr.getch()
        
        if k == curses.KEY_DOWN and cursor_pos < len(items) - 1:
            cursor_pos += 1
        elif k == curses.KEY_UP and cursor_pos > 0:
            cursor_pos -= 1
        elif k == ord('y'):
            if cursor_pos in selected:
                selected.remove(cursor_pos)
            else:
                selected.add(cursor_pos)
        elif k == 10:  # Enter key
            return [items[i] for i in selected]
    return []

def get_db_credentials(stdscr):
    """Gets database credentials from the user, with confirmation."""
    host = "localhost"
    user = "dbuser"
    password = "dbpass"

    stdscr.clear()
    stdscr.addstr(0, 0, "Database credentials:", curses.A_BOLD)
    stdscr.addstr(1, 0, f"Host: {host}")
    stdscr.addstr(2, 0, f"User: {user}")
    stdscr.addstr(3, 0, "Are these credentials correct? (y/n): ")
    stdscr.refresh()
    k = stdscr.getch()

    if k != ord('y'):
        stdscr.clear()
        stdscr.addstr(0, 0, "Enter new database credentials:", curses.A_BOLD)
        stdscr.addstr(1, 0, "Host: ")
        stdscr.refresh()
        curses.echo()
        host = stdscr.getstr(1, 7).decode('utf-8')
        stdscr.addstr(2, 0, "User: ")
        stdscr.refresh()
        user = stdscr.getstr(2, 7).decode('utf-8')
        stdscr.addstr(3, 0, "Password: ")
        stdscr.refresh()
        password = stdscr.getstr(3, 10).decode('utf-8')
        curses.noecho()
    return host, user, password

def main(stdscr):
    stdscr.clear()
    host, user, password = get_db_credentials(stdscr)
    
    try:
        connection = mysql.connector.connect(
            host=host,
            user=user,
            password=password
        )
    except mysql.connector.Error as err:
        print(f"[bold red]Error connecting to MySQL database:[/bold red] {err}")
        stdscr.getch()
        return

    cursor = connection.cursor()
    databases = get_databases(cursor)
    selected_db = display_menu(stdscr, databases, "Select a Database")
    if not selected_db:
        return
    selected_db = selected_db[0]
    cursor.execute(f"USE `{selected_db}`")
    
    tables = get_tables(cursor, selected_db)
    selected_tables = display_menu(stdscr, tables, "Select Tables")
    if not selected_tables:
        return
    
    selected_columns = defaultdict(list)
    all_columns = defaultdict(list)
    for table in selected_tables:
        columns = get_columns(cursor, selected_db, table)
        selected_cols = display_menu(stdscr, columns, f"Select Columns for {table}")
        all_columns[table] = columns
        if selected_cols:
            selected_columns[table] = selected_cols
    
    print("\n[bold]Summary of Indexing:[/bold]")
    for table, cols in all_columns.items():
        print(f"\n[b]Table: {table}[/b]")
        for col in cols:
            if col in selected_columns.get(table, []):
                print(f"  ✅ [green]{col}[/green] (Will be indexed)")
            else:
                print(f"  ❌ [red]{col}[/red] (Not indexed)")
    
    print("\nProceed with indexing? (y/n)")
    k = stdscr.getch()
    if k != ord('y'):
        return
    
    for table, cols in selected_columns.items():
        for col in cols:
            index_name = f"idx_{table}_{col}"
            cursor.execute(f"SHOW INDEX FROM `{table}` WHERE Key_name = '{index_name}';")
            if cursor.fetchone():
                continue
            print(f"Indexing {table}.{col}...")
            try:
                cursor.execute(f"ALTER TABLE `{table}` ADD INDEX `{index_name}` (`{col}`);")
            except mysql.connector.Error as err:
                print(f"[bold red]Error during index creation on {table}.{col}:[/bold red] {err}")
                stdscr.getch()
                return
    connection.commit()
    
    print("\n[bold green]✅ Indexing completed successfully![/bold green]")
    stdscr.getch()

def start_cli():
    curses.wrapper(main)

if __name__ == "__main__":
    start_cli()
