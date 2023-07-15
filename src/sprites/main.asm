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
    .const vic_sprite_ptr_0   = $07f8
    .const vic_sprite_ptr_1   = $07f9
    .const vic_sprite_ptr_2   = $07fa
    .const vic_sprite_ptr_3   = $07fb
    .const vic_sprite_ptr_4   = $07fc
    .const vic_sprite_ptr_5   = $07fd
    .const vic_sprite_ptr_6   = $07fe
    .const vic_sprite_ptr_7   = $07ff
 
    //vic rom 
    .const vic_color_start    = $d800

    .const vic_scrn_mem       = $d018
    .const vic_border         = $d020
    .const vic_background0    = $d021
    .const vic_background1    = $d022
    .const vic_background2    = $d023

     .const rnd = $d41B
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

    lda #32
    ldx #0
    !loop:
    sta vic_screen_start, x 
    sta vic_screen_start + $ff, x 
    sta vic_screen_start + $ff + $ff, x 
    sta vic_screen_start + $ff + $ff + $ff , x 
    inx
    cpx #0
    bne !loop-

    lda #$1
    sta vic_border
    lda #0
    sta vic_background0

    //gobler
    lda #192
    sta vic_sprite_ptr_0
    lda #193
    sta vic_sprite_ptr_1

    //car
    lda #194
    sta vic_sprite_ptr_2
    lda #195
    sta vic_sprite_ptr_3

    lda #$d
    sta vic_sprite_0_color
    lda #$d
    sta vic_sprite_1_color

    lda #$5
    sta vic_sprite_2_color
    lda #$5
    sta vic_sprite_3_color

    lda #100
    sta vic_sprite_0_x
    sta vic_sprite_0_y

    sta vic_sprite_1_x
    sta vic_sprite_1_y

    lda #50
    sta vic_sprite_2_y
    sta vic_sprite_3_y
    lda #200
    sta vic_sprite_2_x
    lda #223
    sta vic_sprite_3_x

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
    inx
    cpx #63
    bne !loop-

    ldx #0
    !loop:
    lda sprite2, x 
    sta 194*64, x
    inx
    cpx #63
    bne !loop-

    ldx #0
    !loop:
    lda sprite3, x 
    sta 195*64, x
    inx
    cpx #63
    bne !loop-

   
    lda #$ff  // maximum frequency value
    sta $d40e // voice 3 frequency low byte
    sta $d40f // voice 3 frequency high byte
    lda #$80  // noise waveform, gate bit off
    sta $d412 // voice 3 control register
    lda #0
    sta car_frame
game_loop:
wait:
    //-----------------------------------
    // delay for a frame-- better to use irq
    //-----------------------------------
    lda $d012
    cmp #200
    bne wait
    
    inc frame_counter
    lda frame_counter
    cmp #120
    bne end_frame_counter
    lda #0
    sta frame_counter
    sta car_frame
end_frame_counter:

    ///////////////////////////
    // drop dots
    ///////////////////////////
   clc
   ldx #0
    lda vic_sprite_3_x
xcol:
    cmp #8
    bcc end_xcol
    sbc #8
    inx
    jmp xcol
end_xcol:
    stx dot_x

    lda vic_sprite_msb
    and #%00001000
    cmp #%1000
    bne end_over
    lda dot_x
    adc #31
    sta dot_x
end_over:

    clc
    ldx #0
    lda vic_sprite_3_y
ycol:
    cmp #8
    bcc end_ycol
    sbc #8
    inx
    jmp ycol
end_ycol:
    stx dot_y

    lda dot_x
    sta vic_screen_start

    lda dot_y
    sta vic_screen_start + 1


    /////////////////////
    // drop dot
    /////////////////////
    clc
    lda #<vic_screen_start
    sta $fe
    lda #>vic_screen_start
    sta $ff
    lda dot_y
    sbc #4
    sta dot_y
    ldy #0
dot_location:
    lda $fe
    adc #40
    sta $fe
    bcs add_hi
    bcc incremtent_y
add_hi:
    inc $ff
incremtent_y:
    iny 
    cpy dot_y 
bne dot_location
dot_location_end:


    clc
    lda $fe
    adc dot_x
    sta $fe
    bcc end_sc_pos
    inc $ff
end_sc_pos:




    lda #46
    ldy #0
    sta ($fe) ,y









    

    


    //-----------------------------------
    // Aminate Gobbler
    //-----------------------------------
    lda sprite_animation
    cmp #0
    bne check_frame1
    lda #%00001101
    sta vic_sprite_on_off
check_frame1:
    lda sprite_animation
    cmp #15
    bne check_frame2
    lda #%00001110
    sta vic_sprite_on_off
