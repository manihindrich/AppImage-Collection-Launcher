#!/bin/bash

# Enter the path to the directory with the .AppImage files
APPIMAGE_DIR="/home/mani/Apps"

# - - - - - - - - - - - - - - - - -

# Dir check
echo "=== START TROUBLESHOOTING ==="
echo "The specified directory: $APPIMAGE_DIR"

if [[ -z "$APPIMAGE_DIR" ]]; then
    echo "Error: The directory is empty."
    echo "=== END TROUBLESHOOTING ==="
    exit 1
fi

if [[ ! -d "$APPIMAGE_DIR" ]]; then
    echo "Error: '$APPIMAGE_DIR' is not a valid directory."
    echo "=== END TROUBLESHOOTING ==="
    exit 1
fi

echo "Directory exists: $APPIMAGE_DIR"

# AppImage files process
echo "I'm looking for .AppImage files in the directory: $APPIMAGE_DIR"
mapfile -t files < <(find "$APPIMAGE_DIR" -maxdepth 1 -type f -name "*.AppImage")

for file in "${files[@]}"; do
  echo "$file" | sed -E 's|.*/([^/_]*)_.*|\1|' 
done > /tmp/appimage_list.txt

echo "Files found: ${#files[@]}"
if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .AppImage files were found in the '$APPIMAGE_DIR' directory."
    echo "=== END TROUBLESHOOTING ==="
    exit 1
fi

# Terminal window with application selection
tilix -e bash -c "
    echo 'In $APPIMAGE_DIR are these AppImages:'
    echo ''
    cat -n /tmp/appimage_list.txt
    echo ''
    read -p 'Enter the number of the AppImage you want to run: ' choice
    echo \$choice > /tmp/appimage_choice.txt
"

# Load the value into a variable in the main script
choice=$(cat /tmp/appimage_choice.txt)
echo "Selection entered: $choice"

# Check if the input is valid
if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Error: '$choice' is not a valid number."
    echo "=== END TROUBLESHOOTING ==="
    exit 1
fi

if ((choice < 1 || choice > ${#files[@]})); then
    echo "Error: The number entered is not in the range of available applications."
    echo "=== END TROUBLESHOOTING ==="
    exit 1
fi

# Run selected .AppImage
app="${files[choice-1]}"
echo "Run: $app"
"$app" &

# Cleaning and exit
rm /tmp/appimage_list.txt /tmp/appimage_choice.txt
echo "Application started. Temp files removed. Closing the script."
sleep 2
echo "=== END TROUBLESHOOTING ==="
exit
