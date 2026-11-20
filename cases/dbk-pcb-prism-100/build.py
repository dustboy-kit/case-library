#!/usr/bin/env python3
"""Build and check the numbered OpenSCAD catalog; stdlib only. Run: python3 build.py"""
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from html import escape
from hashlib import sha256
from zipfile import ZipFile, ZIP_DEFLATED
import json, math, shutil, struct, subprocess, tempfile

ROOT = Path(__file__).resolve().parent
FAMILIES = [
    ("Datum", "Closest to the yellow cover in the photos: compact, rounded corners."),
    ("Pebble", "A pill-shaped outer shell with rounded ends."),
    ("Bumper", "Four proud corners add material around the perimeter."),
    ("Thumb", "A broad, asymmetric ledge gives one side a place to hold."),
    ("Loop", "An eye at one end accepts a cord; strength is untested."),
    ("Bracket", "Two external ears provide mounting-hole concepts."),
    ("Rib", "Six pairs of projecting ribs change the grip along the sides."),
    ("Facet", "Eight flat perimeter faces form clipped corners."),
    ("Scallop", "Four rounded lobes along each long edge."),
    ("Keystone", "A wider shoulder and narrower chin give the body a direction."),
]
FACES = ["Parallel", "Constellation", "Sunburst", "Honeycomb", "Chevron",
         "Arc", "Lozenge", "Wave", "Terrace", "Switchback"]
def run(*args):
    p=subprocess.run(args,cwd=ROOT,capture_output=True,text=True)
    if p.returncode or 'ERROR:' in p.stderr or 'WARNING:' in p.stderr:
        raise RuntimeError(f'{args}: {p.stderr}')
    return p
def mesh_check(path):
    """Weld exact binary-STL vertices; check oppositely wound edge pairs and two bed-flat bodies."""
    data=path.read_bytes()
    count=struct.unpack_from('<I',data,80)[0]
    assert 84+50*count==len(data) and count>20
    vids={};parent=[];edges={};positions=[];vols=[];facekeys=[]
    def find(i):
        while parent[i]!=i:
            parent[i]=parent[parent[i]];i=parent[i]
        return i
    def vid(p):
        if p not in vids:
            vids[p]=len(parent);parent.append(len(parent));positions.append(p)
        return vids[p]
    for rec in struct.iter_unpack('<12fH',data[84:]):
        a,b,c=rec[3:6],rec[6:9],rec[9:12]
        assert all(math.isfinite(u) for p in (a,b,c) for u in p)
        i,j,k=vid(a),vid(b),vid(c)
        assert len({i,j,k})==3,'collapsed face'
        for u,v in ((i,j),(j,k),(k,i)):
            edge=(min(u,v),max(u,v)); n,d=edges.get(edge,(0,0));edges[edge]=n+1,d+(1 if u<v else -1)
        parent[find(i)]=find(j);parent[find(k)]=find(j)
        v=tuple(b[n]-a[n] for n in range(3));w=tuple(c[n]-a[n] for n in range(3))
        cross=(v[1]*w[2]-v[2]*w[1],v[2]*w[0]-v[0]*w[2],v[0]*w[1]-v[1]*w[0])
        assert sum(t*t for t in cross)>1e-20,'degenerate triangle'
        vols.append((i,sum(x*y for x,y in zip(a,cross))/6))
        facekeys.append(tuple(sorted((a,b,c))))
    assert all(val==(2,0) for val in edges.values()),'non-manifold or inconsistent edge'
    bodies=defaultdict(list)
    for i,p in enumerate(positions):bodies[find(i)].append(p)
    assert len(bodies)==2,f'{len(bodies)} components, expected base and lid'
    for pts in bodies.values():
        assert abs(min(p[2] for p in pts))<.0001,'not flat on bed'
    pos=sorted((min(p[1] for p in pts),max(p[1] for p in pts)) for pts in bodies.values())
    assert pos[0][1]<pos[1][0],'no print-plate gap'
    volume=defaultdict(float)
    for i,v in vols:volume[find(i)]+=v
    assert min(volume.values())>0,'inside-out solid'
    # Order-independent geometry fingerprint (STL header, winding and facet order ignored).
    h=sha256()
    for tri in sorted(facekeys):
        for p in tri:h.update(struct.pack('<3f',*p))
    return count,round(sum(volume.values()),2),h.hexdigest()
