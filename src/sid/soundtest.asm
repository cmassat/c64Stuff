*=4000
BasicUpstart2(start)
.const note = 4291
.const duty = 1536
start:
    // frequency
    lda #<note
    sta $d400
    lda #>note
    sta $d401

    // pulse wave dudy cycle
    lda #<duty
    sta $d402
    lda #>duty
    sta $d403
    
    //atack and delay
    lda $00
    sta $d405

    // sustain release
    lda #$f0
    sta $d406

    //volume
    lda #$6f
    sta $d418

    // controle register and gate
    lda #%00100001
    sta $d404


    ldx #0
!delay:
    ldy #0
!inner:
    iny
    cpy #255
    bne !inner-
    inx 
    cpx #10
    bne !delay-

    ldx #0
!delay:
    ldy #0
!inner:
    iny
    cpy #255
    bne !inner-
    inx 
    cpx #100
    bne !delay-

// controle register and gate
    lda #%00000000
    sta $d404



rts
