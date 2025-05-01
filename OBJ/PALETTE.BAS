' PALETTE.BAS - Extract palette from GAMEPAL.OBJ
' This program reads the binary palette data and converts it to QB64 format

' Constants
CONST PALETTE_SIZE = 768      ' 256 colors * 3 bytes per color
CONST OBJ_HEADER_SIZE = 125   ' Size of OBJ file header to skip
CONST TOTAL_FILE_SIZE = 893   ' Total size of GAMEPAL.OBJ including header

' Variables
DIM SHARED colorPalette(255) AS LONG  ' Array to hold converted palette colors
' DIM SHARED colorPaletteCombined(255) AS LONG  ' Array to hold converted palette colors  - red% + 256 * green% + 65536 * blue%.
DIM buffer(PALETTE_SIZE - 1) AS _BYTE  ' Creates array of 768 elements (0 to 767)

' Main program
CLS
PRINT "Wolfenstein 3D Palette Extractor"
PRINT "-------------------------------"

' Open and read the palette file
OPEN "GAMEPAL.OBJ" FOR BINARY AS #1
IF LOF(1) <> TOTAL_FILE_SIZE THEN
    PRINT "Error: GAMEPAL.OBJ is not the correct size!"
    PRINT "Expected:"; TOTAL_FILE_SIZE; "bytes"
    PRINT "Found:"; LOF(1); "bytes"
    CLOSE #1
    END
END IF

' Skip OBJ header
SEEK #1, OBJ_HEADER_SIZE + 1  ' +1 because SEEK is 1-based in BASIC
GET #1, , buffer()
CLOSE #1

' Convert the palette data
FOR i = 0 TO 255
    ' Each color is 3 bytes: R,G,B
    ' VGA uses 6-bit color values (0-63)
    r = buffer(i * 3) \ 4     ' Convert from 0-255 to 0-63
    g = buffer(i * 3 + 1) \ 4
    b = buffer(i * 3 + 2) \ 4
    
    ' Convert to QB64 color format
    colorPalette(i) = _RGB32(r * 4, g * 4, b * 4)  ' Scale back to 0-255
    ' colorPaletteCombined(i) = r + 256 * g + 65546 * b
NEXT i

' Display the palette
SCREEN 13  ' Set to 320x200 mode

' PALETTE USING colorPaletteCombined(0)

FOR y = 0 TO 15
    FOR x = 0 TO 15
        colorIndex = y * 16 + x
        LINE (x * 20, y * 20)-STEP(19, 19), colorPalette(colorIndex), BF
    NEXT x
NEXT y

PRINT "Palette displayed. Press any key to generate GAMEPAL.BAS..."
DO: LOOP UNTIL INKEY$ <> ""

' Save palette data as QB64 code
OPEN "GAMEPAL.BAS" FOR OUTPUT AS #1
PRINT #1, "' GAMEPAL.BAS - Wolfenstein 3D Palette Data"
PRINT #1, "' Generated from GAMEPAL.OBJ"
PRINT #1, ""
PRINT #1, "SUB LoadGamePalette"
PRINT #1, "    DIM gamepal(255) AS LONG"
PRINT #1, ""

FOR i = 0 TO 255
    r = buffer(i * 3) \ 4
    g = buffer(i * 3 + 1) \ 4
    b = buffer(i * 3 + 2) \ 4
    PRINT #1, "    gamepal(" + STR$(i) + ") = _RGB32(" + STR$(r * 4) + ", " + STR$(g * 4) + ", " + STR$(b * 4) + ")"
NEXT i

PRINT #1, ""
PRINT #1, "    ' Set the palette"
PRINT #1, "    FOR i = 0 TO 255"
PRINT #1, "        _PALETTECOLOR i, gamepal(i)"
PRINT #1, "    NEXT i"
PRINT #1, "END SUB"

CLOSE #1

PRINT "GAMEPAL.BAS has been generated successfully!"
PRINT "Press any key to exit..."
DO: LOOP UNTIL INKEY$ <> ""

END