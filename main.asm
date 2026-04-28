; Survival Game
; - player spawns
	;- controlled with WASD
	;- can pick up with E
	;- consume with F
; food spawns randomly
	;- to pick up food, you have to be in a specific radius to pick up with E
; display health/hunger bar
; map can be the window thing we seen in class (the thing where only a portion of the map is visible at a time)
; maybe enemies added on later

INCLUDE Irvine32.inc
; adding constants to get map size and the display for stats the appear on the screen I'm going to keep the fixed layout so all further procedures are dependent on these constants
; this defines the top left of the map and below determines the size of the playable area
; the INNER map is going to be in the playable area where items will spawn and players will be able to interact with them
; bekiw for BOTTOM determines the border parameters on the bottom edge to make a box 
MAP_LEFT = 2
MAP_TOP = 2
MAPW = 68
MAPH = 24

INNER_LEFT = MAP_LEFT + 1
INNER_TOP = MAP_TOP + 1
MAP_RIGHT = MAP_LEFT + MAPW + 1
MAP_BOTTOM = MAP_TOP + MAPH + 1

HUD_LEFT = MAP_RIGHT + 4
HUD_TOP = 2
HUD_WIDTH = 28
HUD_HEIGHT = 23
HUD_RIGHT = HUD_LEFT + HUD_WIDTH - 1
HUD_BOTTOM = HUD_TOP + HUD_HEIGHT

; the display is set here and this will be where the display begins
; the messages on the bottom row are listed and the ending text rows are listed as well
HUD_TEXT_COL = HUD_LEFT + 2
MSG_ROW = MAP_BOTTOM + 2
END_ROW1 = MAP_BOTTOM + 4
END_ROW2 = MAP_BOTTOM + 5

; we are implimenting a limited inventory to make the game more challenging this sets the inventory size the types of items and the length of the day which is in WASD moves
; below are the items ID that are used in an array
MAX_ITEMS = 18
MAX_INV = 6
TURNS_PER_DAY = 10

ITEM_NONE = 0
ITEM_FOOD = 1
ITEM_WATER = 2
ITEM_MED = 3

.data
; this is the title of the game and will show upon startup
titleStr BYTE "=== SURVIVAL ===",0
startPromptStr BYTE "Press any key to start the game...",0
startHintStr   BYTE "Controls: WASD move, E pick up, G gather, F/R/M use items, Q quit",0

; this is just a feature that makes sure the program runs correctly
startStr BYTE "Program initialized.",0

; death message at the end
deathStr BYTE "You have died.",0

; string to print the day (will be followed by the daycount)
dayStr BYTE "Day ",0

player BYTE 'o',0

tickstart DWORD ?
daytime DWORD ?
daycount DWORD 0h
; below are the survival stats for the player of the game
; as the player plays the game the intent is to update these values over time
; for instance when the player will make a move or consume and item
health DWORD 100
hunger DWORD 100
thirst DWORD 100
stamina DWORD 100
; main position for the player on the map
; had an issue with the entire map clearing so this will redraw the cells instead of a clear
playerX DWORD 8
playerY DWORD 8
oldPlayerX DWORD 8
oldPlayerY DWORD 8
; below are inventory counters and state flags for the game to recognize turns game over and exits
; also includes active map storing with arrays and the intent is to use turnCount for day tracking
foodInv DWORD 0
waterInv DWORD 0
medInv DWORD 0
quitFlag DWORD 0
deadFlag DWORD 0
turnCount DWORD 0
messagePtr DWORD OFFSET msgStart
itemX DWORD MAX_ITEMS DUP(0)
itemY DWORD MAX_ITEMS DUP(0)
itemType DWORD MAX_ITEMS DUP(0)
itemActive DWORD MAX_ITEMS DUP(0)
direction DWORD 90

; This is temp storage
tempX DWORD ?
tempY DWORD ?

; these are the possible messages that can appear on the bottom of the screen 
msgMoved  BYTE "You moved.",0
msgBlocked BYTE "You cannot move there.",0
msgPickFood BYTE "Picked up food.",0
msgPickWater BYTE "Picked up water.",0
msgPickMed BYTE "Picked up medicine.",0
msgNoItem BYTE "No item on this tile.",0
msgInvFull BYTE "Inventory full.",0
msgLabel BYTE "Message: ",0
healthLbl BYTE "Health:",0
hungerLbl BYTE "Hunger:",0
thirstLbl BYTE "Thirst:",0
stamLbl BYTE "Stamina:",0
msgDrink BYTE "You drank water.",0
msgNoWater BYTE "No water in inventory.",0

; other possible messages that will also assist the hud 
msgStart        BYTE "Survive as long as you can.",0
msgEat          BYTE "You ate food.",0
msgHeal         BYTE "You used medicine.",0
msgNoFood       BYTE "No food in inventory.",0
msgNoMed        BYTE "No medicine in inventory.",0
msgRiverDrink   BYTE "You drank from the river.",0
msgForestFood   BYTE "You found berries in the forest.",0
msgForestFail   BYTE "You searched the forest and found nothing.",0
msgNoGather     BYTE "Nothing to gather here.",0

