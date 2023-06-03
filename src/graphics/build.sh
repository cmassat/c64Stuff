#!/bin/bash
rm *.d64
c1541 -format "disl, 01" d64 disk.d64
java  -jar /opt/KickAss/KickAss.jar  ./main.asm
c1541 -attach ./disk.d64 -write ./main.prg main
c1541 -attach ./disk.d64 -write ./char.bin char.bin
x64sc -autoload disk.d64
