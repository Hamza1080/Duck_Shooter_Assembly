.model small
.stack 200h

.data
;Game-Menu
Text_DuckShooter db 32,2,' DUCK SHOOT ',2,32,'$'
Text_GameMode1 db 'P1: Game-Mode 1','$'
Text_GameMode2 db 'P2: Game-Mode 2','$'
Text_Inst db 'I: Instruction','$'
Text_Back db 'B: Back','$'
Text_Quit db 'Q: Quit','$'
;Instruction
Text_Inst1 db ' Use Mouse to aim ','$'
Text_Inst2 db ' Kill Ducks ','$'
Text_Inst3 db ' Dont Rage Quit ','$'
Text_Inst4 db '!!Goodluck Losing!!','$'
;Enter Name
Text_EnterYourName db 'ENTER YOUR NAME','$'
Input_Name db 50 dup('$')
;Game
score_word db 'Score:','$'
score dw 0
highscore dw 00
Highscore_word db 'High-Score:','$'
Bullets_word db 'Bullets:','$'
Bullets dw 50
TIME_AUX db 0 ;variable used when checking if the time has changed
tempcx dw 0
tempdx dw 0
Game_Pause db 32,2,' Game Paused ',2,32,'$'
Pause_Resume db 'R: Resume','$'
Pause_Menu db 'B: Main Menu','$'
Round1_Text db ' Round 1 ','$'
Round2_Text db ' Round 2 ','$'
Round3_Text db ' Round 3 ','$'
Round_Over db ' Round Over ','$'
xcoor dw 0
ycoor dw 0
;Mouse
fire_shot_flag dw 0
fire_shot_flag_duck2 dw 0
;filehandling
filename db "Score.txt", 0
fhandle dw ?
buffer_file db 100 dup('$')
linefeed db 13,10
score_file db 32,32,32
count_file db 0
Highscorefilename db "HScore.txt", 0
HSfhandle dw ?
HSbuffer db 2 dup('$')
;GameMode2Timer
currentsecond db 0
nextmin db 0 
flagtimeup db 0
;duck2
duck2cx dw 0
duck2dx dw 0

.code

main proc
	mov ax,@data
	mov ds,ax
	mov ax,0
    ;Set video mode
    mov ah,00h
    mov al,13h
	int 10h
DisplayEnterName:
    mov cx,10
    lea si,Input_Name
    mov al,'$'
    empytname:
        mov [si],al
        inc si
    loop empytname
    Call SetBackground
    Call InsertName
	
DisplayGameMenu:

	Call SetBackground
	Call Draw_UI_Menu
	;wait for key press
    mov ah,07h
    int 21h
    cmp al,'q'
    je EXITP
    cmp al,'Q'
    je EXITP
    cmp al,'b'
    je DisplayEnterName
    cmp al,'B'
    je DisplayEnterName
    cmp al,'1'
    je DisplayMode1
    cmp al,'2'
    je DisplayMode2
    cmp al,'i'
    call displayinstruction
    jmp DisplayGameMenu

DisplayMode1:
    call ClearScreen
    Call SetBackgroundGame
    Call GameMode1
    ; mov ah,07h
    ; int 21h
    ; cmp al,'b'
    jmp DisplayGameMenu
    jmp ExitP
DisplayMode2:
    call ClearScreen
    Call SetBackgroundGame
    Call GameMode2
    ;delete this later (down)
    ; mov ah,07h
    ; int 21h
    ; cmp al,'b'
    je DisplayGameMenu
    jmp ExitP
	ExitP:
    
    	mov ah,00h
        mov al,03h
        int 10h
		mov ah,4ch
		int 21h
    DisplayGameMenu1:
    jmp DisplayGameMenu
main endp
Round1 proc
        mov ax, 1
        int 33h
    ; mov bp,sp
    push cx
    push dx
        mov ah,02h
        mov bh,00h
        mov dh,20h
        mov dl,04h
        int 10h
        mov bl,14 ; set text color
        call Settextcolor
        lea si,Round1_Text
        call writestring
    pop dx
    pop cx

    mov bp, 100
    mov si, 100
    delay3:
    dec bp
    nop
    jnz delay3
    dec si
    cmp si,0    
    jnz delay3
    Check_Time:
    push ax
    push dx
    push cx
        mov ah,2ch ;get the system time
        int 21h ; ch for hour cl for min dh for sec dl for 1/100th second
        cmp dl,Time_AUX
        JE Check_Time
        mov Time_Aux,dl ;update time
    pop cx
    pop dx
    pop ax

    push ax
    push dx
    push cx
        mov ah, 02h  
        sub dx,20
        add cx,3
        cmp dx,1
        jl missedandpop1
        int 10h
        mov tempdx,dx
        mov tempcx,cx
        call draw_duck
 
        call showscore
        call showhighscore
                jmp round1func
            DisplayGameMenu2:
                jmp DisplayGameMenu
            round1func:
    pop cx
    pop dx
    pop ax
    ; ;mouse end
    mov ah,01
    mov bp, 2
    mov si, 2
    
    delay2:
    ; ;mouse
        push ax
        push bx
        mov ax, 3         ; Get mouse button status
        int 33h
        test bx, 1        ; Check if first mouse button is pressed
        jnz fire_shot_jump     ; If pressed, exit loop
        pop bx
        pop ax
        jmp notshot
        fire_shot_jump:
                pop bx
                pop ax
            call fire_shot
        notshot:
        cmp fire_shot_flag,1
        je shotduck
    
    dec bp
    nop
    jnz delay2
    dec si
    cmp si,0    
    jnz delay2
    mov cx,tempcx
    mov dx,tempdx
    call clearduck
    ;useful somthing big brain
        jmp RoundFunc1
        CHECK_TIME1:
            jmp CHECK_TIME
        RoundFunc1:
        
         jmp RoundFunc2
        missedandpop1:
            jmp missedandpop
         RoundFunc2:
    ;big brain ends here
        push ax
        push cx
        push dx
        call SetBackgroundGame
        pop dx
        pop cx
        pop ax
    mov ah,01
    int 16h
    cmp al,'p'
    je pause
    jmp CHECK_TIME
    pause:
    call printpauseprompt
    mov ah,00h
    int 16h
        push ax
        push cx
        push dx
        call SetBackgroundGame
        pop dx
        pop cx
        pop ax
    cmp al,'r'
    je CHECK_TIME1
    cmp al,'b'
    je DisplayGameMenu2
    jmp pause
    shotDuck:
        add score,5
    jmp missed
    missedandpop:
    pop cx
    pop dx
    pop ax

    missed:
    mov fire_shot_flag,0
        push cx
        push dx
        mov ah,02h
        mov bh,00h
        mov dh,20h
        mov dl,04h
        int 10h
        mov bl,14 ; set text color
        call Settextcolor
        lea si,Round_Over
        call writestring
    
        call showscore
        call showhighscore
        pop dx
        pop cx
    mov bp, 100
    mov si, 100
    delay4:
    dec bp
    nop
    jnz delay4
    dec si
    cmp si,0    
    jnz delay4

    ret
