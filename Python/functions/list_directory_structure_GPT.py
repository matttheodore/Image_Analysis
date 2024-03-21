
import os

def list_files_to_txt(startpath):
    with open(os.path.join(startpath, "directory_structure.txt"), "w") as txt_file:
        for root, dirs, files in os.walk(startpath):
            level = root.replace(startpath, '').count(os.sep)
            indent = ' ' * 4 * (level)
            txt_file.write(f"{indent}{os.path.basename(root)}/\n")
            subindent = ' ' * 4 * (level + 1)
            for f in files:
                txt_file.write(f"{subindent}{f}\n")

# Usage example; replace the directory path with the one you want to explore.
list_files_to_txt(r"C:\Users\mattt\Downloads\CpaF_from_pdb100_temp_0a631.result\CpaF_from_pdb100_temp_0a631")