hudTitleStr     BYTE "STATUS",0
hudCtrlTitle    BYTE "CONTROLS",0
ctrl1Str        BYTE "WASD   - Move",0
ctrl2Str        BYTE "E      - Pick Up",0
ctrl3Str        BYTE "G      - Gather",0
ctrl4Str        BYTE "F/R/M  - Use Item",0
ctrl5Str        BYTE "Q      - Quit",0

foodLbl         BYTE "Food Inv : ",0
waterInvLbl     BYTE "Water Inv: ",0
medLbl          BYTE "Med Inv  : ",0
dayLbl          BYTE "Day   : ",0
phaseLbl        BYTE "Phase : ",0
turnLbl         BYTE "Turns : ",0
phaseDayStr     BYTE "Day",0
phaseNightStr   BYTE "Night",0

evtHotDay       BYTE "Hot day! Extra water lost.",0
evtColdNight    BYTE "Cold night! Extra stamina lost.",0
evtLuckyFind    BYTE "Lucky day! Extra items appeared.",0
evtShelter      BYTE "Found shelter. Small health gain.",0
evtSpoiled      BYTE "Spoiled supplies. Lost 1 food.",0
evtQuiet        BYTE "Quiet day. Nothing unusual happened.",0

gameOverStr     BYTE "GAME OVER - press any key to exit.",0
quitStr         BYTE "You quit - press any key to exit.",0
finalDaysStr    BYTE "Days survived: ",0

.code

; these are the starter procedure skeletons for the main game
; going to keep filing them out one at a time just using them as placeholders for less confusion
; these to start will be responsible for 
Clamp100 PROC ; stat clamping to get a 0 to 100 range
    ; this will clamp the value of stats from zero to 100 
    ; this will force any value trying to go below zero to be 0
    cmp eax, 0
    jge clamp_hi
    mov eax, 0
    ret
clamp_hi:
    ; this will do the same thing but on the high end
    cmp eax, 100
    jle clamp_done
    mov eax, 100

clamp_done:
    ret
Clamp100 ENDP

GetInvTotal PROC ; inventory count totals and their final result
	; will return the total count of items the player has
 	; the three categories we chose are food water and medicine as inventory items
 	mov eax, foodInv
 	add eax, waterInv
 	add eax, medInv
    ret
GetInvTotal ENDP

MapToScreen PROC ; cooridnate converter from map coords to screen coords
	; EAX for map x and EBX for map y
	; DH and DL will handle screen column and rows
    ; Converts map coordinates into screen coordinates.
    ; will shift coords in playable area rather than at the edge
    add eax, INNER_LEFT
    add ebx, INNER_TOP

    mov dl, al
    mov dh, bl
    ret
MapToScreen ENDP

GetTerrainChar PROC ; adding in terrain features like trees and rivers this will determine where they appear
    ; this returns terrain characters for a single map locaation
    ; below included forests and rivers that will be scattered around the map for player interactions
    cmp eax, 48
    jl checkForest1
    cmp eax, 52
    jg checkForest1
    mov al, '~'
    ret

checkForest1: ; upper left forest
    cmp eax, 6
    jl checkForest2
    cmp eax, 21
    jg checkForest2
    cmp ebx, 4
    jl checkForest2
    cmp ebx, 13
    jg checkForest2
    mov al, 'T'
    ret

checkForest2: ; forest upper middle
    cmp eax, 28
    jl checkForest3
    cmp eax, 32
    jg checkForest3
    cmp ebx, 3
    jl checkForest3
    cmp ebx, 6
    jg checkForest3
    mov al, 'T'
    ret

checkForest3: ; small forest low middle
    cmp eax, 36
    jl checkForest4
    cmp eax, 40
    jg checkForest4
    cmp ebx, 16
    jl checkForest4
    cmp ebx, 19
    jg checkForest4
    mov al, 'T'
    ret

checkForest4: ; small forest lower left
    cmp eax, 12
    jl notForest
    cmp eax, 16
    jg notForest
    cmp ebx, 18
    jl notForest
    cmp ebx, 21
    jg notForest
    mov al, 'T'
    ret

notForest:
    ;if there isnt a forest or river it defaults to plain ground 
    mov al, '.'
    ret
GetTerrainChar ENDP

FindItemAt PROC ; finds an item if there is an active item in that position
    ; will search item arrays for active items and eax will determine if an item is there 
    ; if eax is -1 there is no active item

    push ecx
    push edx

    mov ecx, 0

