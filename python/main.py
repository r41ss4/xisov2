"""
Step 4: Call and execute everything
    - Call everything
    - Define workflow
"""
# Import libs
import pandas as pd
from analysis import get_user_balance, get_transaction_summary
from db import create_connection

# Connect to db
connection = create_connection("root", "", "xiso_staging")
print("Connection to MySQL DB successful")

# Apply get_user_balance from analysis
df_user = pd.DataFrame(get_user_balance(connection))

# Apply get_user_balance from analysis
df_trans = pd.DataFrame(get_transaction_summary(connection))

# Force print of results df_user
print("\n--- USER BALANCE ---")
print(df_user)

# Force print of results df_trans
print("\n--- TRANSACTION SUMMARY ---")
print(df_trans)