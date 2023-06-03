//BasicUpstart2(start)
* = $1000

start:
//dd02 set vic chip in out
//last two bits to 11 output
lda $dd02
ora #%00000011
lda $dd02

//dd00 vic bank mode last two bits
//11 => 0 to 3fff
//10 => 4000 to 7fff
//01 => 8000 to bfff
//00 => c000 to ffff
lda $dd00
and #%11111100
ora #%11111111
sta $dd00

//////////////////////////////////////////
// d018 SCREEN MEMORY 
// upper 4 bits screen memory location
// 0000 => 0
// 0001 => 0400 default
// 0010 => 0800
// 0011 => 0c00
// 0100 => 1000
///////////////////////////////////////////
lda $d018
and #%00001111
ora #%00010000
sta $d018

// d018 
// lower 4 character memory
// bits 3,2,1 control character memory
// 000 => 0000 - 07ff
// 001 => 0800 - 0fff
// 010 => 1000 - 17ff
// 011 => 1800 - 1fff
// 100 => 2000 - 27ff
// 101 => 2800 - 2fff
// 110 => 3000 - 37ff
// 111 => 3800 - 3fff
lda $d018
and #%11110000
ora #%00001100
sta $d018


//lda #28
//sta $d018
// multi color mode
// set bit 4 to 1
// default mode set to 0
lda $d016
and #%11101111
ora #%00000000
sta $d016

// d011
// set bit 6 to 1 extended color mode
// set bit 5 to 1 standard high resolution bitmap mode 
lda $d011
and #%10111111
ora #%01000000
sta $d011

ldx #0
!loop:
    lda char_data, x
    sta $0800, x
    inx
    cpx #$ff
 bne !loop-


//clear screen
ldx #0
lda #32
!loop:
    sta $0400, x
    sta $0400 + 255, x
    sta $0400 + 255 + 255, x
    sta $0400 + 255 + 255 + 255, x
    inx
    cpx #$ff
    bne !loop- 
    // //color memory
    // lda $d800
    // and #%11111000
    // ora #$04
    // sta $d800

    //border 0 = black
    lda #0
    sta $d020

    //background 1 = white
    // 00
    lda #1
    sta $d021

    //background 2
    // 01
    lda #2
    sta $d022

    // background 3
    // 10
    lda #3
    sta $d023

    // background 4
    // d11
    lda #4
    sta $d024

    lda #1
    sta $0400
!loop:
    nop
jmp !loop-

rts

#import  "charset_mc.asm"

// basic sstart
//$30 = 0
//$31 = 1


*=$0801
    .byte $0c,$08,$0a,$00,$9e,$34,$30,$39,$36,$00,$00,$00

