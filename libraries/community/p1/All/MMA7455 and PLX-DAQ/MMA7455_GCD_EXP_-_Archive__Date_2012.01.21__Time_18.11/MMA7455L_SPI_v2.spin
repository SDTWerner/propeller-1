{{
***************************************
* MMA7455L_SPI_v2.spin         Ver 2  *
* Author: Kevin McCullough            *
* Author: Beau Schwabe                *
* Copyright (c) 2009 Parallax         *
* See end of file for terms of use.   *
***************************************

   History:
        Version 1 - (03-25-2009) initial concept
        Version 2 - (06-10-2009) wrapped default constants inside core module


   Description:
        This program is a basic SPI driver specifically designed to operate with 
        the MMA7455L device for the Digital 3-Axis Accelerometer module.         
        
}}

CON

  XOUTL         = $00           ' 10 bits output value X LSB             XOUT[7]  XOUT[6]  XOUT[5]  XOUT[4]  XOUT[3]  XOUT[2]  XOUT[1]  XOUT[0]
  XOUTH         = $01           ' 10 bits output value X MSB             --       --       --       --       --       --       XOUT[9]  XOUT[8]
  YOUTL         = $02           ' 10 bits output value Y LSB             YOUT[7]  YOUT[6]  YOUT[5]  YOUT[4]  YOUT[3]  YOUT[2]  YOUT[1]  YOUT[0]
  YOUTH         = $03           ' 10 bits output value Y MSB             --       --       --       --       --       --       YOUT[9]  YOUT[8]
  ZOUTL         = $04           ' 10 bits output value Z LSB             ZOUT[7]  ZOUT[6]  ZOUT[5]  ZOUT[4]  ZOUT[3]  ZOUT[2]  ZOUT[1]  ZOUT[0]
  ZOUTH         = $05           ' 10 bits output value Z MSB             --       --       --       --       --       --       ZOUT[9]  ZOUT[8]
  XOUT8         = $06           ' 8 bits output value X                  XOUT[7]  XOUT[6]  XOUT[5]  XOUT[4]  XOUT[3]  XOUT[2]  XOUT[1]  XOUT[0]
  YOUT8         = $07           ' 8 bits output value Y                  YOUT[7]  YOUT[6]  YOUT[5]  YOUT[4]  YOUT[3]  YOUT[2]  YOUT[1]  YOUT[0]
  ZOUT8         = $08           ' 8 bits output value Z                  ZOUT[7]  ZOUT[6]  ZOUT[5]  ZOUT[4]  ZOUT[3]  ZOUT[2]  ZOUT[1]  ZOUT[0]
  STATUS        = $09           ' Status registers                       --       --       --       --       --       PERR     DOVR     DRDY
  DETSRC        = $0A           ' Detection source registers             LDX      LDY      LDZ      PDX      PDY      PDZ      INT1     INT2
  TOUT          = $0B           ' "Temperature output value" (Optional)  TMP[7]   TMP[6]   TMP[5]   TMP[4]   TMP[3]   TMP[2]   TMP[1]   TMP[0]
