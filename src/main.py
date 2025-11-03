# src/main.py
from pathlib import Path
# Use a relative import to get the function from the neighboring file in the src package
from .db_handler import execute_sql_to_dataframe

def main():
    """Main function to orchestrate the daily process."""
    
    # --- FIX: Dynamically determine the SQL file path ---
    # 1. Get the directory of the current file (src/)
    BASE_DIR = Path(__file__).parent
    # 2. Step UP one level to the project root (..) and navigate to sql_queries/
    # This finds: project_root/sql_queries/airway_hold_status.sql
    SQL_FILE_PATH = BASE_DIR.parent / "sql_queries" / "airway_hold_status.sql"
    # ---------------------------------------------------
    
    print(f"Attempting to load SQL file from: {SQL_FILE_PATH}")

    # Step 1: Connect to DB, run query, and get DataFrame
    print("Starting database operation...")
    
    try:
        # We pass the path as a string to the database handler function
        data_df = execute_sql_to_dataframe(str(SQL_FILE_PATH))
    except FileNotFoundError:
        print(f"🚨 ERROR: SQL file not found at the expected path: {SQL_FILE_PATH}")
        return # Exit the function if the file isn't found
    except Exception as e:
        print(f"🚨 ERROR during database operation: {e}")
        return

    if not data_df.empty:
        print("\n--- DataFrame Head ---")
        print(data_df.head())
        print("\n--- Next Step: Google Sheets API ---")
        
        # --- PLACEHOLDER FOR GOOGLE SHEETS UPLOAD ---
        # The function to upload your DataFrame will go here.
        # Example: upload_to_google_sheets(data_df, "My Report Sheet", "Data Tab")
        # --------------------------------------------
        
    else:
        print("Data extraction failed or returned an empty result. Stopping execution.")
        
if __name__ == "__main__":
    # Reminder: Run this from the project root using 'uv run python -m src.main'
    main()