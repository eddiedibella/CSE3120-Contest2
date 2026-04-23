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

; string to print the day (will be followed by the daycount)
dayStr BYTE "Day ",0

player BYTE 'o',0

tickstart DWORD ?
daytime DWORD ?
daycount DWORD 0h

.code
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
