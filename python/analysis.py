"""
Step 3: Return results as table
    - Transform data
    - Compute insights
"""
# Import libs
from queries import run_sql_file
from typing import Any

# Run user_balance.sql through function
def get_user_balance(connection: Any) -> Any:
    """
    Run user_balance.sql within python script
    Parameters:
        connection(any): pass connection to mysql
    Returns:
        any: query result of .sql
    """
    return run_sql_file(connection, "../db/05_analytics/user_balance.sql")

# Run user_balance.sql through function
def get_transaction_summary(connection: Any) -> Any:
    """
    Run transaction_summary.sql within python script
    Parameters:
        connection(any): pass connection to mysql
    Returns:
        any: query result of .sql
    """
    return run_sql_file(connection, "../db/05_analytics/transaction_summary.sql")