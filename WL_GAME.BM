' WL_GAME.BAS - Game Logic and State Management for Wolfenstein 3D QB64 port

'$INCLUDE: 'wl_def.bi'
'$INCLUDE: 'wl_input.bi'
'$INCLUDE: 'wl_render.bi'

' Game Constants
CONST MOVESPEED = 1000
CONST TURNSPEED = 100
CONST FIRESPEED = 500
CONST PLAYERHEIGHT = 32

' Game Variables
DIM SHARED playstate AS INTEGER
DIM SHARED gametic AS INTEGER
DIM SHARED lasttic AS INTEGER
DIM SHARED lastfire AS INTEGER
DIM SHARED lastmove AS INTEGER
DIM SHARED lastturn AS INTEGER

' Initialize game
SUB InitGame
    ' Initialize game state
    playstate = ex_stillplaying
    gametic = 0
    lasttic = TIMER
    lastfire = 0
    lastmove = 0
    lastturn = 0
    
    ' Initialize player
    player.x = 32 * TILEGLOBAL
    player.y = 32 * TILEGLOBAL
    player.angle = 0
    player.health = 100
    player.ammo = 50
    player.weapon = wp_pistol
    player.chosenweapon = wp_pistol
    player.bestweapon = wp_pistol
    
    ' Initialize game systems
    CALL InitInput
    CALL InitRender
    CALL InitGraphics
END SUB

' Main game loop
SUB GameLoop
    DIM currenttic AS SINGLE
    DIM deltatic AS SINGLE
    
    DO
        ' Calculate time delta
        currenttic = TIMER
        deltatic = currenttic - lasttic
        lasttic = currenttic
        gametic = gametic + 1
        
        ' Handle input
        CALL UpdateInput
        CALL HandleInput
        
        ' Update game state
        CALL UpdateGame
        
        ' Render view
        CALL RenderView
        
        ' Limit frame rate
        _LIMIT 60
    LOOP UNTIL playstate <> ex_stillplaying
END SUB

' Handle player input
SUB HandleInput
    DIM move AS INTEGER
    DIM turn AS INTEGER
    
    ' Movement
    IF KeyPressed(KEY_UP) THEN
        move = MOVESPEED
    ELSEIF KeyPressed(KEY_DOWN) THEN
        move = -MOVESPEED
    ELSE
        move = 0
    END IF
    
    ' Turning
    IF KeyPressed(KEY_LEFT) THEN
        turn = TURNSPEED
    ELSEIF KeyPressed(KEY_RIGHT) THEN
        turn = -TURNSPEED
    ELSE
        turn = 0
    END IF
    
    ' Apply movement
    IF move <> 0 AND TIMER - lastmove >= 0.016 THEN
        CALL MoveView(player.angle, move)
        lastmove = TIMER
    END IF
    
    ' Apply turning
    IF turn <> 0 AND TIMER - lastturn >= 0.016 THEN
        CALL RotateView(turn)
        lastturn = TIMER
    END IF
    
    ' Firing
    IF KeyPressed(KEY_SPACE) AND TIMER - lastfire >= 0.5 THEN
        CALL FireWeapon
        lastfire = TIMER
    END IF
    
    ' Exit game
    IF KeyPressed(KEY_ESC) THEN
        playstate = ex_quittomenu
    END IF
END SUB

' Update game state
SUB UpdateGame
    ' Update actors
    CALL UpdateActors
    
    ' Check for game over conditions
    IF player.health <= 0 THEN
        playstate = ex_died
    END IF
END SUB

' Update all actors
SUB UpdateActors
    DIM i AS INTEGER
    
    FOR i = 0 TO MAXACTORS - 1
        IF actors(i).active = ac_ready THEN
            CALL UpdateActor(i)
        END IF
    NEXT i
END SUB

' Update a single actor
SUB UpdateActor (actorNum AS INTEGER)
    DIM actor AS ActorType
    actor = actors(actorNum)
    
    ' Update actor position
    actor.x = actor.x + actor.xmove
    actor.y = actor.y + actor.ymove
    
    ' Update actor animation
    actor.ticcount = actor.ticcount + 1
    IF actor.ticcount >= actor.speed THEN
        actor.ticcount = 0
        ' Update animation frame here
    END IF
    
    ' Check for collisions
    IF walls(actor.x \ TILEGLOBAL, actor.y \ TILEGLOBAL).tiletype > 0 THEN
        ' Handle collision
        actor.x = actor.x - actor.xmove
        actor.y = actor.y - actor.ymove
    END IF
    
    actors(actorNum) = actor
END SUB

' Fire current weapon
SUB FireWeapon
    DIM damage AS INTEGER
    
    ' Check ammo
    IF player.ammo <= 0 THEN
        ' Play empty sound
        EXIT SUB
    END IF
    
    ' Use ammo
    player.ammo = player.ammo - 1
    
    ' Calculate damage based on weapon
    SELECT CASE player.weapon
        CASE wp_knife
            damage = 10
        CASE wp_pistol
            damage = 25
        CASE wp_machinegun
            damage = 15
        CASE wp_chaingun
            damage = 20
    END SELECT
    
    ' Check for hits
    CALL CheckWeaponHit(damage)
END SUB

' Check if weapon hit anything
SUB CheckWeaponHit (damage AS INTEGER)
    DIM i AS INTEGER
    DIM dx AS LONG
    DIM dy AS LONG
    DIM dist AS LONG
    
    FOR i = 0 TO MAXACTORS - 1
        IF actors(i).active = ac_ready THEN
            ' Calculate distance to actor
            dx = actors(i).x - player.x
            dy = actors(i).y - player.y
            dist = (dx * dx + dy * dy) \ TILEGLOBAL
            
            ' Check if actor is in front of player and within range
            IF dist < 10 THEN
                ' Apply damage
                actors(i).health = actors(i).health - damage
                IF actors(i).health <= 0 THEN
                    actors(i).active = ac_dying
                END IF
            END IF
        END IF
    NEXT i
END SUB 