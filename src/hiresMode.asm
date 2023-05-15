BasicUpstart2(start)

* = $1000
start:
    // Import the file "mylibrary.asm"
    #import "InitHiresScreen.asm"

    lda #%10101010
    sta $2000
    lda #%10101010
    sta $2001
    lda #%10101010
    sta $2002
    lda #%10101010
    sta $2003
    lda #%10101010
    sta $2004
    lda #%10101010
    sta $2005
    lda #%10101010
    sta $2006
    lda #%10101010
    sta $2007
    lda #%10101010
    sta $2008
rts