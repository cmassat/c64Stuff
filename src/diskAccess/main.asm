BasicUpstart2(start)
.var load_address = $2000
* = $8000
start:
    // set border color
    lda #0
    sta $d020

    // set multi color
    lda $d016
    ora #00010000
    sta $d016

    // set bitmap
    lda $d011
    ora #00100000
    sta $d011

    // initscreen mem locations
    lda #%00011000
    sta $d018

    lda #9
    sta $d021
    lda #3
    sta $d022
    lda #8
    sta $d023

    ldx #0
!loop:
    lda color_start,x
    sta $d800,x
    lda color_matrix,x
    sta $0400,x
    inx
    cpx #250
    bne !loop-

    ldx #0
!loop:
    lda color_start + 250,x
    sta $d800 + 250,x
    lda color_matrix + 250,x
    sta $0400 + 250,x
    inx
    cpx #250
    bne !loop-

    ldx #0
!loop:
    lda color_start + 500,x
    sta $d800 + 500,x
    lda color_matrix + 500,x
    sta $0400 + 500,x
    inx
    cpx #250
    bne !loop-

    ldx #0
!loop:
    lda color_start + 750,x
    sta $d800 + 750,x
    lda color_matrix + 750,x
    sta $0400 + 750,x
    inx
    cpx #250
    bne !loop-

main:
    jsr $ff9f  //SCNKEY
    jsr $ffe4  //GETIN

    cmp #$31
    bne check_release
    loadImagecolor(fname_hwc,fname_hwc_end)
    loadImageMarix(fname_hwm,fname_hwm_end)
    loadImage(fname,fname_end)
check_release:
    cmp #$32
    bne check_shout
    loadImagecolor(fname_release_c,fname_release_c_end)
    loadImageMarix(fname_release_m,fname_relese_m_end)
    loadImage(fname_release,fname_release_end)
check_shout:
    cmp #$33
    bne check_main
    loadImagecolor(fname_shout_c,fname_shout_c_end)
    loadImageMarix(fname_shout_m,fname_shout_m_end)
    loadImage(fname_shout,fname_shout_end)
check_main:
    cmp #$34
    bne check_end
    loadImagecolor(fname_main_c,fname_main_c_end)
    loadImageMarix(fname_main_m,fname_main_m_end)
    loadImage(fname_main,fname_main_end)
check_end:
    cmp #$20
    jmp main
rts
error:
    sta $0400
rts

.macro loadImagecolor(namestart, nameend) {
lda #nameend-namestart
    ldx #<namestart
    ldy #>namestart
    jsr $ffbd
    lda #$01
    ldx $BA
    bne !skip+
    ldx #$08
!skip:
    ldy #$00
    jsr $ffba
    lda #$00
    ldx #<$d800+2
    ldy #>$d800+2
    jsr $ffd5
}

.macro loadImageMarix(namestart, nameend) {
lda #nameend-namestart
    ldx #<namestart
    ldy #>namestart
    jsr $ffbd
    lda #$01
    ldx $BA
    bne !skip+
    ldx #$08
!skip:
    ldy #$00
    jsr $ffba
    lda #$00
    ldx #<$0400+2
    ldy #>$0400+2
    jsr $ffd5
}

.macro loadImage(namestart, nameend) {
lda #nameend-namestart
    ldx #<namestart
    ldy #>namestart
    jsr $ffbd
    lda #$01
    ldx $BA
    bne !skip+
    ldx #$08
!skip:
    ldy #$00
    jsr $ffba
    lda #$00
    ldx #<$2000+2
    ldy #>$2000+2
    jsr $ffd5
}

fname:
    .text "HWEEK"
fname_end:
fname_hwc:
    .text "HWEEKC"
fname_hwc_end:
fname_hwm:
    .text "HWEEKM"
fname_hwm_end:

fname_release:
    .text "RELEASE"
fname_release_end:
fname_release_c:
    .text "RELEASEC"
fname_release_c_end:
fname_release_m:
    .text "RELEASEM"
fname_relese_m_end:

fname_shout:
    .text "SHOUT"
fname_shout_end:
fname_shout_c:
    .text "SHOUTC"
fname_shout_c_end:
fname_shout_m:
    .text "SHOUTM"
fname_shout_m_end:

fname_main:
    .text "MAIN"
fname_main_end:
fname_main_c:
    .text "MAINC"
fname_main_c_end:
fname_main_m:
    .text "MAINM"
fname_main_m_end:

color_start:
.byte $00,$05,$05,$05,$0b,$0f,$05,$07,$07,$07,$0b,$0b,$0b,$0b,$00,$0b

color_end:

*=$2000

color_matrix:
.byte $78,$78,$78,$af,$cf,$c5,$7f,$75,$78,$75,$85,$78,$78,$78,$2b,$c0



