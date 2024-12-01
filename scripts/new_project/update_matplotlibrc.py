import os, sys

def update_matplotlibrc(existing_path, downloaded_path):

    # Check if the files exist
    if not os.path.exists(existing_path):
        print(f"Error: Existing file '{existing_path}' not found.")
        sys.exit(1)
    if not os.path.exists(downloaded_path):
        print(f"Error: Downloaded file '{downloaded_path}' not found.")
        sys.exit(1)

    # Read the files
    with open(existing_path, 'r') as existing_file, open(downloaded_path, 'r') as downloaded_file:
        existing_lines   = existing_file.readlines()
        downloaded_lines = downloaded_file.readlines()

    # Convert existing_lines to a dictionary for fast lookup
    existing_dict = {line.split(':', 1)[0]: line for line in existing_lines if ':' in line}
    updated_lines = existing_lines[:]

    # 
    for line in downloaded_lines:
        if ':' in line:
            key = line.split(':', 1)[0]
            if key in existing_dict and existing_dict[key] != line:
                updated_lines[updated_lines.index(existing_dict[key])] = line

    with open(existing_path, 'w') as existing_file:
        existing_file.writelines(updated_lines)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python update_matplotlibrc.py <existing_file_path> <downloaded_file_path>")
        sys.exit(1)
    
    update_matplotlibrc(sys.argv[1], sys.argv[2])
