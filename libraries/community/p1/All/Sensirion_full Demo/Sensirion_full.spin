{{ 
┌─────────────────────────────────────┬────────────────┬─────────────────────┬───────────────┐
│ sensirion_full v1.0                 │ BR             │ (C)2010             │  5July2010    │
├─────────────────────────────────────┴────────────────┴─────────────────────┴───────────────┤
│                                                                                            │
│ A full-featured driver for the Sensirion SHT-11 temperature/humidity sensor (Parallax      │
│ part number 28018).  Based on the original object by Cam Thompson:                         │
│ http://obex.parallax.com/objects/21/                                                       │
│                                                                                            │
│ This object retains the low-level driver methods of Cam's original object and adds a few   │
│ more methods to 1) enable control of the sensor's "advanced" functions and 2) enable       │
│ calibrated sensor temperature and humidity output without the need to use the floating     │
│ point routines.                                                                            │
│                                                                                            │
│ Features: •backwards-compatible with the original                                          │
│           •contains methods to calculate temperature and humidity using fixed point math   │
│           •fixed point routines support degC, degF, and relative humidity outputs          │
│           •sensor calibration constants updated to reflect datasheet 4.3 (May2010) values  │
│           •contains methods to control sensor heater and output resolution                 │
│                                                                                            │
│ So sayeth the datasheet:                                                                   │
│ •Measurement time maximum of 20/80/320 ms for a 8/12/14bit measurement.                    │
│ •Measurement time time varies with the speed of the internal oscillator and can be lower   │
│  by up to 30%  [presumably as a function of temperature?]                                  │
│ •To avoid signal contention the microcontroller must only drive DATA low.  An external     │
│  pull-upresistor (e.g. 10kΩ) is required to pull the signal high                           │
│                                                                                            │
│ Miscellaneous notes:                                                                       │
│ •WARNING: the sensirion data sheet says that the heater is not designed to be on           │
│  continuously and should not be on for more than 10% of the time                           │
│ •The fixed point routines are not as accurate as the floating point routines, but they     │
│  do tend to be within 1-2°F of the float result and within 2-3% of the humidity float      │
│  result at room temperature.  Given that the accuracy of the device as spec'd in the data  │
│  sheet is at best ±0.5°C/1.0°F and ±3% RH, the fixed point routines should be accurate     │
│  enough for most uses.                                                                     │
│ •A fixed point routine to calculate dewpoint is not provided                               │
│ •More info: http://forums.parallax.com/forums/default.aspx?f=25&m=467894                   │
│                                                                                            │
│ See end of file for terms of use.                                                          │
└────────────────────────────────────────────────────────────────────────────────────────────┘
DEVICE PINOUT & REFERENCE CIRCUIT

                        ┌────┐            Note1: 4.7KΩ pulldown on clk pin is recommended in
 prop pin29─── data │ ┌──┐ │ vdd             Parallax documentation for stamp interface,
                      │ ││ │                 but seems to work fine without it
 prop pin28 clk ─┳──│ └──┘ │          Note2: This sensor can be attached to the prop's I2C
              4.7KΩ  ┌│      │                 bus without interfering with bus operation;
                      └──────┘                   data should be connected to pin 29, clk to 28
                    GND                     
                                            
FIXME: implement fixed-point dewpoint calc
}}                                                 

CON
  Cmd_Temperature = %00011                              ' measure temperature
  Cmd_Humidity    = %00101                              ' measure humidity
  Cmd_ReadStatus  = %00111                              ' read status
  Cmd_WriteStatus = %00110                              ' write status
  Cmd_Reset       = %11110                              ' soft rest
  #0,hiRes,loRes
  #0,off,on
  #0,yes,no

           
VAR
  word dpin, cpin
  long TC                                               'most recent temperature measurement using get method

 
PUB start(data_pin, clock_pin) 
''assign SHT-11 clock and data pins and reset device

  dpin := data_pin                                      ' assign data pins                       
  cpin := clock_pin                                     ' assign clock pin
  outa[cpin]~                                           ' set clock low
  dira[cpin]~~
' outa[dpin]~~                                          ' set data high
' dira[dpin]~~                                           
  REPEAT 9                                              ' send 9 clock pulses for reset
    !outa[cpin]                                         
    !outa[cpin]

     
pub config(volt,heater,OTPreload,measRes)
''configure SHT-11 options and set up sensor correlation coefficients
''arguments: volt:      Vdd, sensor operating voltage*10
''           heater:    on/off intenral heater...do not leave on continuously
''           OTPreload: yes/no reload internal calibration constants before each measure (no saves 10ms)
''           measRes:   measurement resolution hiRes=14/12 bit, loRes=12/8 bit
''usage: for 3.3 volts with low res output, heat off, no OTP, use: config(33,off,no,loRes)

  volt:= 20#> volt <#55                                                      'limit volts to 2-5.5
  measRes:= 0#> measRes <#1                                                  
  d1 := -438*volt + -634991
  d2 := lookupz(measRes:164,655)
  c2 := lookupz(measRes:38483,615724)
  c3 := lookupz(measRes:-2,-428)
  t2 := lookupz(measRes:84,1342)
  writeStatus((heater<<2)+(OTPreload<<1)+measRes)


