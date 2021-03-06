{{
    NewHaven Serial LCD Object
    Version 1.0
    Copyright (c) 2010, Ron Czapala                             
    See end of file for terms of use.
      
    Modeled after Parallax Serial LCD Driver     
    Authors: Jon Williams, Jeff Martin           
                                                 
    DEC and HEX methods from:                    
    Full-Duplex Serial Driver v1.2               
    Author: Chip Gracey, Jeff Martin             

    Update History:
      v1.0 - 10/13/2010 - Original release
                                                 
   Questions? Please post on the Propeller forum 
         http://forums.parallax.com/forums/      
                
  This object drives the NewHaven line of serial LCDs 
  These displays may have 2 or 4 lines and 16 or 20 columns -
  the init method specifies the number of lines and columns 
}}  

CON

  LCD_CMD         = $FE         'command prefix
  LCD_CLS         = $51         'Clear entire LCD screen
  LCD_ON          = $41         'Display ON
  LCD_OFF         = $42         'Display off
  LCD_NOCURS      = $0C         'Make cursor invisible
  LCD_ULCURS_ON   = $47         'Underline cursor on
  LCD_ULCURS_OFF  = $48         'Underline cursor off
  LCD_BLKCURS_ON  = $4B         'Blinking block cursor on
  LCD_BLKCURS_OFF = $4C         'Blinking block cursor off
  LCD_CURPOS      = $45         'set cursor  + position  
  LCD_CURHOME     = $46         'move cursor to top line, first column                        
  LCD_SCRLEFT     = $55         'scroll left
  LCD_SCRRIGHT    = $56         'scroll right
  LCD_LEFT        = $49         'Move cursor left
  LCD_RIGHT       = $4A         'Move cursor right 
  LCD_BKSPC       = $4E         'Destructive backspace
  LCD_CONTRAST    = $52         '1 byte  1 to 50  Default 40   
  LCD_BACKLIGHT   = $53         '1 byte  1 to 8   Default 1   (not used on RGB displays)
  LCD_CUSTCHAR    = $54         '9 bytes  0 to 7  (custom character address + 8 bytes Custom character pattern bit map)
  LCD_SETBAUD     = $61         '1 byte 1=300 2=1200 3=2400 4=9600 5=14400 6=19.2K 7=57.6K 8=115.2K
  LCD_SET_I2C     = $62         '1 byte New I2C address, 0x00 - 0xFE  The LSB is always '0'
  LCD_VERSION     = $70         'display firmware version
  LCD_SHOWBAUD    = $71         'display baud rate
  LCD_SHOW_I2C    = $72         'display I2C address       
    
'Cursor position values
'             for 16 character                  for 20 character
'line1           0 to 15                           0 to 19  
'line2          64 to 79                          64 to 83      
'line3                                            20 to 39  
'line4                                            84 to 103

VAR

  long lineidx, colidx, started
  byte ix, lpos[4]                             'array of LCD line start positions

OBJ

  serial : "simple_serial"                              ' bit-bang serial driver

  
PUB init(pin, baud, lines, columns): okay

'' Qualifies pin, baud, # lines, # columns input
'' -- makes tx pin an output and sets up other values if valid

  started~                                                    ' clear started flag
  if lookdown(pin : 0..27)                                    ' qualify tx pin 
    if lookdown(baud : 300, 1200, 2400, 9600, 14400, 19200, 57600, 115200) ' qualify baud rate setting
      if lookdown(lines : 2, 4)                               ' qualify lcd rows (lines)
        if lookdown(columns : 16, 20)                         ' qualify lcd columns
          if serial.init(-1, pin, baud)                       ' tx pin only, true mode
            lineidx := lines - 1                              ' save lines size
            colidx := columns - 1                             ' save columns size
            repeat ix from 0 to 3                             ' load lpos (line addresses)
              lpos[ix] := disp[ix]
            started~~                                         ' mark started flag true
  return started

PUB finalize
'' Finalizes serial object, disable LCD object

  if started
    serial.finalize
    started~                                            ' set to false

