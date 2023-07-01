*=$4000 "Sid Program"
#import "sid_notes.asm"
BasicUpstart2(start)
start:
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


// guitar
.const sid_guitar_ad = $0503
.const sid_guitar_sr = $0f0a
.const sid_guitar_duty = 1536
.const sid_guitar_wf = 00100000//1

lda #0
ldx #0
!loop:

    // clear sid
    sta sid_chip,x
    inx
    cpx sid_chip_end
    bne !loop-
    //set volume
    lda #00000111
    sta sid_v1_volume

    // set voice 1
    lda #sid_guitar_ad
    sta sid_v1_ad
    lda #sid_guitar_sr
    sta sid_v1_sr

    lda #<sid_guitar_duty
    sta sid_v1_duty_lo
    lda #>sid_guitar_duty
    sta sid_v1_duty_hi

    //set note
    lda #<C_4
    sta sid_v1_lo
    lda #>C_4
    sta sid_v1_hi

    //play note
    lda #00100000
    sta sid_v1_control

    lda #10100001
    sta sid_v1_control

    lda #10100001
    sta sid_v1_control
    rts