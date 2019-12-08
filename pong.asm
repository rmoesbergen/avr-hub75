/*
 * pong.asm
 *
 *  Created: 07/12/2019 16:01:56
 *   Author: Ronald
 */ 

 /*
 > clear frame buffer
 call clearFrameBuffer
 > Load RGB value into RGB
 ldi RGB, 0b00111111
 > set X and Y position
 ldi POSY, 0
 ldi POSX, 0
 > draw Pixels into register
 call drawPixel
 > draw Frame from register
 call drawFrame
 */

 jmp main

 .include "hub75.asm"
 .include "sleep.asm"

main:
  // Setup stack
  ldi TEMP, HIGH(RAMEND)
  out SPH, TEMP
  ldi TEMP, LOW(RAMEND)
  out SPL, TEMP

  call initialize
  call clearFrameBuffer

  // Teken dingen

  ldi POSY, 2
nogeens:
  call clearFrameBuffer
  ldi POSX, 0
lijntje:
  ldi RGB, 0b00111111
  call drawPixel
  inc POSX
  cpi POSX, 64
  brne lijntje

  call drawFrame

  ldi TEMP, 10
  call delay

  inc POSY

  call drawFrame
  cpi POSY, 31
  brne nogeens
  clr POSY
  rjmp nogeens