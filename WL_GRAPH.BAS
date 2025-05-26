' WL_GRAPH.BAS - Graphics handling for Wolfenstein 3D QB64 port

'$INCLUDE: 'wl_def.bi'

' Graphics Constants
Const SCREENWIDTH = 320
Const SCREENHEIGHT = 200
Const NUMCOLORS = 256

' Graphics Variables
Dim Shared screenbuffer(SCREENWIDTH * SCREENHEIGHT) As Integer
DIM SHARED palette(0 TO 255, 0 TO 2) AS INTEGER
DIM SHARED walltextures(MAXWALLTILES, TILEWIDTH, TILEHEIGHT) AS INTEGER
DIM SHARED sprites(MAXACTORS, 64, 64) AS INTEGER

' Initialize graphics system
Sub InitGraphics
    ' Set up graphics mode
    SCREEN _NEWIMAGE(SCREENWIDTH, SCREENHEIGHT, 256)
    
    ' Initialize screen buffer
    ERASE screenbuffer
    
    ' Load default palette
    CALL LoadPalette
    
    ' Load wall textures
    CALL LoadWallTextures
    
    ' Load sprites
    CALL LoadSprites
End Sub

' Load default VGA palette
Sub LoadPalette
    DIM i AS INTEGER
    DIM r, g, b AS INTEGER
    
    ' Set up a basic grayscale palette
    FOR i = 0 TO 255
        r = i \ 4
        g = i \ 4
        b = i \ 4
        palette(i, 0) = r
        palette(i, 1) = g
        palette(i, 2) = b
        _PALETTECOLOR i, _RGB32(r * 4, g * 4, b * 4)
    NEXT i
End Sub

' Load wall textures (placeholder - will need to load actual textures)
Sub LoadWallTextures
    DIM i, x, y AS INTEGER
    
    ' Create some basic test textures
    FOR i = 0 TO MAXWALLTILES - 1
        FOR y = 0 TO TILEHEIGHT - 1
            FOR x = 0 TO TILEWIDTH - 1
                ' Create a simple pattern
                walltextures(i, x, y) = (x + y + i) MOD 256
            NEXT x
        NEXT y
    NEXT i
End Sub

' Load sprites (placeholder - will need to load actual sprites)
Sub LoadSprites
    DIM i, x, y AS INTEGER
    
    ' Create some basic test sprites
    FOR i = 0 TO MAXACTORS - 1
        FOR y = 0 TO 63
            FOR x = 0 TO 63
                ' Create a simple pattern
                sprites(i, x, y) = (x + y + i) MOD 256
            NEXT x
        NEXT y
    NEXT i
End Sub

' Draw a vertical line
Sub DrawVerticalLine (x AS INTEGER, y1 AS INTEGER, y2 AS INTEGER, color AS INTEGER)
    DIM y AS INTEGER
    DIM starty, endy AS INTEGER
    
    IF y1 > y2 THEN
        starty = y2
        endy = y1
    ELSE
        starty = y1
        endy = y2
    End If
    
    FOR y = starty TO endy
        IF y >= 0 AND y < SCREENHEIGHT THEN
            screenbuffer(y * SCREENWIDTH + x) = color
        End If
    NEXT y
End Sub

' Draw a wall slice
Sub DrawWallSlice (x AS INTEGER, y1 AS INTEGER, y2 AS INTEGER, texture AS INTEGER, texX AS INTEGER)
    DIM y AS INTEGER
    DIM starty, endy AS INTEGER
    DIM texY AS INTEGER
    DIM color AS INTEGER
    
    IF y1 > y2 THEN
        starty = y2
        endy = y1
    ELSE
        starty = y1
        endy = y2
    End If
    
    FOR y = starty TO endy
        IF y >= 0 AND y < SCREENHEIGHT THEN
            texY = ((y - starty) * TILEHEIGHT) \ (endy - starty)
            color = walltextures(texture, texX, texY)
            screenbuffer(y * SCREENWIDTH + x) = color
        End If
    NEXT y
End Sub

' Draw a sprite
Sub DrawSprite (x AS INTEGER, y AS INTEGER, spriteNum AS INTEGER, scale AS INTEGER)
    DIM sx, sy AS INTEGER
    DIM color AS INTEGER
    DIM scaledX, scaledY AS INTEGER
    
    FOR sy = 0 TO 63
        FOR sx = 0 TO 63
            color = sprites(spriteNum, sx, sy)
            IF color <> 0 THEN  ' Skip transparent pixels
                scaledX = x + (sx * scale) \ 64
                scaledY = y + (sy * scale) \ 64
                IF scaledX >= 0 AND scaledX < SCREENWIDTH AND scaledY >= 0 AND scaledY < SCREENHEIGHT THEN
                    screenbuffer(scaledY * SCREENWIDTH + scaledX) = color
                End If
            End If
        NEXT sx
    NEXT sy
End Sub

' Update screen with buffer contents
Sub UpdateScreen
    DIM i AS INTEGER
    
    ' Copy buffer to screen
    FOR i = 0 TO SCREENWIDTH * SCREENHEIGHT - 1
        PSET (i MOD SCREENWIDTH, i \ SCREENWIDTH), screenbuffer(i)
    NEXT i
End Sub

' Clear screen buffer
Sub ClearScreen
    ERASE screenbuffer
End Sub 
