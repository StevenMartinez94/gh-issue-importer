# GitHub Issue Importer

A bash script that automates the creation of GitHub issues from a CSV file and adds them to a GitHub Project V2.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Permission to create issues in the target repositories
- A GitHub Project V2 set up

## Setup

1. **Install GitHub CLI** (if not already installed):
   ```bash
   # macOS
   brew install gh
   
   # Debian based
   sudo apt-get install gh

   # Arch Based
   sudo pacman -S github-cli
   ```

2. **Authenticate with GitHub CLI**:
   ```bash
   gh auth login
   ```

3. **Refresh authentication with project scope**:
   ```bash
   gh auth refresh -s project
   ```
   This grants the necessary permissions to add issues to projects.

## Configuration

1. **Create your `.env` file**:
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file** with your settings:
   ```bash
   OWNER="your-github-username"      # Your GitHub username
   PROJECT_ID="your-project-id"        # Your GitHub Project V2 ID
   CSV_FILE="filename.csv"           # Path to your CSV file
   # REPO_PREFIX is auto-derived from OWNER (optional)
   ```

**Finding your Project V2 ID:**
- Go to your project on GitHub
- The URL will be: `https://github.com/users/{owner}/projects/{id}`
- Copy the `{id}` value

## Running with Docker

No local `gh` install needed. Create `.env` (see Configuration) and run with a token that has `repo` and `project` scopes:

```bash
export GH_TOKEN=$(gh auth token)   # or any PAT with repo + project scopes
docker compose run --rm importer
```

The project directory is mounted into the container, so `CSV_FILE` is resolved relative to it.

## CSV Format

Create a `csv` file with the following format:

```csv
Title,Body,Repo
Visual identity,Brand colors / typography / iconography,ui-ux
Wireframes,Wireframes for all apps,ui-ux
High-fidelity prototype,Final UI/UX prototype,ui-ux
```

**Columns:**
- **Title**: The issue title
- **Body**: The issue description
- **Repo**: The repository name (will be prefixed with `REPO_PREFIX`)

> **Important:** Do not include commas in the CSV fields. The importer does not support commas inside double-quoted values, so a comma will be treated as a column separator even when enclosed in quotes.

## Usage

Run the script:

```bash
chmod +x import_issues.sh
./import_issues.sh
```

The script will:
1. Read each row from the CSV file
2. Create an issue in the specified repository
3. Add the created issue to your GitHub Project
4. Display progress and any errors

## Example Output

```
Starting GitHub Issue and Project Item creation...
Owner: stevenmartinez94
Project ID: 2

==================================================
Processing: "Visual identity" for repo: stevenmartinez94/ui-ux
Issue created successfully: https://github.com/stevenmartinez94/ui-ux/issues/3
Successfully added issue to project 2.

==================================================
Import summary
Successfully added issues (1):
  - "Visual identity" in stevenmartinez94/ui-ux (https://github.com/stevenmartinez94/ui-ux/issues/3)
Issues not added (0):
  None
```

## Troubleshooting

### "Error: CSV file not found"
- Ensure the CSV file exists in the same directory as the script
- Update `CSV_FILE` variable if using a different filename

### "ERROR: Failed to create issue"
- Verify the repository exists and you have permission to create issues
- Check that the `OWNER` and `Repo` values are correct

### "WARNING: Failed to add issue to project"
- Ensure your authentication token has the `project` scope:
  ```bash
  gh auth refresh -s project
  ```
- Verify the `PROJECT_ID` is correct

### "authentication token is missing required scopes [project]"
- Run: `gh auth refresh -s project`

## License

MIT
