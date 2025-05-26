' PALETTE.BAS - Extract palette from GAMEPAL.OBJ
' This program reads the binary palette data and converts it to QB64 format

' Constants
Const PALETTE_SIZE = 768 ' 256 colors * 3 bytes per color

' Variables
Dim Shared colorPalette(255) As Long ' Array to hold converted palette colors
' DIM SHARED colorPaletteCombined(255) AS LONG  ' Array to hold converted palette colors  - red% + 256 * green% + 65536 * blue%.
Dim buffer(PALETTE_SIZE - 1) As _Byte ' Creates array of 768 elements (0 to 767)

' Main program
Cls
Print "Wolfenstein 3D Palette Extractor"
Print "-------------------------------"

' Open and read the palette file
Open "gamepal.bin" For Binary As #1
If LOF(1) <> PALETTE_SIZE Then
    Print "Error: gamepal.bin is not the correct size!"
    Print "Expected:"; PALETTE_SIZE; "bytes"
    Print "Found:"; LOF(1); "bytes"
    Close #1
    End
End If

Get #1, , buffer()
Close #1

' Convert the palette data
For i = 0 To 255
    ' Each color is 3 bytes: R,G,B
    ' VGA uses 6-bit color values (0-63)
    ' previously there was a conversion to 0-63 (divide by 4), but now we are using the original values
    ' since they are already in the 0-63 range
    r = buffer(i * 3)
    g = buffer(i * 3 + 1)
    b = buffer(i * 3 + 2)

    ' Convert to QB64 color format
    colorPalette(i) = _RGB32(r, g, b) 'Previously there was a multiplier by 4 ' Scale back to 0-255
    ' colorPaletteCombined(i) = r + 256 * g + 65546 * b
Next i

' Display the palette
Screen 13 ' Set to 320x200 mode

' PALETTE USING colorPaletteCombined(0)

For y = 0 To 15
    For x = 0 To 15
        colorIndex = y * 16 + x
        Line (x * 20, y * 20)-Step(19, 19), colorPalette(colorIndex), BF
    Next x
Next y

Print "Palette displayed. Press any key to generate GAMEPAL.BAS..."
Do: Loop Until InKey$ <> ""

' Save palette data as QB64 code
Open "gamepal.bas" For Output As #1
Print #1, "' GAMEPAL.BAS - Wolfenstein 3D Palette Data"
Print #1, "' Generated from gamepal.bin"
Print #1, ""
Print #1, "Sub LoadGamePalette"
Print #1, "    Dim gamepal(255) AS Long"
Print #1, ""

For i = 0 To 255
    r = buffer(i * 3)
    g = buffer(i * 3 + 1)
    b = buffer(i * 3 + 2)
    Print #1, "    gamepal(" + Str$(i) + ") = _RGB32(" + Str$(r) + ", " + Str$(g) + ", " + Str$(b) + ")"
Next i

Print #1, ""
Print #1, "    ' Set the palette"
Print #1, "    For i = 0 TO 255"
Print #1, "        _PaletteColor i, gamepal(i)"
Print #1, "    Next i"
Print #1, "End Sub"

Close #1

Print "GAMEPAL.BAS has been generated successfully!"
Print "Press any key to exit..."
Do: Loop Until InKey$ <> ""

End
