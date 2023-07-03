*=$4000 "Sid Program"
BasicUpstart2(start)
    // character graphics mode CIA
    .const joystick1 = $dc01
    .const joystick2 = $dc00
    .const cia_2_in_out       = $dd02
    .const cia_2_vid_bank     = $dd00

    .const vic_sprite_0_x     = $d000
    .const vic_sprite_0_y     = $d001

    .const vic_sprite_1_x     = $d002
    .const vic_sprite_1_y     = $d003

    .const vic_sprite_2_x     = $d004
    .const vic_sprite_2_y     = $d005

    .const vic_sprite_3_x     = $d006
    .const vic_sprite_3_y     = $d007

    .const vic_sprite_4_x     = $d008
    .const vic_sprite_4_y     = $d009

    .const vic_sprite_5_x     = $d00a
    .const vic_sprite_5_y     = $d00b

    .const vic_sprite_6_x     = $d00c
    .const vic_sprite_6_y     = $d00d

    .const vic_sprite_7_x     = $d00e
    .const vic_sprite_7_y     = $d00f
    .const vic_sprite_msb     = $d010

    .const vic_sprite_on_off  = $d015
    .const vic_sprite_0_color = $d027
    .const vic_sprite_1_color = $d028
    .const vic_sprite_2_color = $d029
    .const vic_sprite_3_color = $d02a
    .const vic_sprite_4_color = $d02b
    .const vic_sprite_5_color = $d02c
    .const vic_sprite_6_color = $d02d
    .const vic_sprite_7_color = $d02e

    //screen offsets
    .const vic_screen_start   = $0400
    .const vic_sprite_0_loc   = $07f8
    .const vic_sprite_1_loc   = $07f9
    .const vic_sprite_2_loc   = $07fa
    .const vic_sprite_3_loc   = $07fb
    .const vic_sprite_4_loc   = $07fc
    .const vic_sprite_5_loc   = $07fd
    .const vic_sprite_6_loc   = $07fe
    .const vic_sprite_7_loc   = $07ff
 
    //vic rom 
    .const vic_color_start    = $d800

    .const vic_scrn_mem       = $d018
    .const vic_border         = $d020
    .const vic_background0    = $d021
    .const vic_background1    = $d022
    .const vic_background2    = $d023
start:
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

    lda #3
    sta vic_color_start + (vic_sprite_0_loc - 2 + vic_screen_start) 
    lda #1
    sta vic_sprite_0_loc - 2

    lda #$03
    ldx #0
    !loop:
    sta vic_color_start, x 
    sta vic_color_start + $ff, x 
    sta vic_color_start + $ff + $ff, x 
    sta vic_color_start + $ff + $ff + $ff , x 
    inx
    cpx #0
    bne !loop-

    lda #$0
    sta vic_border
    sta vic_background0

    lda #192
    sta vic_sprite_0_loc
    lda #193
    sta vic_sprite_1_loc

    lda #$d
    sta vic_sprite_0_color
    lda #$d
    sta vic_sprite_1_color

    lda #100
    sta vic_sprite_0_x
    sta vic_sprite_0_y
    sta vic_sprite_1_x
    sta vic_sprite_1_y

    ldx #0
    !loop:
    lda sprite0, x 
    sta 192*64, x
    inx
    cpx #63
    bne !loop-

    ldx #0
    !loop:
    lda sprite1, x 
    sta 193*64, x
    sta vic_screen_start, x
    inx
    cpx #63
    bne !loop-

game_loop:
    lda $cb
    sta vic_screen_start

    lda vic_sprite_0_x
    sta vic_sprite_1_x

    lda vic_sprite_0_y
    sta vic_sprite_1_y

wait:
    lda $d012
    cmp #200
    bne wait
    
    lda sprite_animation
    cmp #0
    bne check_frame1
    lda #00000001
    sta vic_sprite_on_off
check_frame1:
    lda sprite_animation
    cmp #128
    bne end_frame_check
    lda #00000010
    sta vic_sprite_on_off
end_frame_check:
    inc sprite_animation
check_w:
    lda joystick2
    and #%00000001
    cmp #0
    bne check_a
    dec vic_sprite_0_y
check_a:
    lda joystick2
    and #%00000100
    cmp #0
    bne check_d
    dec vic_sprite_0_x
    lda vic_sprite_0_x
    cmp #$ff
    bne check_d
    lda #0
    sta vic_screen_start
    lda $d010
    and #%11111110
    sta $d010
check_d:
    lda joystick2
    and #%00001000
    cmp #0
    bne check_s
    inc vic_sprite_0_x
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
    lda joystick2
    and #%00000010
    cmp #0
    bne continue
    inc vic_sprite_0_y
continue:
  jmp game_loop
rts
sprite_animation:
.byte $0

sprite0:
.byte %00000000, %00000000, %00000000
.byte %00000000, %11111111, %00000000
.byte %00000011, %11111111, %11000000
.byte %00000111, %11111111, %11100000
.byte %00001111, %11111111, %11110000
.byte %00011111, %11111111, %11100000
.byte %00011111, %11111111, %11000000

.byte %00111111, %11111111, %10000000
.byte %01111111, %11111110, %00000000
.byte %01111111, %11111100, %00000000
.byte %01111111, %11111000, %00000000
.byte %01111111, %11110000, %00000000
.byte %01111111, %11111100, %00000000
.byte %00111111, %11111111, %00000000
.byte %00111111, %11111111, %10000000

.byte %00111111, %11111111, %11100000
.byte %00111111, %11111111, %11110000
.byte %00011111, %11111111, %11110000
.byte %00001111, %11111111, %11110000
.byte %00000011, %11111111, %11000000
.byte %00000000, %11111111, %00000000
.byte %00000000, %01111110, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000
sprite0_end:

sprite1:
.byte %00000000, %00000000, %00000000
.byte %00000000, %11111111, %00000000
.byte %00000011, %11111111, %11000000
.byte %00000111, %11111111, %11100000
.byte %00001111, %11111111, %11110000
.byte %00011111, %11111111, %11100000
.byte %00011111, %11111111, %11110000

.byte %00111111, %11111111, %11110000
.byte %01111111, %11111111, %11110000
.byte %01111111, %11111111, %11111000
.byte %01111111, %11111111, %11111000
.byte %01111111, %11111111, %11111000
.byte %01111111, %11111111, %11111000
.byte %00111111, %11111111, %11111000

.byte %00111111, %11111111, %11110000
.byte %00011111, %11111111, %11110000
.byte %00001111, %11111111, %11110000
.byte %00000011, %11111111, %11000000
.byte %00000000, %11111111, %00000000
.byte %00000000, %01111110, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000
sprite1_end:
