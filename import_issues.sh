#!/bin/bash

# --- Load Configuration from .env file ---
if [ ! -f ".env" ]; then
    echo "Error: .env file not found."
    echo "Please create a .env file. You can copy from .env.example:"
    echo "  cp .env.example .env"
    exit 1
fi

# Source the .env file
set -a
source .env
set +a

# Validate required variables
for var in OWNER PROJECT_ID CSV_FILE; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set in .env file."
        exit 1
    fi
done

# Auto-generate REPO_PREFIX from OWNER if not set
if [ -z "$REPO_PREFIX" ]; then
    REPO_PREFIX="${OWNER}/"
fi

echo "Starting GitHub Issue and Project Item creation..."
echo "Owner: $OWNER"
echo "Project ID: $PROJECT_ID"
echo "CSV File: $CSV_FILE"
echo "Repo Prefix: $REPO_PREFIX"

# Check if the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file '$CSV_FILE' not found."
    exit 1
fi

# Read the CSV file, skipping the header (tail -n +2)
tail -n +2 "$CSV_FILE" | while IFS=, read -r TITLE_IN BODY_IN REPO_IN; do
    
    # Use 'xargs' to trim leading/trailing whitespace
    TITLE=$(echo "$TITLE_IN" | xargs)
    BODY=$(echo "$BODY_IN" | xargs)
    REPO=$(echo "$REPO_IN" | xargs)

    # Construct the full repository name (e.g., ghusername/client-app)
    FULL_REPO="${REPO_PREFIX}${REPO}"

    echo ""
    echo "=================================================="
    echo "Processing: \"$TITLE\" for repo: $FULL_REPO"

    # 1. Create the GitHub Issue
    ISSUE_URL=$(gh issue create \
        --repo "$FULL_REPO" \
        --title "$TITLE" \
        --body "$BODY" \
        2>/dev/null) # Suppress standard error for a clean capture

    # Check the exit status of the previous command
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to create issue \"$TITLE\" in $FULL_REPO. Check if the repo exists."
        continue
    fi
    
    echo "Issue created successfully: $ISSUE_URL"

    # 2. Add the created issue to the GitHub Project (V2)
    gh project item-add "$PROJECT_ID" \
        --owner "$OWNER" \
        --url "$ISSUE_URL"
    
    if [ $? -ne 0 ]; then
        echo "WARNING: Failed to add issue $ISSUE_URL to project $PROJECT_ID. Manual intervention may be required."
    else
        echo "Successfully added issue to project $PROJECT_ID."
    fi

done

echo ""
echo "=================================================="
echo "Script finished. Review the output for any errors or warnings."