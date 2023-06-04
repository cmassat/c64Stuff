#!/bin/bash
#rm *.d64
c1541 -format "hires, 01" d64 hires.d64
java  -jar /opt/KickAss/KickAss.jar  ./hiresMode.asm
c1541 -attach ./hires.d64 -write ./hiresMode.prg hires
x64sc -autoload hires.d64


