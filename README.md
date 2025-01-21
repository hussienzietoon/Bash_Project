# Bash Project: Database Management System

## Overview
This project implements a simple database management system using Bash scripting. It provides functionality to create, manage, and manipulate databases and tables through a command-line interface. The project organizes data into directories and files, simulating a basic database system.

---

## Features

### Database Operations
1. **Create Database**
   - Prompts the user for a database name.
   - Validates the name format.
   - Creates a directory for the database if it doesn't already exist.

2. **List Databases**
   - Displays all available databases in the system.

3. **Connect to Database**
   - Allows the user to interact with a selected database.
   - Provides options for table operations, such as creating tables, inserting data, querying data, and more.

4. **Drop Database**
   - Deletes a specified database and its contents.

### Table Operations
1. **Create Table**
   - Prompts the user for a table name and column details.
   - The first column is designated as the primary key.
   - Saves the table structure in a file.

2. **List Tables**
   - Lists all tables within the connected database.

3. **Insert into Table**
   - Allows the user to insert data into a specified table.
   - Ensures the primary key is unique.

4. **Select from Table**
   - Provides options to:
     - View the entire table.
     - Search for rows by a specific value.
     - Retrieve data from a specific column.

5. **Delete from Table**
   - Options to delete:
     - All rows in a table.
     - Rows matching a specific value in a column.

6. **Update Table**
   - Replaces specified values in a table with new values.

---

## Directory Structure
- **`Database/`**: Root directory for all databases.
  - Each database is a subdirectory.
  - Tables are stored as files within their respective database directories.

---

## How to Run the Project
1. **Clone the Repository**
   ```bash
   git clone <repository_url>
   cd Bash_Project
   ```

2. **Make the Script Executable**
   ```bash
   chmod +x database_manager.sh
   ```

3. **Run the Script**
   ```bash
   ./database_manager.sh
   ```

---

## Usage
Upon running the script, you will be presented with a menu to:
1. Create a new database.
2. List existing databases.
3. Connect to a database to perform table operations.
4. Drop an existing database.
5. Exit the program.

### Example
#### Creating a Database
1. Select `Create Database`.
2. Enter a valid name.
3. If successful, the database is created.

#### Connecting to a Database
1. Select `Connect to Databases`.
2. Enter the database name.
3. Choose from options like creating a table, inserting data, or querying.

---

## Validation Rules
- **Database and Table Names**:
  - Must start with a letter or underscore.
  - Can contain letters, numbers, underscores, and hyphens.
  - No spaces or special characters allowed.

- **Primary Key**:
  - Must be unique.

---

## Error Handling
- Invalid input for database or table names is rejected with an error message.
- Attempts to create a database or table that already exists prompt the user to enter a different name.
- Selecting non-existent tables or databases provides appropriate error messages.

---

## Future Enhancements
- Add support for data types and constraints (e.g., integer, string, NOT NULL).
- Implement export/import functionality for databases.
- Add more complex querying capabilities.
- Enhance the UI for better usability.

---

## Author
**Hussien Zietoon**
- Email: [H.Zietoon10660@student.aast.edu](mailto:H.Zietoon10660@student.aast.edu)


