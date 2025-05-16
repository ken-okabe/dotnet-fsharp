# Firebase Studio F# Starter Kit

![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1747377487362.png)

![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1747377989906.png)

This starter kit aims to provide a robust and smooth out-of-the-box F# experience on Google Firebase Studio. Happy  F# coding!

### What is Firebase Studio? (For Beginners)

Firebase Studio is a development platform provided on Google Cloud, differing from traditional methods where you set up an environment on your local computer.

All you need is a web browser to access it from anywhere and start building full-featured applications online, without complex local setup.

Furthermore, the development interface in Firebase Studio offers an experience very similar to Visual Studio Code (VS Code), an editor widely used by many developers. This is because Firebase Studio is built upon "Code - OSS," the open-source project that forms the foundation of VS Code.

Familiarity gained with operations in Firebase Studio will be highly transferable and beneficial should you use VS Code in a local environment in the future.

## Rocket Start for F# Development Environment

Welcome! This repository is a starter kit designed to help you quickly and smoothly set up an F# development environment within Firebase Studio (which is based on Project IDX).

One of the great advantages of Firebase Studio is that once your environment is set up, subsequent workspace launches are remarkably fast. While the initial workspace creation might take a few minutes to provision tools and run initial configurations, you'll be able to resume your development very quickly in future sessions.

This platform is a powerful cloud-based development environment. However, especially with .NET-based languages like C# and F#, extensions can sometimes be a bit tricky during initial setup due to activation timing. This starter kit is engineered to overcome these initial hurdles, allowing you to dive into a pleasant F# development experience right away.

## 🚀 Getting Started

### 0. https://firebase.studio/

![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1747378995760.png)

### 1.  **Import this Repository into Firebase Studio:**

### `https://github.com/ken-okabe/dotnet-fsharp`

On the Firebase Studio workspace creation screen, select the "Import a repository" option and provide the Git repository URL for this starter kit.

![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1747379628566.png)

![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1747379808132.png)

### 2.  **Wait for Initial Workspace Creation:**

![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1747379994030.png)

An initialization script, configured in the `onCreate` hook, will run automatically. This script installs necessary extensions, creates a sample F# project (`HelloApp`), and writes some initial code. This process might take a few minutes. You may be able to see the script's progress in the IDX terminal or logs (look for messages prefixed with `[WorkspaceSetupScript]`).

![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1747380083771.png)

### 3.  **Start Developing:**

![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1747380163450.png)

Once the initialization script is complete, `HelloApp/Program.fs` should open in the editor, and you should have full F# language support from Ionide (the F# extension), including type annotations and code completion.

## ✨ What it Does (The "Magic" Explained)

This starter kit leverages Firebase Studio's environment definition capabilities and initialization scripts to optimize your F# development setup.

* **Environment Definition (`.idx/dev.nix`):**
    Provides the base .NET SDK. (Note: In this kit, VS Code extensions are primarily installed by the script for better control over timing and to work around potential activation issues.)

* **Initialization Script (e.g., `.idx/setup_workspace.sh`):**
    This script runs once when the workspace is created (via the `onCreate` hook in `dev.nix`) and performs the following actions sequentially:
    1.  **Installs the C# Extension:** Provides fundamental .NET support that F# (Ionide) relies on. (The script currently uses `muhammad-sammy.csharp` as identified in the working environment, but you can switch to `ms-dotnettools.csharp` (Microsoft official) if preferred, by editing the script.)
        * The `.NET Runtime Support` extension (`ms-dotnettools.vscode-dotnet-runtime`) is expected to be installed automatically as a dependency of the C# extension.
    2.  **Installs the F# (Ionide) Extension:** Provides comprehensive language support for F#.
    3.  **Creates a Sample Project:** Generates a simple F# console application named `HelloApp`.
    4.  **Writes Initial Code:** Populates `HelloApp/Program.fs` with some basic F# code.
    5.  **Opens `Program.fs`:** Opens the newly created file in the editor.
    6.  **Waits for Timing Adjustment & Re-focuses File:** This is the "secret sauce" of this kit! .NET extensions (especially OmniSharp, used by C#, and Ionide for F#) can take some time for all their background services to fully initialize. Opening an F# file too soon can lead to Ionide not recognizing the project context correctly. Therefore, the script introduces a deliberate delay *after* initially opening the file and then re-focuses (re-opens) the file. This "nudge" helps ensure Ionide properly "catches" the project context after dependent services have had more time to settle.

![image](https://raw.githubusercontent.com/ken-okabe/web-images5/main/img_1747380466527.png)

## 🔧 Key Extensions Installed (by script)

* **C# for Visual Studio Code** (This kit uses `muhammad-sammy.csharp` by default, as per the debugging journey) - Provides base .NET project support, often via OmniSharp.
* **Ionide-fsharp** - Comprehensive language support for F# (autocompletion, type hints, error checking, etc.).
* _(.NET Runtime Extension (`ms-dotnettools.vscode-dotnet-runtime`) - Expected to be auto-installed as a C# extension dependency)_

## 🤔 Troubleshooting / Notes

* **If Ionide doesn't recognize the project immediately:**
    * Even with the script, if you encounter issues after it completes (e.g., no type annotations), try running the "Developer: Reload Window" command from the command palette (Ctrl+Shift+P or Cmd+Shift+P).
    * Check the "OUTPUT" panel in Firebase Studio. Look for logs from channels like "F#," "Ionide," "OmniSharp Log," or "C#" for any error messages or detailed information.
* **Script Wait Times:**
    The wait times in the script (e.g., `POST_OPEN_WAIT_SECONDS`) are tuned based on observations during the creation of this kit. Depending on your network or the specific IDX instance performance, you might need to adjust them slightly in the script.
* **`idx.extensions` in `dev.nix`:** Remember that if you use this script to manage these core .NET extensions, you should remove/comment them out from the `idx.extensions` list in your `dev.nix` file to avoid conflicts.

## 🔗 Reference Links

* **Firebase Studio Official Documentation:** [https://firebase.google.com/docs/studio](https://firebase.google.com/docs/studio)
* **Ionide Official Website:** [http://ionide.io/](http://ionide.io/)
* **F# Software Foundation:** [https://fsharp.org/](https://fsharp.org/)

---