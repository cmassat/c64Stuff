#!/bin/bash
rm *prg
rm *sym
java  -jar /opt/KickAss/KickAss.jar  ./main.asm
x64sc -autoload main.prg