find_loop:
    cmp ecx, MAX_ITEMS
    jge not_found

    ; The following is supposed to check active item spots 
    ; checking x and y coords 
    ; and match if an active item is found
    mov edx, itemActive[ecx*4]
    cmp edx, 1
    jne next_item

    mov edx, itemX[ecx*4]
    cmp edx, eax
    jne next_item

    mov edx, itemY[ecx*4]
    cmp edx, ebx
    jne next_item

    mov eax, ecx
    pop edx
    pop ecx
    ret

next_item:
    inc ecx
    jmp find_loop

not_found:
    mov eax, -1
    pop edx
    pop ecx
    ret
FindItemAt ENDP


DrawBox PROC ; border box
; will draw a rectangular boarder
; EAX will be left col EBX is the top row ECX is width and EDX is height
; going to be used later when the map is fully set up 
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    ; this will save coords
    mov tempX, eax
    mov tempY, ebx
    mov esi, ecx
    mov edi, edx

    ; This is the top boarder
    mov dl, BYTE PTR tempX
    mov dh, BYTE PTR tempY
    call GotoXY

    mov ecx, esi
top_loop:
    mov al, '*'
    call WriteChar
    loop top_loop

    ; this is the bottom border
    mov eax, tempY
    add eax, edi
    dec eax
    mov dh, al
    mov dl, BYTE PTR tempX
    call GotoXY

    mov ecx, esi
bottom_loop:
    mov al, '*'
    call WriteChar
    loop bottom_loop

    ; this is going to be responsible for drawing the left side
    mov eax, tempY
    inc eax
left_loop:
    mov ebx, tempY
    add ebx, edi
    dec ebx
    cmp eax, ebx
    jge right_border

    mov dl, BYTE PTR tempX
    mov dh, al
    call GotoXY
    mov al, '*'
    call WriteChar

    inc eax
    jmp left_loop
; for right border
right_border:
    mov eax, tempX
    add eax, esi
    dec eax
    mov tempX, eax

    mov eax, tempY
    inc eax
right_loop:
    mov ebx, tempY
    add ebx, edi
    dec ebx
    cmp eax, ebx
    jge box_done

    mov dl, BYTE PTR tempX
    mov dh, al
    call GotoXY
    mov al, '*'
    call WriteChar

    inc eax
    jmp right_loop

box_done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawBox ENDP

DrawFrame PROC ; title and border
; will draw the static layout of the map
; clears the screen and adds borders for map and player display
    push eax
    push ebx
    push ecx
    push edx
    call Clrscr
    ; this draws the title and below draws border for map and display
	 mov eax, yellow + (black * 16)
	 call SetTextColor
	
	 ; this draws the title and below draws border for map and display
	 mov dl, 2
	 mov dh, 0
	 call GotoXY
	 mov edx, OFFSET titleStr
	 call WriteString
	
	 mov eax, MAP_LEFT
	 mov ebx, MAP_TOP
	 mov ecx, MAPW + 2
	 mov edx, MAPH + 2
	 call DrawBox
	
	 mov eax, HUD_LEFT
	 mov ebx, HUD_TOP
	 mov ecx, HUD_WIDTH
	 mov edx, HUD_HEIGHT
	 call DrawBox
	 ; hud labels And controls here
	 mov eax, lightGray + (black * 16)
	 call SetTextColor
	
	 mov dl, HUD_TEXT_COL
	 mov dh, HUD_TOP + 1
	 call GotoXY
	 mov edx, OFFSET hudTitleStr
	 call WriteString
	
	 mov dl, HUD_TEXT_COL
	 mov dh, HUD_TOP + 15
	 call GotoXY
	 mov edx, OFFSET hudCtrlTitle
	 call WriteString
	
	 mov dl, HUD_TEXT_COL
	 mov dh, HUD_TOP + 16
	 call GotoXY
	 mov edx, OFFSET ctrl1Str
	 call WriteString
	
	 mov dl, HUD_TEXT_COL
	 mov dh, HUD_TOP + 17
	 call GotoXY
	 mov edx, OFFSET ctrl2Str
	 call WriteString
	
	 mov dl, HUD_TEXT_COL
	 mov dh, HUD_TOP + 18
	 call GotoXY
	 mov edx, OFFSET ctrl3Str
	 call WriteString
	
	 mov dl, HUD_TEXT_COL
	 mov dh, HUD_TOP + 19
	 call GotoXY
	 mov edx, OFFSET ctrl4Str
	 call WriteString
	
	 mov dl, HUD_TEXT_COL
	 mov dh, HUD_TOP + 20
	 call GotoXY
	 mov edx, OFFSET ctrl5Str
	 call WriteString
	
	 pop edx
	 pop ecx
	 pop ebx
	 pop eax
	 ret
