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
.def TEMP2 = r22
.def RGB = r17   // PORT D PIN 2,3,4,5,6,7
.def LINE = r18
.def COUNTER = r19
.def POSX = r20
.def POSY = r21

  // Setup stack
  ldi TEMP, HIGH(RAMEND)
  out SPH, TEMP
  ldi TEMP, LOW(RAMEND)
  out SPL, TEMP

  call initialize
  call clearFramebuffer
  // TODO: Set Pixels
  
  ldi RGB, 0b00111111
  ldi POSY, 0
  ldi POSX, 10
lijntje:
  call drawPixel
  inc POSX
  cpi POSX, 50
  brne lijntje

main_loop:
  call drawFrame
  rjmp main_loop

initialize:
  ser TEMP
  out DDRD, TEMP
  out DDRC, TEMP
  out DDRB, TEMP
  cbi PORTD, CLK
  cbi PORTC, LATCH
  cbi PORTB, OE
  ret

//  Clear framebuffer
clearFramebuffer:
  ldi ZH, high(frameBuffer)
  ldi ZL, low(frameBuffer)
  clr TEMP
  ldi XH, high(64*32-1)
  ldi XL, low(64*32-1)
loop:
  st Z+, TEMP
  sbiw X, 1
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

// Set a pixel in the framebuffer
// X, Y, RGB
drawPixel:
  // FB_ADDR = POSY * 64 -> r1:r0
  ldi TEMP, 64
  mul POSY, TEMP
  movw Z, r0
  // FB_ADDR = FB_ADDR + POSX
  add ZL, POSX
  brcc no_overflow
  inc ZH
no_overflow:
  // Add pixel offset to framebuffer base addres
  ldi TEMP, low(frameBuffer)
  ldi TEMP2, high(frameBuffer)
  add ZL, TEMP
  adc ZH, TEMP2
  st Z, RGB
  ret

.dseg ; Start data segment 
frameBuffer: .BYTE 64 * 32
