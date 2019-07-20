import subprocess, os.path, sys, re, shutil

#OBJDUMP = '/opt/mxe/usr/bin/i686-w64-mingw32.shared-objdump'
#BASEDIR = '/opt/mxe/usr/i686-w64-mingw32.shared/bin/'
OBJDUMP = 'objdump'
BASEDIR = '/c/msys64/mingw64/bin'

def getDependencies(filename):
	out = subprocess.check_output([OBJDUMP, '-x', filename]).decode()
	print('### objdump %s: %i B' % (filename, len(out)))
	return set(re.findall('DLL Name: (.*)', out))

def getDependenciesRecursively(filename, checkedAlready = set()):
	rv = checkedAlready
	for dep in getDependencies(filename):
		if dep in rv: continue

		rv.add(dep)
		filename = os.path.join(BASEDIR, dep)
		if not os.path.exists(filename): continue

		rv = rv.union(getDependenciesRecursively(filename, rv))
	return rv



if len(sys.argv) != 2:
	print('Usage: %s file.exe' % sys.argv[0])
	sys.exit(1)

print('Checking dependencies for %s' % sys.argv[1])

OUTDIR = os.path.dirname(sys.argv[1])

print('Source dir: %s' % BASEDIR)
print('Target dir: %s' % OUTDIR)


for dep in sorted(getDependenciesRecursively(sys.argv[1])):
	print(dep)
	src = os.path.join(BASEDIR, dep)
	print('src = %s' % src)
	if not os.path.exists(src):
		print('no source')
		print('Skipping %s - not in %s' % (dep, BASEDIR))
		continue
	dst = os.path.join(OUTDIR, dep)
	print('dst = %s' % dst)
	if os.path.exists(dst):
		print('no dest')
		print('Skipping %s - already in %s' % (dep, OUTDIR))
		continue
	print('%s > %s' % (src, dst))
	shutil.copy(src, dst)