Round1 endp

Round3 proc
        mov ax, 1
        int 33h
    ; mov bp,sp
    push cx
    push dx
        mov ah,02h
        mov bh,00h
        mov dh,20h
        mov dl,04h
        int 10h
        mov bl,14 ; set text color
        call Settextcolor
        lea si,Round3_Text
        call writestring
    pop dx
    pop cx

    mov bp, 100
    mov si, 100
    delay3r3:
    dec bp
    nop
    jnz delay3r3
    dec si
    cmp si,0    
    jnz delay3r3
    Check_Timer3:
    push ax
    push dx
    push cx
        mov ah,2ch ;get the system time
        int 21h ; ch for hour cl for min dh for sec dl for 1/100th second
        cmp dl,Time_AUX
        JE Check_Timer3
        mov Time_Aux,dl ;update time
    pop cx
    pop dx
    pop ax

    push ax
    push dx
    push cx
        mov ah, 02h  
        sub dx,40
        add cx,6
        cmp dx,1
        jl missedandpop1r3
        int 10h
        mov tempdx,dx
        mov tempcx,cx
        call draw_duck
        call showscore
        call showhighscore
                jmp round1funcr3
            DisplayGameMenu2r3:
                jmp DisplayGameMenu
            round1funcr3:
    pop cx
    pop dx
    pop ax
    ; ;mouse end
    mov ah,01
    mov bp, 1
    mov si, 2
    
    delay2r3:
    ; ;mouse
        push ax
        push bx
        mov ax, 3         ; Get mouse button status
        int 33h
        test bx, 1        ; Check if first mouse button is pressed
        jnz fire_shot_jumpr3     ; If pressed, exit loop
        pop bx
        pop ax
        jmp notshotr3
        fire_shot_jumpr3:
                pop bx
                pop ax
            call fire_shot3
        notshotr3:
        cmp fire_shot_flag,1
        je shotduckr3
    dec bp
    nop
    jnz delay2r3
    dec si
    cmp si,0    
    jnz delay2r3
    mov cx,tempcx
    mov dx,tempdx
    call clearduck
    ;useful somthing big brain
        jmp RoundFunc1r3
        CHECK_TIME1r3:
            jmp CHECK_TIMEr3
        RoundFunc1r3:
        
         jmp RoundFunc2r3
        missedandpop1r3:
            jmp missedandpopr3
         RoundFunc2r3:
    ;big brain ends here
        push ax
        push cx
        push dx
        call SetBackgroundGame
        pop dx
        pop cx
        pop ax
    mov ah,01
    int 16h
    cmp al,'p'
    je pauser3
    jmp CHECK_TIMEr3
    pauser3:
    call printpauseprompt
    mov ah,00h
    int 16h
        push ax
        push cx
        push dx
        call SetBackgroundGame
        pop dx
        pop cx
        pop ax
    cmp al,'r'
    je CHECK_TIME1r3
    cmp al,'b'
    je DisplayGameMenu2r3
    jmp pauser3
    shotDuckr3:
        add score,20
    jmp missedr3
    missedandpopr3:
    pop cx
    pop dx
    pop ax

    missedr3:
    mov fire_shot_flag,0
        push cx
        push dx
        mov ah,02h
        mov bh,00h
        mov dh,20h
        mov dl,04h
        int 10h
        mov bl,14 ; set text color
        call Settextcolor
        lea si,Round_Over
        call writestring
        call showscore
        call showhighscore
        pop dx
        pop cx
    mov bp, 100
    mov si, 100
    delay4r3:
    dec bp
    nop
    jnz delay4r3
    dec si
    cmp si,0    
    jnz delay4r3

    ret
Round3 endp

