# The QB64 sources are in basicsrc/. The exes go here, next to the data files: a QB64
# program runs in the folder of its exe. qb64 -o needs an absolute path (a relative one is
# taken from the source folder), so the Windows path of this folder is used (WSL make).
QB64 = /mnt/c/qb64/qb64.exe
OUT = $(shell wslpath -w $(CURDIR))
BUILDS = WOLF3D WOLF1 WOLFS14 SPEAR SPEARDEMO

all: $(BUILDS:=.exe)

clean:
	rm -f $(BUILDS:=.exe)

%.exe: basicsrc/%.BAS basicsrc/*.BI basicsrc/*.BM
	$(QB64) -x basicsrc/$*.BAS -o "$(OUT)\$@"