'               = $0C           ' (Reserved)                             --       --       --       --       --       --       --       --
  I2CAD         = $0D           ' I2C device address I                   2CDIS    DAD[6]   DAD[5]   DAD[4]   DAD[3]   DAD[2]   DAD[1]   DAD[0]
  USRINF        = $0E           ' User information (Optional)            UI[7]    UI[6]    UI[5]    UI[4]    UI[3]    UI[2]    UI[1]    UI[0]
  WHOAMI        = $0F           ' "Who am I" value (Optional)            ID[7]    ID[6]    ID[5]    ID[4]    ID[3]    ID[2]    ID[1]    ID[0]
  XOFFL         = $10           ' Offset drift X value (LSB)             XOFF[7]  XOFF[6]  XOFF[5]  XOFF[4]  XOFF[3]  XOFF[2]  XOFF[1]  XOFF[0]
  XOFFH         = $11           ' Offset drift X value (MSB)             --       --       --       --       --       XOFF[10] XOFF[9]  XOFF[8]
  YOFFL         = $12           ' Offset drift Y value (LSB)             YOFF[7]  YOFF[6]  YOFF[5]  YOFF[4]  YOFF[3]  YOFF[2]  YOFF[1]  YOFF[0]
  YOFFH         = $13           ' Offset drift Y value (MSB)             --       --       --       --       --       YOFF[10] YOFF[9]  YOFF[8]
  ZOFFL         = $14           ' Offset drift Z value (LSB)             ZOFF[7]  ZOFF[6]  ZOFF[5]  ZOFF[4]  ZOFF[3]  ZOFF[2]  ZOFF[1]  ZOFF[0]
  ZOFFH         = $15           ' Offset drift Z value (MSB)             --       --       --       --       --       ZOFF[10] ZOFF[9]  ZOFF[8]
  MCTL          = $16           ' Mode control                           LPEN     DRPD     SPI3W    STON     GLVL[1]  GLVL[0]  MOD[1]   MOD[0]
  INTRST        = $17           ' Interrupt latch reset                  --       --       --       --       --       --       CLRINT2  CLRINT1
  CTL1          = $18           ' Control 1                              --       THOPT    ZDA      YDA      XDA      INTRG[1] INTRG[0] INTPIN
  CTL2          = $19           ' Control 2                              --       --       --       --       --       DRVO     PDPL     LDPL
  LDTH          = $1A           ' Level detection threshold limit value  LDTH[7]  LDTH[6]  LDTH[5]  LDTH[4]  LDTH[3]  LDTH[2]  LDTH[1]  LDTH[0]
  PDTH          = $1B           ' Pulse detection threshold limit value  PDTH[7]  PDTH[6]  PDTH[5]  PDTH[4]  PDTH[3]  PDTH[2]  PDTH[1]  PDTH[0]
  PW            = $1C           ' Pulse duration value                   PD[7]    PD[6]    PD[5]    PD[4]    PD[3]    PD[2]    PD[1]    PD[0]
  LT            = $1D           ' Latency time value                     LT[7]    LT[6]    LT[5]    LT[4]    LT[3]    LT[2]    LT[1]    LT[0]
  TW            = $1E           ' Time window for 2nd pulse value        TW[7]    TW[6]    TW[5]    TW[4]    TW[3]    TW[2]    TW[1]    TW[0]
'               = $1F           ' (Reserved)                             --       --       --       --       --       --       --       --

  G_RANGE_2g    = %01           ' 2g = %01
  G_RANGE_4g    = %10           ' 4g = %10
  G_RANGE_8g    = %00           ' 8g = %00

  G_MODE        = %01           ' 00 - Standby                                        
                                ' 01 - Measurement    
                                ' 10 - Level Detection
                                ' 11 - Pulse Detection
  
VAR

  byte  Cog
  long  TempData 

                                                           
PUB start(SPC, SDI, CS) 

  TempData := (SDI & $1F) << 10 + (SPC & $1F) << 5 + (CS & $1F)
  Cog := cognew(@Entry, result := @TempData)                  

PUB stop                        'Stop the currently running cog, if any
                        
  if !Cog
    cogstop(Cog)

PUB write(Addr, Value)

    Addr |= $40                 'set the read/write bit
    TempData := (($FFFF << 16)|(Addr << 9)|Value)
    repeat until ((TempData >> 16) == 0)
    TempData := 0
    
PUB read(Addr)
    Addr &= $BF                 'clear the read/write bit
    TempData := ($FFFF << 16)|(Addr << 9)

    'wait until done receiving data
    repeat until ((TempData >> 16) == 0) 
    Addr := TempData
    TempData := 0
    return (Addr & $FF)
        
DAT

                        org
Entry
                        mov     index,par               'get data pointer
                        rdlong  Data, index
                        mov     Select, #1              'store CS pin mask
                        rol     Select, Data
                        ror     Data, #5
                        
                        mov     Clock, #1               'store CLK pin mask
                        rol     Clock, Data
                        ror     Data, #5

                        mov     DataPin, #1             'store DATA pin mask
                        rol     DataPin, Data
                        
                        mov     temp, Select
                        or      temp, Clock
                        or      temp, DataPin
                        mov     outa, temp               'Select, Clock, DataPin are set output and high
                        mov     dira, temp
                        
                        wrlong  num_0, index             'Clear the command buffer to wait for a new command
                        