Round2 proc
        mov ax, 1
        int 33h
    ; mov bp,sp
    push cx
    push dx
        mov ah,02h
        mov bh,00h
        mov dh,20h
        mov dl,04h
        int 10h
        mov bl,14 ; set text color
        call Settextcolor
        lea si,Round2_Text
        call writestring
    pop dx
    pop cx

    mov bp, 100
    mov si, 100
    delay3r2:
    dec bp
    nop
    jnz delay3r2
    dec si
    cmp si,0    
    jnz delay3r2
    Check_Timer2:
    push ax
    push dx
    push cx
        mov ah,2ch ;get the system time
        int 21h ; ch for hour cl for min dh for sec dl for 1/100th second
        cmp dl,Time_AUX
        JE Check_Timer2
        mov Time_Aux,dl ;update time
    pop cx
    pop dx
    pop ax

    push ax
    push dx
    push cx
        mov ah, 02h  
        sub dx,25
        sub cx,8
        cmp dx,1
        jl missedandpop1r2
        int 10h
        mov tempdx,dx
        mov tempcx,cx
        call draw_duck
        call showscore
        call showhighscore
                jmp round1funcr2
            DisplayGameMenu2r2:
                jmp DisplayGameMenu
            round1funcr2:
    pop cx
    pop dx
    pop ax
    ; ;mouse end
    mov ah,01
    mov bp, 1
    mov si, 2
    
    delay2r2:
    ; ;mouse
        push ax
        push bx
        mov ax, 3         ; Get mouse button status
        int 33h
        test bx, 1        ; Check if first mouse button is pressed
        jnz fire_shot_jumpr2     ; If pressed, exit loop
        pop bx
        pop ax
        jmp notshotr2
        fire_shot_jumpr2:
                pop bx
                pop ax
            call fire_shot
        notshotr2:
        cmp fire_shot_flag,1
        je shotduckr2
    dec bp
    nop
    jnz delay2r2
    dec si
    cmp si,0    
    jnz delay2r2
    mov cx,tempcx
    mov dx,tempdx
    call clearduck
    ;useful somthing big brain
        jmp RoundFunc1r2
        CHECK_TIME1r2:
            jmp CHECK_TIMEr2
        RoundFunc1r2:
        
         jmp RoundFunc2r2
        missedandpop1r2:
            jmp missedandpopr2
         RoundFunc2r2:
    ;big brain ends here
        push ax
        push cx
        push dx
        call SetBackgroundGame
        pop dx
        pop cx
        pop ax
    mov ah,01
    int 16h
    cmp al,'p'
    je pauser2
    jmp CHECK_TIMEr2
    pauser2:
    call printpauseprompt
    mov ah,00h
    int 16h
        push ax
        push cx
        push dx
        call SetBackgroundGame
        pop dx
        pop cx
        pop ax
    cmp al,'r'
    je CHECK_TIME1r2
    cmp al,'b'
    je DisplayGameMenu2r2
    jmp pauser2
    shotDuckr2:
        add score,10
    jmp missedr2
    missedandpopr2:
    pop cx
    pop dx
    pop ax

    missedr2:
    mov fire_shot_flag,0
        push cx
        push dx
        mov ah,02h
        mov bh,00h
        mov dh,20h
        mov dl,04h
        int 10h
        mov bl,14 ; set text color
        call Settextcolor
        lea si,Round_Over
        call writestring
        call showscore
        call showhighscore
        pop dx
        pop cx
    mov bp, 100
    mov si, 100
    delay4r2:
    dec bp
    nop
    jnz delay4r2
    dec si
    cmp si,0    
    jnz delay4r2

    ret
Round2 endp

showhighscore Proc
push ax
push bx
push dx
;setposition
    mov ax,score
    cmp highscore,ax
    jl updatescore
    jmp noupdate
    updatescore:
    ;call saveHighScore
    noupdate:
    mov ah,02h
    mov bh,00h
    mov dh,24
    mov dl,78
    int 10h
    mov bl,15 ; set text color

    ;print
    mov ax,highscore
    mov bl,10
    div bl
    ;
    push ax
    add al,48
    mov ah,0Eh
    int 10h
    ;
    pop ax
    mov al,ah
    add al,48
    mov ah,0Eh
    int 10h

pop dx
pop bx
pop ax
ret
showhighscore endp
showscore Proc
push ax
push bx
push dx
;setposition
    mov ah,02h
    mov bh,00h
    mov dh,24
    mov dl,06
    int 10h
    mov bl,15 ; set text color

    ;print
    mov ax,score
    mov bl,10
    div bl
    ;
    push ax
    add al,48
    mov ah,0Eh
    int 10h
    ;
    pop ax
    mov al,ah
    add al,48
    mov ah,0Eh
    int 10h

pop dx
pop bx
pop ax
ret
showscore endp

showbullets Proc
push ax
push bx
push dx
;setposition
    mov ah,02h
    mov bh,00h
    mov dh,24
    mov dl,20
    int 10h
    mov bl,15 ; set text color

    ;print
    mov ax,Bullets
    mov bl,10
    div bl
    ;
    push ax
    add al,48
    mov ah,0Eh
    int 10h
    ;
    pop ax
    mov al,ah
    add al,48
    mov ah,0Eh
    int 10h

pop dx
pop bx
pop ax
ret
showbullets endp

