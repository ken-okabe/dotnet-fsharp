#!/bin/bash

# --- Configuration ---
RUNTIME_EXT_ID="ms-dotnettools.vscode-dotnet-runtime"
CSHARP_EXT_ID="muhammad-sammy.csharp" # The C# extension currently identified in your environment
FSHARP_EXT_ID="ionide.ionide-fsharp"
NEW_FSHARP_PROJECT_NAME="ScriptedFSharpConsoleApp" # Name for the new F# project

# Commands in IDX environment (adjust if necessary)
INSTALL_CMD="code --install-extension"
LIST_CMD="code --list-extensions"
OPEN_CMD="code" # Command to open a file in the editor.
DOTNET_CMD="dotnet" # Command for dotnet CLI

# Polling settings
POLL_INTERVAL_SECONDS=5
MAX_ATTEMPTS=36 # Approx. 3 minutes (36 * 5s)

# Logging function
log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WorkspaceSetupScript] $1"
}

# Function to check if an extension is listed
is_extension_listed() {
  local ext_to_check="$1"
  if $LIST_CMD | grep -qF "$ext_to_check"; then
    return 0 # Exists
  else
    return 1 # Does not exist
  fi
}

# Function to install and poll for an extension
install_and_poll_extension() {
  local ext_id_to_install="$1"
  local ext_friendly_name="$2"

  if is_extension_listed "$ext_id_to_install"; then
    log_message "$ext_friendly_name ($ext_id_to_install) is already listed. Skipping installation."
    return 0
  fi

  log_message "Installing $ext_friendly_name ($ext_id_to_install)..."
  $INSTALL_CMD "$ext_id_to_install"

  log_message "Polling for $ext_friendly_name ($ext_id_to_install) to be listed..."
  local attempts=0
  until is_extension_listed "$ext_id_to_install"; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge "$MAX_ATTEMPTS" ]; then
      log_message "Error: $ext_friendly_name ($ext_id_to_install) was not listed after $MAX_ATTEMPTS attempts."
      log_message "Aborting further operations. Please check logs and installed extensions."
      return 1 # Failed
    fi
    log_message "Attempt $attempts/$MAX_ATTEMPTS: $ext_friendly_name ($ext_id_to_install) not yet listed. Waiting $POLL_INTERVAL_SECONDS seconds..."
    sleep "$POLL_INTERVAL_SECONDS"
  done
  log_message "$ext_friendly_name ($ext_id_to_install) is now listed."
  return 0 # Succeeded
}

# --- Main process ---
log_message "Starting workspace setup sequence (triggered by onCreate)..."

# 0. IMPORTANT: From your .idx/dev.nix file's idx.extensions list,
#    remove or comment out the extension IDs that are managed by this script.

# 1. Install & poll for .NET Runtime extension
install_and_poll_extension "$RUNTIME_EXT_ID" ".NET Runtime"
if [ $? -ne 0 ]; then log_message "Failed to ensure $RUNTIME_EXT_ID installation. Exiting."; exit 1; fi

# 2. Install & poll for C# extension
install_and_poll_extension "$CSHARP_EXT_ID" "C#"
if [ $? -ne 0 ]; then log_message "Failed to ensure $CSHARP_EXT_ID installation. Exiting."; exit 1; fi

# 3. Install & poll for F# (Ionide) extension
install_and_poll_extension "$FSHARP_EXT_ID" "F# (Ionide)"
if [ $? -ne 0 ]; then log_message "Failed to ensure $FSHARP_EXT_ID installation. Exiting."; exit 1; fi

log_message "All three core extensions (.NET Runtime, C#, F#) are now listed."

# 4. Create a new F# console project if it doesn't exist
PROJECT_PATH="./$NEW_FSHARP_PROJECT_NAME" # Create in the workspace root
PROGRAM_FS_PATH="$PROJECT_PATH/Program.fs"

if [ ! -d "$PROJECT_PATH" ]; then
  log_message "Project directory '$PROJECT_PATH' does not exist. Creating new F# console project..."
  $DOTNET_CMD new console -lang "F#" -o "$PROJECT_PATH"
  if [ $? -ne 0 ]; then
    log_message "Error: Failed to create F# console project in '$PROJECT_PATH'."
    log_message "Please check .NET SDK installation and permissions."
    exit 1
  fi
  log_message "F# console project '$NEW_FSHARP_PROJECT_NAME' created successfully."
else
  log_message "Project directory '$PROJECT_PATH' already exists. Skipping project creation."
fi

# 5. Open the Program.fs file from the new project
if [ -f "$PROGRAM_FS_PATH" ]; then
  log_message "Attempting to open '$PROGRAM_FS_PATH' in the editor..."
  $OPEN_CMD "$PROGRAM_FS_PATH"
else
  log_message "Warning: '$PROGRAM_FS_PATH' not found. Cannot open it. Project creation might have failed or the path is incorrect."
fi

log_message "Workspace setup script finished."
log_message "IMPORTANT: This script attempts to replicate the successful manual workflow."
log_message "If Ionide still has issues, further debugging of Ionide's logs or a 'Developer: Reload Window' might be necessary."

exit 0