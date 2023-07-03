*=$4000 "Sid Program"
#import "sid_notes.asm"
BasicUpstart2(start)
//BasicUpstart_128(start)
.const sid_chip = $d400
.const sid_chip_end = $d41c-$d400
.const sid_v1_lo = $d400
.const sid_v1_hi = $d401
.const sid_v1_duty_lo = $d402 //lower4
.const sid_v1_duty_hi = $d403 //lower4
.const sid_v1_control = $d404 //noise-pulse-saw-tri  --  test-ring mod v3 - sync v3 - gate
.const sid_v1_ad = $d405 //attack decay
.const sid_v1_sr = $d406 //sustain release

.const sid_v2_lo = $d407
.const sid_v2_hi = $d408
.const sid_v2_duty_lo = $d409 //lower4
.const sid_v2_duty_hi = $d40a //lower4
.const sid_v2_control = $d40b //noise-pulse-saw-tri  --  test-ring mod v3 - sync v3 - gate
.const sid_v2_ad = $d40c //attack decay
.const sid_v2_sr = $d40d //sustain release

.const sid_v3_lo = $d40e
.const sid_v3_hi = $d40f
.const sid_v3_duty_lo = $d410 //lower4
.const sid_v3_duty_hi = $d411 //lower4
.const sid_v3_control = $d412 //noise-pulse-saw-tri  --  test-ring mod v3 - sync v3 - gate
.const sid_v3_ad = $d413 //attack decay
.const sid_v3_sr = $d414 //sustain release

.const sid_freq_cut1 = $d415
.const sid_freq_cut2 = $d416
.const sid_filter_control = $d417
.const sid_v1_volume = $d418

//instruments
// piano
.const sid_piano_ad = $09
.const sid_piano_sr = $00
.const sid_piano_duty = 1536
.const sid_piano_wf = 11000001 // pulse

// calliope
.const sid_ad_calliope = $33
.const sid_sr_calliope = $33
.const sid_duty_calliope = 2000
.const sid_wf_calliope = 01000001 // triangle

// drum
.const sid_ad_drums = $05
.const sid_sr_drums = $50
.const sid_duty_drums = $0
.const sid_wf_drums = 10000001 // noise

// accordion
.const sid_ad_accordion = $0001
.const sid_sr_accordion = $0f0f
.const sid_duty_accordion = $0
.const sid_wf_accordion = 00100001 // sawtooth

// guitar
.const sid_ad_guitar = $09
.const sid_sr_guitar = $21
.const sid_duty_guitar = 0
.const sid_wf_guitar = 10100001 // sawtooth

start:
lda #0
ldx #0
!loop:
  sta sid_chip,x
  inx
  cpx sid_chip_end
  bne !loop-
  set_irq();
  lda #00000111
  sta sid_v1_volume

  set_voice_1()
  //set_voice_2()
  !mainloop:
  clc
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
    .byte $9e  // sysf
    .text toIntString(address)
    .byte 0
upstartEnd:
    .word 0  // empty link signals the end of the program
    .pc = $1c0e "Basic End"
}

.macro play_voice_1() {
    lda #0
    sta sid_v1_control
    lda #sid_wf_guitar
    sta sid_v1_control

    //lda #0
    //sta sid_freq_cut1
    //sta sid_freq_cut2
    //sta sid_filter_control
}

.macro play_voice_2() {
    lda #sid_wf_accordion
    sta sid_v2_control

    lda sid_v2_control
    ora #%00000001
    sta sid_v2_control
}

.macro play_noteV1() {
    lda note_durationV1
    cmp #0
    bne delay
    ldx music_ctrV1
    lda musicV1,x
    sta sid_v1_lo
    lda musicV1 + 1, x
    sta sid_v1_hi
    play_voice_1()
delay:
  inc note_durationV1
  ldx music_ctrV1
  lda musicV1+2,x
  cmp note_durationV1
  bne finish
  lda #0
  sta note_durationV1
  inc $d020
  inc music_ctrV1
  inc music_ctrV1
  inc music_ctrV1
finish:
}

