#!/bin/bash

# Prompt the user for the file or directory path
echo "Do you want to change permissions for a file or a directory? (f/d)"
read -r type

if [ "$type" != "f" ] && [ "$type" != "d" ]; then
  echo "Invalid option. Please run the script again and choose 'f' for file or 'd' for directory."
  exit 1
fi

# Ask for the path of the file or directory
echo "Please enter the path of the $([ "$type" = "f" ] && echo "file" || echo "directory") (e.g., /path/to/your/file or /path/to/your/directory):"
read -r path

# Check if the specified path exists and is of the correct type
if [ "$type" = "f" ] && [ ! -f "$path" ]; then
  echo "The specified file does not exist. Please check the path and try again."
  exit 1
elif [ "$type" = "d" ] && [ ! -d "$path" ]; then
  echo "The specified directory does not exist. Please check the path and try again."
  exit 1
fi

# List common permission options
echo "Please select the desired permission:"
echo "1) 644 - Owner: read/write, Group: read, Others: read (Common for files)"
echo "2) 755 - Owner: read/write/execute, Group: read/execute, Others: read/execute (Common for directories)"
echo "3) 600 - Owner: read/write, Group: none, Others: none"
echo "4) 700 - Owner: read/write/execute, Group: none, Others: none"
echo "5) 666 - Owner: read/write, Group: read/write, Others: read/write"
echo "6) 777 - Owner: read/write/execute, Group: read/write/execute, Others: read/write/execute"

read -r permission_choice

# Map the user's choice to the corresponding permission
case $permission_choice in
  1) permissions="644" ;;
  2) permissions="755" ;;
  3) permissions="600" ;;
  4) permissions="700" ;;
  5) permissions="666" ;;
  6) permissions="777" ;;
  *) echo "Invalid choice. Please run the script again and select a valid option." ; exit 1 ;;
esac

# Change the permissions
chmod "$permissions" "$path"

# Confirm the change
if [ $? -eq 0 ]; then
  echo "Permissions for '$path' have been successfully changed to '$permissions'."
else
  echo "Failed to change permissions for '$path'. Please check the input and try again."
fi
