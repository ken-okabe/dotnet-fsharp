#!/bin/bash

# --- Configuration ---
RUNTIME_EXT_ID="ms-dotnettools.vscode-dotnet-runtime"
CSHARP_EXT_ID="muhammad-sammy.csharp" # The C# extension currently identified in your environment
FSHARP_EXT_ID="ionide.ionide-fsharp"
FILE_TO_OPEN_ON_COMPLETION="README.md" # File to open when the script completes

# Commands in IDX environment (adjust if necessary)
INSTALL_CMD="code --install-extension"
LIST_CMD="code --list-extensions"
OPEN_CMD="code" # Command to open a file in the editor. Check if 'code path/to/file' works.

# Polling settings
POLL_INTERVAL_SECONDS=5
MAX_ATTEMPTS=36 # Approx. 3 minutes (36 * 5s) - a bit longer as it's for three extensions

# Logging function
log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ExtensionSetupScript] $1"
}

# Function to check if an extension is listed
# Returns 0 if listed (true), 1 if not listed (false)
is_extension_listed() {
  local ext_to_check="$1"
  if $LIST_CMD | grep -qF "$ext_to_check"; then # -F for fixed string match, -q to suppress output
    return 0 # Exists (true)
  else
    return 1 # Does not exist (false)
  fi
}

# Function to install and poll for an extension
# Usage: install_and_poll_extension "extensionID" "DisplayNameForLog"
install_and_poll_extension() {
  local ext_id_to_install="$1"
  local ext_friendly_name="$2" # For log display

  # If already listed, skip installation (primarily for idempotency,
  # not necessarily to avoid multiple runs in onCreate which should ideally run once).
  if is_extension_listed "$ext_id_to_install"; then
    log_message "$ext_friendly_name ($ext_id_to_install) is already listed. Skipping installation."
    return 0
  fi

  log_message "Installing $ext_friendly_name ($ext_id_to_install)..."
  $INSTALL_CMD "$ext_id_to_install" # Consider adding --force if re-installation or specific versions are needed

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
log_message "Starting custom extension installation sequence (triggered by onCreate)..."

# 0. IMPORTANT: From your .idx/dev.nix file's idx.extensions list,
#    remove or comment out the extension IDs that are managed by this script
#    (i.e., $RUNTIME_EXT_ID, $CSHARP_EXT_ID, $FSHARP_EXT_ID).

# 1. Install & poll for .NET Runtime extension
install_and_poll_extension "$RUNTIME_EXT_ID" ".NET Runtime"
if [ $? -ne 0 ]; then # Check exit status of the function
  log_message "Failed to ensure $RUNTIME_EXT_ID installation. Exiting."
  exit 1
fi

# 2. Install & poll for C# extension
install_and_poll_extension "$CSHARP_EXT_ID" "C#"
if [ $? -ne 0 ]; then
  log_message "Failed to ensure $CSHARP_EXT_ID installation. Exiting."
  exit 1
fi

# 3. Install & poll for F# (Ionide) extension
install_and_poll_extension "$FSHARP_EXT_ID" "F# (Ionide)"
if [ $? -ne 0 ]; then
  log_message "Failed to ensure $FSHARP_EXT_ID installation. Exiting."
  exit 1
fi

log_message "All three core extensions (.NET Runtime, C#, F#) are now listed."

# 4. Open README.md (if the file exists)
if [ -f "$FILE_TO_OPEN_ON_COMPLETION" ]; then
  log_message "Attempting to open $FILE_TO_OPEN_ON_COMPLETION in the editor..."
  $OPEN_CMD "$FILE_TO_OPEN_ON_COMPLETION"
  # Check: Does $OPEN_CMD open the editor in the background and the script continues,
  # or does it wait until the editor is closed? Usually, it's the former.
else
  log_message "Warning: $FILE_TO_OPEN_ON_COMPLETION not found at the workspace root. Cannot open it."
fi

log_message "Custom extension installation and setup script finished successfully."
log_message "IMPORTANT: This script confirms that extensions are listed, not that they are fully activated and ready for use."
log_message "If Ionide still has issues recognizing your F# project, a 'Developer: Reload Window' might be necessary, or further debugging of Ionide's logs is required."

exit 0