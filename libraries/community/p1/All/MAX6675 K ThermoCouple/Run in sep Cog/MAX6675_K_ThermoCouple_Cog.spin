{
''***************************************
''*  MAX675 v1.1                        *
''*  Author: Mike Lord                  *
''*  Copyright (c) Mike Lord            *
''*  Mike@electronicdesignservice.com   *
''*  650-219-6467                       *                
''*  See end of file for terms of use.  *               
''***************************************

' v1.0 - 01 Jul7 2011 - original version

This is written as a spin driver for the max6675 K type thermocouple chip.


┌─────────────────────────────────────┬────────────────┬─────────────────────┬───────────────┐
│ MAX6675 driver                      │ PG             | (C) 2011            | July 20 2011  |
├─────────────────────────────────────┴────────────────┴─────────────────────┴───────────────┤
│                                                                                            │
│ A driver for the MAX6675 K Type theromcouple chip                                          │
|                                                                                            |   
| See end of file for terms of use                                                           |
└────────────────────────────────────────────────────────────────────────────────────────────┘
 SCHEMATIC
                      ┌────┐      
             Gnd 1  │      │ 8 Nc    
             T+  2  │MAX   │ 7 Sd
             T-  3  │6675  │ 6 Cs
             Vcc 4  │      │ 5 Sck
                      └──────┘      



 }
CON
     bits = 16

     RedLedPin = 21
   
var   long stack1[20]
      long CogNr



obj

      Tv        :  "Mirror_TV_Text"
 



'==================================================================
Pub  Start(So, CS, SCK, TempScale , TempIn_Addr )  | InBit   , Value
'==================================================================

   'Stop

  CogNr:=cognew(ReadTemp(So, CS, SCK, TempScale , TempIn_Addr),@stack1)
Return CogNr  



  
'==================================================================
Pub Stop
'==================================================================
  CogStop(CogNr)






'==================================================================
Pub  ReadTemp(So, CS, SCK, TempScale , TempIn_Addr )  | InBit   , Value
'==================================================================
              ' SD, CS, SCK are the pin numbers of the propeller connected to the max6675
              'TempScale  = 1     '1 is Farienheight   0 is Centegrade  
              
          dira[Cs] := 1
          dira[SCK] := 1
          dira[So] := 0 

          'dira[ RedLedPin ] := 1
          'outa[ RedLedPin ] := 0 
          'waitcnt(clkfreq * 4 + cnt) 
          
          Outa[Cs] := 1     'Make sure chip select is high
          Outa[SCK] := 0    'make sure Sck is low as initial value
             
 Repeat


 
            Value := 0
            Outa[Cs] := 0    'Now take Chip select low to shart shift out of data 
            REPEAT Bits    ' for number of bits 

                Waitcnt(clkfreq /10_000 + cnt)
                Outa[SCK] := 1
                Waitcnt(clkfreq /10_000 + cnt)
                Outa[SCK] := 0      'Data is now ready to be read

                                                                 
                InBit:= ina[So]                                ' get bit value                          
                Value := (Value << 1) + InBit                    ' Add to  value shifted by position                                         


     If  TempScale == 0
         Long[TempIn_Addr] :=  Value  /80       'devide by 8 to get rid of 3 status bits & by 10 to get C                                               
     else
         Long[TempIn_Addr] := (( Value  /80 ) * 9)/5 +32      'devide by 8 to get rid of 3 status bits & by 10 to get C                                               


          
     Outa[Cs]  := 1     'Make sure chip select is high
     Outa[SCK] := 0    'make sure Sck is low as initial value
     

                    
        ' !Outa[ RedLedPin]            
         waitcnt(clkfreq + cnt)
        
 
  

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