PUB putc(txByte) 
'' Transmit a byte

  serial.tx(txByte)

PUB str(strAddr)
'' Transmit z-string at strAddr

  serial.str(strAddr)

PUB dec(value) | i, x
'' Print a decimal number

  x := value == NEGX                                                            'Check for max negative
  if value < 0
    value := ||(value+x)                                                        'If negative, make positive; adjust for max negative
    serial.tx("-")                                                              'and output sign
                                                                     
  i := 1_000_000_000                                                            'Initialize divisor

  repeat 10                                                                     'Loop for 10 digits
    if value => i                                                               
      serial.tx(value / i + "0" + x*(i == 1))                                   'If non-zero digit, output digit; adjust for max negative
      value //= i                                                               'and digit from value
      result~~                                                                  'flag non-zero found
    elseif result or i == 1
      serial.tx("0")                                                            'If zero digit (or only digit) output it
    i /= 10                                                                     'Update divisor

PUB hex(value, digits)
'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    serial.tx(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    serial.tx((value <-= 1) & 1 + "0")    
    
PUB cls
'' Clears LCD and moves cursor to home (0, 0) position

  if started
    putc(LCD_CMD)
    putc(LCD_CLS)
    waitcnt(clkfreq / 200 + cnt)                        ' 5 ms delay 

PUB home
'' Moves cursor to 0, 0

  if started
    putc(LCD_CMD)
    putc(LCD_CURHOME)

PUB gotoxy(col, line)         
'' Moves cursor to col/line

  if started
    if lookdown(line : 0..lineidx)                     ' qualify line input
      if lookdown(col : 0..colidx)                     ' qualify column input
        Posit(col, line)

PRI Posit(col, line)
  putc(LCD_CMD)
  putc(LCD_CURPOS)
  putc(lpos[line] + col) ' move to target position

PUB clrln(line)
'' Clears line

  if started
    if lookdown(line : 0..lineidx)                       ' qualify line input
      Posit(0, line)
      repeat colidx + 1
        putc(32)                                          ' clear line with spaces
      Posit(0, line)

PUB cursor(cval)
   if started
     if cval == LCD_NOCURS
       putc(LCD_CMD)
       putc(LCD_NOCURS)
     else  
       if lookdown(cval: $47..$4C)
         putc(LCD_CMD)
         putc(cval)         
         waitcnt(clkfreq / 200 + cnt)                      ' 5 ms delay 

PUB scrollLeft
'' Scrolls display left
  if started
    putc(LCD_CMD)
    putc(LCD_SCRLEFT) 

PUB scrollRight
'' Scrolls display right
  if started
    putc(LCD_CMD)
    putc(LCD_SCRRight) 

PUB cursorLeft
'' Moves cursor left
  if started
    putc(LCD_CMD)
    putc(LCD_LEFT) 

PUB cursorRight
'' Moves cursor right
  if started
    putc(LCD_CMD)
    putc(LCD_Right) 

PUB displayOff
'' Turns display off
  if started
    putc(LCD_CMD)
    putc(LCD_OFF) 

PUB displayOn
'' Turns display on
  if started
    putc(LCD_CMD)
    putc(LCD_ON) 

PUB contrast(cval)
'' Sets contrast level: 1 to 50 
  if started
     if lookdown(cval: 1..50)
       putc(LCD_CMD)
       putc(LCD_CONTRAST)
       putc(cval) 

PUB backLight(brightness)
'' Sets backlight brightness: 1 to 8 
  if started
     if lookdown(brightness: 1..8)
       putc(LCD_CMD)
       putc(LCD_BACKLIGHT)
       putc(brightness) 

DAT
  disp        byte   0, 64, 20, 84   'line pos for 16 and 20 column displays

'Cursor position values
'             for 16 character                  for 20 character
'line1           0 to 15                           0 to 19  
'line2          64 to 79                          64 to 83      
'line3                                            20 to 39  
'line4                                            84 to 103  

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