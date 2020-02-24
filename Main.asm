;--------------------------------------------------
; Resume cartridge
;--------------------------------------------------

;--------------------------------------------------
; Setting
;--------------------------------------------------
PrgCount	= 1
Mapper		= 4

	.inesprg PrgCount	; PRG Bank
	.ineschr 0		; CHR Bank
	;.inesmir 1		; Mirror
	.inesmap Mapper		; Mapper



;--------------------------------------------------
; Include
;--------------------------------------------------
	.include	"Include/IOName_Standard.asm"
	.if Mapper = 4
	.include	"Include/IOName_MMC3.asm"
	.endif
	.include	"Include/Library_Macro.asm"



;--------------------------------------------------
; Interrupt
;--------------------------------------------------
	.bank PrgCount*2-1
	.org $FFF9

NMI:
IRQ:
	RTI

	.dw NMI
	.dw RST
	.dw IRQ



;--------------------------------------------------
; PRG
;--------------------------------------------------

	.org $E000
	.include	"StateDefine.asm"
	.inesmir State_Mirroring

	.org $FF00

RST:
		SEI
		CLD

		WaitVBlank
		WaitVBlank

	.if Mapper = 4
		LDA	#(1-State_Mirroring)
		STA	IO_MMC3_Mirroring
	.endif

		LDA	#$00
		STA	IO_PPU_Setting
		STA	IO_PPU_Display

		LDA	#$40
		STA	IO_Controller_Port2		;   APU IRQ Disable

;--------------------------------------------------

GameMain:
CopyState_StackPointer:
		LDX	#State_StackPointer
		TXS

CopyState_Nametable:
.Src		= $02
.SrcLow		= .Src + 0
.SrcHigh	= .Src + 1
		PPU_SetDestinationAddress	$2000
		LDA	#HIGH(State_Nametable)
		STA	<.SrcHigh
		LDA	#LOW(State_Nametable)
		STA	<.SrcLow
		LDX	#$07
		LDY	#$00
.Loop		LDA	[.Src], Y
		STA	IO_PPU_VRAMAccess
		INY
		BNE	.Loop
		CPX	#$04
		BNE	.SkipPlane
		PPU_SetDestinationAddress	$2C00
.SkipPlane	INC	<.SrcHigh
		DEX
		BPL	.Loop

CopyState_Ram:
.Dst		= $00
.DstLow		= .Dst + 0
.DstHigh	= .Dst + 1
.Src		= $02
.SrcLow		= .Src + 0
.SrcHigh	= .Src + 1

		;LDY	#$00
		STY	<.DstLow
		STY	<.DstHigh
		STY	<.SrcLow
		LDY	#$04
		LDA	#HIGH(State_Ram)
		STA	<.SrcHigh
		LDX	#$08
.CopyPage
.CopyByte	LDA	[.Src], Y
		STA	[.Dst], Y
		INY
		BNE	.CopyByte
		INC	<.SrcHigh
		INC	<.DstHigh
		CPX	<.DstHigh
		BNE	.CopyPage

		; clean used area
		LDA	State_Ram + 0
		STA	<$00
		LDA	State_Ram + 1
		STA	<$01
		LDA	State_Ram + 2
		STA	<$02
		LDA	State_Ram + 3
		STA	<$03

CopyState_Oam:
		WaitVBlank
		LDA	#HIGH(State_Oam)
		STA	IO_Sprite_DMA

CopyState_Palette:
		PPU_SetDestinationAddress	$3F00
		LDX	#$20
		;LDY	#$00
.Loop		LDA	State_Palette, Y
		STA	IO_PPU_VRAMAccess
		INY
		DEX
		BNE	.Loop

;--------------------------------------------------

SetRamWaitCode:
		LDY	#(RamWaitCodeLength)
.Loop		LDA	RamWaitCode, Y
		STA	InsertCodeAddress, Y
		DEY
		BPL	.Loop

		LDX	#$01
		INY					;   Y = 0
		STY	IO_PPU_Scroll
		STY	IO_PPU_Scroll
		LDA	#%00010000
		STA	IO_PPU_Display			;   Enable SP
		JMP	InsertCodeAddress

RamWaitCode:
		; Read controller
		STX	.Pad
		STX	IO_Controller_Port1
		STY	IO_Controller_Port1
.Loop		LDA	IO_Controller_Port1
		LSR	A
		ROL	.Pad
		BCC	.Loop

		LDA	.Pad
		AND	#ResumeKey
		BEQ	RamWaitCode

		ResumeCode
.End
RamWaitCodeLength	= .End - RamWaitCode
.Pad			= InsertCodeAddress + RamWaitCodeLength



;--------------------------------------------------
; CHR
;--------------------------------------------------
;	.bank PrgCount*2
;	.org $0000
;	.incbin "Graphics/GFX_Font.bin"		; $00-$01
;	.org $0800
;	.incbin "Graphics/GFX_Blank.bin"	; $02-$03