DrawFrame ENDP
; same thing as before these are going to be the skeleton procs for the program
; adding them in to avoid confusion
DrawMapCell PROC ; will draw the map with the terrain players and items included
; only implimenting drawing terrain cells for this commit that is the main goal below

    push eax
    push ebx
    push ecx
    push edx
    push esi

    ; Save original map coordinates for comparisons
    mov ecx, eax
    mov esi, ebx

    ; converts map coords to screen coords
    call MapToScreen
    call GotoXY
    ; if the tile is in the players position it draws the player first
    cmp ecx, playerX
    jne check_item
    cmp esi, playerY
    jne check_item

    mov al, 'o'
    call WriteChar
    jmp cell_done
check_item:
    ; draws and item instead of terrain if there is an item that should exist at a specific tile
    ; the type of item is determined by the symbol
    mov eax, ecx
    mov ebx, esi
    call FindItemAt
    cmp eax, -1
    je draw_terrain

    ; EAX will now hold the item index
    mov edx, eax
    mov eax, itemType[edx*4]

    cmp eax, ITEM_FOOD
    jne chk_water
    mov al, 'f'
    call WriteChar
    jmp cell_done

chk_water:
    cmp eax, ITEM_WATER
    jne chk_med
    mov al, 'w'
    call WriteChar
    jmp cell_done

chk_med:
    mov al, 'm'
    call WriteChar
    jmp cell_done

draw_terrain: ; draw terrain added so it will draw terrain if there are not items in the way 
    mov eax, ecx
    mov ebx, esi
    call GetTerrainChar

    cmp al, 'T'
    jne chk_river
    mov al, 'T'
    call WriteChar
    jmp cell_done


chk_river:
    ; river or water feature will be seen as ~
    cmp al, '~'
    jne draw_plain
    mov al, '~'
    call WriteChar
    jmp cell_done
draw_plain:
    mov al, '.'
    call WriteChar
cell_done:
   pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
	ret
DrawMapCell ENDP

DrawTerrain PROC ; map terrain drawn at startup
    ; this will loop over the maps coords and draw tiles upon startup
    ; it will start at the first row and col and stop after the last 

    push eax
    push ebx
    push ecx
    mov ebx, 0

row_loop:
    cmp ebx, MAPH
    jge terrain_done
    mov ecx, 0

col_loop:
    cmp ecx, MAPW
    jge next_row
    ; draws current tile and moves to the next col and row
    ; Draw the current tile.
    mov eax, ecx
    push ebx
    call DrawMapCell
    pop ebx
    inc ecx
    jmp col_loop

next_row:
    inc ebx
    jmp row_loop

terrain_done:
    pop ecx
    pop ebx
    pop eax
    ret
DrawTerrain ENDP

SpawnOneItem PROC ; will spawns one random item on a valid point
    ; finds an item spot that is free 
    ; and will pick a random map coord
    ; not allowed to place on a player spot
    push eax
    push ebx
    push ecx
	push edx
    push esi
    mov esi, 0
find_slot:
    cmp esi, MAX_ITEMS
    jge spawn_done
    cmp itemActive[esi*4], 0
    je slot_found
    inc esi
    jmp find_slot

slot_found:
spawn_try: ; spawns on random map coord as stated above
    mov eax, MAPW
    call RandomRange
    mov tempX, eax

    mov eax, MAPH
    call RandomRange
    mov tempY, eax
    ; cant place on top of a player
    mov eax, tempX
    cmp eax, playerX
    jne check_overlap
    mov eax, tempY
    cmp eax, playerY
    je spawn_try
; cant place on a spot that with another item occupying it 
check_overlap:
    mov eax, tempX
    mov ebx, tempY
    call FindItemAt
    cmp eax, -1
    jne spawn_try
    mov eax, 3
    call RandomRange
    inc eax
    mov itemType[esi*4], eax
    mov eax, tempX
    mov itemX[esi*4], eax
    mov eax, tempY
    mov itemY[esi*4], eax
    mov itemActive[esi*4], 1
    mov eax, itemX[esi*4]
    mov ebx, itemY[esi*4]
    call DrawMapCell

spawn_done:
    pop esi
	pop edx
    pop ecx
    pop ebx
    pop eax
    ret
SpawnOneItem ENDP

SpawnInitialItems PROC ; at startup this will initially spawn a random set of items
    ; this will populate the map upon startup
    ; so the game is not starting with no items these will be the initial day 1 items
    mov ecx, 8
spawn_loop:
    push ecx
    call SpawnOneItem
    pop ecx
    loop spawn_loop
    ret
SpawnInitialItems ENDP

DrawBar PROC ; responsible for hud drawing and status bars
    ; ECX is the offset of the label string, eax will give the stat value, and dh is the row to be drawn
    ; below saves the valur and raw and draws the label
    push eax
    push ebx
    push ecx
    push edx
    push esi
    mov esi, eax
    mov bl, dh
    push ebx ; push current row
    mov dl, HUD_TEXT_COL
    mov dh, bl
    call GotoXY

    mov edx, ecx
    call WriteString

    ; computes the filled blocks out of 10 
    ; and moves the bar
    mov eax, esi
    mov ebx, 10
    xor edx, edx
    div ebx
    mov ecx, eax
    mov dl, HUD_TEXT_COL + 12
    pop ebx ; pop current row
    mov dh, bl
    call GotoXY
fill_loop:
    cmp ecx, 0
    je empty_setup
    mov al, '*'
    call WriteChar
    dec ecx
    jmp fill_loop
empty_setup:
    mov eax, esi
    mov ebx, 10
    xor edx, edx
    div ebx
    mov ecx, 10
    sub ecx, eax
empty_loop:
    cmp ecx, 0
    je bar_done
    mov al, '-'
    call WriteChar
    dec ecx
    jmp empty_loop
bar_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawBar ENDP

UpdateHUD PROC ; will update the display
    ; all will be shown on the right hand side of the screen
    push eax
    push ecx
    push edx
    ; This is the health bar
    mov eax, red + (black * 16)
    call SetTextColor
    mov eax, health
    mov edx, OFFSET healthLbl
    mov dh, HUD_TOP + 3
    call DrawBar
    ; This is the hunger bar
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov eax, hunger
    mov edx, OFFSET hungerLbl
    mov dh, HUD_TOP + 4
    call DrawBar
    ; This is the thirst bar
    mov eax, lightBlue + (black * 16)
    call SetTextColor
    mov eax, thirst
    mov edx, OFFSET thirstLbl
    mov dh, HUD_TOP + 5
    call DrawBar
    ; this will be the Stamina bar
    mov eax, stamina
    mov edx, OFFSET stamLbl
    mov dh, HUD_TOP + 6
    call DrawBar
    ; finally this is the stamina bar
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov eax, stamina
    mov ecx, OFFSET stamLbl
    mov dh, HUD_TOP + 8
    call DrawBar
    mov eax, white + (black * 16)
    call SetTextColor

    ; this will be the Food inventory
    mov dl, HUD_TEXT_COL
    mov dh, HUD_TOP + 8
    call GotoXY
    mov edx, OFFSET foodLbl
    call WriteString
    mov dl, HUD_TEXT_COL + 11
    mov dh, HUD_TOP + 8
    call GotoXY
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    mov dl, HUD_TEXT_COL + 11
    mov dh, HUD_TOP + 8
	 call GotoXY
	 mov eax, foodInv
	 call WriteDec
	
	 ; this will be the water inventory 
	 mov dl, HUD_TEXT_COL
	 mov dh, HUD_TOP + 9
	 call GotoXY
	 mov edx, OFFSET waterInvLbl
	 call WriteString
	 mov dl, HUD_TEXT_COL + 11
	 mov dh, HUD_TOP + 9
	 call GotoXY
	 mov al, ' '
	 call WriteChar
	 call WriteChar
	 call WriteChar
	 mov dl, HUD_TEXT_COL + 11
	 mov dh, HUD_TOP + 9
	
	 call GotoXY
	 mov eax, waterInv
	 call WriteDec
	
	 ; this will be the Medicine inventory
	 mov dl, HUD_TEXT_COL
	 mov dh, HUD_TOP + 10
	 call GotoXY
	 mov edx, OFFSET medLbl
	 call WriteString
	 mov dl, HUD_TEXT_COL + 11
	 mov dh, HUD_TOP + 10
	 call GotoXY
	 mov al, ' '
	 call WriteChar
	 call WriteChar
	 call WriteChar
	 mov dl, HUD_TEXT_COL + 11
	 mov dh, HUD_TOP + 10
    ret
UpdateHUD ENDP

UpdateMessage PROC ; message line refresher
    ; This will draw the message needed at the bottom of the screen 
    ; Clears the row first so there are no text remaining when a new message pops up 

    push eax
    push ecx
    push edx

    ; responsible for clearing the message row
    mov dl, 2
    mov dh, MSG_ROW
    call GotoXY
    mov ecx, HUD_RIGHT

clear_msg:
    mov al, ' '
    call WriteChar
    loop clear_msg

    ; will print the message needed 
    mov dl, 2
    mov dh, MSG_ROW
    call GotoXY
    mov edx, OFFSET msgLabel
    call WriteString

    mov edx, messagePtr
    call WriteString

    pop edx
    pop ecx
    pop eax
    ret
UpdateMessage ENDP

DailyEvent PROC ; we want to impliment random daily events this is the placeholder for those
    push eax

    mov eax, 6
    call RandomRange
    ; I added this event so the player can lose extra water on some days
    cmp eax, 0
    jne evt1
    mov eax, thirst
    sub eax, 10
    call Clamp100
    mov thirst, eax
    mov messagePtr, OFFSET evtHotDay
    jmp evt_done