fire_shot Proc

    push ax
    push cx
    push dx
        mov ax, 3
        int 33h
        mov xcoor, cx
        mov ycoor, dx
        mov ax,tempdx
        add ax,17
            cmp ycoor,ax
            jb checkupperboundry
            jmp setnothing
        checkupperboundry:
            mov ax,tempdx
            sub ax,8
            cmp ycoor,ax
            ja checkleftboundry
            jmp setnothing
        checkleftboundry:
            mov ax,tempcx
            add ax,105
            cmp xcoor,ax
            ja checkrightboundry
            jmp setnothing
        checkrightboundry:
            mov ax,tempcx
            add ax,135
            cmp xcoor,ax
            jb set1
            jmp setnothing
        set1:
        mov fire_shot_flag,1
        setnothing:
    pop dx
    pop cx
    pop ax
    ret
fire_shot endp
fire_shotDuck2 Proc

    push ax
    push cx
    push dx
        mov ax, 3
        int 33h
        mov xcoor, cx
        mov ycoor, dx
        mov ax,duck2dx
        add ax,0
            cmp ycoor,ax
            jb checkupperboundryDuck2
            jmp setnothingDuck2
        checkupperboundryDuck2:
            mov ax,duck2dx
            sub ax,40
            cmp ycoor,ax
            ja checkleftboundryDuck2
            jmp setnothingDuck2
        checkleftboundryDuck2:
            mov ax,duck2cx
            add ax,20
            cmp xcoor,ax
            ja checkrightboundryDuck2
            jmp setnothingDuck2
        checkrightboundryDuck2:
            mov ax,duck2cx
            add ax,135
            cmp xcoor,ax
            jb set1Duck2
            jmp setnothingDuck2
        set1Duck2:
        mov fire_shot_flag_duck2,1
        setnothingDuck2:
    pop dx
    pop cx
    pop ax
    ret
fire_shotDuck2 endp


fire_shot3 Proc
    push ax
    push cx
    push dx
        mov ax, 3
        int 33h
        mov xcoor, cx
        mov ycoor, dx
        mov ax,tempdx
        add ax,12
            cmp ycoor,ax
            jb checkupperboundryR3
            jmp setnothing
        checkupperboundryR3:
            mov ax,tempdx
            sub ax,8
            cmp ycoor,ax
            ja checkleftboundryR3
            jmp setnothing
        checkleftboundryR3:
            mov ax,tempcx
            add ax,150
            cmp xcoor,ax
            ja checkrightboundryR3
            jmp setnothing
        checkrightboundryR3:
            mov ax,tempcx
            add ax,170
            cmp xcoor,ax
            jb set1r3
            jmp setnothingR3
        set1R3:
        mov fire_shot_flag,1
        setnothingR3:
    pop dx
    pop cx
    pop ax
    ret
fire_shot3 endp


SetBackgroundGame Proc
		;Draw pixel
		mov ah,0ch
		mov dx,0
		mov cx,200
		backgroundgamel1:
		push cx
        cmp dx ,15
        jb setsunlight
        jmp checkgreen
        setsunlight:
        mov al,11
        jmp colorset
        checkgreen:
        cmp dx,170 
        ja setgreen
        mov al,76   ;blue
        jmp colorset
        setgreen:
        mov al,2 ;green
        colorset:
            mov cx,320
			backgroundgamel2:
				int 10h
			loop backgroundgamel2
			inc dx
		pop cx
		loop backgroundgamel1
        
    mov ah,02h
    mov bh,00h
    mov dh,24
    mov dl,00
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    lea si,score_word
    call writestring
    
    mov ah,02h
    mov bh,00h
    mov dh,24
    mov dl,12
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    lea si,Bullets_word
     call writestring

    mov ah,02h
    mov bh,00h
    mov dh,24
    mov dl,67
    int 10h
    mov al,120 
    mov bl,14 
    lea si,Highscore_word
    call writestring
    
    mov ah,02h
    mov bh,00h
    mov dh,0
    mov dl,0
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    lea si,INPUT_NAME
    nextcharname:
    mov al,[si]
    cmp al,'$'
    je forwardmode1
    mov ah,0Eh
    int 10h
    inc si
    jmp nextcharname
    forwardmode1:

    ret
SetBackgroundGame endp

SetBackgroundGameMode2 Proc
		;Draw pixel
		mov ah,0ch
		mov dx,0
		mov cx,200
		backgroundgamel1M2:
		push cx
        cmp dx ,15
        jb setsunlightM2
        jmp checkgreenM2
        setsunlightM2:
        mov al,11
        jmp colorset
        checkgreenM2:
        cmp dx,170 
        ja setgreenM2
        mov al,76   ;blue
        jmp colorsetM2
        setgreenM2:
        mov al,2 ;green
        colorsetM2:
            mov cx,320
			backgroundgamel2M2:
				int 10h
			loop backgroundgamel2M2
			inc dx
		pop cx
		loop backgroundgamel1M2
        
    mov ah,02h
    mov bh,00h
    mov dh,24
    mov dl,00
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    lea si,score_word
    call writestring

    mov ah,02h
    mov bh,00h
    mov dh,24
    mov dl,10
    int 10h
    mov al,120 
    mov bl,14 
    lea si,Bullets_word
    call writestring

    
    mov ah,02h
    mov bh,00h
    mov dh,24
    mov dl,67
    int 10h
    mov al,120 
    mov bl,14 
    lea si,Highscore_word
    call writestring
    
    mov ah,02h
    mov bh,00h
    mov dh,0
    mov dl,0
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    lea si,INPUT_NAME
    nextcharnameM2:
    mov al,[si]
    cmp al,'$'
    je forwardmode1M2
    mov ah,0Eh
    int 10h
    inc si
    jmp nextcharnameM2
    forwardmode1M2:

    ret
