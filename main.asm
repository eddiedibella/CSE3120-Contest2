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
itemX DWORD MAX_ITEMS DUP(0)
itemY DWORD MAX_ITEMS DUP(0)
itemType DWORD MAX_ITEMS DUP(0)
itemActive DWORD MAX_ITEMS DUP(0)
direction DWORD 90

; This is temp storage
tempX DWORD ?
tempY DWORD ?

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
    ret
GetTerrainChar ENDP

FindItemAt PROC ; finds an item if there is an active item in that position
    ret
FindItemAt ENDP

DrawBox PROC ; border box
    ret
DrawBox ENDP

DrawFrame PROC ; title and border
    ret
DrawFrame ENDP
; same thing as before these are going to be the skeleton procs for the program
; adding them in to avoid confusion
DrawMapCell PROC ; will draw the map with the terrain players and items included
    ret
DrawMapCell ENDP

DrawTerrain PROC ; map terrain drawn at startup
    ret
DrawTerrain ENDP

SpawnOneItem PROC ; will spawns one random item on a valid point
    ret
SpawnOneItem ENDP

SpawnInitialItems PROC ; at startup this will initially spawn a random set of items
    ret
SpawnInitialItems ENDP

DrawBar PROC ; responsible for hud drawing and status bars
    ret
DrawBar ENDP

UpdateHUD PROC ; will update the display
    ret
UpdateHUD ENDP

UpdateMessage PROC ; message line refresher
    ret
UpdateMessage ENDP

DailyEvent PROC ; we want to impliment random daily events this is the placeholder for those
    ret
DailyEvent ENDP

AdvanceDay PROC ; stat loss and day to day updates will happen here
    ret
AdvanceDay ENDP
; same thing as before these are going to be the skeleton procs for the program
; adding them in to avoid confusion
AdvanceTurn PROC ; turn counter will determine length of day here
    ret
AdvanceTurn ENDP

TryMove PROC ; will eventually move the player on the map
    ret
TryMove ENDP

TryPickup PROC ; will be responsible for picking items up
    ret
TryPickup ENDP

TryGather PROC ; want to add a gather feature along with a pickup feature when you are in a forested area it will be here
    ret
TryGather ENDP

UseFood PROC ; for consuming food
    ret
UseFood ENDP

UseWater PROC ; for consuming water
    ret
UseWater ENDP

UseMedicine PROC ; for consuming medicine
    ret
UseMedicine ENDP

HandleInput PROC ; going to be responsible for handling keyboard inputs
    ret
HandleInput ENDP

InitGame PROC ; the initialization of the stats, inventory items, and position of the player
    ; initialize position of player in the center of the screen
    ; init direction to be right
    mov direction, 90
    ; move to row15, col60 and update corresponding variables
    mov playerX, 60
    mov playerY, 15
    mov eax, playerX
    mov dl, al
    mov eax, playerY
    mov dh, al
    call GotoXY
    mov al, player
    call WriteChar
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
    call Clrscr

    mov edx, OFFSET titleStr
    call WriteString
    call Crlf

    mov edx, OFFSET startStr
    call WriteString
    call Crlf

    call WaitMsg

    mov daytime, 5000 ; time of day in ms

    call InitGame ; initialize the player, stats, and inventory items
    call gameLoop

	exit
main ENDP

; The main game loop
gameLoop PROC
    call GetTickCount
    mov tickstart, eax

game:
    call GetTickCount
    mov ecx, eax
    call debug ; remove when done

    sub eax, tickstart
    cmp eax, daytime
    jb sameday
    ; if we got here, daytime is up and time to print new day message
    inc daycount
    mov tickstart, ecx
    call printDay
sameday:

    ; get the input

contgame:
    jmp game

gameLoop ENDP

debug PROC
    push dx
    mov dh, 4
    mov dl, 0
    call GotoXY
    pop dx
    call DumpRegs
    
    ret
debug ENDP

printDay PROC

    mov dh, 0 ; go to correct spot (top middle)
    mov dl, 60
    call GotoXY
	mov eax, yellow + (black*16) ; Set text color to yellow on black background
	call SetTextColor 
    mov edx, OFFSET dayStr ; load the string in eax then print
    call WriteString
    ; also print the day number
    mov dh, 0
    mov dl, 64
    call GotoXY
    mov eax, daycount
    call WriteDec
    ; reset text color
	mov eax, white + (black*16) ; Set text color to white on black background
	call SetTextColor 
    ret
printDay ENDP

; This procedure displays the updated inventory
displayInv PROC

displayInv ENDP



END main