; daily event 1 cold night you lose stamina 
evt1:
    cmp eax, 1
    jne evt2
    mov eax, stamina
    sub eax, 10
    call Clamp100
    mov stamina, eax
    mov messagePtr, OFFSET evtColdNight
    jmp evt_done
; daily event 2 luck makes more items spawn
evt2:
    cmp eax, 2
    jne evt3
    mov messagePtr, OFFSET evtLuckyFind
    call SpawnOneItem
    call SpawnOneItem
    jmp evt_done
; daily event 3 you found shelter 
evt3:
    cmp eax, 3
    jne evt4
    mov eax, health
    add eax, 8
    call Clamp100
    mov health, eax
    mov messagePtr, OFFSET evtShelter
    jmp evt_done
; daily event 4 food got spoiled inventory decreases
evt4:
    cmp eax, 4
    jne evt5
    cmp foodInv, 0
    jle spoiled_done
    dec foodInv
spoiled_done:
    mov messagePtr, OFFSET evtSpoiled
    jmp evt_done
; daily event 5 means everything quiet nothing is happening on this day 
evt5:
    mov messagePtr, OFFSET evtQuiet

evt_done:
    pop eax
    ret
DailyEvent ENDP

AdvanceDay PROC ; stat loss and day to day updates will happen here
   push eax

    ; the day will advance and the counter is reset 
    inc daycount
    mov turnCount, 0

    ; each day stats are reduced below are the stats this is hunger
    mov eax, hunger
    sub eax, 12
    call Clamp100
    mov hunger, eax
    ; each new day lowers thirst
    mov eax, thirst
    sub eax, 15
    call Clamp100
    mov thirst, eax
    ; each new day will lower stamina
    mov eax, stamina
    sub eax, 8
    call Clamp100
    mov stamina, eax
    ; if your hunger is now at a value of 0
    ; your health with start to drop as well
    cmp hunger, 0
    jne chkThirst
    mov eax, health
    sub eax, 10
    call Clamp100
    mov health, eax

chkThirst: 
    ; if your thirst is now at a value of 0
    ; your health with start to drop as well
    cmp thirst, 0
    jne chkStam
    mov eax, health
    sub eax, 10
    call Clamp100
    mov health, eax

chkStam:
    ; if your stamina is now at a value of 0
    ; your health with start to drop as well
    cmp stamina, 0
    jne phase_effect
    mov eax, health
    sub eax, 5
    call Clamp100
    mov health, eax
phase_effect:
    ; keeps the day and night by seeing even numbers as night 
    ; this will apply extra stamina loss
    mov eax, daycount
    and eax, 1
    cmp eax, 0
    jne spawn_and_event
    mov eax, stamina
    sub eax, 5
    call Clamp100
    mov stamina, eax
spawn_and_event:
    ; each day adds more items to the map
    ; and also the random daily event is triggered
    call SpawnOneItem
    call SpawnOneItem
    call DailyEvent
    ; if the health of the player turns out to be zero
    ; the player is dead
    cmp health, 0
    jne adv_done
    mov deadFlag, 1

adv_done:
    pop eax
    ret
AdvanceDay ENDP
; same thing as before these are going to be the skeleton procs for the program
; adding them in to avoid confusion
AdvanceTurn PROC ; turn counter will determine length of day here
    ; everytime there is a successful action by the player it is counted as a turn
    ; this includes moving picking things up gathering or using items
    inc turnCount
    ; a new day is started when the turn counter has reached it's limit
    ; a new day should begin
    cmp turnCount, TURNS_PER_DAY
    jl no_day_pass
    call AdvanceDay
no_day_pass:
    ; after each turn that is completed the hud will be updated
    ; and the bottom message will be refreshed
    call UpdateHUD
    call UpdateMessage
    ret
AdvanceTurn ENDP

TryMove PROC ; will eventually move the player on the map
    ; saves old player positions and applies movement 
    ; blocks any movement that would violate the border boundaries we have set

    push ecx
    push edx

    mov ecx, playerX
    mov edx, playerY
    mov oldPlayerX, ecx
    mov oldPlayerY, edx
    add ecx, eax
    add edx, ebx
    cmp ecx, 0
    jl blocked
    cmp ecx, MAPW
    jge blocked
    cmp edx, 0
    jl blocked
    cmp edx, MAPH
    jge blocked

    ; gives a new position and redraws the old and new tiles 
    mov playerX, ecx
    mov playerY, edx
    ; mvement will cost stamina
    mov eax, stamina
    sub eax, 1
    call Clamp100
    mov stamina, eax
    ; redraws old tile so it goes back to being terrain
    mov eax, oldPlayerX
    mov ebx, oldPlayerY
    call DrawMapCell
    ; draws a player at its new location
    mov eax, playerX
    mov ebx, playerY
    call DrawMapCell
    ; if the move is successful then the movement updates and the message also and it spends one turn 
    mov messagePtr, OFFSET msgMoved
    call AdvanceTurn
    jmp move_done