SetBackgroundGameMode2 endp

SetBackground Proc
        call ClearScreen
		;Draw pixel
		mov ah,0ch
		mov dx,520
		mov cx,520
		backgroundl1:
		push cx
			backgroundl2:
				mov al,76
				int 10h
			loop backgroundl2
			dec dx
		pop cx
		loop backgroundl1
	
    mov cx,300
    loop_top:
        cmp cx,20
        je line_bottom
        mov ah,0Ch
        mov al,14
        mov dx,10
        int 10h
    loop loop_top
    line_bottom:

    mov cx,300
    loop_bottom:
        cmp cx,20
        je line_left
        mov ah,0Ch
        mov al,14
        mov dx,190
        int 10h
    loop loop_bottom

    line_left:
    mov cx,20
    mov dx,191
    loop_left:
    cmp dx,10
    je line_right
        mov ah,0ch
        mov al,14
        dec dx
        int 10h
    jmp loop_left
    
    line_right:
        mov cx,300
        mov dx,191
        loop_right:
        cmp dx,10
        je endoffunction
            mov ah,0ch
            mov al,14
            dec dx
            int 10h
        jmp loop_right
    endoffunction:
    ret
SetBackground Endp
Draw_UI_Menu Proc
    mov ah,02h
    mov bh,00h
    mov dh,30
    mov dl,04h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Text_DuckShooter
    call writestring
    
    ;Write Mode1
    mov ah,02h
    mov bh,00h
    mov dh,34
    mov dl,01h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Text_GameMode1
    call writestring
    
    ;Write Mode2
    mov ah,02h
    mov bh,00h
    mov dh,37
    mov dl,01h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Text_GameMode2
    call writestring
    
    ;Write Instruction
    mov ah,02h
    mov bh,00h
    mov dh,40
    mov dl,01h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Text_Inst
    call writestring
    
    ;Write Back
    mov ah,02h
    mov bh,00h
    mov dh,43
    mov dl,01h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Text_Back
    call writestring

    ;Write Back
    mov ah,02h
    mov bh,00h
    mov dh,46
    mov dl,01h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Text_Quit
    call writestring

    ret
Draw_UI_Menu endp
InsertName proc
    ;write DuckShooter
    mov ah,02h
    mov bh,00h
    mov dh,20h
    mov dl,06h
    int 10h
    
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Text_EnterYourName
    call writestring
    
    mov ah,02h
    mov bh,00h
    mov dh,23h
    mov dl,06h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor

    lea si,INPUT_NAME

    next_char:
        ;take input here
        push ax
        mov ah,07h
        int 21h
        mov [si],al
        pop ax
        mov al,[si]
        cmp al,13
        je endfun
        mov ah,0Eh
        int 10h
        inc si
    jmp next_char
    endfun:

    ret
InsertName endp

GameMode1 proc
    ;call setHighScore
    mov ah, 02h   
    mov dx,195 ;duck position y
    mov cx,100 ; duck position x
    int 10h
    call showscore
    call showhighscore
    call Round1
    call SetBackgroundGame
    mov ah, 02h   
    mov dx,195 ;duck position y
    mov cx,140; duck position x
    int 10h

    call showscore
    call showhighscore
    call Round2
    call SetBackgroundGame
    mov ah, 02h   
    mov dx,195 ;duck position y
    mov cx,140; duck position x
    int 10h
    call showscore
    ;call showhighscore
    call Round3
    ;call savetofile
    ;call saveHighScore
    mov score,0
    ret

GameMode1 endp

printpauseprompt proc
push ax
push cx
push dx
    mov ah,02h
    mov bh,00h
    mov dh,20h
    mov dl,04h
    int 10h
    mov bl,14 ; set text color
    call Settextcolor
    lea si,GAME_PAUSE
    call writestring
    ;Write Resume
    mov ah,02h
    mov bh,00h
    mov dh,24h
    mov dl,00h
    int 10h
    mov al,120 
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Pause_Resume
    call writestring
    
    ;Write Menu
    mov ah,02h
    mov bh,00h
    mov dh,27h
    mov dl,00h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Pause_Menu
    call writestring
 
    pop dx
    pop cx
    pop ax
ret
printpauseprompt endp
clearduck proc
push dx
push cx
sub cx,1
mov ax,cx
mov bx,dx
sub dx,17
    loopclear1:
    push cx
        inc dx
        mov cx,18
        loopclear2:
        push cx
            add cx,ax
            push ax
            mov ah,0Ch
            mov al,76
            int 10h
            pop ax
        pop cx
        loop loopclear2
    pop cx
    loop loopclear1
