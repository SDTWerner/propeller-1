{{
┌───────────────────────────────────────────────────┐
│ BBTestsADC1543.spin version 1.0.0                 │
├───────────────────────────────────────────────────┤
│                                                   │               
│ Author: Mark M. Owen                              │
│                                                   │                 
│ Copyright (C)2013 Mark M. Owen                    │               
│ MIT License - see end of file for terms of use.   │                
└───────────────────────────────────────────────────┘


General description


  simple tests for verification of ADC driver code
  uses QuickStart card and Parallax Serial Terminal


Revision History


}}

CON
  _CLKMODE = XTAL1 + PLL16X     ' System clock → 80 MHz
  _XINFREQ = 5_000_000          ' external crystal 5MHz (XTAL1)

  IOCpin        = 13            ' output i/o clock
  ADRpin        = 15            ' output multiplexer address MSB first
  DATpin        = 17            ' input data bits MSB first
  CSpin         = 19            ' output chip select, active low

  FIRSTCHANNEL  = 0
  LASTCHANNEL   = 13

VAR
  word  d[LASTCHANNEL+1] ' channel data

DAT
      
OBJ
  ADC   : "TLC1543ADC"
  PST   : "Parallax Serial Terminal"
  
PUB Main  | i,n, cycles

  PST.Start(115200)

  ADC.Start(IOCpin, CSpin, ADRpin, DATpin, FIRSTCHANNEL, LASTCHANNEL)

  repeat
    PST.Home                    ' output starts at the top, left
    PST.Clear
    
    ' retrieve the current data for all channels
    ADC.GetChannels(@d)         ' data channels   1-11
    d[11]:=ADC.Get($B)          ' self test channel 12
    d[12]:=ADC.Get($C)          '                   13
    d[13]:=ADC.Get($D)          '                   14
    
    ' examine all channel values, one at a time
    repeat i from FIRSTCHANNEL to LASTCHANNEL       
      PST.ClearEnd              ' erase prior output
      PST.Dec(d[i])             ' show the raw value returned
      PST.PositionX(6)          ' align the next text column             
      PST.Hex(d[i],4)           ' show the raw value in hex
      PST.PositionX(15)         ' align the next text column
      PST.Char("[")             
      PST.Hex(i,1)              ' show the channel index
      PST.Char("]")
      n := Decimalize(d[i],5)   ' scale the channel value to 5 volts, fixed point (16/16)
      PST.Dec(n>>16)            ' show the integer part
      PST.Char(".")             ' decimal point
      'PST.Dec drops leading zeros, so deal with
      'it by scaling out one digit at a time
      n &= $0000FFFF             ' dispose of the integer part
      PST.Dec(n/100)             ' show tenths
      n //= 100                  ' remainder
      PST.Dec(n/10)              ' show hundredths
      PST.Str(string("V"))       ' volts
      PST.Newline
    waitcnt(clkfreq / 10 + cnt)  ' 100mS delay - not really needed

 PST.Stop
 ADC.Stop
       
PRI Decimalize(V,S) | Vi, Vf, S0, S1
  Vi := (S * V) /   1023 ' integer portion
  S0 := (S * V) //  1023 ' remainder
  Vf := (S0 / 102) * 100 ' tenths as integer
  S0 := S0 // 102        ' remainder
  S1 := (S0 / 10) * 10   ' 100ths as integer
  Vf := S1 + Vf
  S0 := S0 // 10
  Vf := S0 + Vf
  result := Vi<<16 | Vf  ' return a 16/16 fixed point value

DAT
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