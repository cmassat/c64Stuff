*=$4000 "Sid Program"
BasicUpstart_128(start)
.const sid_chip = $d400
.const sid_chip_end = $d41c-$d400
.const sid_v1_lo = $d400
.const sid_v1_hi = $d401
.const sid_v1_duty_lo = $d402 //lower4
.const sid_v1_duty_hi = $d403 //lower4
.const sid_v1_control = $d404 //noise-pulse-saw-tri  --  test-ring mod v3 - sync v3 - gate
.const sid_v1_ad = $d405 //attack decay
.const sid_v1_sr = $d406 //sustain release
.const sid_v1_volume = $d418
//notes
.const mid_c = $1150
//instruments
.const sid_piano_ad = $09
.const sid_piano_sr = $00
.const sid_piano_duty = 1536

start:
lda #0
ldx #0
!loop:
  sta sid_chip,x
  inx
  cpx sid_chip_end
  bne !loop-

  lda #$0f
  sta sid_v1_volume

  set_voice_1()
  !mainloop:
  clc
  lda counter
  cmp #$ff
  inc counter
  bne !mainloop-
  inc counter+1
  lda counter + 1
  cmp #$ff
  bne !mainloop-
  play_voice_1()
  inc $d020
  jmp !mainloop-

rts
counter: .byte $00, $00
/*----------------------------------------------------------
 BasicUpstart for C128

 Syntax:    :BasicUpstart(address)
 Usage example: :BasicUpstart($2000)
             Creates a basic program that sys' the address
------------------------------------------------------------*/
.macro BasicUpstart_128(address) {
    .pc = $1c01 "C128 Basic Start"
    .word upstartEnd  // link address
    .word 10   // line num
    .byte $9e  // sys
    .text toIntString(address)
    .byte 0
upstartEnd:
    .word 0  // empty link signals the end of the program
    .pc = $1c0e "Basic End"
}

.macro play_voice_1() {
    lda #01000000
    sta sid_v1_control
    lda #01000001
    sta sid_v1_control
}

.macro set_voice_1() {
  lda #<mid_c
  sta sid_v1_lo
  lda #>mid_c
  sta sid_v1_hi

  lda #sid_piano_ad
  sta sid_v1_ad
  lda #sid_piano_sr
  sta sid_v1_sr

  lda #<sid_piano_duty
  sta sid_v1_duty_lo
  lda #>sid_piano_duty
  sta sid_v1_duty_hi
}