pop cx
pop dx
ret
clearduck endp
draw_duck proc
    push cx
    push dx
    add cx,5
    duck_line1:
    mov ax,cx
    mov cx,4
    loop_duckline1:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline1
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,4
    mov ax,cx
    duck_line2:
        mov cx,6
    loop_duckline2:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline2
    
    ;Line3
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,3
    mov ax,cx
    duck_line3:
        mov cx,8
    loop_duckline3:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline3
    pop dx
    pop cx
    push cx
    push dx
        add cx,6 ;adding eyes
        mov ah,0Ch
        mov al,0
        int 10h
        add cx,1 ;adding eyes
        mov ah,0Ch
        mov al,0
        int 10h
    ;Line 4x
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,3
    mov ax,cx
    duck_line4:
    mov cx,8
    loop_duckline4:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline4
    pop dx
    pop cx
    push cx
    push dx
        add cx,6 ;adding eyes
        mov ah,0Ch
        mov al,0
        int 10h
        add cx,1 ;adding eyes
        mov ah,0Ch
        mov al,0
        int 10h
    ;line 5
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,0
    mov ax,cx
    duck_line5:
    mov cx,11
    loop_duckline5:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline5
    pop dx
    pop cx
    push cx
    push dx
        mov ah,0Ch
        mov al,42
        int 10h
        add cx,1 ;adding beak
        mov ah,0Ch
        mov al,42
        int 10h
        add cx,1 ;adding beak
        mov ah,0Ch
        mov al,42
        int 10h
        add cx,1 ;adding beak
        mov ah,0Ch
        mov al,42
        int 10h
    ;line 6
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,3
    mov ax,cx
    duck_line6:
    mov cx,8
    loop_duckline6:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline6
    pop dx
    pop cx
    push cx
    push dx
        add cx,3
        mov ah,0Ch
        mov al,42
        int 10h
        add cx,1 ;adding beak
        mov ah,0Ch
        mov al,42
        int 10h
        add cx,1 ;adding beak
        mov ah,0Ch
        mov al,42
        int 10h
        add cx,12 ;adding tail
        mov ah,0Ch
        mov al,42
        int 10h
    ;line 7
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,5
    mov ax,cx
    duck_line7:
    mov cx,9
    loop_duckline7:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline7
    pop dx
    pop cx
    push cx
    push dx
        add cx,16
        mov ah,0Ch
        mov al,14
        int 10h
        add cx,1 ;adding beak
        mov ah,0Ch
        mov al,42
        int 10h
    ;line 8
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,4
    mov ax,cx
    duck_line8:
    mov cx,14
    loop_duckline8:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline8
    pop dx
    pop cx
    push cx
    push dx
    ;line 9
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,2
    mov ax,cx
    duck_line9:
    mov cx,16
    loop_duckline9:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline9
    pop dx
    pop cx
    push cx
    push dx
    ;line 10
        pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,1
    mov ax,cx
    duck_line10:
    mov cx,17
    loop_duckline10:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline10
    pop dx
    pop cx
    push cx
    push dx
    ;line 11
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,1
    mov ax,cx
    duck_line11:
    mov cx,17
    loop_duckline11:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline11
    pop dx
    pop cx
    push cx
    push dx
        add cx,13
        mov ah,0Ch
        mov al,42
        int 10h
        ;line 12
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,1
    mov ax,cx
    duck_line12:
    mov cx,17
    loop_duckline12:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline12
    pop dx
    pop cx
    push cx
    push dx
        add cx,12
        mov ah,0Ch
        mov al,42
        int 10h
        add cx,1
        mov ah,0Ch
        mov al,42
        int 10h
        ;line 13
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,2
    mov ax,cx
    duck_line13:
    mov cx,15
    loop_duckline13:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline13
    pop dx
    pop cx
    push cx
    push dx
        add cx,10
        mov ah,0Ch
        mov al,42
        int 10h
        add cx,1
        mov ah,0Ch
        mov al,42
        int 10h
        add cx,1
        mov ah,0Ch
        mov al,42
        int 10h
        ;line 14
    pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,4
    mov ax,cx
    duck_line14:
    mov cx,11
    loop_duckline14:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline14
    pop dx
    pop cx
    push cx
    push dx
    ;line 15
       pop dx
    pop cx
    inc dx
    push cx
    push dx
    add cx,5
    mov ax,cx
    duck_line15:
    mov cx,9
    loop_duckline15:
    push cx
    push ax 
        mov cx,ax
        mov ah,0Ch
        mov al,14
        int 10h
    pop ax
    inc ax
    pop cx
    loop loop_duckline15
    pop dx
    pop cx
    push cx
    push dx
        add dx,1
        add cx,10
        mov ah,0Ch
        mov al,42
        int 10h
        add dx,1
        mov ah,0Ch
        mov al,42
        int 10h
        add dx,1
        mov ah,0Ch
        mov al,42
        int 10h
        sub cx,1
        mov ah,0Ch
        mov al,42
        int 10h
        sub cx,1
        mov ah,0Ch
        mov al,42
        int 10h
        add cx ,3
        mov ah,0Ch
        mov al,42
        int 10h
        add cx ,1 
        mov ah,0Ch
        mov al,42
        int 10h
        sub dx ,1
        mov ah,0Ch
        mov al,42
        int 10h
        sub dx ,1
        mov ah,0Ch
        mov al,42
        int 10h
    ;line 16
    pop dx
    pop cx
    ret
