*=$4000 "Sid Program"
BasicUpstart2(start)
start:

    // character graphics mode
    .const cia_2_in_out       = $dd02
    .const cia_2_vid_bank     = $dd00

    .const vic_sprite_0_x     = $d000
    .const vic_sprite_0_y     = $d001

    .const vic_sprite_0_color = $d027
    .const vic_screen_start   = $0400
    .const vic_sprite_start   = $07f8
    .const vic_sprite_on_off  = $d015
    .const vic_color_start    = $d800

    .const vic_scrn_mem       = $d018
    .const vic_border         = $d020
    .const vic_background0    = $d021
    .const vic_background1    = $d022
    .const vic_background2    = $d023

    lda cia_2_in_out
    ora #$03
    sta cia_2_in_out

    lda cia_2_vid_bank
    and #%11111100
    ora #%00000011
    sta cia_2_vid_bank

    lda vic_scrn_mem
    and #%00001111
    ora #%00010000
    sta vic_scrn_mem

    lda #1
    sta vic_screen_start

    lda #$03
    sta vic_color_start

    lda #$0
    sta vic_border
    sta vic_background0

    lda #14
    sta vic_sprite_start

    lda #3
    sta vic_sprite_0_color

    lda #00000001
    sta vic_sprite_on_off

    lda #100
    sta vic_sprite_0_x
    sta vic_sprite_0_y

    ldx #0
    !loop:
    lda sprite0, x 
    sta 896, x
    inx
    cpx #64
    bne !loop-

game_loop:

wait:
    lda $d012
    cmp #200
    bne wait

    lda $cb
    sta vic_screen_start
check_w:
    cmp #$09
    bne check_a
    dec vic_sprite_0_y
check_a:
    clc
    cmp #$0a
    bne check_d
    dec vic_sprite_0_x
    lda vic_sprite_0_x
    cmp #$12
    bne check_d
    lda #0
    sta vic_screen_start
    lda $d010
    and #%11111110
    sta $d010
check_d:
    cmp #$12
    bne check_s
    inc vic_sprite_0_x
    lda #1
    sta vic_screen_start
    lda vic_sprite_0_x
    cmp #0
    bne check_s
    beq check_over
check_over:
    lda #0
    sta vic_screen_start
    lda $d010
    ora #$1
    sta $d010
check_s:
    cmp #$0d
    bne continue
    inc vic_sprite_0_y
continue:
  jmp game_loop
rts


sprite0:
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff

.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff

.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
.byte $ff, $ff, $ff
sprite0_end:
