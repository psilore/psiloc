#!/bin/bash

# VS Code Settings Export Script
# This script exports your VS Code settings to a backup directory
GIT_ROOT_DIR=$(git rev-parse --show-toplevel)
BACKUP_DIR="$GIT_ROOT_DIR/config/vscode/settings"
VSCODE_USER_DIR="$HOME/.config/Code/User"

# Check if VS Code user directory exists
if [ ! -d "$VSCODE_USER_DIR" ]; then
    echo "Error: VS Code user directory not found at $VSCODE_USER_DIR"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "Exporting VS Code settings to: $BACKUP_DIR"

# Copy main settings files
cp "$VSCODE_USER_DIR/settings.json" "$BACKUP_DIR/" 2>/dev/null && echo "✓ Exported settings.json" || echo "⚠ settings.json not found"
cp "$VSCODE_USER_DIR/keybindings.json" "$BACKUP_DIR/" 2>/dev/null && echo "✓ Exported keybindings.json" || echo "⚠ keybindings.json not found"
cp "$VSCODE_USER_DIR/tasks.json" "$BACKUP_DIR/" 2>/dev/null && echo "✓ Exported tasks.json" || echo "⚠ tasks.json not found"

# Copy snippets directory if it exists
if [ -d "$VSCODE_USER_DIR/snippets" ]; then
    cp -r "$VSCODE_USER_DIR/snippets" "$BACKUP_DIR/"
    echo "✓ Exported snippets directory"
else
    echo "⚠ snippets directory not found"
fi

# Get list of installed extensions
code --list-extensions > "$BACKUP_DIR/extensions.txt" 2>/dev/null && echo "✓ Exported extensions list" || echo "⚠ Could not export extensions list"

echo ""
echo "VS Code settings exported successfully!"
echo "Backup location: $BACKUP_DIR"
echo ""
echo "To restore on another machine:"
echo "1. Copy the files back to your VS Code User directory"
echo "2. Install extensions: cat extensions.txt | xargs -n 1 code --install-extension"