#!/bin/python3
import sys

from itertools import zip_longest
def grouper(iterable, n, fillvalue=None):
    args = [iter(iterable)] * n
    return list(zip_longest(*args, fillvalue=fillvalue))

if __name__ == '__main__':
    if len(sys.argv) != 2:
        exit(1)

    edid = sys.argv[1]

    stdin = []
    while(True):
        try:
            stdin.append(input())
        except EOFError:
            break
    grouped = grouper(stdin, 4)
    edid_to_scr = {edid.strip(): screen_id.strip().split()[0] for (screen_id, _, edid, _) in grouped}
    print(edid_to_scr[edid])

