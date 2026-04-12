"""
Step 2: Query runner
    - Execute queries
    - Return results
"""
# Import libs
from typing import Any
import mysql.connector
from mysql.connector import Error
# pip install mysql-connector-python

# Execute query
def execute_query(connection: Any, query: Any) -> None:
    """
    Execure queries when needed for INSERT, CREATE, etc.
    Parameters:
        connection(any): connection which must include user, password, db
        query(any): MySQL query to run in db
    Returns:
        None
    """
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        connection.commit()
        print("Query executed successfully")
    except Error as e:
        print(f"The error '{e}' occurred")   

# Fetch query for SELECT
def fetch_query(connection: Any, query: Any) -> Any:
    """
    Execure queries when needed for SELECT. Only works for 1 SELECT
    Parameters:
        connection(any): connection which must include user, password, db
        query(any): MySQL query to run in db
    Returns:
        None
    """
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        result = cursor.fetchall()
        return result
    except Error as e:
        print(f"The error '{e}' occurred")
        return None

# Run sql file through python 
def run_sql_file(connection: Any, path: Any) -> Any:
    """
    Use to run a sql file as query 
    Parameters:
        connection(any): connnection to mysql
        path(any): path to the .sql file to run
    Returns:
        any: Execution output of query
    """
    with open(path, "r") as file:
        query = file.read()
    return fetch_query(connection, query)