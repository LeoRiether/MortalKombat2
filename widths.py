#! python3

import sys
from os import listdir
from PIL import Image

if len(sys.argv) < 2:
    print("Usage: ./widths.py folder_with_a_bunch_of_bmps")
    exit(0)

def get_size(file):
    im = Image.open(file)
    sz = im.size
    im.close()
    return sz


files = listdir(sys.argv[1])
files.sort(key = lambda x: int(x[:-4]))

for file in files:
    w, h = get_size(sys.argv[1] + file)
    print(f"{w} {h}")
