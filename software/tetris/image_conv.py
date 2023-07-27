#!/bin/python
from PIL import Image
import argparse

def cpu16rgb(r,g,b):
    return (0x8000 | (r & 0x1f) | ((g & 0x1f) << 5) | ((b & 0x1f) << 10))

def little_endian(i16):
    return (i16 & 0xff, (i16 >> 8) & 0xff)

def main():

    parser = argparse.ArgumentParser("cpu16 image converter")
    parser.add_argument("input")
    parser.add_argument("output")
    args = parser.parse_args()


    img = Image.open(args.input)
    raw_data = []
    for pixel in img.getdata():
        (l,h) = little_endian(cpu16rgb(pixel[0],pixel[1],pixel[2]))
        raw_data.append(l)
        raw_data.append(h)
    with open(args.output, 'wb') as f:
        f.write( bytes(raw_data) )



if __name__ == "__main__":
    main()