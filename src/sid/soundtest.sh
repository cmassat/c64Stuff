#!/bin/bash
rm *.d64
c1541 -format "disk, 01" d64 disk.d64
java  -jar /opt/KickAss/KickAss.jar  ./soundtest.asm
c1541 -attach ./disk.d64 -write ./soundtest.prg soundtest
x64sc -autoload disk.d64