blocked:
    mov messagePtr, OFFSET msgBlocked
    call UpdateMessage

move_done:
    pop edx
    pop ecx
    ret
TryMove ENDP

TryPickup PROC ; will be responsible for picking items up
    push eax
    push ebx
    push esi

    ; checks inventory total size
    ; can_pick looks for an item at the current players location
    call GetInvTotal
    cmp eax, MAX_INV
    jl can_pick
    mov messagePtr, OFFSET msgInvFull
    call UpdateMessage
    jmp pickup_done

can_pick:
    mov eax, playerX
    mov ebx, playerY
    call FindItemAt
    cmp eax, -1
    jne found_item
    mov messagePtr, OFFSET msgNoItem
    call UpdateMessage
    jmp pickup_done

found_item:
    mov esi, eax
    mov eax, itemType[esi*4]

    ; responsible for adding items to inventory at the correct inventory spot
    cmp eax, ITEM_FOOD
    jne pick_water
    inc foodInv
    mov messagePtr, OFFSET msgPickFood
    jmp clear_item

pick_water:
    cmp eax, ITEM_WATER
    jne pick_med
    inc waterInv
    mov messagePtr, OFFSET msgPickWater
    jmp clear_item

pick_med:
    inc medInv
    mov messagePtr, OFFSET msgPickMed

clear_item:
    ; once an item is picked up it is deactivated from the map
    ; so it no longer appears in the item arrays
    mov itemActive[esi*4], 0
    ; symbols will vanish now and the current til is redrawn
    mov eax, playerX
    mov ebx, playerY
    call DrawMapCell
    ; a pickup is an action and will cost a turn
    call AdvanceTurn

pickup_done:
    pop esi
    pop ebx
    pop eax
    ret
TryPickup ENDP

TryGather PROC ; want to add a gather feature along with a pickup feature when you are in a forested area it will be here
    ret
TryGather ENDP

UseFood PROC ; for consuming food
    push eax
    ; if there is no food to be consumed it will do nothing
    cmp foodInv, 0
    jg have_food
    mov messagePtr, OFFSET msgNoFood
    call UpdateMessage
    jmp done_food
have_food:
    ; will remove exactly one item of food from hte players inventory 
    ; then it will restore the players hunger stat
    dec foodInv
    ; refreshed the hud after the player consumes food and restores hunger and stamina
    ; eating restores hunger
    mov eax, hunger
    add eax, 25
    call Clamp100
    mov hunger, eax
    ; eating also restores stamina
    mov eax, stamina
    add eax, 5
    call Clamp100
    mov stamina, eax
    ; will also spend exactly one turn
    mov messagePtr, OFFSET msgEat
    call AdvanceTurn

done_food:

    pop eax
    ret
UseFood ENDP

UseWater PROC ; for consuming water
    push eax

    ; if there is no food to be consumed it will do nothing
    cmp waterInv, 0
    jg have_water
    mov messagePtr, OFFSET msgNoWater
    call UpdateMessage
    call UpdateMessage
    jmp done_water
have_water:
    ; will remove exactly one item of food from the players inventory 
    ; then it will restore the players hunger stat
    dec waterInv
    ; clamped to 100
    ; refreshed the hud after the player consumes water
    mov eax, thirst
    add eax, 30
    call Clamp100
    mov thirst, eax

    ; drinking uses a turn in the finished game
    mov messagePtr, OFFSET msgDrink
    call AdvanceTurn
done_water:
    pop eax
    ret
UseWater ENDP

UseMedicine PROC ; for consuming medicine
    push eax
    cmp medInv, 0 ; if there is no meds to be consumed it will do nothing
    jg have_meds
    mov messagePtr, OFFSET msgNoMed
    call UpdateMessage
    jmp done_med
have_meds:
    ; will remove exactly one item of meds from the players inventory 
    dec medInv
    ; clamped to 100
    ; refreshed the hud after the player consumes water
    ; mov messagePtr, OFFSET msgMeds
    mov eax, health
    add eax, 20
    call Clamp100
    mov health, eax

    ; using medicine also costs a turn
    mov messagePtr, OFFSET msgHeal
    call AdvanceTurn
done_med:

    pop eax
    ret
UseMedicine ENDP

HandleInput PROC ; going to be responsible for handling keyboard inputs
    ; This first version only reads one key and supports quitting.
    ; More controls will be added in later commits.
    call ReadChar
    ; These qill be the keys set the quit the game
    cmp al, 'q'
    je do_quit
    cmp al, 'Q'
    je do_quit
    ; These will be the movement keys
    cmp al, 'w'
    je move_up
    cmp al, 'W'
    je move_up
    cmp al, 's'
    je move_down
    cmp al, 'S'
    je move_down
    cmp al, 'a'
    je move_left
    cmp al, 'A'
    je move_left
    cmp al, 'd'
    je move_right
    cmp al, 'D'
    je move_right
    ; key used to pick up items
    cmp al, 'e'
    je do_pickup
    cmp al, 'E'
    je do_pickup
    ; gather command
    cmp al, 'g'
    je do_gather
    cmp al, 'G'
    je do_gather
    ; eat food keys
    cmp al, 'f'
    je do_food
    cmp al, 'F'
    je do_food
    ; drink water keys
    cmp al, 'r'
    je do_water
    cmp al, 'R'
    je do_water
    ; use medicine keys
    cmp al, 'm'
    je do_med
    cmp al, 'M'
    je do_med
    ret
