BasicUpstart2(start)
.var sid = $d400
.var sid_hf = sid + 1
.var sid_gate = sid + 4
.var sid_attack = sid + 5
.var sid_decay = sid + 6
.var sid_volume = sid + 24
 .var music = LoadSid("Knight_Rider_Theme.sid")
// *=$0ff6
// .import binary "Knight_Rider_Theme.sid"

*=$c000
start:
lda #music.startSong-1
jsr music.init
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

//lda #0
//jsr $0FF6
// lda #0
// ldx #0
// loop:
//     sta sid, x
//     inx 
//     cpx #24
//     bne loop

//     lda #5
//     sta sid_attack

//     lda #$ff
//     sta sid_decay

//     lda #$f
//     sta sid_volume

//     lda #$aa
//     sta sid_hf

//     lda #$fa
//     sta sid

//     lda #33
//     sta sid_gate

//     ldx #0
// !loop:
//     lda #33
//     sta sid_gate
//     lda music,x
//     sta sid_hf
//     sta sid

//     dec $d020
//     ldy #0
// wait:
//     iny
//     cpy #255
//     bne wait
//     inc $d020 
//     inx
//     cpx #13
//     bne !loop-
ldx #0
loop:
    cpx #1
    bne loop
    jmp loop
    
rts

//  music:
// .byte 134, 123, 213
// .byte 134, 123, 213
// .byte 134, 123, 213
// .byte 134, 123, 213, 0


irq:       
        asl $d019
        inc $d020
        jsr music.play 
        dec $d020
         jmp $EA31   
        // pla
        // tay
        // pla
        // tax
        // pla
        // rti       // jump into KERNAL's standard interrupt service routine to handle keyboard scan, cursor display etc.
//---------------------------------------------------------
        *=music.location "Music"
        .fill music.size, music.getData(i)

//----------------------------------------------------------
// Print the music info while assembling
.print ""
.print "SID Data"
.print "--------"
.print "location=$"+toHexString(music.location)
.print "init=$"+toHexString(music.init)
.print "play=$"+toHexString(music.play)
.print "songs="+music.songs
.print "startSong="+music.startSong
.print "size=$"+toHexString(music.size)
.print "name="+music.name
.print "author="+music.author
.print "copyright="+music.copyright

.print ""
.print "Additional tech data"
.print "--------------------"
.print "header="+music.header
.print "header version="+music.version
.print "flags="+toBinaryString(music.flags)
.print "speed="+toBinaryString(music.speed)
.print "startpage="+music.startpage
.print "pagelength="+music.pagelength