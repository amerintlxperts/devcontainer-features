#!/bin/bash
find . -type f -name "devcontainer-feature.json" -exec bash -c '
  for file; do
    # Extract the version number
    version=$(jq -r .version "$file")
    
    # Split the version into its components
    IFS="." read -r major minor patch <<< "$version"
    
    # Increment the patch version
    patch=$((patch + 1))
    
    # Create the new version string
    new_version="$major.$minor.$patch"
    
    # Use jq to update the version in the JSON file
    jq --arg new_version "$new_version" ".version = \$new_version" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    
    echo "Updated $file: $version -> $new_version"
  done
' bash {} +

