# AppImage Collection Launcher
*Bash script to list, select, and run collection of `.AppImage` files quickly and simply. With error handling included.*

### Summary
The script performs several steps, from checking the directory to executing the selected `.AppImage` file. Throughout the process, emphasis is placed on input validation and error handling to ensure smooth operation.

## Use Case
I manage a large number of `.AppImage` files in my software collection, including various versions of applications, which I frequently update, remove, and add new ones. Manually integrating these applications to the OS is cumbersome, and I prefer not to spend any time searching for them.

## Features
- Searches for `.AppImage` files in a specified directory.
- Allows the user to select which `.AppImage` to run via a terminal interface.
- Validates the user's input to ensure it corresponds to an available file.
- Handles common errors such as missing directory or invalid file selection.

## Usage
1. Clone the repository or download the script.
2. Edit the `APPIMAGE_DIR` variable in the script to point to the directory containing your `.AppImage` files. (optional) Change the terminal application for selection.
3. Run the script `bash AppImage.sh`. (optional) I use keyboard shortcut and Script Menu ([more](https://cinnamon-spices.linuxmint.com/applets/view/185))
4. Select the .AppImage to run by entering the corresponding number.

## Requirements
- A bash terminal `tilix` (or a terminal emulator that supports `-e` option) to display the file list and interact with the user.

# Detail

This bash script is designed to search a specified directory for `.AppImage` files, allow the user to select one of these files, and then execute it. The script is divided into several logical sections, which I will explain.

### 1. **Defining the Variable and Initial Check**
```bash
APPIMAGE_DIR="/home/mani/Apps"
```
This variable defines the path to the directory where `.AppImage` files are located. The path is on my device `/home/mani/Apps`.

### 2. **Directory Existence Check**
```bash
echo "=== START TROUBLESHOOTING ==="
echo "Specified directory: $APPIMAGE_DIR"

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
```
- The script outputs a message indicating that the troubleshooting process is starting.
- First, it checks if the `APPIMAGE_DIR` variable is empty. If it is, the script outputs an error and exits.
- Next, it verifies that the specified directory exists. If it doesn't, an error is displayed, and the script terminates.
- If the directory is valid, the script proceeds to search for files.

### 3. **Searching for .AppImage Files**
```bash
echo "I'm looking for .AppImage files in the directory: $APPIMAGE_DIR"
mapfile -t files < <(find "$APPIMAGE_DIR" -maxdepth 1 -type f -name "*.AppImage")
```
- This section searches for all `.AppImage` files in the specified directory `APPIMAGE_DIR`.
- The `find` command is used with the `-maxdepth 1` option to search only within the specified directory (without checking subdirectories), and the `-name "*.AppImage"` option filters for files with the `.AppImage` extension.
- The search results are stored in the `files` array.

### 4. **Processing temporary list of Files**
```bash
for file in "${files[@]}"; do
  echo "$file" | sed -E 's|.*/([^/_]*)_.*|\1|' 
done > /tmp/appimage_list.txt
```
- This loop iterates over all the files found in the directory and uses `sed` to extract the file names. The pattern `s|.*/([^/_]*)_.*|\1|` means:
- Remove all parts of the file path from the last slash to the first underscore, leaving only the file name between these characters.
- The results are saved to the first temporary file `/tmp/appimage_list.txt`.

### 5. **Checking the Number of Files**
```bash
echo "Files found: ${#files[@]}"
if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .AppImage files were found in the '$APPIMAGE_DIR' directory."
    echo "=== END TROUBLESHOOTING ==="
    exit 1
fi
```
- The script displays the number of files found and if no `.AppImage` files are found, it outputs an error and exits.

### 6. **User File Selection**
```bash
tilix -e bash -c "
    echo 'The following AppImage files are available in $APPIMAGE_DIR:'
    echo ''
    cat -n /tmp/appimage_list.txt
    echo ''
    read -p 'Enter the number of the AppImage you want to run: ' choice
    echo \$choice > /tmp/appimage_choice.txt
"
```
- The script opens a terminal window using the `tilix` terminal application (you can define another), where it displays a numbered list of the available `.AppImage` files using `cat -n`.
- The user is prompted to enter the number corresponding to the file they wish to run.
- This selection is saved to the second temporary file `/tmp/appimage_choice.txt`.

### 7. **Validating the User Selection**
```bash
choice=$(cat /tmp/appimage_choice.txt)
echo "Selection entered: $choice"

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "Error: '$choice' is not a valid number."
    echo "=== END TROUBLESHOOTING ==="
    exit 1
fi

if ((choice < 1 || choice > ${#files[@]})); then
    echo "Error: The number entered is not within the available range."
    echo "=== END TROUBLESHOOTING ==="
    exit 1
fi
```
- The script reads the user's selection from the temporary file.
- It verifies if the selection is a valid number and within the valid range corresponding to the available files. If not, an error message is displayed, and the script exits.

### 8. **Running the Selected File**
```bash
app="${files[choice-1]}"
echo "Run: $app"
"$app" &
```
- Based on the user's choice, the script executes the corresponding `.AppImage` file in a new process.

### 9. **Cleanup and Script Termination**
```bash
rm /tmp/appimage_list.txt /tmp/appimage_choice.txt
echo "Application started. Temp files removed. Closing the script."
sleep 2
echo "=== END TROUBLESHOOTING ==="
exit
```
- At the end of the script, the temporary files `/tmp/appimage_list.txt` and `/tmp/appimage_choice.txt` are removed, a cleanup message is displayed, and the script exits.