draw_duck endp
GameMode2 proc

    ; call showbullettext
    call settimevar
    looptilltime:
        mov ah, 02h   
        mov dx,195 ;duck position y
        mov cx,100 ; duck position x
        int 10h
        
        call showbullets
        call Round1Mode2
        mov fire_shot_flag,0
        mov fire_shot_flag_duck2,0
        call minuteupcheck
        cmp flagtimeup,1
        je roundend
        jmp looptilltime
    roundend:
    mov flagtimeup,0
    ; mov ah,02h
    ; mov bh,00h
    ; mov dh,24
    ; mov dl,00
    ; int 10h
    ; mov al,120 ;foreposition useless rn
    ; mov bl,14 ; set text color
    ; lea si,score_word
    ; call writestring
    

    ; mov ah,02h
    ; mov bh,00h
    ; mov dh,24
    ; mov dl,67
    ; int 10h
    ; mov al,120 
    ; mov bl,14 
    ; lea si,Highscore_word
    ; call writestring
    
    ; mov ah,02h
    ; mov bh,00h
    ; mov dh,0
    ; mov dl,0
    ; int 10h
    ; mov al,120 ;foreposition useless rn
    ; mov bl,14 ; set text color
    ; lea si,INPUT_NAME
    ; nextcharnamemode2:
    ; mov al,[si]
    ; cmp al,'$'
    ; je forwardmode2
    ; mov ah,0Eh
    ; int 10h
    ; inc si
    ; jmp nextcharnamemode2
    ; forwardmode2:
    mov score,0
    ret
GameMode2 endp
settimevar proc
push ax
push bx
push cx
push dx
    mov ah,2ch
    int 21h
    mov currentsecond,dh
    mov nextmin,cl
    add nextmin,1
pop dx
pop cx
pop bx
pop ax
ret
settimevar endp
minuteupcheck proc
    push ax
    push bx
    push cx
    push dx
    checktimeagain:
        mov ah,2ch
        int 21h
        cmp cl,nextmin
        jnge timesnotup
        cmp dh,7
        je checktimeagain
        cmp dh,currentsecond
        jg timesup
        jmp timesnotup
    timesup:
        mov flagtimeup,1
    timesnotup:
    pop dx
    pop cx
    pop bx
    pop ax
ret
minuteupcheck endp
Round1Mode2 proc
        push cx
        push dx
            mov dx,0
            mov cx,90
            mov duck2cx,cx
            mov duck2dx,dx
        pop dx
        pop cx
        mov ax, 1
        int 33h
    ; mov bp,sp
    push cx
    push dx
        mov ah,02h
        mov bh,00h
        mov dh,20h
        mov dl,04h
        int 10h
        mov bl,14 ; set text color
        call Settextcolor
        lea si,Round1_Text
        call writestring
    pop dx
    pop cx

    mov bp, 2
    mov si, 2
    delay3M2R1:
    dec bp
    nop
    jnz delay3M2R1
    dec si
    cmp si,0    
    jnz delay3M2R1
    Check_TimeM2R1:
    push ax
    push dx
    push cx
        mov ah,2ch ;get the system time
        int 21h ; ch for hour cl for min dh for sec dl for 1/100th second
        cmp dl,Time_AUX
        JE Check_TimeM2R1
        mov Time_Aux,dl ;update time
    pop cx
    pop dx
    pop ax

    push ax
    push dx
    push cx
        mov ah, 02h  
        sub dx,20
        add cx,3
        cmp dx,1
        jl missedandpop2M2R1
        int 10h
        mov tempdx,dx
        mov tempcx,cx
        call draw_duck
        mov dx,duck2dx
        mov cx,duck2cx
        call draw_duck
        add dx,20
        mov duck2dx,dx
        mov dx,tempdx
        mov cx,tempcx
        call showbullets
        call showscore
        call showhighscore
                jmp round1funcM2R1
            DisplayGameMenu2M2R1:
                jmp DisplayGameMenu
            round1funcM2R1:
    pop cx
    pop dx
    pop ax
    ;bigbrain
    jmp RoundFunc5M2R1
        missedandpop2M2R1:
            jmp missedandpop1M2R1
         RoundFunc5M2R1:
    
    ; ;mouse end
    mov ah,01
    mov bp, 2
    mov si, 2
    
    delay2M2R1:
    ; ;mouse
        push ax
        push bx
        mov ax, 3         ; Get mouse button status
        int 33h
        test bx, 1        ; Check if first mouse button is pressed
        jnz fire_shot_jumpM2R1     ; If pressed, exit loop
        pop bx
        pop ax
        jmp notshotM2R1
        fire_shot_jumpM2R1:
                pop bx
                pop ax
            call fire_shot
            push cx
            push dx
            mov cx,duck2cx
            mov dx,duck2dx
            call fire_shotDuck2
            pop dx
            pop cx
        notshotM2R1:
        cmp fire_shot_flag,1
        je checkduck2
        jmp forwardnoshoot
        checkduck2:
        cmp fire_shot_flag_duck2,1
        je shotduckM2R1
        forwardnoshoot:
    dec bp
    nop
    jnz delay2M2R1
    dec si
    cmp si,0    
    jnz delay2M2R1
    mov cx,tempcx
    mov dx,tempdx
    call clearduck
    ;useful somthing big brain
        jmp RoundFunc1M2R1
        CHECK_TIME1M2R1:
            jmp CHECK_TIMEM2R1
        RoundFunc1M2R1:
        
         jmp RoundFunc2M2R1
        missedandpop1M2R1:
            jmp missedandpopM2R1
         RoundFunc2M2R1:

            jmp RoundFunc3M2R1
        DisplayGameMenu3M2R1:
            jmp DisplayGameMenu2M2R1
         RoundFunc3M2R1:
         
    ;big brain ends here
    
        push ax
        push cx
        push dx
        call SetBackgroundGame

        pop dx
        pop cx
        pop ax
    mov ah,01
    int 16h
    cmp al,'p'
    je pauseM2R1
    jmp CHECK_TIMEM2R1
    pauseM2R1:
    call printpauseprompt
    mov ah,00h
    int 16h
        push ax
        push cx
        push dx
        call SetBackgroundGame
        ; call showbullettext
        pop dx
        pop cx
        pop ax
    cmp al,'r'
    je CHECK_TIME1M2R1
    cmp al,'b'
    je DisplayGameMenu3M2R1
    jmp pauseM2R1
    shotDuckM2R1:
        add score,3
    jmp missedM2R1
    missedandpopM2R1:
    pop cx
    pop dx
    pop ax

    missedM2R1:
    mov fire_shot_flag,0
        push cx
        push dx
        mov ah,02h
        mov bh,00h
        mov dh,20h
        mov dl,04h
        int 10h
        mov bl,14 ; set text color
        call Settextcolor
        lea si,Round_Over
        call writestring
        call showscore
        call showbullets
        call showhighscore
        pop dx
        pop cx
    mov bp, 1
    mov si, 1
    delay4M2R1:
    dec bp
    nop
    jnz delay4M2R1
    dec si
    cmp si,0    
    jnz delay4M2R1

    ret
