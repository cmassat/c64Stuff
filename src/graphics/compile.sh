#!/bin/bash
rm *prg
java  -jar /opt/KickAss/KickAss.jar  ./main.asm
x64sc -autoload main.prg