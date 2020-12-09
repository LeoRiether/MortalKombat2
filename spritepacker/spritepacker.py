#! python3

from PIL import Image
import sys
import struct

if len(sys.argv) < 2:
    print("Usage: python3 spritepacker.py image.bmp")
    exit(0)

def resize(a, n, x):
    """ Resize the list `a` to `n` elements, extending with the element `x` """
    a.extend([x] * (n - len(a)))

def tup2byte(rgb):
    """ Transforms an (R, G, B) tuple into a BBGGGRRR byte that FPGRARS can understand """
    r, g, b = rgb
    r8 = int(r / 255.0 * 7.0)
    g8 = int(g / 255.0 * 7.0)
    b8 = int(b / 255.0 * 3.0)

    return (b8 << 6) | (g8 << 3) | r8

# https://stackoverflow.com/questions/434287/what-is-the-most-pythonic-way-to-iterate-over-a-list-in-chunks
from itertools import zip_longest
def chunks(iterable, n, fillvalue=None):
    args = [iter(iterable)] * n
    return zip_longest(*args, fillvalue=fillvalue)

file = sys.argv[1]
outfile = file.replace('.bmp', '.packed.bin')

im = Image.open(file)

# Build the color palette
palette = list({ tup2byte(pixel) for pixel in im.getdata() })

print(f"Found \033[92m{len(palette)}\033[0m pixels: {palette}")
if len(palette) > 16:
    print("More than 16 pixels? Tough luck, this isn't going to work very well")

palette = palette[0:min(len(palette), 16)]
resize(palette, 16, 0xC7)
pindex = { p: i for i, p in enumerate(palette) }

# Write to output file
with open(outfile, 'wb') as f:
    # Write pallete
    f.write(struct.pack('<16B', *palette))

    # Write (width, height) words
    width, height = im.size
    f.write(struct.pack('<i', im.width))
    f.write(struct.pack('<i', im.height))

    # Write the sprite
    iterable = chunks(map(lambda pixel: pindex.get(tup2byte(pixel), 0), im.getdata()), 2, (255, 0, 255)) # horrible
    for p0, p1 in iterable:
        f.write(struct.pack('<B', (p1 << 4) | p0))

print("\033[92mDone\033[0m")

im.close()