.macro play_noteV2() {
    lda note_durationV2
    cmp #0
    bne delay
    ldx music_ctrV2
    lda musicV2,x
    sta sid_v2_lo
    lda musicV2 + 1, x
    sta sid_v2_hi
    play_voice_2()
delay:
  inc note_durationV2
  ldx music_ctrV2
  lda musicV2+2,x
  cmp note_durationV2
  bne finish
  lda #0
  sta note_durationV2
  inc $d020
  inc music_ctrV2
  inc music_ctrV2
  inc music_ctrV2
finish:
}

.macro set_voice_1() {
  lda #sid_ad_guitar
  sta sid_v1_ad
  lda #sid_sr_guitar
  sta sid_v1_sr

  lda #<sid_duty_guitar
  sta sid_v1_duty_lo
  lda #>sid_duty_guitar
  sta sid_v1_duty_hi
}

.macro set_voice_2() {
  lda #sid_ad_accordion
  sta sid_v2_ad
  lda #sid_sr_accordion
  sta sid_v2_sr

  lda #<sid_duty_accordion
  sta sid_v2_duty_lo
  lda #>sid_duty_accordion
  sta sid_v2_duty_hi
}

.macro set_irq() {
  sei 
  lda #%01111111
  sta $DC0D

  and $D011            // clear most significant bit of VIC's raster register
  sta $D011

  lda $DC0D            // acknowledge pending interrupts from CIA-1
  lda $DD0D            // acknowledge pending interrupts from CIA-2
  lda #210             // set rasterline where interrupt shall occur
  sta $D012

  lda #<irq            // set interrupt vectors, pointing to interrupt service routine below
  sta $0314
  lda #>irq
  sta $0315

  lda #%00000001       // enable raster interrupt signals from VIC
  sta $D01A
  cli                  // clear interrupt flag, allowing the CPU to respond to interrupt requests
}

irq:       
        asl $d019
        inc $d020
        play_noteV1()      
        //play_noteV2() 
        dec $d020
        jmp $EA31  
*=$8000 
musicV1:
.byte <G_4, >G_4, 20
.byte <A_4, >A_4, 20
.byte <G_4, >G_4, 20
.byte <F_4, >F_4, 20
.byte <E_4, >E_4, 20
.byte <F_4, >F_4, 20
.byte <G_4, >G_4, 40

.byte <D_4, >D_4, 20
.byte <E_4, >E_4, 20
.byte <F_4, >F_4, 40
.byte <E_4, >E_4, 20
.byte <F_4, >F_4, 20
.byte <G_4, >G_4, 40

.byte <G_4, >G_4, 20
.byte <A_4, >A_4, 20
.byte <G_4, >G_4, 20
.byte <F_4, >F_4, 20
.byte <E_4, >E_4, 20
.byte <F_4, >F_4, 20
.byte <G_4, >G_4, 40

.byte <D_4, >D_4, 40
.byte <G_4, >G_4, 40
.byte <E_4, >E_4, 20
.byte <D_4, >D_4, 20

.byte <G_4, >G_4, 20
.byte <A_4, >A_4, 20
.byte <G_4, >G_4, 20
.byte <F_4, >F_4, 20
.byte <E_4, >E_4, 20
.byte <F_4, >F_4, 20
.byte <G_4, >G_4, 40

.byte <D_4, >D_4, 20
.byte <E_4, >E_4, 20
.byte <F_4, >F_4, 40
.byte <E_4, >E_4, 20
.byte <F_4, >F_4, 20
.byte <G_4, >G_4, 40

.byte <G_4, >G_4, 20
.byte <A_4, >A_4, 20
.byte <G_4, >G_4, 20
.byte <F_4, >F_4, 20
.byte <E_4, >E_4, 20
.byte <F_4, >F_4, 20
.byte <G_4, >G_4, 40

.byte <D_4, >D_4, 40
.byte <G_4, >G_4, 40
.byte <E_4, >E_4, 20
.byte <D_4, >D_4, 20

musicV2:
.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40
.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40

.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40
.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40

.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40
.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40

.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40
.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40

.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40
.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40

.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40
.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40

.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40
.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40

.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40
.byte <C_5, >C_5, 40
.byte <G_5, >G_5, 40
note_durationV1:
.byte $00

note_durationV2:
.byte $00

music_ctrV1:
.byte $00

music_ctrV2:
.byte $00