TITLE Reading a Large File

;	Модифицируйте файл ReadFile.asm из главы 11.1.8 так чтобы он мог читать
;	афйлы больше чем его буфер для ввода текста. Уменьшите размер буфера
;	до 1024 байт. Используйте цикл для того что бы продолжить считывание и 
;	вывода на экран содержимого после считывания небольшой порции данных.
;	Если вы планируете выводить информацию на экран с помощью WriteString,
;	незабудьте вставить null байт в конце буфера для данных.

; Открывает вводный файл, читает его содержимое в буфер 
; и выводит буфер на экран

include Irvine32.inc
include Macros.inc

BUFFER_SIZE = 1024

.data
buffer BYTE BUFFER_SIZE DUP(?)
filename    BYTE 80 DUP(0)
fileHandle  HANDLE ?

.code
main Proc

; Попросим пользователя ввести имя файла
	mWrite "Enter an input filename: "
	mov	edx,OFFSET filename
	mov	ecx,SIZEOF filename
	call	ReadString

; Открываем вводящий файл.
	mov	edx,OFFSET filename
	call	OpenInputFile
	mov	fileHandle,eax

; Проверяем на ошибку
	cmp	eax,INVALID_HANDLE_VALUE		; Ошибка открытия файла?
	jne	file_ok					; нет: перескакиваем
	mWrite <"Cannot open file",0dh,0ah>
	jmp	quit						; и выход
file_ok:

; Читаем из файла в буфер
	mov	edx,OFFSET buffer
	mov	ecx,BUFFER_SIZE
	call	ReadFromFile
	
; Если в программе изменить хендл файла то программа выдаст ошибку чтения
; из файла:

;				Error riding file. Error 6: The handl is invalid.

	jnc	check_buffer_size			; Ошибка чтения?
	mWrite "Error reading file. "		; Да: показать сообщение об ошибке
	call	WriteWindowsMsg
	jmp	close_file
	
check_buffer_size:
	cmp	eax,BUFFER_SIZE			; Достаточно ли большой буфер?
	jb	buf_size_ok				; Да
	mWrite <"Error: Buffer too small for the file",0dh,0ah>
	jmp	quit						; на выход
	
buf_size_ok:	
	mov	buffer[eax],0		; Вставим ноль-завершение строки
	mWrite "File size: "
	call	WriteDec			; Выводим на экран размер файла
	call	Crlf

; Выводим на экран содержимое буфера.
	mWrite <"Buffer:",0dh,0ah,0dh,0ah>
	mov	edx,OFFSET buffer	; вывести на экран буфер
	call	WriteString
	call	Crlf

close_file:
	mov	eax,fileHandle
	call	CloseFile

quit:
invoke ExitProcess,0
main EndP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

END main
