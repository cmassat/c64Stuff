
.var smem00 = $2000
.var smem01 = smem00 + 255
.var smem02 = smem01 + 255
.var smem03 = smem02 + 255
.var smem04 = smem03 + 255
.var smem05 = smem04 + 255
.var smem06 = smem05 + 255
.var smem07 = smem06 + 255
.var smem08 = smem07 + 255
.var smem09 = smem08 + 255
.var smem10 = smem09 + 255
.var smem11 = smem10 + 255
.var smem12 = smem11 + 255
.var smem13 = smem12 + 255
.var smem14 = smem13 + 255
.var smem15 = smem14 + 255
.var smem16 = smem15 + 255
.var smem17 = smem16 + 255
.var smem18 = smem17 + 255
.var smem19 = smem18 + 255
.var smem20 = smem19 + 255
.var smem21 = smem20 + 255
.var smem22 = smem21 + 255
.var smem23 = smem22 + 255
.var smem24 = smem23 + 255
.var smem25 = smem24 + 255
.var smem26 = smem25 + 255
.var smem27 = smem26 + 255
.var smem28 = smem27 + 255
.var smem29 = smem28 + 255
.var smem30 = smem29 + 255
.var smem31 = smem30 + 255
.var smem32 = smem31 + 255

    //set hires mode
    lda $d011
    ora #%00100000
    sta $d011
    // set $d018
    // set 1111xxxx * 1024/$0400 color information
    // set xxxx1xxx bitmap location 0 = 0 and  1 = 8192/$2000
    lda $d018
    ora #%00001000
    sta $d018

    //clear screen memory
    lda #0
    ldx #0
!loop:  sta smem00, x
        sta smem01, x
        sta smem02, x
        sta smem03, x
        sta smem04, x
        sta smem05, x
        sta smem06, x
        sta smem07, x
        sta smem08, x
        sta smem09, x
        sta smem10, x
        sta smem11, x
        sta smem12, x
        sta smem13, x
        sta smem14, x
        sta smem15, x
        sta smem16, x
        sta smem17, x
        sta smem18, x
        sta smem19, x
        sta smem20, x
        sta smem21, x
        sta smem22, x
        sta smem23, x
        sta smem24, x
        sta smem25, x
        sta smem26, x
        sta smem27, x
        sta smem28, x
        sta smem29, x
        sta smem30, x
        sta smem31, x
        sta smem32, x
        inx
        cpx #$ff
    bne !loop-

    // foreground black
    lda #$00
    ldx #0
!loop:
    sta $0400, x
    sta $04ff, x
    sta $05fd, x
    sta $06fc, x
    inx
    cpx #$ff
bne !loop-

    // background black
    lda #$00
    sta $d020