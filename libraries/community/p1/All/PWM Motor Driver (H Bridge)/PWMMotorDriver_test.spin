{{Motor driver for H Bridge driven motors; for instance L298N based driver circuits, based on code by Jev Kuznetsov and the code from AN001 - propeller counters

┌────────────────────────────────────────────┐
│ PWMMotor Driver 0.8  Test Code             │
│ Author: Rick Price (rprice@price-mail.com) │             
│ Copyright (c) <2009> <Rick Price           │             
│ See end of file for terms of use.          │              
└────────────────────────────────────────────┘

 date  :  11 May 2009

 usage

 OBJ
        pwm : PWMMotorDriver

  ....

  pwm.Start(outputEnablePin,driveForwardPin,driveForwardInversePin,Frequency) ' Start PWM on cog with a base frequency of *frequency*
  pwm.SetDuty( duty)            ' set duty in % -100 goes full backward, 0 brakes, 100 goes full forward       
  pwm.Halt                      ' Brake motor
  pwm.Stop                      ' Brake motor for 1s and then stop cog

}}

' This is example code

CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000             ' CHECK THIS!!!
    max_duty_forward = 100
    max_duty_backward = -100
    stopped = 0
    enablePin = 8
    forwardPin = 9
    forwardInversePin = 10

VAR long parameter
  

OBJ
  pwm1  :  "PWMMotorDriver"

PUB go | x
  pwm1.start(enablePin,forwardPin,forwardInversePin,40000) ' start at 10khz
  
  repeat
    repeat x from stopped to max_duty_forward ' linearly advance speed from stopped to maximum speed forward
      setDutyAndWait(x)
    repeat x from max_duty_forward to stopped ' slowly stop motor
      setDutyAndWait(x)
    waitcnt(clkfreq*1+cnt)
    repeat x from stopped to max_duty_backward ' linearly advance speed from stopped to maximum speed backward
      setDutyAndWait(x)
    repeat x from max_duty_backward to stopped ' slowly stop motor
      setDutyAndWait(x)

PUB setDutyAndWait(duty)
  pwm1.SetDuty(duty)
  waitcnt(clkfreq/4+cnt)



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