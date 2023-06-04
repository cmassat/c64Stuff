.var music = LoadSid("Knight_Rider_Theme.sid")
#import "screen.asm"
BasicUpstart2(start)
*=$c000
.var zp = $02
.var zp_tmp1 = $fb
.var zp_tmp2 = $fc
.var zp_draw_letter = $fd
.var address_lo = $a7
.var address_hi = $a8

//bit 3 38 colo mode
//bit 2 to 0 for x scroll
.var vic_scroll_reg = $d016

start:
  // Allow set VIC-ii location
  lda $d002
  and #%11111100
  ora #%00000011
  sta $d002


  lda $d016
  and #%11110000
  sta $d016

  //Dev VIC-II location
  lda $d000
  ora #%00000011
  sta $d000

  lda #0
  sta $d020
  sta $d021

// bitmap mode graphic location
// upper 4 bits control screen memory
// lower 4 bits control character memory
  lda $d018
  ora #%00001000
  sta $d018

  lda $d011
  and #%11011111
  ora #%00100000
  sta $d011

  // set multi color
  // bitmap mode
  lda $d016
  and #%11101111
  ora #%00010000
  sta $d016

  jsr clear_color
  jsr draw_voice
  jsr draw_air
  jsr draw_oil
  jsr draw_p1
  jsr draw_p2
  jsr draw_s1
  jsr draw_s2
  jsr draw_p3
  jsr draw_p4
  jsr draw_scroll
  lda #music.startSong-1
jsr music.init
sei 
lda #%01111111
sta $DC0D

and $D011            // clear most significant bit of VIC's raster register
sta $D011

lda $DC0D            // acknowledge pending interrupts from CIA-1
lda $DD0D            // acknowledge pending interrupts from CIA-2
lda #110            // set rasterline where interrupt shall occur
sta $d012

lda #<irq            // set interrupt vectors, pointing to interrupt service routine below
sta $0314
lda #>irq
sta $0315

lda #%00000001       // enable raster interrupt signals from VIC
sta $D01A

cli  

  lda #<img_s
  sta zp_tmp1
  lda #>img_s
  sta zp_tmp1 + 1
  jsr draw_spry
 loop:

  lda #4
  cmp scroll_counter
  bne next
  lda #0
  sta scroll_counter
  inc letter_counter

  lda #1
  cmp letter_counter
  bne letter1
  lda #<img_s
  sta zp_tmp1
  lda #>img_s
  sta zp_tmp1 + 1
  jsr draw_spry
letter1:
  lda #2
  cmp letter_counter
  bne letter2
  lda #<img_p
  sta zp_tmp1
  lda #>img_p
  sta zp_tmp1 + 1
  jsr draw_spry
letter2:
  lda #3
  cmp letter_counter
  bne next
  lda #<img_r
  sta zp_tmp1
  lda #>img_r
  sta zp_tmp1 + 1
  jsr draw_spry
reset_letter:
  lda #0
  sta letter_counter
next:
  jsr draw_color_voice
  lda #2
  cmp frame_counter
  beq scroll_letters
  jmp loop

scroll_letters:
  jsr scroll_text
  lda #0
  sta frame_counter
  jmp loop
rts

draw_voice:
  clc
  ldx #0
