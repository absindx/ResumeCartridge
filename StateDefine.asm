;--------------------------------------------------
; State define
;--------------------------------------------------

; Load state data
	Align	256
State_Ram:
	.incbin	"State/SMBOrigMap/Ram.bin"

	Align	256
State_Oam:
	.incbin	"State/SMBOrigMap/Oam.bin"

State_Nametable:
	Align	256
	.incbin	"State/SMBOrigMap/Nametable.bin"

State_Palette:
	.incbin	"State/SMBOrigMap/Palette.bin"

; Mirroring setting (0=Horizontal , 1=Vertical)
State_Mirroring		= 1

; Stack pointer initialize value
State_StackPointer	= $FF

; Execution start address
State_ResumeAddress	= $8054

; RAM address to insert wait code
InsertCodeAddress	= $0120	; Use 25 bytes + ResumeCode length

; Key to return from standby state
ResumeKey		= $20	; Select key

; Code to execute before jumping to the resume address
ResumeCode	.macro
		; $8054 : JSR $8EED
		; $8EED : STA $2000
		; $8EF0 : STA $0778
		; $8EF3 : RTS
		; $8057 : JMP $8057	; infinity loop
		; -> Just load #$90 into A and jump to $8054
		LDA	#$90
		JMP	State_ResumeAddress
.	.endm
