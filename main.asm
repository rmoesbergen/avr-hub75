;
; HUB75.asm
;
; Created: 29/11/2019 20:17:26
; Author : Ronald
;

.equ CLK = 1     // PD1
.equ LATCH = 0   // PC0
.equ OE = 5      // PB5


.def TEMP = r16
.def RGB = r17   // PORT D PIN 2,3,4,5,6,7
.def LINE = r18
.def COUNTER = r19
.def POSX = r1
.def POSY = r2

start:
  call setupStack
  call initialize
  call drawFrame


setupStack:
  ldi TEMP, HIGH(RAMEND)
  out SPH, R16
  ldi TEMP, LOW(RAMEND)
  out SPL, R16
  ret

// Switch a
initialize:
  push TEMP
  ser TEMP
  out DDRD, TEMP
  out DDRC, TEMP
  out DDRB, TEMP
  cbi PORTD, CLK
  cbi PORTC, LATCH
  cbi PORTB, OE
  pop TEMP
  call clearFramebuffer
  ret

//  Clear framebuffer
clearFramebuffer:
  ldi ZH, high(frameBuffer + (64*32 - 1))
  ldi ZL, low(frameBuffer + (64*32 - 1))
  clr TEMP
loop:
  st Z, TEMP
  sbiw Z, 1
  brne loop
  ret

// RGB = 0b00111111
//           BGRBGR
//           222111
// PORTD 0b11111100
//         76543210      
//         BGRBGRC
//         222111L
writeOneRGBPixel:
  push RGB
  lsl RGB
  lsl RGB
  sbr RGB, 2 // Set CLK bit (PD1)
  out PORTD, RGB
  pop RGB
  // Toggle Clock
  cbi PORTD, CLK
  ret

// LINE = 0b00011111
outputPixelsToLine:
  sbi PORTB, OE
  push LINE
  lsl LINE
  andi LINE, 0b00111110
  sbr LINE, 1 // Set LATCH
  out PORTC, LINE
  pop LINE
  // toggle latch
  cbi PORTC, LATCH
  cbi PORTB, OE
  ret

drawFrame:
  ldi ZH, high(frameBuffer)
  ldi ZL, low(frameBuffer)
  ldi LINE, 0
next_line:
  ldi COUNTER, 63
next_pixel:
  ld RGB, Z+
  call writeOneRGBPixel
  dec COUNTER
  brne next_pixel
  call outputPixelsToLine
  inc LINE
  cpi LINE, 32
  brne next_line
  // all done
  ret


.dseg ; Start data segment 
frameBuffer: .BYTE 64 * 32
