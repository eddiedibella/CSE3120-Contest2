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

.data
; this is the title of the game and will show upon startup
titleStr BYTE "=== SURVIVAL ===",0

; this is just a feature that makes sure the program runs correctly
startStr BYTE "Program initialized.",0
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

	exit
main ENDP

END main
