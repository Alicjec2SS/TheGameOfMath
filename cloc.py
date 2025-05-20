import os

from pathlib import Path

#CLOC - count line of code, only count things were coded by myself

# Định nghĩa phần mở rộng và thư mục cần bỏ qua
EXTENSIONS = ['.gd', '.tres']#,'.tscn']
EXCLUDE_FOLDERS = ['addons', '.git', '.import', 'build', 'bin']

# Dữ liệu thống kê
stats = {'.gd': {'files': 0, 'lines': 0}, '.tres': {'files': 0, 'lines': 0}}#,'.tscn' : {'files': 0, 'lines': 0}}

# Duyệt file nhanh bằng pathlib
for file_path in Path(".").rglob("*"):
    if not file_path.is_file():
        continue
    if file_path.suffix not in EXTENSIONS:
        continue
    if any(exclude in file_path.parts for exclude in EXCLUDE_FOLDERS):
        continue

    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            lines = sum(1 for _ in f)
            stats[file_path.suffix]['files'] += 1
            stats[file_path.suffix]['lines'] += lines
    except Exception as e:
        print(f"Lỗi khi đọc {file_path}: {e}")

# In kết quả
print(f"{'Loại file':<10} | {'Số file':<8} | {'Số dòng'}")
print('-' * 30)
total_files = 0
total_lines = 0
for ext in EXTENSIONS:
    files = stats[ext]['files']
    lines = stats[ext]['lines']
    print(f"{ext:<10} | {files:<8} | {lines}")
    total_files += files
    total_lines += lines

print('-' * 30)
print(f"{'TỔNG':<10} | {total_files:<8} | {total_lines}")