def build(case):
    tag=f'{case:03}';f,m=divmod(case-1,10)
    with tempfile.TemporaryDirectory(dir=ROOT) as d:
        stl=Path(d)/'plate.stl';png=Path(d)/'preview.png'
        cmd=('openscad','--hardwarnings','--backend=Manifold','-D',f'case_id={case}')
        run(*cmd,'-D','part="plate"','--export-format','binstl','-o',stl,'cases.scad')
        try: faces,vol,digest=mesh_check(stl)
        except AssertionError as e: raise ValueError(f'Case {tag}: {e}') from e
        run(*cmd,'--render=true','--projection=o','--autocenter','--viewall','--colorscheme=Tomorrow',
            '--imgsize=760,570','--camera=0,0,0,47,0,32,160','-o',png,'cases.scad')
        buf=png.read_bytes()
        assert buf[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',buf[16:24])==(760,570)
        stl.replace(ROOT/f'plates/{tag}.stl');png.replace(ROOT/f'views/{tag}.png')
    return dict(id=tag,family=FAMILIES[f][0],face=FACES[m],triangles=faces,volume_mm3=vol,geometry_sha256=digest)
def gallery(rows):
    cards=[]
    for r in rows:
        i=r['id'];f=r['family'];m=r['face']
        cards.append(f'<article data-family="{f}" data-face="{m}"><a href="views/{i}.png" aria-label="Full preview: {i} {f} {m}"><img src="views/{i}.png" loading="lazy" width="760" height="570" alt="{f} enclosure with {m} grille"></a><div><small>№ {i}</small><h2>{f} <span>/</span> {m}</h2><a href="plates/{i}.stl" download="pm25-{i}-{f}-{m}.stl">STL · lid + base ↓</a></div></article>')
    opts=lambda vals: ''.join('<option>'+escape(s)+'</option>' for s in vals)
    return (ROOT/'gallery.template.html').read_text().replace('<!--FAMILIES-->',opts([f for f,_ in FAMILIES])).replace('<!--FACES-->',opts(FACES)).replace('<!--CARDS-->','\n'.join(cards))
def main():
    for sub in ['plates','views']:(ROOT/sub).mkdir(exist_ok=True)
    assert shutil.which('openscad'), 'OpenSCAD CLI required'
    rows=[]
    with ThreadPoolExecutor(max_workers=4) as pool:
        for r in pool.map(build,range(1,101)):
            rows.append(r)
            if len(rows)%10==0:print(f'{len(rows)}/100 checked',flush=True)
    assert len({r['geometry_sha256'] for r in rows})==100
    assert len({(r['family'],r['face']) for r in rows})==100
    (ROOT/'manifest.json').write_text(json.dumps(rows,indent=2)+'\n')
    (ROOT/'index.html').write_text(gallery(rows))
    with ZipFile(ROOT/'all-100.zip','w',ZIP_DEFLATED,compresslevel=5) as z:
        names=['cases.scad','README.md','PRISM.md','manifest.json','index.html','build.py','gallery.template.html']
        for name in names+[f'{s}/{r["id"]}.{ext}' for r in rows for s,ext in [('plates','stl'),('views','png')]]:
            if name=='index.html':
                z.writestr(name,(ROOT/name).read_text().replace('<a href="all-100.zip" download>Download the collection ↓</a>', ''))
            else: z.write(ROOT/name,name)
    print('100 different meshes; 200 closed components; bundle complete.')
if __name__=='__main__':main()
