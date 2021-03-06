{{

┌──────────────────────────────────────────┐
│ <object name and version>                │
│ Author: Thomas E. McInnes                │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

<object details, schematics, etc.>

}}
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  kdata = 26
  kclock = 27

  mdata = 24
  mclock = 25

  vgapin = 16

  tvpin = 12

  laudio = 11
  raudio = 10 

VAR

  Long stack[128]

OBJ

  k     :       "Keyboard"
  m     :       "Mouse"
  v     :       "VGA_Text"
  t     :       "TV_Terminal"
  s     :       "Synth"

PUB start_up

  k.start(kdata, kclock)
  m.start(mdata, mclock)
  v.start(vgapin)
  t.start(tvpin)
  cognew(program_code, @stack)

PUB program_code



DAT
     {<end of object code>}
     
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