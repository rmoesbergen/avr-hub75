/*
 * sleep.asm
 *
 *  Created: 07/12/2019 16:29:13
 *   Author: Ronald
 */ 

; delay with r16 as parameter
delay:
  clr r24
  clr r25
wait_1:
  adiw r25:r24, 1
  call drawFrame
  brne wait_1
  dec r16
  brne delay
  ret