rm *.d64
c1541.exe -format "hires, 01" d64 .\hires.d64
java  -jar ..\..\KickAssembler\KickAss.jar  .\hiresMode.asm
c1541.exe -attach .\hires.d64 -write .\hiresMode.prg hires
x64sc.exe -autoload hires.d64


