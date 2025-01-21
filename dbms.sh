#!/bin/bash

# Function to create a new database
create_database() {
    read -p "Please enter the Database name: " name
    if [[ ! "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
        echo "Invalid database name. The name must start with a letter or underscore, and can contain letters, numbers, underscores, and hyphens only. No spaces or special characters allowed."
    else
        if [ -d "$DB_Dir/$name" ]; then
            echo "Database '$name' already exists. Please enter another name."
        else
            mkdir "$DB_Dir/$name"
            echo "Database '$name' created successfully."
        fi
    fi
}

# Function to list all databases
list_databases() {
    ls -F "$DB_Dir" | grep /
}

# Function to connect to a database
connect_to_database() {
    read -p "Please enter the Database name: " name
    if [[ ! "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
        echo "Invalid database name. The name must start with a letter or underscore, and can contain letters, numbers, underscores, and hyphens only. No spaces or special characters allowed."
    else
        if [ -d "$DB_Dir/$name" ]; then
            cd "$DB_Dir/$name"
            while true; do
                select secopt in "create table" "list table" "insert table" "select from table" "delete from table" "update from table" "exit"; do
                    case $secopt in
                        "create table")
                            read -p "Please enter the Table name: " table
                            if [[ ! "$table" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
                                echo "Invalid Table name. The name must start with a letter or underscore, and can contain letters, numbers, underscores, and hyphens only. No spaces or special characters allowed."
                            else
                                if [ -f "$DB_Dir/$name/$table" ]; then
                                    echo "Table '$table' already exists. Please enter another name."
                                else
                                    read -p "Please enter the number of columns: " col_num
                                    declare -a columns
                                    echo "Please note that the first column will be the primary key."
                                    for ((i=1; i<=col_num; i++)); do
                                        read -p "Please enter Column name: " col_name
                                        read -p "Please enter Column type: " col_type
                                        if [[ $i -eq 1 ]]; then
                                            columns+=("PK:$col_name:$col_type")
                                        else 
                                            columns+=("$col_name:$col_type")
                                        fi    
                                    done
                                    touch "$DB_Dir/$name/$table"
                                    table_structure=$(IFS=','; echo "${columns[*]}")
                                    echo "$table_structure" > "$DB_Dir/$name/$table"
                                    echo "Table '$table' created with structure: $table_structure"
                                fi
                            fi
                            ;;
                        "list table")
                            ls "$DB_Dir/$name"
                            ;;
                        "insert table")
                            read -p "Please enter the Table to insert into : " table
                            if [ -f "$DB_Dir/$name/$table" ]; then
                                structure=$(head -n 1 "$DB_Dir/$name/$table")
                                IFS=',' read -r -a columns <<< "$structure"
                              
                                echo "Enter values for the following columns:"
                                values=()
                                for column in "${columns[@]}"; do
                                    col_name=$(echo "$column" | cut -d':' -f1)  
                                    read -p "Please enter value for $col_name: " value
                                    if [[ "$column" == PK:* ]]; then
                                        # Check if the primary key value already exists in the table
                                        while grep -q "^$value," "$DB_Dir/$name/$table"; do
                                            echo "Error: The primary key value '$value' already exists. It must be unique."
                                            read -p "Please enter a new value for $col_name: " value
                                        done
                                    fi
                                    values+=("$value")
                                done

                                row=$(IFS=',' ; echo "${values[*]}" )

                                echo "$row" >> "$DB_Dir/$name/$table"
                                echo "Row inserted successfully."
                            else 
                                echo "Table not exist"                        
                            fi
                            ;;
                        "select from table")
                            read -p "Please enter the Table to select : " table
                            select secopt in "full_table" "by_column" "by_row"; do 
                                case $secopt in
                                    "full_table")
                                        cat "$DB_Dir/$name/$table"
                                        ;;
                                    "by_row")
                                        read -p "please enter the row you looking for : " searched_value
                                        matching_rows=$(tail -n +2 "$DB_Dir/$name/$table" | grep -w "$searched_value" )

                                        if [[ -n "$matching_rows" ]]; then
                                            echo "Rows matching '$searched_value':"
                                            echo "$matching_rows"
                                        else
                                            echo "No rows found containing '$searched_value'."
                                        fi
                                        ;;
                                    "by_column")
                                        read -p "please enter the column you looking for : " column_name

                                        header=$(head -n 1 "$DB_Dir/$name/$table")
                                        IFS=',' read -r -a columns <<< "$header"

                                        column_index=-1
                                        for ((i=0; i<${#columns[@]}; i++)); do 
                                            col_name=$(echo "${columns[$i]}" | cut -d':' -f1)
                                            if [[ "$col_name" == "$column_name" ]]; then
                                                column_index=$i
                                                break
                                            fi
                                        done

                                        if [[ $column_index -eq -1 ]]; then
                                            echo "Column '$column_name' not found in the table."
                                        else
                                            tail -n +2 "$DB_Dir/$name/$table" | awk -F',' -v idx=$((column_index+1))  '{print $idx}'
                                        fi
                                        ;;
                                    *)
                                        echo "Option not Valid"
                                        ;;
                                esac
                            done
                            ;;
                        "delete from table")
                            read -p "Please enter the Table name: " table
                            if [[ ! -f "$DB_Dir/$name/$table" ]]; then
                                echo "Table '$table' does not exist."
                            else
                                select secopt in "full_table" "by_column" "by_row" "exit"; do
                                    case $secopt in
                                        "full_table")
                                            read -p "Are you sure you want to delete all data in table '$table'? (y/n): " confirm
                                            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                                                head -n 1 "$DB_Dir/$name/$table" > "$DB_Dir/$name/$table.tmp" && \
                                                mv "$DB_Dir/$name/$table.tmp" "$DB_Dir/$name/$table"
                                                echo "All data in table '$table' has been deleted. Table structure remains intact."
                                            else
                                                echo "Operation canceled."
                                            fi
                                            ;;
                                        "by_column")
                                            read -p "Please enter the column you are looking for: " column_name

                                            header=$(head -n 1 "$DB_Dir/$name/$table")
                                            IFS=',' read -r -a columns <<< "$header"

                                            column_index=-1
                                            for ((i=0; i<${#columns[@]}; i++)); do 
                                                col_name=$(echo "${columns[$i]}" | cut -d':' -f1)
                                                if [[ "$col_name" == "$column_name" ]]; then
                                                    column_index=$i
                                                    break
                                                fi
                                            done

                                            if [[ $column_index -eq -1 ]]; then
                                                echo "Column '$column_name' not found in the table."
                                            else
                                                read -p "Please enter the value you want to delete in '$column_name': " value_to_delete

                                                awk -F',' -v col_idx=$((column_index+1)) -v value="$value_to_delete" \
                                                'BEGIN {OFS=","} $col_idx != value' \
                                                "$DB_Dir/$name/$table" > "$DB_Dir/$name/$table.tmp" && mv "$DB_Dir/$name/$table.tmp" "$DB_Dir/$name/$table"

                                                echo "Rows with value '$value_to_delete' in column '$column_name' deleted."
                                            fi
                                            ;;
                                        "by_row")
                                            read -p "Please enter the value you want to delete: " value_to_delete

                                            awk -F',' -v value="$value_to_delete" \
                                                'BEGIN {OFS=","} $0 !~ value' \
                                                "$DB_Dir/$name/$table" > "$DB_Dir/$name/$table.tmp" && \
                                            mv "$DB_Dir/$name/$table.tmp" "$DB_Dir/$name/$table"
                                            ;;    
                                        *)
                                            echo "Invalid option."
                                            ;;
                                    esac
                                done
                            fi
                            ;;
                        "update from table")
                            read -p "Please enter Table name: " table

                            if [[ ! -f "$DB_Dir/$name/$table" ]]; then
                                echo "Table '$table' does not exist."
                            else
                                read -p "Please enter the value you want to replace: " old_value
                                read -p "Please enter the new value: " new_value

                                awk -F',' -v old="$old_value" -v new="$new_value" '
                                BEGIN {OFS=","}
                                { 
                                    for (i=1; i<=NF; i++) {
                                        if ($i == old) {
                                            $i = new
                                        }
                                    }
                                    print
                                }
                                ' "$DB_Dir/$name/$table" > "$DB_Dir/$name/$table.tmp" && \
                                mv "$DB_Dir/$name/$table.tmp" "$DB_Dir/$name/$table"

                                echo "Value '$old_value' replaced with '$new_value' in table '$table'."
                            fi
                            ;;
                        "exit")
                            echo "Exiting database '$name'."
                            cd "$DB_Dir"
                            break 
                            ;;
                        *)
                            echo "Invalid option."
                            ;;
                    esac
                done
            done
        else
            echo "Database '$name' does not exist."
        fi
    fi
}

# Function to drop a database
drop_database() {
    read -p "Please enter the Database name: " name
    if [[ ! "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
        echo "Invalid database name. The name must start with a letter or underscore, and can contain letters, numbers, underscores, and hyphens only. No spaces or special characters allowed."
    else
        if [ -d "$DB_Dir/$name" ]; then
            rm -r "$DB_Dir/$name"
            echo "Database '$name' dropped successfully."
        else
            echo "No such database name."
        fi
    fi
}

# Main script
script_dir="$(cd "$(dirname "$0")" && pwd)"
DB_Dir="$script_dir/Database"

# Ensure the Database directory exists
if [ -d "$DB_Dir" ]; then
    cd "$DB_Dir"
else
    mkdir "$DB_Dir"
    cd "$DB_Dir"
fi

# Main menu
while true; do
    select option in "Create Database" "List Databases" "Connect To Databases" "Drop Database" "Exit"; do
        case $option in
            "Create Database")
                create_database
                ;;
            "List Databases")
                list_databases
                ;;
            "Connect To Databases")
                connect_to_database
                ;;
            "Drop Database")
                drop_database
                ;;
            "Exit")
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option."
                ;;
        esac
    done
done