CheckCommand            rdlong  Address, index
                        tjz     Address, #CheckCommand   'see if a new command has been loaded (if the register contains any value)
                        mov     temp, Address
                        shr     temp, #8
                        and     temp, #$80
                        tjz     temp, #ReadByte
                        jmp     #WriteByte

WaitForClear            rdlong  Address, index
                        tjnz    Address, #WaitForClear      'wait for entire register to be cleared
                        jmp     #CheckCommand                    
                        
'-------[ Write - Write 8 bits of SPI data to a 6 bit address ] ----------------
WriteByte
                        shl     Address, #16
                        mov     Data, #16       wz      'Set for 16 loops; clear zero
                        muxnz   dira, DataPin           'make sure data pin is an output
                        muxz    outa, Select            'Clear Select pin
                        muxz    outa, Clock             'Clear Clock pin
                 
                        mov     temp, cnt
                        add     temp, clkspeed
:SendBit
                        shl     Address, #1     wc      'Set c to Address[31] and shift the next bit into place
                        muxc    outa, DataPin           'Set DataPin pin to c
                        waitcnt temp, clkspeed
                        muxnz   outa, Clock             'Set Clock pin
                        waitcnt temp, clkspeed
                        muxz    outa, Clock             'Clear Clock pin
                        djnz    Data, #:SendBit

                        waitcnt temp, clkspeed
                        muxnz   outa, Select            'bring select line back high
                        muxnz   outa, DataPin
                        muxnz   outa, Clock             'Set Clock pin
                        wrlong  num_FFFF, index         'Clear busy flags (upper 16 bits)
                        jmp     #WaitForClear

'-------[ Read - read 8 bits of SPI data from a 6 bit address ] ----------------
ReadByte
                        shl     Address, #16            'Shift data to high side of word
                        mov     Data, #8        wz      'Set for 8 loops and clear zero
                        muxz    outa, Select            'Clear Select pin
                        muxnz   dira, DataPin           'make sure data pin is an output 
                                                
                        mov     temp, cnt
                        add     temp, clkspeed
:SendBit
                        shl     Address, #1     wc      'Set c to Address[31] and shift the next bit into place
                        waitcnt temp, clkspeed                          
                        muxz    outa, Clock             'Clear Clock pin
                        muxc    outa, DataPin           'Set DataPin pin to c
                        waitcnt temp, clkspeed                          
                        muxnz   outa, Clock             'Set Clock pin
                        djnz    Data, #:SendBit

                        waitcnt temp, clkspeed                          
                        muxz    dira, DataPin           'Make DataPin an input
                        muxz    outa, Clock             'Clear Clock pin
                        mov     Address, #8             'Set for 8 loops
:GetBit                 
                        waitcnt temp, clkspeed                          
                        muxnz   outa, Clock             'Set Clock pin
                        shl     Data, #1                'Prepare Data for next bit
                        and     DataPin, ina    nr, wc  'c := ina[DataPin]
                        waitcnt temp, clkspeed                          
                        muxz    outa, Clock             'Clear Clock pin
                        muxc    Data, #1                'Data[0] := c                        
                        djnz    Address, #:GetBit

                        waitcnt temp, clkspeed                          
                        muxnz   outa, Clock              'set clock and select back high, and DataPin as output high again
                        muxnz   outa, Select
                        muxnz   outa, DataPin
                        muxnz   dira, DataPin

                        and     Data, num_FFFF          'Clears the busy flags (upper 16 bits)
                        or      Data, num_FF00             
                        wrlong  Data, index             'Write result back to shared memory location
                        jmp     #WaitForClear


'Constants and Data for assembly code
  num_FFFF      long      $FFFF
  num_FF00      long      $FF00
  num_0         long      0
  clkspeed      long      60      'number of system clock cycles between transitions of the SPI clock
   
  index         res       1
  temp          res       1
  Clock         res       1
  DataPin       res       1
  Select        res       1
   
  Data          res       1
  Address       res       1
   
                                     