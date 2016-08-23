.model small 
.data
	input db 'd' ;user input variable
	tempInput db 'd'
	head db 31 ;the head of the snake
	col db 40 ;x coordinate
	row db 14 ;y coordinate
	score db 0 ;0
	temp db ?
	arr db 3 dup(?) ;score array
	scoreText db "Score: ","$"
	gameOverText db "Game Over!","$"
	randomRow db ? ;random food row
	randomCol db ? ;random food col
	foodColor db 03h
	food db 'o'
	foodBoolean db 0
	colArr db 200 dup(80) ;x coordinates of the snake body
	rowArr db 200 dup(25) ;y coordinates of the snake body
	snakeArr db 200 dup(?); array of snake
	delayTime db 2	
	snakeLength db 1
	ctrFood db 0
.stack 100h
.code
	main proc
		;initialize
		mov ax, @data
		mov ds,ax
		
		mov al, 03h ; 80 x 25 video mode
		mov ah, 00h
		int 10h
		xor ax, ax
		
		mov cx, 3200h ;hide cursor
		mov ah, 01h
		int 10h
	
        waitInput:
			mov ah, 01h
            int 16h
            jnz gotInput 
            call process
			call clearRegisters
			call delay
			
			mov ah, 01h
            int 16h
            jnz gotInput ;jmp if there is input
            jmp waitInput ;wait if no no input

		gotInput:     
			mov ah, 00h ;key is pressed
			int 16h
					
			cmp al, 'w' ;w key
			je wasde
			cmp al, 'a' ;a key
			je wasde
			cmp al, 's' ;s key
			je wasde
			cmp al, 'd' ;d key
			je wasde
			
			cmp al, 27 ;escape (exit program)
			je wasde
				
			cmp ah, 72 ;up arrow
			je arrow
			cmp ah, 75 ;left arrow
			je arrow
			cmp ah, 77 ;right arrow
			je arrow
			cmp ah, 80 ;down arrow
			je arrow
			
			jmp waitInput
			
			wasde:
				mov input, al
				jmp waitInput
				
			arrow:
				mov input, ah
				jmp waitInput
	
		mov ax, 4c00h
		int 21h
	
	main endp
	
	process proc
		call clearRegisters
		
		mov al, 03h
		mov ah, 00h
		int 10h
		
		mov cx, 3200h ;hide cursor
		mov ah, 01h
		int 10h
		
		cmp foodBoolean, 1
		je printFood
			call getRandomCoor
			
		printFood:
			mov dl, randomCol
			mov dh, randomRow
			xor bh, bh ;video page 0
			mov ah, 02h ;move cursor to the right place
			int 10h
				
			mov cx, 1
			xor bh, bh
			mov bl, foodColor
			mov al, food
			mov ah, 09h ;prints food
			int 10h
			mov cx, 0
			
			mov foodBoolean, 1
		
		;prints score
		mov dl, 2
		mov dh, 1
		mov ah, 02h
		int 10h
			
		mov dx, offset scoreText
		mov ah, 09h
		int 21h
		
		mov dl, 11
		mov dh, 1
		mov ah, 02h
		int 10h
		
		mov cl, 0
		printlabel:
			mov bl, cl
			mov dl, arr[bx]
			mov ah, 02h
			int 21h
		inc cl
		cmp cl, 3
		jl printlabel
		
		;prints division
		mov dl, 0
		mov dh, 2
		mov ah, 02h
		int 10h
			
		mov cx, 80
		mov bl, 0bh
		mov al, '='
		mov ah, 09h
		int 10h

		call presentHead
		call clearRegisters
		
		mov dl, col
		mov dh, row
		mov ah, 02h
		int 10h
		
		mov ah, 08h ;checks character at cursor position
		int 10h
		
		cmp al, 'o' ;if food is 'eaten'
	;	jne cmp31
		jne printSnake
			mov foodBoolean, 0
			inc snakeLength
			call getScore
		;	jmp printSnake
		
		printSnake:
		mov ctrFood, 0
		loopPrint:
			mov bl, ctrFood
				
			mov dl, colArr[bx] ;sets the x coordinate
			mov dh, rowArr[bx] ;sets the y coordinates
			mov ah, 02h
			int 10h
			
			mov ah, 08h ;checks character at cursor position
			int 10h
			
			cmp31: ;if body is eaten
			cmp al, 31
			jne cmp30
				call gameOver
			
			cmp30:
			cmp al, 30
			jne cmp17
				call gameOver
		
			cmp17:
			cmp al, 17
			jne cmp16
				call gameOver
		
			cmp16:
			cmp al, 16
			jne cont
				call gameOver
			
			cont:
			
			
			xor bx, bx

			mov bl, ctrFood
			mov dl, snakeArr[bx] ;sets the head of the snake
			
			mov cx, 1 ;prints snake 
			mov bl, 0bh
			mov al, dl
			mov ah, 09h
			int 10h
		
			;loop until the number of food the snake has eaten is reached
			inc ctrFood
			mov bl, ctrFood
			cmp bl, snakeLength
			jl loopPrint
			
	
		call clearRegisters
		
		cmp input, 'w' ;w key
		je checkUp
		cmp input, 'a' ;a key
		je checkLeft
		cmp input, 's' ;s key
		je checkDown
		cmp input, 'd' ;d key
		je checkRight
			
		cmp input, 72 ;up arrow
		je checkUp
		cmp input, 75 ;left arrow
		je checkLeft
		cmp input, 77 ;right arrow
		je checkRight
		cmp input, 80 ;down arrow
		je checkDown
		
		cmp input, 27
		jne endCheck  
			call gameOver
			
		jmp endCheck
			
		checkUp: ;go up
			cmp tempInput, 's'
			je checkDown
				mov head, 30
				cmp row, 3
				jne upContinue
					mov row, 24
					jmp endCheck
						
				upContinue:
				mov tempInput, 'w'
				dec row
				jmp endCheck
			
		checkDown: ;go down
			cmp tempInput, 'w'
			je checkUp
				mov head, 31
				cmp row, 24
				jne downContinue					
					mov row, 3
					jmp endCheck
				
				downContinue:
				mov tempInput, 's'
				inc row
				jmp endCheck
			
		checkLeft: ;go left
			cmp tempInput, 'd'
			je checkRight
				mov head, 17
				cmp col, 0
				jne leftContinue
					mov col, 79
					jmp endCheck
				
				leftContinue:
				mov tempInput, 'a'
				dec col
				jmp endCheck
			
		checkRight: ;go right
			cmp tempInput, 'a'
			je checkLeft
				mov head, 16
				cmp col, 79
				jne rightContinue
					mov col, 0
					jmp endCheck
				
				rightContinue:
				mov tempInput, 'd'
				inc col
				jmp endCheck
			
		endCheck:
			call clearRegisters
			call addSnakeLength
			
		ret
	process endp
	
	presentHead proc ;puts the current state of the snake head to index 0 of the array	
		call clearRegisters
		
		mov dl, col
		mov bl, 0
		mov colArr[bx], dl
		mov dl, row
		mov rowArr[bx], dl
		mov dl, head
		mov snakeArr[bx], dl		
		
		call clearRegisters
		ret
	presentHead endp
	
	addSnakeLength proc 
		;saves previous col and row of the snake
		mov bl, snakeLength
		loop1:
			mov dl, colArr[bx]
			inc bl
			mov colArr[bx], dl
			dec bl
				
			mov dl, rowArr[bx]
			inc bl
			mov rowArr[bx], dl
			dec bl
				
			mov dl, snakeArr[bx]
			inc bl
			mov snakeArr[bx], dl
			dec bl
		loop2:
			dec bl
			cmp bl, 0
			jge loop1
		ret
	addSnakeLength endp
	
	getRandomCoor	proc
		call getRandomRow
		mov randomRow, dl
		
		call getRandomCol
		mov randomCol, dl
		
		mov foodBoolean, 1
		ret
	getRandomCoor	endp
	
	getRandomRow	proc
		xor ax, ax ;clear values
		xor bx, bx
		xor dx, dx
		
		mov ah, 00h
		int 1Ah
		mov ax, 0
		mov ax, dx ;copies dx to ax
		mov dx, 0
		
		mov bx, 22
		div bx ;divides dx:ax by bx; quotient will be stored to ax and remainder to dx
		add dl, 3
		ret
	getRandomRow	endp
	
	getRandomCol	proc
		xor ax, ax ;clear values
		xor bx, bx
		xor dx, dx
		
		mov ah, 00h
		int 1Ah
		mov ax, 0
		mov ax, dx ;copies dx to ax
		mov dx, 0
		
		mov bx, 80
		div bx ;divides dx:ax by bx; quotient will be stored to ax and remainder to dx
		ret
	getRandomCol	endp
	
	getScore	proc
		mov ah, 0
		mov al, score
		inc al
		mov score, al
		
		mov temp, 0
		mov cl, 2
		convertlabel:
			mov ah, 0
			mov bh, 0
			mov bl, 10
			div bl ;divides al by 10, ones digit will be the remainder (ah)
			mov temp, al
			
			add ah, 48 ;converts ah (remainder) to ascii value			
			
			mov bl, cl ;bl = cl (counter)
			mov arr[bx], ah
			
			cmp temp, 0
			je endconvert
			
			mov ah, 0
			mov al, temp
			
			dec cl
			jge convertlabel
		endconvert:
		ret
	getScore	endp
	
	gameOver	proc
		mov dl, 35
		mov dh, 14
		xor bh, bh ;video page 0
		mov ah, 02h ;move cursor to the right place
		int 10h
			
		lea dx, gameOverText
		mov ah, 09h
		int 21h
			
		mov delaytime, 20
		call delay
			
		mov ax, 4c00h
		int 21h
		ret
	gameOver	endp
	
	clearRegisters	proc
		xor ax,ax
		xor bx,bx
		xor cx,cx
		xor dx,dx
		ret
	clearRegisters	endp
	
	delay proc
		mov ah, 00
		int 1Ah
		mov bx, dx

		jmp_delay:
			int 1Ah
			sub dx, bx
			cmp dl, delayTime
		jl jmp_delay
		call clearRegisters
		ret
	delay endp
	
	end main