check_frame2:  
    lda sprite_animation
    cmp #30
    bne check_frame3
    lda #%00001101
    sta vic_sprite_on_off
check_frame3:
    lda sprite_animation
    cmp #45
    bne check_last_frame
    lda #%00001110
    sta sprite_animation
check_last_frame:
    lda sprite_animation
    cmp #60
    bne end_frame_check
    lda $ff
    sta sprite_animation
end_frame_check:
    inc sprite_animation


    //-----------------------------------
    // Set Direction
    //-----------------------------------
    lda car_frame
    cmp #0
    bne set_direction_end
    inc car_frame
    lda rnd 
    sta random_dir
    clc
set_direction:
    lda random_dir
    cmp #64
    bcs direction1
    lda #0
    sta car_direction
    jmp set_direction_end
direction1:
    lda random_dir
    cmp #128
    bcs direction2
    lda #1
    sta car_direction
    jmp set_direction_end
direction2:
    lda random_dir
    cmp #190
    bcs direction3
    lda #2
    sta car_direction
    jmp set_direction_end
direction3:
    lda #3
    sta car_direction
set_direction_end:

    //-----------------------------------
    // Move Truckster
    //-----------------------------------

 move_truck_right:
    lda car_direction
    cmp #0
    bne move1
    inc vic_sprite_2_x
    lda vic_sprite_2_x
    adc #23
    sta vic_sprite_3_x

    lda vic_sprite_3_x
    cmp #0
    bne end_over_check3
    lda vic_sprite_msb
    and #%11110111
    ora #%00001000
    sta vic_sprite_msb
end_over_check3:
    lda vic_sprite_2_x
    cmp #0
    bne end_over_check2
    lda vic_sprite_msb
    and #%11111011
    ora #%00000100
    sta vic_sprite_msb
end_over_check2:
    jmp truckster_move_end
move1: // move truck left
    lda car_direction
    cmp #1
    bne move2
    dec vic_sprite_2_x
    lda vic_sprite_2_x
    adc #23
    sta vic_sprite_3_x
    
    lda vic_sprite_2_x
    cmp #$ff
    bne end_under_check2
    lda vic_sprite_msb
    and #%11111011
    sta vic_sprite_msb
end_under_check2:

    lda vic_sprite_3_x
    cmp #$ff
    bne end_under_check3
    lda vic_sprite_msb
    and #%11110111
    sta vic_sprite_msb
end_under_check3:

    jmp truckster_move_end
move2:
    lda car_direction
    cmp #2
    bne move3
    inc vic_sprite_2_y
    inc vic_sprite_3_y
    jmp truckster_move_end
move3:
    dec vic_sprite_2_y
    dec vic_sprite_3_y
truckster_move_end:


    //-----------------------------------
    // Gobbler Movement
    //-----------------------------------
check_up:
    lda joystick2
    and #%00000001
    cmp #0
    bne check_left
    dec vic_sprite_0_y
    dec vic_sprite_1_y
check_left:
    lda joystick2
    and #%00000100
    cmp #0
    bne check_right
    dec vic_sprite_0_x
    dec vic_sprite_1_x
    lda vic_sprite_0_x
    cmp #$ff
    bne check_right
    lda $d010
    and #%00000000
    sta $d010
check_right:
    lda joystick2
    and #%00001000
    cmp #0
    bne check_down
    inc vic_sprite_0_x
    inc vic_sprite_1_x
    lda vic_sprite_0_x
    cmp #0
    bne check_down
    //set over flow bit
    lda $d010
    and #%11111100
    ora #%00000011
    sta $d010
check_down:
    lda joystick2
    and #%00000010
    cmp #0
    bne move_end
    inc vic_sprite_0_y
    inc vic_sprite_1_y
move_end:


    //-----------------------------------
    // Check Min Gobbler X Position
    //-----------------------------------
    lda vic_sprite_msb
    and #$01
    cmp #$0
    bne check_min_x_end
    lda vic_sprite_0_x
    cmp #20
    bcs check_min_x_end
    lda #20
    sta vic_sprite_0_x
    sta vic_sprite_1_x
check_min_x_end:

    //-----------------------------------
    // Check Max Gobbler X Position
    //-----------------------------------
    lda vic_sprite_msb
    and #$01
    cmp #$01
    bne check_max_x_end
    lda vic_sprite_0_x
    cmp #65
    bcc check_max_x_end
    lda #65
    sta vic_sprite_0_x
    sta vic_sprite_1_x
