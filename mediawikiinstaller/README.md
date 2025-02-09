```markdown
# MediaWiki Installer

This project provides an automated Bash script for installing MediaWiki on Linux systems (especially Debian/Ubuntu-based distributions). The script automates the installation, configuration, and (optionally) Let's Encrypt SSL certificate setup on a LAMP (Linux, Apache, MySQL, PHP) stack.

---

## Features

- **System Update:**
  - Updates the system packages using `apt update` and `apt upgrade`.

- **LAMP Stack Installation:**
  - Installs Apache, MySQL, and PHP (version 8.1) along with necessary modules (mbstring, curl, xml, zip, gd, intl, apcu).

- **Database Setup:**
  - Creates a database using provided information.
  - Creates a database user with appropriate permissions.

- **MediaWiki Installation:**
  - Downloads the specified version (e.g., 1.43.0) of MediaWiki from the official Wikimedia servers.
  - Extracts the files to `/var/www/html/mediawiki`.
  - Backs up any existing MediaWiki installation if present.

- **Apache Configuration:**
  - Creates a new VirtualHost configuration file for Apache.
  - Tests and reloads the Apache configuration.
  - Enables the Apache `rewrite` module.

- **SSL Certificate Installation (Optional):**
  - Installs a Let's Encrypt SSL certificate via Certbot if the user opts in.

- **Non-Interactive Mode:**
  - Use the `-y` flag to run the script non-interactively with default values.

- **Logging and Error Handling:**
  - Logs all operations to `/var/log/mediawiki_install.log`.
  - Provides detailed error messages and safe termination in case of errors.

---

## Pre-requisites and Warnings

- **System:**
  - Designed for Debian/Ubuntu-based Linux distributions.

- **Permissions:**
  - Requires `sudo` privileges for some operations, including package installations and configuration changes.
  - Ensure proper permissions for creating and writing to the log file.

- **Security:**
  - Handles sensitive information like database passwords from the command line.
  - Using default passwords in non-interactive mode is not recommended for production environments.

- **Testing:**
  - It is strongly recommended to test the script in a staging environment before deploying in production.

---

## Installation and Usage

Ensure that all required dependencies (e.g., `lsb_release`, `mysqladmin`, `wget`, `tar`, `sudo`, `apache2ctl`, and optionally `certbot`) are installed on your system.

### One-liner Installation and Execution

Run the following command in your terminal to download and execute the script in a single command:

```bash
curl -s https://raw.githubusercontent.com/snipeTR/linux_utility/main/mediawikiinstaller/mediawiki-installer.sh | sudo bash
```

Alternatively, using `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/snipeTR/linux_utility/main/mediawikiinstaller/mediawiki-installer.sh | sudo bash
```

> **Note:** The `sudo` command is required for the operations performed by the script.

### Manual Download and Execution

1. **Download the Script:**

   ```bash
   wget https://raw.githubusercontent.com/snipeTR/linux_utility/main/mediawikiinstaller/mediawiki-installer.sh
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x mediawiki-installer.sh
   ```

3. **Execute the Script:**

   ```bash
   sudo ./mediawiki-installer.sh
   ```

   To run the script in non-interactive mode (using default values), use the `-y` flag:

   ```bash
   sudo ./mediawiki-installer.sh -y
   ```

---

## How It Works

1. **System Information and User Input:**
   - The script determines the operating system and sets versions for PHP and MediaWiki.
   - It collects input for the database name, user, password, database host, and server domain.

2. **Dependency Checks:**
   - It verifies that all necessary commands and packages are available on the system.

3. **System Update and LAMP Stack Installation:**
   - The system is updated, and required packages for Apache, MySQL, and PHP are installed.

4. **Database Configuration:**
   - The database is created, and a user with the appropriate permissions is set up.

5. **MediaWiki Installation:**
   - The script downloads the MediaWiki tarball, extracts it to the specified directory, and backs up any existing installation.

6. **Apache Configuration:**
   - A new Apache VirtualHost configuration is created, tested, and applied.
   - The Apache rewrite module is enabled.

7. **SSL Certificate Installation (Optional):**
   - If opted, Certbot is used to install a Let's Encrypt SSL certificate.

8. **Final Check and Summary:**
   - A summary of the installation, including access URL and database information, is displayed.

---

## Contributing

Contributions are welcome! Please use the [issue tracker](https://github.com/snipeTR/linux_utility/issues) and [pull requests](https://github.com/snipeTR/linux_utility/pulls) on GitHub to report bugs, suggest features, or submit improvements.

---

## License

This project is open-source. For more details, refer to the [LICENSE](LICENSE) file.

---

## Contact

For questions or suggestions, feel free to reach out to [snipeTR](https://github.com/snipeTR) on GitHub.

---

This README provides detailed information on the script’s functionality and installation process. In case of any issues, please consult the log file located at `/var/log/mediawiki_install.log` for further details.
```