Round1Mode2 endp

; showbullettext proc

; push si
; push ax
; push bx
; push cx
; push dx
;     mov ah,02h
;     mov bh,00h
;     mov dh,24
;     mov dl,10
;     int 10h
;     mov al,120 
;     mov bl,14 
;     lea si,Bullets_word
;     call writestring
; pop dx
; pop cx
; pop bx
; pop ax
; pop si
; ret
; showbullettext endp
displayinstruction proc
call SetBackground

mov ah,02h
    mov bh,00h
    mov dh,30
    mov dl,04h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,Text_DuckShooter
    call writestring


    ;Write Mode1
    mov ah,02h
    mov bh,00h
    mov dh,34
    mov dl,01h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,TEXT_INST1
    call writestring
    
    ;Write Mode2
    mov ah,02h
    mov bh,00h
    mov dh,37
    mov dl,01h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,TEXT_INST2
    call writestring
    
     ;Write Instruction
    mov ah,02h
    mov bh,00h
    mov dh,40
    mov dl,01h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,TEXT_INST3
    call writestring
    
    ;Write Back
    mov ah,02h
    mov bh,00h
    mov dh,43
    mov dl,01h
    int 10h
    mov al,120 ;foreposition useless rn
    mov bl,14 ; set text color
    call Settextcolor
    lea si,TEXT_INST4
    call writestring




mov ah,07h
    int 21h

ret
displayinstruction endp
savetofile proc
push si
push ax
push bx
push cx
push dx

    ;counting
    lea si,Input_Name
    counting:
    mov al,[si]
    cmp al,'$'
    je printcount
    inc count_file
    inc si
    jmp counting
    
    printcount:
    mov dx,0
    mov dl,count_file
    add dl,48
    mov ah,02h
    int 21h

    mov si,offset score_file
    inc si
    mov ax,score
    mov bl,10
    div bl
    
    add al,48
    mov [si],al
    inc si
    add ah,48
    mov [si],ah

    
    ;Open an existing file
    mov ah,3dh
    lea dx, filename
    mov al,2
    int 21h    
    mov fhandle,ax



;Read Data
mov ah,3fh
lea dx,buffer_file
mov cx,100
mov bx,fhandle
int 21h


    ;write inside
    write:
        sub count_file,1
        mov ah,40h
        mov bx,fhandle
        lea dx,linefeed
        mov cx,2
        int 21h

        mov ah,40h
        mov bx,fhandle
        lea dx,Input_Name
        mov cx,0
        mov cl,count_file
        int 21h
        
        mov ah,40h
        mov bx,fhandle
        lea dx,score_file
        mov cx,3
        int 21h


    ;close file
    mov ah,3eh
    mov bx,fhandle
    int 21h

pop dx
pop cx
pop bx
pop ax
pop si
ret
savetofile endp
saveHighScore proc
push si
push ax
push bx
push cx
push dx
    mov ah,3dh
    lea dx, Highscorefilename
    mov al,2
    int 21h    
    mov HSfhandle,ax

     mov ah,40h
     mov bx,HSfhandle
     lea dx,score
     mov cx,1
     int 21h

    mov ah,3eh
    mov bx,HSfhandle
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    ret
saveHighScore endp

setHighScore proc
push si
push ax
push bx
push cx
push dx
    ; ;Open an existing file
    mov ah,3dh
    lea dx, Highscorefilename
    mov al,2
    int 21h    
    mov HSfhandle,ax

;Read Data
mov ah,3fh
lea dx,HSbuffer
mov cx,2
mov bx,HSfhandle
int 21h

mov dx,0
lea si,HSbuffer
mov dl,[si]
mov highscore,dx

    ;close file
    mov ah,3eh
    mov bx,HSfhandle
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
    pop si
ret
setHighScore endp

ClearScreen proc
    mov ah, 06h    
    mov al, 0       
    mov bh, 00h
    mov cx, 0      
    mov dx, 184Fh   
    int 10h       
ret
ClearScreen endp
Settextcolor proc
    or al, bl       
    mov ah, 0Bh
    mov bh, 0
    mov cx, 10
    int 10h
    ret
Settextcolor endp
writestring proc




    nextchar:
    mov al,[si]         
    cmp al,'$'
    je retstr
    mov ah,0Eh
    int 10h
    inc si
    jmp nextchar
    retstr:
    ret
writestring endp
end main