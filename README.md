# Directory Listing Script 📁

A simple Bash script to list files and directories with optional tree format output.

## Author
**JxH** - v7_@hotmail.com

## Usage

```bash
# Make executable
chmod +x list_paths.sh

# Basic listing
./list_paths.sh /path/to/directory

# Tree format
./list_paths.sh /path/to/directory --tree
```

## Features
- 📋 Simple file/directory listing
- 🌳 Tree view format
- 📊 Statistics (file count, directory count)
- 🕐 Timestamped output files
- ❌ Basic error handling

## Output
Creates `directory_contents_YYYYMMDD_HHMMSS.txt` in current directory.

## Requirements
- Bash 4.0+
- Standard Unix tools (find, sort, date)

## License
MIT License

---
*Simple tool for documenting directory structures* ✨
