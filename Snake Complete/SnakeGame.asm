title Snake

.model small 
.data
	
	input db ? ;user input variable
	head db ? ;the head of the snake
	x db ? ;x axis
	y db ?; y axis
	scoreTemp dw ? ;temporary score container
	exitGame db ? ;when esc is pressed set to 1
	seed db ? ;seed for randomizing food spawn
	foodX db ? ;food x coordinate
	foodY db ? ;food y coordinate
	count db ? ;for countdown
	scoreText db "Score: $"
	gameOverMsg db "Game Over! $"
	yourScoreMsg db "Your score is $"
	goMessage db "GO! $"
	prevInput db 'd' ;set previous input to d = down
	foodExists db 0 ;if food exists set to 1
	delaytime db 1 ;speed of delay
	score dw 0 ;initial score is 0
	scoreArr db 5 dup (0) ;contains the ones, tens, hundreds, thousands and ten thousands digit of the score
	xArr db 254 dup(80) ;x coordinate of the snake
	yArr db 254 dup(25) ;y coordinate of the snake
	headArr db 254 dup(?); array of snake heads
	limiter db 3 ;# of food the snake has eaten. Initial value is 3
	ctr db 0 ;ctr purposes
.stack 100h
.code
	main proc
		
		call initialize ;initialize the program
		call countDown ;start the countdown
        call getInput ;get input from user
	
		mov ax, 4c00h
		int 21h
	
	main endp
	
	
	
	getInput proc
		waitForKey:
			mov ah,01h
            int 16h
            jnz gotKey       ;jmp if key is pressed
            call process  ;run program while waiting
			call clear
			call delay
            jmp waitForKey   ;wait again if key is not pressed

		gotKey:     
				mov ah, 00h  ;key is pressed
                int 16H
				
				cmp al, 119 ;w is pressed
				je cont
				cmp al, 97 ;a is pressed
				je cont 
				cmp al, 100 ;d is pressed
				je cont
				cmp al, 115 ;s is pressed
				je cont
				
				cmp ah, 4bh ;left is pressed
				je cont2
				cmp ah, 48h ;up is pressed
				je cont2
				cmp ah, 4Dh ;right is pressed
				je cont2
				cmp ah, 50h ;down is pressed
				je cont2
				cmp ah, 01h ;esc is pressed
				je cont2
				
				jmp waitForKey
				;wasd keys
				cont:
				mov input, al
				jmp waitForKey
				
				;other special characters are saved to ah
				cont2:
				mov input, ah
				jmp waitForKey 	   ;wait for key again
				ret
	getInput endp
	
	
	
	process proc ;the main process
			call clear
		
			mov al, 03h ;clear screen
			mov ah, 00h
			int 10h
			
			mov cx, 3200h ;hide cursor
			mov ah, 01h
			int 10h

			call clear
		
			;save the present coordinate of the snake to index 0 of the array
			
			mov dl, x
			mov bl, 0
			mov xArr[bx], dl
			mov dl, y
			mov yArr[bx], dl
			mov dl, head
			mov headArr[bx], dl
				
				
			call clear
			call printSnake ;calls the process that prints the snake
			call extendSnake ;calls the process that increases the length of the snake
			call parseInput ;parse user's input at change the direction of snake
			call printScore ;prints the score
			call generateFood ;spawns food in random places of the console
	
			cmp limiter, 254
			jne available
			
			mov exitGame, 1
			call gameOver
			
			available:
			xor dx, dx
			mov dx, score
			cmp dh, 255
			jne available2
			
			mov score, 65535	
			mov exitGame, 1
			call gameOver
			
			available2:
			xor dx, dx
	process endp
	
	
	
	printSnake proc
		mov ctr, 0
		
		loopPrint: ;prints the snake by using the xcoordinate, ycoordinate and head array
		
			call clear
			mov bl, ctr
				
			mov dl, xArr[bx] ;sets the x coordinate
			mov dh, yArr[bx] ;sets the y coordinates
			mov ah, 02h
			int 10h
			
			cmp ctr, 0 ;check only the collision of the head
			jne noCollision
			
			call collisionDetection	 ;check if the head has collisions
			
			noCollision:
			
			call clear
			mov bl, ctr
			mov dl, headArr[bx] ;sets the head of the snake
				
			;print a snake segment
			mov cx, 1 
			mov bl, 0eh
			mov al, dl
			mov ah, 09h
			int 10h
		
			;loop until the number of food the snake has eaten is reached
			inc ctr
			mov bl, ctr
			cmp bl, limiter
			jl loopPrint
		ret
	printSnake endp
	
	
	
	extendSnake proc ;process that saves the segments of the snake
		mov bl, limiter
		
			;saves the previous value of an index and moves it to the next index
			;gives the illusion of snake increasing in length
			loopAssign:
				mov dl, xArr[bx]
				inc bl
				mov xArr[bx], dl
				dec bl
				
				mov dl, yArr[bx]
				inc bl
				mov yArr[bx], dl
				dec bl
				
				cmp bl, 0
				je snakeHead
				
				;set the body of snake as 'O'
				;loop until length of snake
				mov dl, 'O'
				inc bl
				mov headArr[bx], dl
				dec bl
				jmp loopCont
				
				;set the head of snakes as arrows
				snakeHead:
				mov dl, headArr[bx]
				inc bl
				mov headArr[bx], dl
				dec bl
			;loop until length of snake
			loopCont:
			dec bl
			cmp bl, 0
			jge loopAssign
			ret
	extendSnake endp
	
	
	
	parseInput proc
		call clear
			
			cmp input, 01h ;esc key
			jne contInput
			mov exitGame, 1
			call gameOver
			
			contInput:
			cmp input, 119 ;w key
			je up
			cmp input, 97 ;a key
			je left
			cmp input, 100 ;d key
			je right
			cmp input, 115 ;s key
			je down
			
			cmp input, 48h ;up cursor
			je up
			cmp input, 4bh ;left cursor
			je left
			cmp input, 4Dh ;right cursor
			je right
			cmp input, 50h ;down cursor
			je down
			
			jmp cont
			
			call clear
		
			up: ;when up is pressed
				cmp prevInput, 'd' ;if snake is facing down, block up
				je down
				
				mov head, 30
				cmp y, 2
				jne upcont
				;if y axis is 0 go to otherside
				mov y, 24
				jmp cont
				
				upcont:
				dec y
				mov prevInput, 'u' ;set previous input as u = up
				jmp cont
				
			down: ;when down is pressed
				cmp prevInput, 'u' ;if snake is facing up, block down
				je up
				
				mov head, 31
				cmp y, 24
				jne downcont
				;if y axis is 24 go to the otherside
				mov y, 2
				jmp cont
				
				downcont:
				inc y
				mov prevInput, 'd' ;set previous input as d = down
				jmp cont
				
			left: ;when left is pressed
				cmp prevInput, 'r' ;if snake is facing right, block left
				je right
			
				mov head, 17
				cmp x, 0
				jne leftcont
				;if x axis is 0 go to the otherside
				mov x, 79
				jmp cont
				
				leftcont:
				dec x
				mov prevInput, 'l' ;set previous input as l = left
				jmp cont
				
			right: ;when right is pressed
				cmp prevInput, 'l' ;if snake is facing left, block right
				je left
				
				mov head, 16
				cmp x, 79
				jne rightcont
				;if x axis is 79 go to the otherside
				mov x, 0
				jmp cont
				
				rightcont:
				inc x
				mov prevInput, 'r' ;set previous input as r = right
				jmp cont
			
			cont:
			call clear
			ret
	parseInput endp
	
	
	
	printScore proc ;prints the user's score
	call clear
	
	;set the location of printing horizontal line
	mov dl, 0
	mov dh, 1
	mov ah, 02h
	int 10h
	
	call clear
	
	;print horizontal line
	mov cx, 80
	mov bl, 04h
	mov al, '_'
	mov ah, 09h
	int 10h
	
	call clear
	
	;set location of scoreText
	mov dl, 1
	mov dh, 0
	mov ah, 02h
	int 10h
	
	call clear
	
	;prints scoreText
	lea dx, scoreText
	mov ah, 09h
	int 21h
	
	call clear
	;set the location of the score
	mov dl, 8
	mov dh, 0
	mov ah, 02h
	int 10h
	
	call clear
	
	
	;stores score to temporary score storage
	mov dx, score
	mov scoreTemp, dx
	
	mov ctr, 0
	;print the score using remainders when dividing by 10
	getValue:
		call clear
		mov bx, 10
		mov ax, scoreTemp
		div bx
		
		;result in ax, remainder in dx
		xor bx,bx
		mov bl, ctr
		
		mov scoreTemp, ax
		add dl, 48 ;convert to digit
		mov scoreArr[bx], dl ;digits are stored in array for printing
		
	inc ctr
	cmp scoreTemp, 0 ;loop until answer is 0
	jne getValue
	
	call clear
	mov ctr, 4 ;4 is the maximum length of score
	
	printValue:
	
		mov bl, ctr ;set index to 4
	
		cmp scoreArr[bx], 0 ;if the value is blank skip printing
		je cont
	
		mov dl, scoreArr[bx] ;prints the digits to score array
		mov ah, 02h
		int 21h
	
	cont:
	call clear
	
	;loop until maximum digit
	dec ctr
	cmp ctr, 0
	jge printValue
	
	ret
	printScore endp
	
	
	collisionDetection proc ;detects collision on food or snake body
	call clear
	
	mov ah, 08h
	int 10h
	
	cmp al, 'O' ;if head collides with body call gameOver otherwise jump to alive
	jne alive
	
	call gameOver
	
	alive: ;if the snake is alive
	cmp al, 233 ;if the snake collides with food extend snake and add score
	jne noFood ;otherwise nothing happens
	
	mov foodExists, 0 ;remove food
	inc limiter	;increase # of foods eaten
	call clear
	
	mov cl, limiter
	
	mov ax, cx ;personal score coefficient
	mov bx, 7
	mul bx
	
	add score, ax ;set the score
	call clear
	
	noFood: ;if nothing happens
	
	ret
	collisionDetection endp
	
	
	
	generateFood proc ;process that
	call clear
	
	cmp foodExists, 1 ;if food exists dont random new value of x and y coordinates
	je dontRandom
	
	;randomized location of food
	random:
	mov ah, 00h
	int 1ah
	
	mov seed,dl
	
	xor ax,ax
	
	;x coordinate randomize
	mov al, seed
	mov bl, 79
	div bl
	
	;set x coordinates to foodX
	mov foodX, ah
	
	call clear
	
	mov ah, 00h
	int 1ah
	
	mov seed,dl
	
	xor ax,ax
	
	;y coordinate randomiz
	mov al, seed
	mov bl, 21 ;21 instead of 23 because -2
	div bl
	
	;add 2 because 1 and 2 is not accessible by the snake
	add ah, 2
	mov foodY, ah
	
	call clear
	;set cursor location to preferred spawn point
	mov dl, foodX
	mov dh, foodY
	mov ah, 02h
	int 10h
	
	;get values at that location
	mov ah, 08h
	int 10h
	
	;if the body is in there spawn another random
	cmp al, 'O'
	je random
	
	dontRandom:
	;set at the preferred spawn point
	mov dl, foodX
	mov dh, foodY
	mov ah, 02h
	int 10h
	
	call clear
	
	;print the food
	mov cx, 1
	mov bl, 02h
	mov al, 233
	mov ah, 09h
	int 10h
	
	call clear
	;set that the food now exists
	mov foodExists, 1
	ret
	generateFood endp
	
	
	
	gameOver proc ;call gameOver when snake dies or user exits
		call clear
		call printScore
		
		cmp exitGame, 1 ;if esc is pressed instead of snake dying
		jne exit
		
		call printSnake
		
		exit:
		mov delaytime, 20 ;slows don fps
		
		call delay
		
		mov al, 03h ; 80 x 25 video mode
		mov ah, 00h
		int 10h
		
		
		call clear
		;set printing location for gameOver message
		mov dl, 34
		mov dh, 11
		mov ah, 02h
		int 10h
		
		call clear
		;prints gameOver message
		lea dx, gameOverMsg
		mov ah, 09h
		int 21h
		
		call clear
		;sets location of your score message
		mov dl, 30
		mov dh, 12
		mov ah, 02h
		int 10h
		
		call clear
		;prints yourScore message
		lea dx, yourScoreMsg
		mov ah, 09h
		int 21h
		
		call clear
		;set the location for printing the score
		mov dl, 44
		mov dh, 12
		mov ah, 02h
		int 10h
		
		call clear
		
		mov cx, 3200h ;hide cursor
		mov ah, 01h
		int 10h
		
		call clear
		;prints the score in the game over screen
		mov ctr, 4
		
		printValue:
		mov bl, ctr
		
		cmp scoreArr[bx], 0
		je cont
		
		mov dl, scoreArr[bx]
		mov ah, 02h
		int 21h
		
		cont:
		call clear
	
		dec ctr
		cmp ctr, 0
		jge printValue
		;end of printing score
		
		;delays the screen before ending
		mov delaytime, 30
		call delay
		
		mov ax, 4c00h
		int 21h
		ret
	gameOver endp
	
	
	
	countDown proc ;countdown in the start screen
	mov delaytime, 18
	
	xor si,si
	xor si,51
	mov count, 51 ;start from 3
	
	
	countDownStart:
		mov al, 03h ; 80 x 25 video mode
		mov ah, 00h
		int 10h
		
		mov cx, 3200h ;hide cursor
		mov ah, 01h
		int 10h
		
		call printScore
		;sets the printing location of the countdown
		mov dl, 39
		mov dh, 12
		mov ah, 02h
		int 10h
		
		call clear
		
		mov dl, count
		mov ah, 02h
		int 21h
		call delay
		sub count, 1
		dec si
	
	;end at 1
	cmp si, 48
	jg countDownStart
	
	mov delaytime, 20
	;sets the printing location of "GO!"
	mov dl, 39
	mov dh, 12
	mov ah, 02h
	int 10h
	
	call clear
	;print G0!
	lea dx, goMessage
	mov ah, 09h
	int 21h
	
	call delay
	
	mov delaytime, 1 ;return normal fps
	ret
	countDown endp
	
	
	
	initialize proc
		;initialize
		mov ax, @data
		mov ds,ax
		
		;set initial valies of snake head
		mov x, 38
		mov y, 13
		mov input, 115
		mov head, 31
		
		call clear
		
		mov al, 03h ; 80 x 25 video mode
		mov ah, 00h
		int 10h
		
		xor ax, ax
		
		mov cx, 3200h ;hide cursor
		mov ah, 01h
		int 10h
		ret
	initialize endp
	
	
	
	clear proc ;clear function
		xor ax,ax
		xor bx,bx
		xor cx,cx
		xor dx,dx
		ret
	clear endp
	
	
	
	delay proc ;executes the delaying of the program
    mov ah, 00
    int 1Ah
    mov bx, dx

	jmp_delay:
		int 1Ah
		sub dx, bx
		cmp dl, delaytime
	jl jmp_delay
		
		call clear		
	ret
	delay endp
	
	
	
	end main