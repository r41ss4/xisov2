"""
Step 1: DB connection
    - Connect Python to MySQL
"""
# Import libs
import mysql.connector
from mysql.connector import Error
from typing import Any
# pip install mysql-connector-python

# Create connection
def create_connection(user_name: Any, user_password: Any, database: Any) -> Any | None:
    """ 
    Create connection to a db 
    Parameters:
        user_name(any): user name of the db
        user_password(any): password of db
        database(any): name of the database that wants to be use
    Return:
        Any | None
    """
    connection = None
    try:
        connection = mysql.connector.connect(
            user=user_name,
            passwd=user_password,
            db=database
        )
        #print("Connection to MySQL DB successful")
    except Error as e:
        print(f"The error '{e}' occurred")

    return connection

