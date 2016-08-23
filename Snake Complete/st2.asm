.model small 
.data
	snake db ?
	snakeSize db ?
	food db ?
	foodcolor db ?
	row db ? 
	col db ?
	rowtail db ?
	coltail db ?
	color db ?
	input db ? 
	randomrow db ?
	randomcol db ?
	delaytime db 20,"$"
.stack 100h
.code
	main proc
		mov snakeSize, 1
		mov col, 39
		mov row, 12
		mov snake, 232
		mov color, 0ah
		mov food, 111
		mov foodcolor, 03h
		
		call getRandomCoor
		
		mov al, 03h ;default mode
		mov ah, 00h
		int 10h
		
		xor ax, ax ;clear values
		xor cx, cx
		
		
		moveSnake:
			mov al, 03h ;clear screen
			mov ah, 00h
			int 10h
			
			mov cx, 3200h ;hides blinking cursor
			mov ah, 01h
			int 10h
			
			call printFood

			mov dl, col
			mov dh, row
			xor bh, bh ;video page 0
			mov ah, 02h ;move cursor to the right place
			int 10h
			
			mov cx, 1
			xor bh, bh
			mov bl, color
			mov al, snake
			mov ah, 09h ;prints snake
			int 10h
			mov cx, 0
			
			xor ax, ax
			xor bx, bx
			xor dx, dx
			
			mov ah, 01h ;gets input from user
			int 21h
	
			mov input, al ;stores user input
	
			cmp input, 'w' ;w key
			je checkUp
			cmp input, 'a' ;a key
			je checkLeft
			cmp input, 'd' ;d key
			je checkRight
			cmp input, 's' ;s key
			je checkDown
			
			cmp input, 72 ;up arrow
			je checkUp
			cmp input, 75 ;left arrow
			je checkLeft
			cmp input, 77 ;right arrow
			je checkRight
			cmp input, 80 ;down arrow
			je checkDown
			
			cmp input, 27 ;escape (exit program)
			je endofmain
			
			jmp endCheck
			
			checkUp: ;go up
				cmp row, 0
				jne upContinue
					mov row, 24
					jmp endCheck
					
				upContinue:
				dec row
				
				mov dl, col ;sets the cursor position
				mov dh, row
				mov ah, 02h
				int 10h
				jmp endCheck
				
			checkDown: ;go down
				cmp row, 24
				jne downContinue					
					mov row, 0
					jmp endCheck
				
				downContinue:
				inc row
				
				mov dl, col ;set the cursor position
				mov dh, row
				mov ah, 02h
				int 10h
				
				jmp endCheck
				
			checkLeft: ;go left
				cmp col, 0
				jne leftContinue
					mov col, 79
					jmp endCheck
				
				leftContinue:
				dec col
				
				mov dl, col ;set the cursor position
				mov dh, row
				mov ah, 02h
				int 10h
			
				jmp endCheck
				
			checkRight: ;go right
				cmp col, 79
				jne rightContinue
					mov col, 0
					jmp endCheck
				
				rightContinue:
				inc col
				
				mov dl, col ;set the cursor position
				mov dh, row
				mov ah, 02h
				int 10h
				
				jmp endCheck
				
			endCheck:
			
			xor ax, ax
			xor bx, bx
			xor cx, cx
			xor dx, dx
			
			mov ah, 08h ;checks character at cursor position
			int 10h
			
			;eats food, prints snake's tail
			cmp al, 'o'
			jne printSnakeHead
				inc snakeSize
				
				call getRandomCoor
				call printFood
				call printSnakeTail
				
			;mov al, 03h ;clears screen
			;mov ah, 00h
			;int 10h
			printSnakeHead:
			
			
			mov cx, 1
			mov bl, color
			mov al, snake ;prints snake
			mov ah, 09h
			int 10h
			xor cx, cx
				
			mov dl, col ;return the cursor position
			mov dh, row
			mov ah, 02h
			int 10h
			
			mov ah, 03h ;get cursor values
			int 10h
			
			mov col, dl
			mov row, dh
	
		jmp moveSnake
		
		endofmain:
		mov ax, 4c00h
		int 21h
	
	main endp
	
	getRandomCoor	proc
		call getRandomRow
		mov randomrow, dl
		
		call getRandomCol
		mov randomcol, dl
		ret
	getRandomCoor	endp
	
	getRandomRow	proc
		xor ax, ax ;clears values
		xor bx, bx
		xor dx, dx
		
		mov ah, 00h
		int 1Ah
		mov ax, 0
		mov ax, dx ;copies dx to ax
		mov dx, 0
		
		mov bx, 25
		div bx ;divides dx:ax by bx; quotient will be stored to ax and remainder to dx
		ret
	getRandomRow	endp
	
	getRandomCol	proc
		xor ax, ax ;clears values
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
	
	printFood	proc
		xor dx, dx
		mov dl, randomcol
		mov dh, randomrow
		xor bh, bh ;video page 0
		mov ah, 02h ;move cursor to the right place
		int 10h
			
		mov cx, 1
		xor bh, bh
		mov bl, foodcolor
		mov al, food
		mov ah, 09h ;prints food
		int 10h
		mov cx, 0
		ret
	printFood	endp
	
	printSnakeTail	proc
		mov dl, coltail
		mov dh, rowtail
		xor bh, bh ;video page 0
		mov ah, 02h ;move cursor to the right place
		int 10h
			
		mov cx, 1
		xor bh, bh
		mov bl, color
		mov al, snake
		mov ah, 09h ;prints snake
		int 10h
		mov cx, 0
		ret
	printSnakeTail	endp
	
	delay	proc		
		xor ax, ax ;clears values
		xor bx, bx
		xor cx, cx
		xor dx, dx
	
		mov ah, 00h
		int 1Ah
		mov bx, dx

	jmp_delay:
		int 1Ah
		sub dx, bx
		cmp dl, delaytime
		jl jmp_delay
		ret
	delay	endp

	end main