'this is a useless function since the prop's brownout detector trips at 2.7v...
{pub checkLowBat
''queries status register to see if low battery bit is set (indicates voltage < 2.47V)
''returns 1 if low bat status bit is set

  return (readStatus & %01000000)>>6

} 
pub getTemperatureC
''Read sensor, apply correlation coefficients, return calibrated temperature in degC

  TC := (d1 + d2 * readTemperature)~>14
  return TC
  

pub getTemperatureF
''Read sensor, apply correlation coefficients, return calibrated temperature in degF

  getTemperatureC
  return ((TC<<12)*9/5+(32<<12))~>12


pub getHumidity|raw_rh,linear_rh,tmp
''Read raw humidity value, apply sensor correlation coefficients, return calibrated humidity
''NOTE: getTemperatureC or getTemperatureF should be called before calling this function

  raw_rh := readHumidity
  linear_rh := c1 + c2 * raw_rh + raw_rh * c3 * raw_rh
  tmp := linear_rh + (TC - 25) * (t1 + t2*raw_rh)
  return tmp~>20
 
  
dat
'-----------[ Predefined variables and constants ]-----------------------------
'correlation coefficient data based on datasheet version 4.3, May2010
'temperature is scaled by 2^14, humidity is scaled by 2^20
d1     long 0
d2     long 0
c1     long -2146225
c2     long 0
c3     long 0
t1     long 10486
t2     long 0


PUB readTemperature | ack
''return raw SHT-11 temperature value

  ack := sendCommand(Cmd_Temperature)                   ' measure temperature
  wait                                                  ' wait until done
  return readWord                                       ' return result


PUB readHumidity | ack
'' return raw SHT-11 humidity value

  ack := sendCommand(Cmd_Humidity)                      ' measure humidity
  wait                                                  ' wait until done
  return readWord                                       ' return result


PUB readStatus | ack
'' read SHT-11 status register

  ack := sendCommand(cmd_ReadStatus)                    ' read status
  return readByte(1)

  
PUB writeStatus(n) | ack
'' set SHT-11 status register

  ack := sendCommand(cmd_WriteStatus)                   ' write status
  writeByte(n & $47)                                    ' (mask out reserved bits)

  
PUB reset | ack
'' soft reset the SHT-11

  ack := sendCommand(cmd_Reset)                         ' write status
  waitcnt(cnt+clkfreq*15/1000)                          ' delay for 15 msec

  
PRI sendCommand(cmd)
  ' send transmission start sequence
  ' clock  
  ' data   
  dira[dpin]~                                           ' data high (pull-up)                                '
  outa[cpin]~                                           ' clock low                                   
  outa[cpin]~~                                          ' clock high                                 
  outa[dpin]~                                           ' data low
  dira[dpin]~~
  outa[cpin]~                                           ' clock low
  outa[cpin]~~                                          ' clock high
  dira[dpin]~                                           ' data high (pull-up)                                '
  outa[cpin]~                                           ' clock low

  return writeByte(cmd)                                 ' send command and return ACK

PRI readWord                                            ' read 16-bit value 
  return (readByte(0) << 8) + readByte(1)               
  
PRI readByte(ack)                                       ' read 8-bit value
  ' data is valid before rising edge of clock
  ' clock   
  ' data   

  dira[dpin]~                                           ' data input
  REPEAT 8
    result := (result << 1) | ina[dpin]                 ' get next bit
    !outa[cpin]                                         ' send clock pulse 
    !outa[cpin]

  dira[dpin]~~                                          ' enable data output
  outa[dpin] := ack                                     ' write ACK bit
  !outa[cpin]                                           ' send clock pulse 
  !outa[cpin]
  dira[dpin]~                                           ' enable data input
  
PRI writeByte(value)                                    ' write 8-bit value, return ACK
  ' data must be valid on rising edge of clock and while clock is high
  ' clock   
  ' data   

' dira[dpin]~~                                          ' enable data output
  value:=true ^ value                                   ' invert bits of value
  outa[dpin]~
  REPEAT 8
'   outa[dpin] := value >> 7                            ' output next bit
    dira[dpin] := value >> 7                            ' output next bit
    value := value << 1
    !outa[cpin]                                         ' send clock pulse
    !outa[cpin]

  dira[dpin]~                                           ' enable data input
  result := ina[dpin]                                   ' read ACK bit
  !outa[cpin]                                           ' send clock pulse 
  !outa[cpin]
  
PRI wait | t                                            ' wait for data low (250 msec timeout) 
  t := cnt                                              
  repeat until not ina[dpin] or (cnt - t)/(clkfreq/1000) > 250


dat

{{

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     TERMS OF USE: MIT License                                       │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and    │
│associated documentation files (the "Software"), to deal in the Software without restriction,        │
│including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,│
│and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,│
│subject to the following conditions:                                                                 │
│                                                                                                     │                        │
│The above copyright notice and this permission notice shall be included in all copies or substantial │
│portions of the Software.                                                                            │
│                                                                                                     │                        │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT│
│LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  │
│IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION│
│WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}