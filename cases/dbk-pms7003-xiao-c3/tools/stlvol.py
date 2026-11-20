#!/usr/bin/env python3
"""Print the enclosed volume (mm^3) of an STL file, ASCII or binary."""
import re, struct, sys
d = open(sys.argv[1], 'rb').read()
if d[:5] == b'solid':
    v = [tuple(map(float, m.groups())) for m in re.finditer(rb'vertex\s+(\S+)\s+(\S+)\s+(\S+)', d)]
    t = [v[i:i+3] for i in range(0, len(v), 3)]
else:
    n = struct.unpack('<I', d[80:84])[0]
    t = [(lambda f: (f[3:6], f[6:9], f[9:12]))(struct.unpack('<12f', d[84+i*50:132+i*50])) for i in range(n)]
V = sum(a[0]*(b[1]*c[2]-b[2]*c[1]) - a[1]*(b[0]*c[2]-b[2]*c[0]) + a[2]*(b[0]*c[1]-b[1]*c[0]) for a, b, c in t) / 6
print(f"{abs(V):.3f}")
