{{

┌──────────────────────────────────────────┐
│ Demo program for MonVarsVGA 1.4          │
│ Author: Eric Ratliff                     │               
│ Copyright (c) 2008 Eric Ratliff          │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

MonVarsVGA_demo, to test operation of variable monitoring object 'MonVarsVGA', hex start option
by Eric Ratliff 2008.12.26

}}

CON _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  IncStep = 40
  ARRAY_SIZE=30

OBJ
  Monitor :     "MonVarsVGA"

VAR
  long MonArray[ARRAY_SIZE]
  long SampleVariable
  long SpacerLong[100]
  long Stack1[100]     ' space for new cog, no idea how much to allocate

PUB go
''test main

  ' start showing signed long ints on the VGA monitor in Hex format
  MonArray[0] := -2_000_000_000
  MonArray[1] := 10
  MonArray[2] := -15
  MonArray[3] := -25
  MonArray[4] := -2111111111
  MonArray[5] := 2111111111
  MonArray[6] := 32767
  MonArray[7] := -32768
  MonArray[8] := 2_000_000_000
  ' start cog to show that numbers are being updated live
  cognew(FastUptick,@Stack1)
  
  repeat
    ' show numbers as unsigned hex with bytes separated by underscores
    ' entire array and following long variable
    Monitor.UHexStart(Monitor#DevBoardVGABasePin,@MonArray[0],ARRAY_SIZE+1)
    pause(5)
    Monitor.Stop
    pause(1)

    ' show numbers as signed hex
    ' entire array and following long variable
    Monitor.SHexStart(Monitor#DevBoardVGABasePin,@MonArray[0],ARRAY_SIZE+1)
    pause(5)
    Monitor.Stop
    pause(1)

    ' show numbers as signed decimals with groups of three digits separated by underscores
    ' entire array and following long variable
    Monitor.Start(Monitor#DevBoardVGABasePin,@MonArray[0],ARRAY_SIZE+1)
    pause(5)
    Monitor.Stop
    pause(1)

PRI pause(Seconds)
  waitcnt((clkfreq*Seconds)+cnt)

PRI FastUptick|CountAtStart
' constantly update a particular variable, to simulate purpose of MonVarVGA, showing variable values for program debugging
' note that long variables are assigned different place in hub than byte variables, so be careful what you expect to be sequential
' interesting that last digit stays fixed, BUT! is not same digit with each program start, something is not deterministic
  CountAtStart := cnt
  repeat
    SampleVariable := cnt - CountAtStart

  {{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}