check_max_x_end:

    //-----------------------------------
    // Check min truckster X Position
    //-----------------------------------
    //upper area
    lda vic_sprite_msb
    and #%00001100
    cmp #0
    bne check_min_truckster_x_end
    lda vic_sprite_2_x
    cmp #20
    bcs check_min_truckster_x_end
    lda #22
    sta vic_sprite_2_x
    lda vic_sprite_2_x
    adc #23
    sta vic_sprite_3_x

    lda #0
    sta car_frame
    check_min_truckster_x_end:

    //-----------------------------------
    // Check Max truckster X Position
    //-----------------------------------
    lda vic_sprite_msb
    and #%00001100
    cmp #%1100
    bne check_max_truckster_x_end
    lda vic_sprite_3_x
    cmp #53
    bcc check_max_truckster_x_end
    lda #25
    sta vic_sprite_2_x
    lda vic_sprite_2_x
    adc #23
    sta vic_sprite_3_x
    lda #0
    sta car_frame
    jmp continue
check_max_truckster_x_end:

    //-----------------------------------
    // Check Min truckster y Position
    //-----------------------------------
    lda vic_sprite_2_y
    cmp #50
    bcs check_min_truckster_y_end
    lda #50
    sta vic_sprite_2_y
    sta vic_sprite_3_y
    lda #0
    sta car_frame
check_min_truckster_y_end:

    //-----------------------------------
    // Check max truckster y Position
    //-----------------------------------
    lda vic_sprite_2_y
    cmp #225
    bcc check_max_truckster_y_end
    lda #225
    sta vic_sprite_2_y
    sta vic_sprite_3_y

    lda #0
    sta car_frame
check_max_truckster_y_end:

continue:
  jmp game_loop
rts

sprite_animation:
    .byte $0
car_frame:
    .byte $0
car_direction:
    .byte $0
random_dir:
    .byte $0
frame_counter:
    .byte $0
dot_x:
    .byte $0
dot_y:
    .byte $0


sprite0:
.byte %00000000, %00000000, %00000000
.byte %00000000, %11111111, %00000000
.byte %00000011, %11111111, %11000000
.byte %00000111, %11111111, %11100000
.byte %00001111, %11111111, %11110000
.byte %00011111, %11111111, %11000000
.byte %00011111, %11111111, %00000000

.byte %00111111, %11111110, %00000000
.byte %01111111, %11111000, %00000000
.byte %01111111, %11100000, %00000000
.byte %01111111, %00000000, %00000000
.byte %01111111, %11100000, %00000000
.byte %01111111, %11110000, %00000000
.byte %00111111, %11111110, %00000000

.byte %00111111, %11111111, %00000000
.byte %00011111, %11111111, %11000000
.byte %00001111, %11111111, %11000000
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
.byte %00011111, %11111111, %11111000
.byte %00011111, %11111111, %11111000

.byte %00111111, %11111111, %11111100
.byte %01111111, %11111111, %11111110
.byte %01111111, %11111111, %11111110
.byte %01111111, %11111111, %11111110
.byte %01111111, %11111111, %11111110
.byte %01111111, %11111111, %11111110
.byte %00111111, %11111111, %11111100

.byte %00111111, %11111111, %11111100
.byte %00011111, %11111111, %11111000
.byte %00001111, %11111111, %11110000
.byte %00000011, %11111111, %11000000
.byte %00000000, %11111111, %00000000
.byte %00000000, %01111110, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000
sprite1_end:

sprite2:
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %11111111
.byte %00000000, %00000011, %11111111
.byte %00000000, %00001000, %00000010
.byte %00000000, %00010000, %00000010
.byte %00000000, %01100000, %00000010

.byte %00000000, %11111111, %11111111
.byte %11111111, %00000000, %00000000
.byte %10000000, %11111111, %11111111
.byte %01111111, %11111111, %11110011
.byte %01111111, %11111111, %11111111
.byte %11111111, %00000000, %11111111
.byte %00000000, %00111100, %00000000

.byte %00000000, %11111111, %00000000
.byte %00000000, %11100111, %00000000
.byte %00000000, %11111111, %00000000
.byte %00000000, %00111100, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000
sprite2_end:

sprite3:
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %1111111, %11111111, %00000000
.byte %11111111, %11111111, %10000000
.byte %00000000, %01000000, %01000000
.byte %00000000, %01000000, %00100000
.byte %00000000, %01000000, %00010000

.byte %11111111, %11111111, %11111110
.byte %00000000, %00000000, %00000000
.byte %11111111, %11111111, %11111110
.byte %11111100, %11111111, %11111100
.byte %11111111, %11111111, %11111100
.byte %11111111, %00000000, %11111110
.byte %00000000, %01111110, %00000000

.byte %00000000, %11111111, %00000000
.byte %00000000, %11100111, %00000000
.byte %00000000, %11111111, %00000000
.byte %00000000, %00111100, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000
sprite3_end: