{{
***************************************
*  Name: 3Dfix Color                  *
*  Author: Thomas P. Sullivan/W1AUV   *
*  Copyright (c) 2008 TPS             *
*  See end of file for terms of use.  *
***************************************

 -----------------REVISION HISTORY-----------------
 v1.00 - Original Version
 v1.03 - First preliminary release
 v1.04 - Release

}}

CON
  _CLKMODE      = XTAL1 + PLL8X                        
  _XINFREQ      = 8_000_000

  dSlow         = 50
  dFast         = 20
  GPS_RX        = 31
  GPS_TX        = 30
  GPS_BAUD      = 4800

  MAX_NMEA      = 128

  'Line definitions
  LN_3D  = 0
  LN_MHD = 1
  LN_UTC = 2
  LN_LAT = 3
  LN_LON = 4
  LN_SPD = 5
  LN_DIR = 6
  LN_DAT = 7

  'Field Start
  FD_START = 0

OBJ
  OLED  : "uOLED-96-Prop_V4"
  DELAY : "Clock"
  NMEA  : "FullDuplexSerial"
  MH    : "Maidenhead_1_08"

VAR
  byte  rxchar
  byte  nmeastr[MAX_NMEA]
  byte  tempstr[32]
  byte  tempstr2[32]
  byte  tempstr3[32]
  byte  erase[32]
  byte  mhstr[10]
  byte  tt
  long  index

PUB Demo

'Initialize the serial port for GPS NMEA input
  NMEA.start(GPS_RX, GPS_TX, %0000, GPS_BAUD)
' The timer initialization
  DELAY.Init(8_000_000)
' Initialize the oLED display
  OLED.InitOLED
' Clear the display to start
  OLED.CLS

  bytemove(@erase,string(127,127,127,127,127,127,127,127,127,127,127,127,127,127,127),strsize(string(127,127,127,127,127,127,127,127,127,127,127,127,127,127,127)))

  Splash
' Clear the display
  OLED.CLS

  REPEAT
    'It may be needed to flush the rx buffer so we don't get behind 
    NMEA.rxflush
    'Sync to the beginning of the next NMEA sentence
    REPEAT
      tt := NMEA.rx
    WHILE(tt<>"$")

    'Should be $
    nmeastr[0] := tt
    index := 1
 
    'Get the rest of the string
    REPEAT
      tt := NMEA.rx
      nmeastr[index] := tt
      index := index + 1
    WHILE((tt<>13)AND(index<(MAX_NMEA-1)))

'   Uncomment the three lines below to echo the string
'   back out the serial port (just for debugging)
    'NMEA.str(@nmeastr)
    'NMEA.tx(13)
    'NMEA.tx(10)

    if(tt==13)
      nmeastr[index-1] := 0     'Add a NULL to the end of the received string
      if(MH.NMEACS(@nmeastr)>0) 'When checking the checksum
    'if(TRUE)                  'When NOT checking the checksum
        wordmove(@tempstr3,@nmeastr,6)
        tempstr3[6] := 0        'Add a NULL to ther end of the string
        if(strcomp(@tempstr3,string("$GPRMC")))
          '
          'Compute and display Maidenhead 
          '
          MH.NMEA2MH(@nmeastr,@mhstr)  
          oled.PutText (FD_START,LN_MHD,0, 000,000,000, @erase)
          oled.PutText (FD_START,LN_MHD,0, 255,000,000, @mhstr)

          'Extract and format time 123456 becomes 12:34:56 UTC (with a NULL on the end) 
          ' 0 0 0 0 0 0 0 0 0 
          ' 0 1 2 3 4 5 6 7 8 
          '+-+-+-+-+-+-+-+-+-+
          '|1|2|3|4|5|6| | | |
          '+-+-+-+-+-+-+-+-+-+
          '|1|2|:|3|4|:|5|6| |
          '+-+-+-+-+-+-+-+-+-+
          bytefill(@tempstr,0,32)
          tt := ExtractRMC(1,@nmeastr,@tempstr)
          if(tt)
            tempstr[7] := tempstr[5] 
            tempstr[6] := tempstr[4] 
            tempstr[4] := tempstr[3] 
            tempstr[3] := tempstr[2] 
            tempstr[5] := ":" 
            tempstr[2] := ":" 
            tempstr[8] := 0 

            oled.PutText (FD_START,LN_UTC,0, 000,000,000, @erase)
            oled.PutText (FD_START,LN_UTC,0, 000,255,255, @tempstr)

          '***************************
          'Extract and format Latitude 
          '***************************
          ' 0 0 0 0 0 0 0 0 0 0
          ' 0 1 2 3 4 5 6 7 8 9
          '+-+-+-+-+-+-+-+-+-+-+
          '|4|2|2|1|.|5|8|3|5| |
          '+-+-+-+-+-+-+-+-+-+-+-+-+
          '|4|2| |2|1|.|5|8|3|5| |N|
          '+-+-+-+-+-+-+-+-+-+-+-+-+
          bytefill(@tempstr,0,32)
          tt := ExtractRMC(3,@nmeastr,@tempstr)
          if(tt)
            tempstr[9] := tempstr[8] 
            tempstr[8] := tempstr[7] 
            tempstr[7] := tempstr[6] 
            tempstr[6] := tempstr[5] 
            tempstr[5] := tempstr[4] 
            tempstr[4] := tempstr[3] 
            tempstr[3] := tempstr[2] 
            tempstr[2] := " "

            tt := ExtractRMC(4,@nmeastr,@tempstr2)
            tempstr[10] := " " 
            tempstr[11] := tempstr2[0] 
            tempstr[12] := 0 

            oled.PutText (FD_START+1,LN_LAT,0, 000,000,000, @erase)
            oled.PutText (FD_START+1,LN_LAT,0, 255,255,000, @tempstr)

          '****************************
          'Extract and format Longitude 
          '****************************
          ' 0 0 0 0 0 0 0 0 0 0
          ' 0 1 2 3 4 5 6 7 8 9
          '+-+-+-+-+-+-+-+-+-+-+
          '|0|7|3|1|7|.|0|3|4|2|
          '+-+-+-+-+-+-+-+-+-+-+-+-+-+
          '|0|7|3| |1|7|.|0|3|4|2| |W|
          '+-+-+-+-+-+-+-+-+-+-+-+-+-+
          bytefill(@tempstr,0,32)
          tt := ExtractRMC(5,@nmeastr,@tempstr)
          if(tt)
            tempstr[10] := tempstr[9] 
            tempstr[9] := tempstr[8] 
            tempstr[8] := tempstr[7] 
            tempstr[7] := tempstr[6] 
            tempstr[6] := tempstr[5] 
            tempstr[5] := tempstr[4] 
            tempstr[4] := tempstr[3] 
            tempstr[3] := " "

            tt := ExtractRMC(6,@nmeastr,@tempstr2)
            tempstr[11] := " " 
            tempstr[12] := tempstr2[0] 
            tempstr[13] := 0 

            oled.PutText (FD_START,LN_LON,0, 000,000,000, @erase)
            oled.PutText (FD_START,LN_LON,0, 255,000,255, @tempstr)

          '*********************
          'Extract speed (knots) 
          '*********************
          ' 0 0 0 0 0 0 0 0 0 
          ' 0 1 2 3 4 5 6 7 8 
          '+-+-+-+-+-+-+-+-+-+
          '|4|4|.|1|3|6| | | |
          '+-+-+-+-+-+-+-+-+-+
          bytefill(@tempstr,0,32)
          tt := ExtractRMC(7,@nmeastr,@tempstr)
          if(tt)
            oled.PutText (FD_START,LN_SPD,0, 000,000,000, @erase)
            oled.PutText (FD_START,LN_SPD,0, 000,255,000, @tempstr)

          '*******************************
          'Extract track or bearing (true) 
          '*******************************
          ' 0 0 0 0 0 0 0 0 0 
          ' 0 1 2 3 4 5 6 7 8 
          '+-+-+-+-+-+-+-+-+-+
          '|3|5|2|.|4| | | | |
          '+-+-+-+-+-+-+-+-+-+
          bytefill(@tempstr,0,32)
          tt := ExtractRMC(8,@nmeastr,@tempstr)
          if(tt)
            oled.PutText (FD_START,LN_DIR,0, 000,000,000, @erase)
            oled.PutText (FD_START,LN_DIR,0, 000,000,255, @tempstr)

          '***********************
          'Extract and format date 
          '***********************
          ' 0 0 0 0 0 0 0 0 0 
          ' 0 1 2 3 4 5 6 7 8 
          '+-+-+-+-+-+-+-+-+-+
          '|1|1|0|3|0|7| | | |
          '+-+-+-+-+-+-+-+-+-+
          '|1|1|/|0|3|/|0|7| |
          '+-+-+-+-+-+-+-+-+-+
          bytefill(@tempstr,0,32)
          tt := ExtractRMC(9,@nmeastr,@tempstr)
          if(tt)
            tempstr[7] := tempstr[5] 
            tempstr[6] := tempstr[4] 
            tempstr[4] := tempstr[3] 
            tempstr[3] := tempstr[2] 
            tempstr[5] := "/" 
            tempstr[2] := "/" 
            tempstr[8] := 0 

            oled.PutText (FD_START,LN_DAT,0, 000,000,000, @erase)
            oled.PutText (FD_START,LN_DAT,0, 127,127,127, @tempstr)

        '*****************************
        'Determine if we have a 3D fix
        '*****************************
        elseif(strcomp(@tempstr3,string("$GPGSA")))
          bytefill(@tempstr,0,32)
          tt := ExtractRMC(2,@nmeastr,@tempstr)
          if(tt)
            oled.PutText (FD_START,LN_3D,0,000,000,000, @erase)
            CASE tempstr[0]
              $32:
                oled.PutText (FD_START,LN_3D,0,063,000,127, string("2D Position Fix"))
              $33:
                oled.PutText (FD_START,LN_3D,0,063,000,127, string("3D Position Fix"))
              OTHER:
                oled.PutText (FD_START,LN_3D,0,063,000,127, string("No Fix Yet!"))
        else    
          bytefill(@nmeastr,0,MAX_NMEA)
          'Not a string we handle
      else
        'Invalid Checksum!
      
PUB ExtractRMC(field, str, dstr):found | ii, jj, len, cfield 
' Extract GPRMC data
{{
$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A

Where:
     RMC          Recommended Minimum sentence C
     123519       Fix taken at 12:35:19 UTC
     A            Status A=active or V=Void.
     4807.038,N   Latitude 48 deg 07.038' N
     01131.000,E  Longitude 11 deg 31.000' E
     022.4        Speed over the ground in knots
     084.4        Track angle in degrees True
     230394       Date - 23rd of March 1994
     003.1,W      Magnetic Variation
     *6A          The checksum data, always begins with * (so they say)
}}
  len := strsize(str)

' Count the number of commas (fields)    
  ii := 0
  cfield := 0
  repeat while((field<>cfield)AND(ii<len))
    if(byte[str][ii]==",")
      cfield++
    ii++

  if(ii=<len) 'Make sure we didn't search the whole string in vain
    jj := 0
    if(field==cfield) 'We found the field we want
      repeat
        byte[dstr][jj] := byte[str][ii]
        ii++
        jj++
      while((byte[str][ii]<>",")AND(byte[str][ii]<>0))
      byte[dstr][jj] := 0  'Add a NULL
      found := TRUE      
    else
      found := FALSE
  else
      found := FALSE
       
PUB Splash
' Startup banner
  oled.PutText (0,0,0, 255,255,000, string("***************"))
  oled.PutText (0,1,0, 255,000,255, string("*             *"))
  oled.PutText (0,2,0, 000,255,255, string("*    3Dfix    *"))
  oled.PutText (0,3,0, 255,000,000, string("*    COLOR    *"))
  oled.PutText (0,4,0, 000,255,000, string("*     by      *"))
  oled.PutText (0,5,0, 000,000,255, string("*    W1AUV    *"))
  oled.PutText (0,6,0, 127,127,127, string("*             *"))
  oled.PutText (0,7,0, 063,000,127, string("***************"))

  delay.PauseSec(5)

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
  