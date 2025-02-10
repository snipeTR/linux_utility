# MediaWiki Backup & Restore Script

This Bash script automates the backup and restoration of your MediaWiki installation on a Linux server (Ubuntu). It gathers your MediaWiki files and database into a time-stamped archive and provides an interactive menu for both backup and restore operations.

The script also automatically retrieves database credentials from your `LocalSettings.php` file and can generate an XML dump (via MediaWiki’s `maintenance/dumpBackup.php`) as an additional backup component.

> **GitHub Repository:** [MediaWiki Backup Script](https://github.com/snipeTR/linux_utility/blob/main/mediawiki_backup/mediawiki_backup.sh)

## Features

- **Automatic DB Credential Extraction:**  
  Retrieves database settings (`wgDBserver`, `wgDBname`, `wgDBuser`, and `wgDBpassword`) from your `LocalSettings.php`.

- **Interactive Menu:**  
  Choose between creating a backup or restoring from an existing backup.

- **Time-stamped Archives:**  
  Backup archives are named using the format `HHMMSS_YYYY-MM-DD_yedek.tar.gz` for easy identification.

- **XML Dump Generation:**  
  If available, an XML dump is created using MediaWiki’s `maintenance/dumpBackup.php`. (Restoration via XML dump must be done manually.)

- **Safe File Synchronization:**  
  Uses `rsync` to copy MediaWiki files while excluding backup and temporary directories.

- **Temporary Directories:**  
  Uses temporary directories for both backup (`temp_backup`) and restore (`temp_restore`) operations to ensure a clean process.

## Requirements

- **Operating System:** Ubuntu (or another compatible Linux distribution)
- **Software Dependencies:**
  - Bash
  - `mysqldump`
  - `mysql`
  - `tar`
  - `rsync`
  - PHP (for XML dump generation)

## Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/snipeTR/linux_utility.git
   ```

2. **Navigate to the MediaWiki Backup Directory:**

   ```bash
   cd linux_utility/mediawiki_backup
   ```

3. **Make the Script Executable:**

   ```bash
   chmod +x mediawiki_backup.sh
   ```

## Configuration

- **MediaWiki Directory:**  
  The script is designed to be run from your MediaWiki installation directory (e.g., `/var/www/html/mediawiki`). Ensure you execute the script from this directory or adjust the `MEDIAWIKI_DIR` variable in the script accordingly.

- **Database Credentials:**  
  The script automatically extracts the database credentials from `LocalSettings.php`. Make sure your `LocalSettings.php` is present and correctly configured.

- **Backup Directory:**  
  Backups are stored in the directory specified by the `BACKUP_DIR` variable (default is `backup` inside your MediaWiki directory).

## Usage

Run the script from the MediaWiki installation directory:

```bash
./mediawiki_backup.sh
```

You will be presented with an interactive menu:

1. **Yedek Oluştur (Backup):**  
   - A temporary directory (`temp_backup`) is created.
   - The script creates a SQL dump of your MediaWiki database.
   - An XML dump is generated (if `maintenance/dumpBackup.php` exists).
   - MediaWiki files are copied into the temporary directory (excluding backup and temporary directories).
   - The temporary directory is then packaged into a time-stamped archive (e.g., `235959_2025-02-10_yedek.tar.gz`) and saved to the backup directory.
   - The temporary directory is removed after archiving.

2. **Geri Yükle (Restore):**  
   - The script lists available backup archives from the backup directory.
   - You select the desired archive to restore.
   - The selected archive is extracted to a temporary directory (`temp_restore`).
   - The SQL dump is used to restore the database.
   - MediaWiki files are synchronized back to the installation directory using `rsync`.
   - The temporary restore directory is removed after the process.

3. **Çıkış (Exit):**  
   - Exits the script.

> **Note:**  
> The XML dump is generated as an extra backup; restoration using the XML dump must be performed manually if needed.

## License

This project is licensed under the [MIT License](LICENSE).

---

Feel free to contribute, report issues, or suggest improvements by visiting the [GitHub repository](https://github.com/snipeTR/linux_utility/blob/main/mediawiki_backup/mediawiki_backup.sh).
