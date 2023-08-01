#!/bin/bash
rm *.d64
c1541 -format "disl, 01" d64 disk.d64
java  -jar /opt/KickAss/KickAss.jar  ./main.asm -debug
c1541 -attach ./disk.d64 -write ./main.prg main
x128 -autoload disk.d64