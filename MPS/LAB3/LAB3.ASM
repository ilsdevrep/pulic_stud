E equ p1.0
speed equ 14
cseg at 8000h

jmp START

INIT:
	clr 	E
	mov 	a,#28h ; 00101000 - DL=0, N = 1, F = 0 (ðàçðÿäíîñòü áóôåðà äàííûõ = 4, äâå ñòðîêè,ðàçìåð ìàòðèöû 5íà8 òî÷åê)
	call 	write_command
	mov 	a,#0ch ; 00001110 - D = 1,C = 0,B = 0 (îòîáðîæåíèå ñèìâîëîâ âêëþ÷åíî,êóðñîð íå âèäåí,êóðñîð íå âèäåí)
	call 	write_command
	mov 	a,#06h ; 00000110 - I/D = 1,S = 0 (Ñäâèã ýêðàíà âëåâî(èíêðåìåíò àäðåñà)),ñäâèã ýêðàíà ïîñëå çàïèñè î÷åðåäíîãî çíà÷åíèÿ äàííûõ)
	call 	write_command
	mov 	a,#01h ; î÷èñòêà ýêðàíà
	call 	write_command
	ret

timer:
	push 	acc
	push 	b
	MOV 	TH0, #0h
	MOV 	TL0, #0h
	MOV 	TMOD, #1h
	MOV 	R0, #speed
	SETB 	TCON.4
	nop
	nop
	nop
again:
	mov 	r1, 293
	DJNZ	r1, $

	JNB 	TCON.5, $
	CLR 	TCON.5
	DJNZ 	R0, again

skip:
	pop b
	pop acc
	ret

wait_bf:
	push acc

wait_ll:
	mov 	p1,#11110100b
	setb 	E
	mov 	a,p1
	clr 	E
	mov 	b,a
	setb 	E
	mov 	a,p1
	clr 	E
	mov 	a,b
	jb 		acc.7,wait_ll
	pop 	acc
	ret

write_command:
	call 	wait_bf
	push 	acc
	push 	b
	mov 	b,a
	anl 	a,#11110000b
	mov 	p1,a
	mov 	p1,a
	setb 	E
	nop
	clr 	E
	mov 	a,b
	swap 	a
	anl 	a,#11110000b
	mov 	p1,a
	setb 	E
	nop
	clr 	E
	mov 	p1,#11110000b

	pop b
	pop acc
	ret

write_data:
	push 	acc
	push 	b
	call 	wait_bf
	mov 	b,a

	anl 	a,#11110000b
	orl 	a,#00000010b
	mov 	p1,a
	setb 	E
	nop
	clr 	E
	mov 	a,b
	swap 	a
	anl 	a,#11110000b
	orl 	a,#00000010b
	mov 	p1,a
	setb 	E
	nop
	clr 	E
	mov 	p1,#11110000b

	pop b
	pop acc
	ret

write_sec:
	;Вывод секунд на экран
	push 	acc
	mov 	a,#086h
	call 	write_command ;kursor
	pop 	acc
	push 	acc
	push 	b

	mov 	b,#10 ; Разбиение на десятки и единицы
	div 	ab
	add 	a,#'0'
	call 	write_data
	mov 	a,b
	add 	a,#'0'	;Прибавление первой цифры '0' к требуемой цифре даст код требуемой цифры
	call 	write_data

	pop 	b
	pop 	acc
	ret

write_min:
	; Минуты
	push 	acc
	mov 	a,#083h
	call 	write_command
	pop 	acc
	push 	acc
	push	b

	mov 	b, #10
	div 	ab
	add 	a,#'0'

	call 	write_data
	mov 	a,b
	add 	a,#'0'
	call 	write_data

	pop 	b
	pop 	acc
	ret

write_hour:
	; A
	push 	acc
	mov 	a,#080h
	call 	write_command
	pop		acc
	push	acc
	push 	b

	mov 	b,#10
	div 	ab
	add 	a,#'0'

	call 	write_data
	mov 	a,b
	add 	a,#'0' 
	call 	write_data

	pop 	b
	pop	 	acc
	ret

START:
	call 	INIT

	push 	acc
	push 	b

	mov 	a,#080h
	call 	write_command

	mov 	r7,#8 ;Размер строчки
	mov 	dptr,#text_clock ;Вывод начальной строчки

label1:
	mov 	a,#0
	movc 	a,@a+dptr
	inc 	dptr
	call 	write_data
	djnz r7,label1

	mov 	a,#0C0h ;Адрес первого знакоместа нижней строки
	call 	write_command

	mov 	r7,#8
	mov 	dptr,#text	;Вывод сообщения на второй строке

label2:
	mov 	a, #0
	movc 	a,@a+dptr
	call 	write_data
	inc 	dptr
	djnz 	r7,label2

	pop 	b
	pop 	acc

	mov 	r4,#0h ;sec	 	 ;начальная инициализация значений времени
	mov 	r3,#0h ;mins   ;начальная инициализация значений времени
	mov 	r2,#0h ;hour   ;начальная инициализация значений времени

	mov 	a,r2
	call 	write_hour
	mov 	a,r3
	call 	write_min
	mov 	a,r4
	call 	write_sec

time:
	;Проверка переполнений отсчетов 
		;времени и увеличение каждого из значений при переполнении предыдущего
	call 	timer ; Пауза 1 секунда
	
	inc 	r4
	mov 	a,r4
	add 	a,#-60
	jnz 	time_sec

	mov 	r4,#0
	inc 	r3
	mov 	a,r3
	add 	a,#-60
	jnz 	time_min

	mov 	r3,#0
	inc 	r2
	mov 	a,r2
	add 	a,#-24
	jnz 	time_hour
	mov 	r2,#0

time_hour:
	mov 	a,r2
	call 	write_hour

time_min:
	mov 	a,r3
	call 	write_min

time_sec:
	mov 	a,r4
	call 	write_sec

	jmp 	time
	
	nop

text_clock: db '00:00:00'
text: db 'LCDCLOCK'
end