lp_draw_voice:
    lda bitmap1, x

    sta $2000 + (18*8) + (09*8*40),x
    sta $2000 + (18*8) + (10*8*40),x
    sta $2000 + (18*8) + (11*8*40),x
    sta $2000 + (18*8) + (12*8*40),x
    sta $2000 + (18*8) + (13*8*40),x
    sta $2000 + (18*8) + (14*8*40),x
    sta $2000 + (18*8) + (15*8*40),x
    sta $2000 + (18*8) + (16*8*40),x

    sta $2000 + (20*8) + (08*8*40),x
    sta $2000 + (20*8) + (09*8*40),x
    sta $2000 + (20*8) + (10*8*40),x
    sta $2000 + (20*8) + (11*8*40),x
    sta $2000 + (20*8) + (12*8*40),x
    sta $2000 + (20*8) + (13*8*40),x
    sta $2000 + (20*8) + (14*8*40),x
    sta $2000 + (20*8) + (15*8*40),x
    sta $2000 + (20*8) + (16*8*40),x
    sta $2000 + (20*8) + (17*8*40),x
    sta $2000 + (20*8) + (18*8*40),x

    sta $2000 + (22*8) + (09*8*40),x
    sta $2000 + (22*8) + (10*8*40),x
    sta $2000 + (22*8) + (11*8*40),x
    sta $2000 + (22*8) + (12*8*40),x
    sta $2000 + (22*8) + (13*8*40),x
    sta $2000 + (22*8) + (14*8*40),x
    sta $2000 + (22*8) + (15*8*40),x
    sta $2000 + (22*8) + (16*8*40),x
    inx
    cpx #8
  bne lp_draw_voice

  lda #$20
  sta $0400 + (20) + (06*40)
  sta $0400 + (20) + (07*40)
  sta $0400 + (20) + (08*40)
  sta $0400 + (20) + (09*40)
  sta $0400 + (20) + (10*40)
  sta $0400 + (20) + (11*40)
  sta $0400 + (20) + (12*40)
  sta $0400 + (20) + (13*40)
  sta $0400 + (20) + (14*40)

  sta $0400 + (18) + (06*40)
  sta $0400 + (18) + (07*40)
  sta $0400 + (18) + (08*40)
  sta $0400 + (18) + (09*40)
  sta $0400 + (18) + (10*40)
  sta $0400 + (18) + (11*40)
  sta $0400 + (18) + (12*40)
  sta $0400 + (18) + (13*40)
  sta $0400 + (18) + (14*40)

  sta $0400 + (22) + (06*40)
  sta $0400 + (22) + (07*40)
  sta $0400 + (22) + (08*40)
  sta $0400 + (22) + (09*40)
  sta $0400 + (22) + (10*40)
  sta $0400 + (22) + (11*40)
  sta $0400 + (22) + (12*40)
  sta $0400 + (22) + (13*40)
  sta $0400 + (22) + (14*40)
rts

draw_air:
  ldx #0
!loop:
    lda img_air, x
    sta $2000 + (13*8) + (8*8*40),x
    inx
    cpx #24
  bne !loop-
  lda #$70
  sta $0400 + (13) + (8*40)
  sta $0400 + (14) + (8*40)
  sta $0400 + (15) + (8*40)
rts

draw_oil:
  ldx #0
  !loop:
    lda img_oil, x
    sta $2000 + (13*8) + (10*8*40),x
    inx
    cpx #24
  bne !loop-
  lda #$70
  sta $0400 + (13) + (10*40)
  sta $0400 + (14) + (10*40)
  sta $0400 + (15) + (10*40)
rts

draw_p1:
  ldx #0
  !loop:
    lda img_p1, x
    sta $2000 + (13*8) + (12*8*40),x
    inx
    cpx #24
  bne !loop-
  lda #$20
  sta $0400 + (13) + (12*40)
  sta $0400 + (14) + (12*40)
  sta $0400 + (15) + (12*40)
rts

draw_p2:
  ldx #0
  !loop:
    lda img_p2, x
    sta $2000 + (13*8) + (14*8*40),x
    inx
    cpx #24
  bne !loop-
  lda #$20
  sta $0400 + (13) + (14*40)
  sta $0400 + (14) + (14*40)
  sta $0400 + (15) + (14*40)
rts

draw_s1:
  ldx #0
  !loop:
    lda img_s1, x
    sta $2000 + (25*8) + (8*8*40),x
    inx
    cpx #24
  bne !loop-
  lda #$70
  sta $0400 + (25) + (8*40)
  sta $0400 + (26) + (8*40)
  sta $0400 + (27) + (8*40)
rts

