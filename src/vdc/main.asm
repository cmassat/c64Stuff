BasicUpstart_128(start)
  .const low80 = $fb
  .const high80 = $fc
  //txa
*= $1300
start:
  .print "starting"
  lda #$1
  jsr vdc_init_80_graphic
  jsr vdc_fill_80_screen
  jsr vdc_get_attribute_mem_start

  lda #0
  !loop:
    jsr vdc_write_byte
    adc #1
    cmp #255
    bne !loop-



//   lda #2
//   ldx #0
//   ldy #0
//   jsr vdc_set_xy_pos
//   jsr vdc_write_byte

//   ldx #0
// !loop:
//   lda characters,x
//   jsr vdc_write_byte
//   inx
//   cpx char_end
//   bne !loop-

//   lda #%0100
//   jsr vdc_set_background_color
//   lda #%0100
//   jsr vdc_set_foreground_color
WAIT_KEY:
  jsr $FFE4
  beq WAIT_KEY

rts

vdc_init_80_text:
  ldx #25
  jsr vdc_read
  and #$7f
  jsr vdc_write
rts

vdc_init_80_graphic:
  ldx #25
  jsr vdc_read
  ora #$80
  jsr vdc_write
rts

vdc_fill_80_screen:
  ldx #0
  ldy #0
  jsr vdc_set_xy_pos

  ldy #0
loop_outer:
    ldx #0
    !loop:
      stx tmp
      jsr vdc_write_byte
      ldx tmp
      inx
      cpx #80
    bne !loop-
    iny
    cpy #25
  bne loop_outer
  rts


vdc_set_xy_pos:
  pha
  lda #0
  sta high80
  sta low80
  cpy #0
  beq xpos

  !loop:
  clc
  adc #80
  bcc continue_y
  inc high80
continue_y:
  dey
  cpy #0
  bne !loop-
  sta low80
xpos:
  stx vdc_screen_ram
  lda low80
  clc
  adc vdc_screen_ram
  bcc continue_x
  inc high80
continue_x:
  sta low80
  lda high80
  sta vdc_screen_ram
  lda low80
  sta vdc_screen_ram + 1
  jsr vdc_set_screen_pointer
  pla
  rts

vdc_write_byte:
  jsr save_registers
  stx tmp
  ldx #$1f
  jsr vdc_write
  ldx tmp
  jsr load_registers
  rts

save_registers:
  sty temp_y
  stx temp_x
  sta temp_a
  rts
load_registers:
  ldy temp_y
  ldx temp_x
  lda temp_a
  rts


vdc_repeat_byte:
  pha
  ldx #$18
  jsr vdc_read
  and #%01111111
  jsr vdc_write
  pla
  ldx #$1e
  jsr vdc_write
  rts

vdc_set_screen_pointer:
  pha
  ldx #$12
  lda vdc_screen_ram
  jsr vdc_write
  ldx #$13
  lda vdc_screen_ram + 1
  jsr vdc_write
  pla
  rts

vdc_set_background_color:
  sta tmp
  ldx #$1a
  jsr vdc_read
  and #$f0
  ora tmp
  ldx #$1a
  jsr vdc_write
  rts

vdc_set_foreground_color:
  asl
  asl
  asl
  asl
  sta tmp
  //sta high80
  //lda #0
  //sta low80
  ldx #$1a
  jsr vdc_read
  and #$0f
  ora tmp
  ldx #$1a
  jsr vdc_write
  rts


vdc_get_screen_mem_start:
  ldx #$0c
  jsr vdc_read
  sta vdc_screen_ram + 1
  ldx #$0d
  jsr vdc_read
  sta vdc_screen_ram
rts

vdc_get_attribute_mem_start:
  ldx #$14
  jsr vdc_read
  sta vdc_screen_ram + 1
  ldx #$15
  jsr vdc_read
  sta vdc_screen_ram
rts

vdc_read:
!loop:
  stx $d600
  bit $d600
  bpl !loop-
  lda $d601
  rts

vdc_write:
!loop:
  stx $d600
  bit $d600
  bpl !loop-
  sta $d601
  rts

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
    .byte $9e  // sysf
    .text toIntString(address)
    .byte 0
upstartEnd:
    .word 0  // empty link signals the end of the program
    .pc = $1c0e "Basic End"
}
tmp: .byte $00
temp_x: .byte $00
temp_y: .byte $00
temp_a: .byte $00
vdc_screen_ram: .byte $00, $00
vdc_attribute_ram: .byte $00, $00
characters:
.text "hello"
characters_end:
char_end:
.byte characters_end - characters