# 📊 Scheduled Daily Report Pipeline

## Project Overview

This project is a Python-based data pipeline designed to run daily via **Windows Task Scheduler**. Its purpose is to automate a routine reporting task:
1.  Connect to a local **SQLite database** (`DB_PATH`).
2.  Execute a predefined **SQL query** (`sql_queries/airway_hold_status.sql`).
3.  Load the results into a **Pandas DataFrame**.
4.  Upload the final data to a specific tab in a **Google Sheet** using the Sheets API.

---

## 🚀 Getting Started

### 1. Prerequisites

Ensure the following tools are installed and accessible on your system:

* **Python 3.8+**
* **Git** (for cloning)
* **uv** (for dependency and environment management)
* A **Google Cloud Project** with the Google Sheets API enabled.
* A **Service Account Key** (JSON file) for API authentication.

### 2. Setup and Installation

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/USERNAME/REPO-NAME.git](https://github.com/nicholas-pds/airway_hold_status.git)
    cd REPO-NAME
    ```

2.  **Install Dependencies:**
    This command creates the virtual environment and installs all required packages (`pandas`, `python-dotenv`, `gspread`, `oauth2client`).

    ```bash
    uv init
    uv add pandas python-dotenv gspread oauth2client
    uv sync
    ```

---

## ⚙️ Configuration

### 1. `.env` File

Create a file named **`.env`** in the root directory and populate it with your confidential configuration details:

```ini
# Database Configuration (SQLite)
DB_PATH=data/my_local_db.sqlite

# Google Sheets API Authentication
# The path to your downloaded service account JSON key file
GOOGLE_CREDENTIALS_PATH=credentials/google_sheets_service_account.json

# Google Sheet Configuration
# The unique ID of the target spreadsheet
GOOGLE_SHEET_ID=1ABC-xyz-GHI-pqr-789-uvw