draw_s2:
  ldx #0
  !loop:
    lda img_s2, x
    sta $2000 + (25*8) + (10*8*40),x
    inx
    cpx #24
  bne !loop-
  lda #$70
  sta $0400 + (25) + (10*40)
  sta $0400 + (26) + (10*40)
  sta $0400 + (27) + (10*40)
rts

draw_p3:
  ldx #0
  !loop:
    lda img_p3, x
    sta $2000 + (25*8) + (12*8*40),x
    inx
    cpx #24
  bne !loop-
  lda #$20
  sta $0400 + (25) + (12*40)
  sta $0400 + (26) + (12*40)
  sta $0400 + (27) + (12*40)
rts

draw_p4:
  ldx #0
  !loop:
    lda img_p4, x
    sta $2000 + (25*8) + (14*8*40),x
    inx
    cpx #24
  bne !loop-
  lda #$20
  sta $0400 + (25) + (14*40)
  sta $0400 + (26) + (14*40)
  sta $0400 + (27) + (14*40)
rts

draw_spry:
  ldy #0
  !loop:
    lda (zp_tmp1), y
    sta screen_row_20 + screen_col_39,y
    iny
    cpy #8
  bne !loop-
  lda #$00
  sta color_row_20 + color_col_39
rts

draw_scroll:
  ldx #0
  !loop:
    lda img_scroll, x
    sta screen_col_30 + screen_row_20,x
    inx
    cpx #8
  bne !loop-

  lda #$20
  ldx #0
  !loop:
    sta $400 + (0*8) + (20*8*40),x
    inx
    cpx #40
  bne !loop-
rts

scroll_text:
  ldy #0
!loop_outer:
  ldx #0
  !loop:
    rol screen_row_20 + screen_col_39,x
    rol screen_row_20 + screen_col_39-8,x
    rol screen_row_20 + screen_col_39-(8*2),x
    rol screen_row_20 + screen_col_39-(8*3),x
    rol screen_row_20 + screen_col_39-(8*4),x
    rol screen_row_20 + screen_col_39-(8*5),x
    rol screen_row_20 + screen_col_39-(8*6),x
    rol screen_row_20 + screen_col_39-(8*7),x
    rol screen_row_20 + screen_col_39-(8*8),x
    rol screen_row_20 + screen_col_39-(8*9),x
    rol screen_row_20 + screen_col_39-(8*10),x
    rol screen_row_20 + screen_col_39-(8*11),x
    rol screen_row_20 + screen_col_39-(8*12),x
    rol screen_row_20 + screen_col_39-(8*13),x
    rol screen_row_20 + screen_col_39-(8*14),x
    rol screen_row_20 + screen_col_39-(8*15),x
    rol screen_row_20 + screen_col_39-(8*16),x
    rol screen_row_20 + screen_col_39-(8*17),x
    rol screen_row_20 + screen_col_39-(8*18),x
    rol screen_row_20 + screen_col_39-(8*19),x
    rol screen_row_20 + screen_col_39-(8*20),x
    rol screen_row_20 + screen_col_39-(8*21),x
    rol screen_row_20 + screen_col_39-(8*22),x
    rol screen_row_20 + screen_col_39-(8*23),x
    rol screen_row_20 + screen_col_39-(8*24),x
    rol screen_row_20 + screen_col_39-(8*25),x
    rol screen_row_20 + screen_col_39-(8*26),x
    rol screen_row_20 + screen_col_39-(8*27),x
    rol screen_row_20 + screen_col_39-(8*28),x
    rol screen_row_20 + screen_col_39-(8*29),x
    rol screen_row_20 + screen_col_39-(8*30),x
    rol screen_row_20 + screen_col_39-(8*31),x
    rol screen_row_20 + screen_col_39-(8*32),x
    rol screen_row_20 + screen_col_39-(8*33),x
    rol screen_row_20 + screen_col_39-(8*34),x
    rol screen_row_20 + screen_col_39-(8*35),x
    rol screen_row_20 + screen_col_39-(8*36),x
    //rol screen_row_20 + screen_col_39-(8*37),x
    inx
    cpx #8
    bne !loop-
    iny
    cpy #2
    bne !loop_outer-
    inc scroll_counter
