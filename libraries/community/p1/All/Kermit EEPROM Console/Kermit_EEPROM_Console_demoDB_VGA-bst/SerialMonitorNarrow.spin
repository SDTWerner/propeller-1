{{

┌──────────────────────────────────────────────────────────────────────┐
│ to see how full rx        buffer  of full duplex serial is  getting  │
| this version expects head and tail indicies to be words, not longs   │
| hard coded for 128 byte receive buffer                               │
│ Author: Eric Ratliff                                                 │
│ Copyright (c) 2008, 2009 Eric Ratliff                                │
│ See end of file for terms of use.                                    │
└──────────────────────────────────────────────────────────────────────┘

Kermit EEPROM SerialMonitorNarrow.spin,
2008.11.27 by Eric Ratliff, to see how full rx and tx buffers of full duplex serial are getting
2009.5.31 Eric Ratliff, modified for word indicies instead of long indicies
}}

CON
  RX_BUF_SIZEp2 = 7                                     ' base 2 log of the size of the receive buffer
  RX_BUF_SIZE = 1 << RX_BUF_SIZEp2                      ' size of the receive buffer
  RX_BUF_REMAINDER_MASK = RX_BUF_SIZE - 1
VAR
  long  prx_head                ' pointers to indicies of where we are in the receive buffer
  long  prx_tail
  long  pCurrentRxUnused        ' most recent receive buffer status
  long  pMinRxUnused            ' worst receive buffer status
  'long  pHeadValue
  'long  pTailValue
  'long  BufferContents
  'long  pBufferContents
  long RxHeadTailCombo
  long SerialMonitorStackLocal[30]
  'long SerialMonitorStackLocal[100]

PUB CogRun(pIndiciesAddress, pReportAddress):CogNumber
  CogNumber := cognew(run(pIndiciesAddress,pReportAddress),@SerialMonitorStackLocal) ' start the serial monitor in its own cog

PRI run(pIndiciesAddress, pReportAddress)
'' continuously monitor remaining space in buffer, post results: current, minimum

  ' input addresses
  prx_head := pIndiciesAddress
  prx_tail := pIndiciesAddress + 2 ' now add just 2, added 4 when indicies were longs

  ' output addresses
  'pHeadValue := pReportAddress
  'pTailValue := pReportAddress + 4
  'pBufferContents := pReportAddress + 8
  pCurrentRxUnused := pReportAddress + 12
  pMinRxUnused := pReportAddress + 16

  ' starting min value
  LONG[pMinRxUnused] := RX_BUF_SIZE
  
  repeat
{
    ' verbose debugging version
    LONG[pHeadValue] := LONG[prx_head]
    LONG[pTailValue] := LONG[prx_tail]
    LONG[pBufferContents] := (LONG[pHeadValue] - LONG[pTailValue]) & RX_BUF_REMAINDER_MASK ' subtract and do remainder for wrap
    LONG[pCurrentRxUnused] := RX_BUF_SIZE - LONG[pBufferContents]               ' subtract what's used to find what's not used
    LONG[pMinRxUnused] := LONG[pMinRxUnused] <# LONG[pCurrentRxUnused]          ' pick lowest of two numbers
}

    ' fast version
    'LONG[pHeadValue] := LONG[prx_head]
    'LONG[pTailValue] := LONG[prx_tail]
    'LONG[pBufferContents] := (LONG[prx_head] - LONG[prx_tail]) & RX_BUF_REMAINDER_MASK ' subtract and do remainder for wrap
    RxHeadTailCombo := LONG[prx_head]  ' read both head and tail indicies simultaneously

    ' hub memory is little endian
    ' second "WORD" is supposed to get head index, first "WORD" is supposed to get tail index
    LONG[pCurrentRxUnused] := RX_BUF_SIZE - ((WORD[@RxHeadTailCombo] - WORD[@RxHeadTailCombo+2]) & RX_BUF_REMAINDER_MASK) ' subtract what's used to find what's not used
    LONG[pMinRxUnused] := LONG[pMinRxUnused] <# LONG[pCurrentRxUnused]          ' pick lowest of two numbers

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