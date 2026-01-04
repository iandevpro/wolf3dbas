all: WOLF3D.EXE

clean:
	rm WOLF3D.EXE

WOLF3D.EXE: *.BAS *.BI *.BM
	/mnt/c/qb64/qb64.exe -x WOLF3D.BAS