rts

draw_blank_voice:
  lda #$00
  sta $0400 + (18) + (05*40)
  sta $0400 + (18) + (06*40)
  sta $0400 + (18) + (07*40)
  sta $0400 + (18) + (08*40)
  sta $0400 + (18) + (09*40)
  sta $0400 + (18) + (10*40)
  sta $0400 + (18) + (11*40)
  sta $0400 + (18) + (12*40)
  sta $0400 + (18) + (13*40)
  sta $0400 + (18) + (14*40)

  sta $0400 + (20) + (05*40)
  sta $0400 + (20) + (06*40)
  sta $0400 + (20) + (07*40)
  sta $0400 + (20) + (08*40)
  sta $0400 + (20) + (09*40)
  sta $0400 + (20) + (10*40)
  sta $0400 + (20) + (11*40)
  sta $0400 + (20) + (12*40)
  sta $0400 + (20) + (13*40)
  sta $0400 + (20) + (14*40)

  sta $0400 + (22) + (05*40)
  sta $0400 + (22) + (06*40)
  sta $0400 + (22) + (07*40)
  sta $0400 + (22) + (08*40)
  sta $0400 + (22) + (09*40)
  sta $0400 + (22) + (10*40)
  sta $0400 + (22) + (11*40)
  sta $0400 + (22) + (12*40)
  sta $0400 + (22) + (13*40)
  sta $0400 + (22) + (14*40)
rts

draw_color_voice:
  lda #$20
  sta $0400 + (18) + (14*40)
  sta $0400 + (18) + (13*40)
  sta $0400 + (18) + (12*40)
  sta $0400 + (18) + (11*40)
  sta $0400 + (18) + (10*40)
  sta $0400 + (18) + (09*40)
  sta $0400 + (18) + (08*40)
  sta $0400 + (18) + (07*40)
  sta $0400 + (18) + (06*40)

  sta $0400 + (20) + (14*40)
  sta $0400 + (20) + (13*40)
  sta $0400 + (20) + (12*40)
  sta $0400 + (20) + (11*40)
  sta $0400 + (20) + (10*40)
  sta $0400 + (20) + (09*40)
  sta $0400 + (20) + (08*40)
  sta $0400 + (20) + (07*40)
  sta $0400 + (20) + (06*40)

  sta $0400 + (22) + (06*40)
  sta $0400 + (22) + (07*40)
  sta $0400 + (22) + (08*40)
  sta $0400 + (22) + (09*40)
  sta $0400 + (22) + (10*40)
  sta $0400 + (22) + (11*40)
  sta $0400 + (22) + (12*40)
  sta $0400 + (22) + (13*40)
  sta $0400 + (22) + (14*40)
rts

clear_color:
  clc
  lda #0
  ldx #0
  lp_clear_color:
    sta $0400,x
    sta $0500,x
    sta $0600,x
    inx
    cpx #255
  bne lp_clear_color  
rts

bitmap1:
  .byte %00000000, %01010101, %01010101, %01010101, %00000000, %01010101, %01010101, %01010101

img_air:
  .byte %00010101, %01000000, %01000100, %01000000, %01000100, %01000100, %01000100, %00010101
  .byte %01010101, %01000100, %01000100, %01000100, %01000100, %01000100, %01000100, %01010101
  .byte %01010100, %00000101, %01000101, %00000101, %00010101, %01000101, %01000101, %01010100

img_oil:
  .byte %00010101, %01000000, %01000100, %01000100, %01000100, %01000100, %01000000, %00010101
  .byte %01010101, %01000100, %01000100, %01000100, %01000100, %01000100, %01000100, %01010101
  .byte %01010100, %01010101, %01010101, %01010101, %01010101, %01010101, %00000101, %01010100

