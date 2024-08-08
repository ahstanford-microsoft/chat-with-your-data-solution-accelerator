#!/bin/bash

echo "Starting local development environment setup..."

# Troubleshooting intro message
echo "Before proceeding, ensure:"
echo "- You have installed bash and a bash distribution on your system as an elevated user (eg. Ran 'wsl --install', 'winget install Microsoft.WSL' on windows command line prompt being 'Run as Administrator')."
echo "- Latest code from the main branch is synced."
echo "- You must select a supported Azure region (e.g., northcentralus) for the gpt-35-turbo-16k 0613 model."
echo "- The new Azure resource name you create must be 20 characters or less."
echo "- You need to be using Python 3.11 (eg. winget install -e --id Python.Python.3.11 --scope machine)."
read -p "Continue? (yes/no): "

# Capture user input
read user_choice

# Check user input
if [[ $user_choice != "yes" && $user_choice != "y" && $user_choice != "Y" ]]; then
    echo "Please make the necessary changes and run the script again."
    exit 1
fi

echo "Proceeding with the setup..."

# Section 1: Install Azure command line tools, if not yet installed.

if ! command azd version &> /dev/null; then
    echo "Azure Developer CLI is not yet installed. Installing..."
    winget install microsoft.azd
fi # Installs Developer CLI (azd) if not installed

# Check if Azure CLI (az) is installed
if ! command az --version &> /dev/null; then
    echo "Azure CLI is not yet installed. Installing..."
    winget install -e --id Microsoft.AzureCLI
fi

# Section 2: Navigate to the 'chat-with-your-data-solution-accelerator' folder

echo "Searching for 'chat-with-your-data-solution-accelerator' folder..."

# Function to search for the folder in the current and surrounding directories
find_and_cd() {
    local search_paths=("" "../" "../../" "./*/" "../*/")
    for path in "${search_paths[@]}"; do
        if [[ -d "${path}chat-with-your-data-solution-accelerator" ]]; then
            echo "Found 'chat-with-your-data-solution-accelerator' at ${path}"
            cd "${path}chat-with-your-data-solution-accelerator"
            return 0
        fi
    done
    return 1
}

# Attempt to find and change directory
if ! find_and_cd; then
    echo "Warning: 'chat-with-your-data-solution-accelerator' folder not found."
    read -p "Do you want to proceed anyway? (yes/no): " user_choice

if [[ $user_choice != "yes" && $user_choice != "y" && $user_choice != "Y" ]]; then
        echo "Please navigate to inside 'chat-with-your-data-solution-accelerator' and run the script again."
        exit 1
    fi
else
    echo "Successfully navigated to 'chat-with-your-data-solution-accelerator'."
fi

# Section 3: Create Environment Dependencies

echo "Logging into Azure DevOps..."
echo "Please authenticate in the window that opens. Return to this terminal and press any key to continue once authentication is complete."

azd auth login  # enter contoso credentials

read -p "Press any key to confirm authentication is complete and continue..."

echo "Creating infrastructure..."

if azd up --debug; then  # creates infrastructure (when naming, include cwyd-<yourname>)
    echo "Infrastructure created successfully."

    # Section 3.1: Copy .env file created by azure to the current directory

    echo "Locating and copying .env file from the .azure directory..."

    # Find the first directory inside .azure
    first_dir=$(find .azure -mindepth 1 -maxdepth 1 -type d | head -n 1)

    # Assuming .env is the first file in the found directory
    env_file=$(find "$first_dir" -name "*.env" | head -n 1)

    if [[ -f "$env_file" ]]; then
        echo "Found .env file: $env_file"
        cp "$env_file" ./
        echo ".env file copied successfully to the current directory."
    else
        echo "No .env file found in the .azure directory."
    fi

    # Section 4: Install Python Dependencies
    echo "Upgrading pip..."
    pip install --upgrade pip

    echo "Installing poetry..."
    pip install poetry

    echo "Exporting dependencies to requirements.txt..."
    poetry export -o requirements.txt

    echo "Installing dependencies from requirements.txt..."
    pip install -r requirements.txt

    cd code/backend

    # Section 3: Run the Application
    echo "Setting environment variables..."
    azd env set AZURE_AUTH_TYPE rbac
    azd env set USE_KEY_VAULT false

    echo "Launching the application..."
    streamlit run Admin.py --server.port 80 --server.enableXsrfProtection false

    echo "Local development environment is ready."
else
    echo "Error encountered during infrastructure creation."
    echo "Please verify you are synced to the latest code, name your resource in less than 20 characters, and select a region (useast, useast2, uksouth) that supports gpt-35-turbo-16k 0613."

    # Check if the .azure folder exists
    if [ -d ".azure" ]; then
        read -p "Do you want to delete the .azure folder and try again? (yes/no): " user_choice

        if [[ $user_choice == "yes" ]]; then
            echo "Deleting the .azure folder..."
            rm -rf .azure
            echo ".azure folder deleted. You can now try running the script again. Reminder: "
        else
            echo "The .azure folder was not deleted. Please delete the .azure folder manually and delete any azure resources created before trying again."
        fi
    else
        echo "The .azure folder does not exist or has already been deleted."
    fi
fi
