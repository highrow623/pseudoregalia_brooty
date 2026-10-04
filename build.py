"""
This script builds a zip from pack source files.
"""

import os
import os.path
import zipfile

zipname = "pseudoregalia_brooty.zip"
# top level folders and files to include in zip
dirs = ("images", "items", "layouts", "locations", "maps", "scripts", "var_itemsonly")
files = ("manifest.json","README.md")

def write_dir(packzip: zipfile.ZipFile, dir: str):
    for subdir, _, files in os.walk(dir):
        packzip.mkdir(subdir)
        for file in files:
            packzip.write(os.path.join(subdir, file))

def main():
    with zipfile.ZipFile(zipname, "w") as packzip:
        for dir in dirs:
            write_dir(packzip, dir)
        for file in files:
            packzip.write(file)

if __name__ == "__main__":
    main()