img_p1:
  .byte %00010101, %01010000, %01010001, %01010001, %01010000, %01010001, %01010001, %00010101
  .byte %01010101, %00010100, %00010001, %00010101, %00010101, %01010101, %01010101, %01010101
  .byte %01010100, %00010101, %00010101, %00010101, %00010101, %00010101, %00010101, %01010100

img_p2:
  .byte %00010101, %01010000, %01010001, %01010001, %01010000, %01010001, %01010001, %00010101
  .byte %01010101, %00010100, %00010101, %00010101, %00010100, %01010100, %01010100, %01010101
  .byte %01010100, %00000101, %01000101, %01000101, %00000101, %01010101, %00000101, %01010100

img_s1:
  .byte %00010101, %01010000, %01010001, %01010001, %01010000, %01010101, %01010000, %00010101
  .byte %01010101, %00010100, %00010001, %01010101, %00010101, %00010101, %00010101, %01010101
  .byte %01010100, %00010101, %00010101, %00010101, %00010101, %00010101, %00010101, %01010100

img_s2:
  .byte %00010101, %01010000, %01010001, %01010001, %01010000, %01010101, %01010000, %00010101
  .byte %01010101, %00010100, %00010101, %01010101, %00010100, %00010100, %00010100, %01010101
  .byte %01010100, %00000101, %01000101, %01000101, %00000101, %01010101, %00000101, %01010100

img_p3:
  .byte %00010101
  .byte %01010000
  .byte %01010001
  .byte %01010001
  .byte %01010000
  .byte %01010001
  .byte %01010001
  .byte %00010101

  .byte %01010101
  .byte %00010100
  .byte %00010101
  .byte %00010101
  .byte %00010100
  .byte %01010101
  .byte %01010100
  .byte %01010101

  .byte %01010100
  .byte %00000101
  .byte %01000101
  .byte %01000101
  .byte %00000101
  .byte %01000101
  .byte %00000101
  .byte %01010100

img_p4:
  .byte %00010101
  .byte %01010000
  .byte %01010001
  .byte %01010001
  .byte %01010000
  .byte %01010001
  .byte %01010001
  .byte %00010101

  .byte %01010101
  .byte %00010100
  .byte %00010100
  .byte %00010100
  .byte %00010100
  .byte %01010101
  .byte %01010101
  .byte %01010101

  .byte %01010100
  .byte %01000101
  .byte %01000101
  .byte %01000101
  .byte %00000101
  .byte %01000101
  .byte %01000101
  .byte %01010100

img_scroll:
  .byte %01010000
  .byte %01001000
  .byte %01000100
  .byte %01000001
  .byte %01000001
  .byte %01000001
  .byte %01000100
  .byte %01010000

  img_s:
  .byte %01010100
  .byte %01000000
  .byte %01000000
  .byte %01010100
  .byte %00000100
  .byte %00000100
  .byte %00000100
  .byte %01010100
img_p:
  .byte %01010100
  .byte %01000100
  .byte %01000100
  .byte %01010100
  .byte %01000000
  .byte %01000000
  .byte %01000000
  .byte %01000000
img_r:
  .byte %01010100
  .byte %01000100
  .byte %01000100
  .byte %01010100
  .byte %01010000
  .byte %01000100
  .byte %01000100
  .byte %01000100
img_spry_end:

scroll_counter: .byte $00
letter_counter: .byte $00
frame_counter:  .byte $00
kitt_voice_flag: .byte $00

// *=$0801
//   .byte $0c,$08,$0a,$00,$9e,$34,$30,$39,$36,$00,$00,$00
irq:
    //dec $d020
    lda #0
    cmp kitt_voice_flag
    bne change_voice
    jsr draw_color_voice
    lda #0
    sta kitt_voice_flag
    jmp voice_changed
  change_voice:
    //lda #0
    inc kitt_voice_flag
    jsr draw_blank_voice
  voice_changed:
    inc frame_counter
    asl $d019
    jsr music.play

    jmp $EA31 

//---------------------------------------------------------
        *=music.location "Music"
        .fill music.size, music.getData(i)

//----------------------------------------------------------