move_up:
    mov eax, 0
    mov ebx, -1
    call TryMove
    ret
move_down:
    mov eax, 0
    mov ebx, 1
    call TryMove
    ret
move_left:
    mov eax, -1
    mov ebx, 0
    call TryMove
    ret
move_right:
    mov eax, 1
    mov ebx, 0
    call TryMove
    ret
do_food:
    call UseFood
    ret
do_med:
    call UseMedicine
    ret
do_water:
    call UseWater
    ret
do_pickup:
    call TryPickup
    ret
do_gather:
    call TryGather
    ret
do_quit:
    mov quitFlag, 1
    ret
HandleInput ENDP

InitGame PROC ; the initialization of the stats, inventory items, and position of the player
    ; initialize position of player in the center of the screen
    ; init direction to be right
    ; sets the starting position for the player 
    ; moves the cursor the the players start position
    ; also will draw the character of the player
    ; Set starting player position.
  call Randomize
    ; resets players direction and the starting map position
    mov direction, 90
    mov playerX, 8
    mov playerY, 8
    mov oldPlayerX, 8
    mov oldPlayerY, 8
    ; resets stats
    mov health, 100
    mov hunger, 100
    mov thirst, 100
    mov stamina, 100
    ; clears inventory and game flags
    mov foodInv, 0
    mov waterInv, 0
    mov medInv, 0
    mov quitFlag, 0
    mov deadFlag, 0
    mov turnCount, 0
    mov daycount, 1
    mov messagePtr, OFFSET msgStart
    ; clears item arrays
    mov ecx, 0
clear_items:
    cmp ecx, MAX_ITEMS
    jge init_done
    mov itemActive[ecx*4], 0
    mov itemType[ecx*4], 0
    mov itemX[ecx*4], 0
    mov itemY[ecx*4], 0
    inc ecx
    jmp clear_items

init_done:
    ret
InitGame ENDP

ShowEndScreen PROC ; the final result of each game will be held here
    ; clear the screen
    call ClrScr
    ; show the death message in the middle in red(row 15 col 60)
    mov dx, 0
    mov dl, 60
    mov dh, 15
    call GotoXY
    mov eax, red + (black*16) ; Set text color to red on black background
	call SetTextColor 
    mov edx, OFFSET deathStr
    call WriteString
    ; (optional) show ending stats

    ; reset color
    mov eax, white + (black*16) ; Set text color to white on black background
	call SetTextColor 
    ret
ShowEndScreen ENDP

main PROC
; this will clear the console so the screen is clean then will print the game title and startup 
; WaitMSG pauses briefly so the window doesn't close immediately
    call Clrscr ; clears the screen and shows title

    mov eax, yellow + (black * 16)
    call SetTextColor

    mov dl, 25
    mov dh, 10
    call GotoXY
    mov edx, OFFSET titleStr
    call WriteString

    ; there will also be some startup instruction added to the final version of the game
    mov eax, lightGray + (black * 16)
    call SetTextColor
    mov dl, 18
    mov dh, 12
    call GotoXY
    mov edx, OFFSET startPromptStr
    call WriteString

    mov dl, 5
    mov dh, 14
    call GotoXY
    mov edx, OFFSET startHintStr
    call WriteString

    ; waits for a key to be pressed to start the game
    call ReadChar

    ; initializes the game state by calling procedures
    call InitGame
    call DrawFrame
    call DrawTerrain
    call SpawnInitialItems
    call UpdateHUD
    call UpdateMessage

    mov eax, playerX
    mov ebx, playerY
    call DrawMapCell

    call gameLoop
    call ShowEndScreen
    exit
main ENDP

; The main game loop
gameLoop PROC
    ; records the startin tick count for the current day and checks how much time has passed since the start of the day
    ; Record the starting tick count for the current day.
game:
    ; stop if a procedure marks the player dead
    cmp deadFlag, 1
    je done_game

    ; this is going to be used as a backup dead check
    cmp health, 0
    jg still_alive
    mov deadFlag, 1
    jmp done_game

still_alive:
    ; if a player quits the game then the game stops
    cmp quitFlag, 1
    je done_game
    ; processes one key input and continues looping
    call HandleInput
    jmp game


done_game:
    ret
gameLoop ENDP
END main
