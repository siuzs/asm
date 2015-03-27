TITLE Reading a Large File

;	Модифицируйте файл ReadFile.asm из главы 11.1.8 так что бы он мог читать
;	фйлы больше чем буфер для ввода текста. Уменьшите размер буфера
;	до 1024 байт. Используйте цикл для того что бы продолжить считывание и 
;	вывод на экран содержимого после считывания небольшой порции данных.
;	Если вы планируете выводить информацию на экран с помощью WriteString,
;	незабудьте вставить null байт в конце буфера для данных.

; Открывает вводный файл, читает его содержимое в буфер 
; и выводит буфер на экран

include Irvine32.inc
include Macros.inc

BUFFER_SIZE = 1024

.data
buffer BYTE BUFFER_SIZE DUP(?)
filename byte "output.txt", 0 ; Имя для данного конкретного файла
;filename    byte 80 DUP(0) ; Для ввода имя файла от пользователя
fileHandle  HANDLE ?
bytesRead dword ?

.code
main Proc

;; Попросим пользователя ввести имя файла
;	mWrite "Enter an input filename: "
;	mov	edx,OFFSET filename
;	mov	ecx,SIZEOF filename
;	call	ReadString

; Открываем вводный файл.
invoke CreateFile, addr filename, GENERIC_READ, DO_NOT_SHARE, NULL,
	OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov	fileHandle,eax

; Проверяем на ошибку
cmp	eax, INVALID_HANDLE_VALUE ; Ошибка открытия файла?
jne	file_ok					  ; нет: перескакиваем
mWrite <"Cannot open file",0dh,0ah>
jmp	quit						; и выход
file_ok:

; Читаем из файла в буфер
mov ecx, 2
L_ReadFile:
	push ecx
	 ; Чтениче части файла
invoke ReadFile,
    fileHandle,	; file handle
    addr buffer,	; buffer pointer
    BUFFER_SIZE,	; max bytes to read
    addr bytesRead,	; number of bytes read
    0		; overlapped execution flag

; Проверим на ошибки
call ChekErrorRead
	
; Если в программе изменить хендл файла то программа выдаст ошибку чтения
; из файла:

;				Error riding file. Error 6: The handl is invalid.

	jnc	buf_size_ok			; Ошибка чтения?
	mWrite "Error reading file. "		; Да: показать сообщение об ошибке
	call	WriteWindowsMsg
	pop ecx ; Вернем наместо стек перед незапланированным выходом
	jmp	close_file
	
;check_buffer_size:
;	cmp	eax,BUFFER_SIZE			; Достаточно ли большой буфер?
;	jb	buf_size_ok				; Да
;	mWrite <"Read buffer № *** :",0dh,0ah>
;	jmp	quit						; на выход
	
buf_size_ok:	
	call OutputPartFile ; Выводим на экран часть содержимого файла 
	; Move the file pointer to the current space of the file
	invoke SetFilePointer,fileHandle,0,0,FILE_CURRENT
	pop ecx
loop L_ReadFile

close_file:
invoke CloseHandle, fileHandle ; Закрыть файл

quit:
invoke ExitProcess,0
main EndP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ChekErrorRead Proc
cmp	eax, 0	; failed?
jne	L1	; no: return bytesRead

invoke GetLastError	; yes: EAX = error code
stc		; set Carry flag
jmp	L2
	    
L1:	mov	eax,bytesRead	; success
	clc		; clear Carry flag
	
L2:
	Ret
ChekErrorRead EndP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OutputPartFile Proc
	mov	buffer[eax],0		; Вставим ноль-завершение строки
	mWrite "File size: "
	call	WriteDec			; Выводим на экран размер файла
	call	Crlf

; Выводим на экран содержимое буфера.
	mWrite <"Buffer:",0dh,0ah,0dh,0ah>
	mov	edx,offset buffer	; вывести на экран буфер
	call	WriteString
	call	Crlf
	Ret
OutputPartFile EndP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

END main
