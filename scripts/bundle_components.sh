#!/bin/bash

# Check if we're in the correct directory
CURRENT_DIR=$(basename "$(pwd)")
if [ "$CURRENT_DIR" != "scripts" ]; then
    echo "Error: This script must be run from its location in fluf_core_components/scripts"
    exit 1
fi

# Check if version is provided as parameter
if [ -z "$1" ]; then
    echo "Error: Version parameter is required in format x.x.x (e.g., 1.2.3)"
    exit 1
fi

# Validate version format (x.x.x)
if ! [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in the format x.x.x (e.g., 1.2.3)"
    exit 1
fi
VERSION="$1"
echo "Using version: $VERSION"

# Define base paths
BASE_DIR=".."  # Relative to script location
ARCHIVES_DIR="$BASE_DIR/archives"
LATEST_DIR="$BASE_DIR/latest"
SOURCE_DIR="$BASE_DIR/components"  # Now relative to the script location

# Create necessary directories
mkdir -p "$ARCHIVES_DIR"
mkdir -p "$LATEST_DIR"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# If there's an existing latest version, archive it and remove latest directory
if [ -f "$LATEST_DIR/manifest.json" ]; then
    OLD_VERSION=$(jq -r '.version' "$LATEST_DIR/manifest.json")
    if [ ! -z "$OLD_VERSION" ]; then
        mv "$LATEST_DIR" "$ARCHIVES_DIR/$OLD_VERSION"
    fi
fi

# Remove latest directory if it exists and create a fresh one
rm -rf "$LATEST_DIR"
mkdir -p "$LATEST_DIR"

# Create a fresh manifest file with current timestamp
cat > "$LATEST_DIR/manifest.json" << EOF
{
    "version": "$VERSION",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%S") UTC",
    "components": []
}
EOF

# Loop through all directories in the source directory
for brick_dir in "$SOURCE_DIR"/*/ ; do
    if [ -d "$brick_dir" ]; then
        brick_name=$(basename "$brick_dir")
        echo "Bundling brick: $brick_name"
        
        # Bundle the brick
        mason bundle "$brick_dir" -o "$LATEST_DIR"
        
        if [ $? -eq 0 ]; then
            echo "Successfully bundled $brick_name"
            # Add component to manifest
            tmp=$(mktemp)
            jq ".components += [\"$brick_name\"]" "$LATEST_DIR/manifest.json" > "$tmp" && mv "$tmp" "$LATEST_DIR/manifest.json"
        else
            echo "Error bundling $brick_name"
        fi
    fi
done

# Keep only the last 5 archives (adjust number as needed)
cd "$ARCHIVES_DIR"
ls -t | tail -n +6 | xargs -r rm -rf

echo "Bundling complete!"
echo "New version created: $VERSION"
echo "Bundles available in: $LATEST_DIR"
