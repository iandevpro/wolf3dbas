'' WL_RENDER.BAS - 3D Rendering Engine for Wolfenstein 3D QB64 port

''$INCLUDE: 'wl_def.bi'
''$INCLUDE: 'wl_graph.bi'

'' Rendering Constants
'CONST MAXWALLHEIGHT = 200
'CONST MINDIST = 0.5
'CONST MAXDIST = 1000

'' Rendering Variables
'DIM SHARED viewangle AS INTEGER
'DIM SHARED viewx AS LONG
'DIM SHARED viewy AS LONG
'DIM SHARED viewheight AS INTEGER
'DIM SHARED viewwidth AS INTEGER
'DIM SHARED viewheight2 AS INTEGER
'DIM SHARED heightnumerator AS LONG
'DIM SHARED scale AS LONG
'DIM SHARED maxslope AS LONG
'DIM SHARED pixelangle(VIEWWIDTH) AS INTEGER
'DIM SHARED wallheight(VIEWWIDTH) AS INTEGER
'DIM SHARED walltexture(VIEWWIDTH) AS INTEGER
'DIM SHARED walltexpos(VIEWWIDTH) AS INTEGER

'' Initialize rendering system
'SUB InitRender
'' Initialize variables
'viewangle = 0
'viewx = 0
'viewy = 0
'viewheight = VIEWHEIGHT
'viewwidth = VIEWWIDTH
'viewheight2 = VIEWHEIGHT \ 2
    
'' Calculate projection constants
'CALL CalcProjection(FOCALLENGTH)
'END SUB

'' Calculate projection constants
'SUB CalcProjection (focal AS LONG)
'DIM i AS INTEGER
'DIM angle AS SINGLE
'DIM tang AS DOUBLE
'DIM facedist AS DOUBLE
'DIM halfview AS INTEGER
    
'focallength = focal
'facedist = focal + MINDIST
'halfview = viewwidth \ 2
    
'' Calculate scale value for vertical height calculations
'scale = halfview * facedist / (VIEWGLOBAL / 2)
    
'' Calculate height numerator
'heightnumerator = (TILEGLOBAL * scale) \ 64
'minheightdiv = heightnumerator \ 32767 + 1
    
'' Calculate angle offset for each pixel's ray
'FOR i = 0 TO halfview - 1
'tang = i * VIEWGLOBAL / viewwidth / facedist
'angle = ATN(tang)
'pixelangle(halfview - 1 - i) = angle * ANGLES / PI
'pixelangle(halfview + i) = -pixelangle(halfview - 1 - i)
'NEXT i
    
'' Calculate maximum slope
'maxslope = finetangent(pixelangle(0)) \ 256
'END SUB

'' Render the 3D view
'SUB RenderView
'DIM x AS INTEGER
'DIM y AS INTEGER
'DIM angle AS INTEGER
'DIM distance AS LONG
'DIM height AS INTEGER
'DIM texture AS INTEGER
'DIM texpos AS INTEGER
    
'' Clear screen buffer
'CALL ClearScreen
    
'' Cast rays for each vertical column
'FOR x = 0 TO viewwidth - 1
'' Calculate ray angle
'angle = (viewangle + pixelangle(x)) AND (ANGLES - 1)
        
'' Cast ray and get wall information
'CALL CastRay(angle, distance, texture, texpos)
        
'' Calculate wall height
'IF distance > 0 THEN
'height = (heightnumerator \ distance) \ 4
'IF height > MAXWALLHEIGHT THEN height = MAXWALLHEIGHT
'ELSE
'height = MAXWALLHEIGHT
'END IF
        
'' Store wall information
'wallheight(x) = height
'walltexture(x) = texture
'walltexpos(x) = texpos
        
'' Draw wall slice
'CALL DrawWallSlice(x, viewheight2 - height \ 2, viewheight2 + height \ 2, texture, texpos)
'NEXT x
    
'' Update screen
'CALL UpdateScreen
'END SUB

'' Cast a ray and return wall information
'SUB CastRay (angle AS INTEGER, distance AS LONG, texture AS INTEGER, texpos AS INTEGER)
'DIM x AS INTEGER
'DIM y AS INTEGER
'DIM xstep AS INTEGER
'DIM ystep AS INTEGER
'DIM xfrac AS LONG
'DIM yfrac AS LONG
'DIM xintercept AS LONG
'DIM yintercept AS LONG
'DIM xdist AS LONG
'DIM ydist AS LONG
    
'' Calculate step direction
'xstep = sintable(angle) \ 65536
'ystep = costable(angle) \ 65536
    
'' Initialize position
'x = viewx \ TILEGLOBAL
'y = viewy \ TILEGLOBAL
    
'' Calculate intercepts
'IF xstep > 0 THEN
'xintercept = ((x + 1) * TILEGLOBAL - viewx) * sintable(angle + ANGLES/2) \ TILEGLOBAL
'ELSE
'xintercept = (x * TILEGLOBAL - viewx) * sintable(angle + ANGLES/2) \ TILEGLOBAL
'END IF
    
'IF ystep > 0 THEN
'yintercept = ((y + 1) * TILEGLOBAL - viewy) * costable(angle + ANGLES/2) \ TILEGLOBAL
'ELSE
'yintercept = (y * TILEGLOBAL - viewy) * costable(angle + ANGLES/2) \ TILEGLOBAL
'END IF
    
'' DDA algorithm
'DO
'' Check x intersection
'IF ABS(xintercept) < ABS(yintercept) THEN
'x = x + xstep
'xintercept = xintercept + TILEGLOBAL * sintable(angle + ANGLES/2) \ TILEGLOBAL
'IF walls(x, y).tiletype > 0 THEN
'distance = ABS(xintercept)
'texture = walls(x, y).tiletype
'texpos = (viewy + (xintercept * costable(angle)) \ TILEGLOBAL) AND (TILEWIDTH - 1)
'EXIT SUB
'END IF
'ELSE
'' Check y intersection
'y = y + ystep
'yintercept = yintercept + TILEGLOBAL * costable(angle + ANGLES/2) \ TILEGLOBAL
'IF walls(x, y).tiletype > 0 THEN
'distance = ABS(yintercept)
'texture = walls(x, y).tiletype
'texpos = (viewx + (yintercept * sintable(angle)) \ TILEGLOBAL) AND (TILEWIDTH - 1)
'EXIT SUB
'END IF
'END IF
'LOOP UNTIL distance > MAXDIST
'END SUB

'' Move view position
'SUB MoveView (angle AS INTEGER, distance AS LONG)
'DIM newx AS LONG
'DIM newy AS LONG
    
'' Calculate new position
'newx = viewx + (distance * sintable(angle)) \ TILEGLOBAL
'newy = viewy + (distance * costable(angle)) \ TILEGLOBAL
    
'' Check for wall collision
'IF walls(newx \ TILEGLOBAL, newy \ TILEGLOBAL).tiletype = 0 THEN
'viewx = newx
'viewy = newy
'END IF
'END SUB

'' Rotate view angle
'SUB RotateView (angle AS INTEGER)
'viewangle = (viewangle + angle) AND (ANGLES - 1)
'END SUB
