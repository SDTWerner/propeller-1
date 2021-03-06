{{
stepper.spin
Simple SPIN stepper motor driver for Bipolar stepper motor
Copyright 2011 Perry Harrington <pedward!apsoft•com>

Bipolar stepper motors are 2 phase motors, with the phases arranged at
90 degrees separation.

 A  ──┐
     
 A  ──┘
       ┌┐
       │  │
          
       B  B

Stepper motors can be directly driven in the following methods
Full Step - wave mode
Full Step - high torq
Half Step - high torq

Wave mode keeps all terminals at ground potential and drives only one terminal
high at a time.  This uses less power, which corresponds to less torque.

High Torque Full step energizes 2 terminals at a time, energizing two adjacent phases
in alternating order

Half step is a combination of Wave mode and High Torque mode, dithering the bit values

Here is the commutation sequence for each type of drive mode:

Wave Drive
     
   AABB
0  0001
1  0010
2  0100
3  1000

High Torque
     
   AABB
0  0011
1  0110
2  1100
3  1001

Half Step
     
   AABB
0  0001
1  0011
2  0010
3  0110
4  0100
5  1100
6  1000
7  1001

The calling convention for this object follows:

OBJ
  Motor: "stepper"

PUB Main
  Motor.Start(<Port Base Pin>, Motor#<Mode>)
  Motor.StepDir(<Direction>)

}}
CON
  #0,Disabled,FullStep,HalfStep,HighTorq

VAR
  long Delay
  long StepPos
  byte PortPinL
  byte PortPinH
  long Up
  long Dn
  long Dirs[2]

PUB Start(pin,mode)
  PortPinL := pin
  PortPinH := pin+3
  DIRA[PortPinL..PortPinH]~~

  CASE mode
    Disabled:
      OUTA[PortPinL..PortPinH]:=0
    FullStep:
      Up := @FullStepUp
      Dn := @FullStepDn
    HalfStep:
      Up := @HalfStepUp
      Dn := @HalfStepDn
    HighTorq:
      Up := @HiTqStepUp
      Dn := @HiTqStepDn

  Dirs[1] := Up                 'store the pointers to the phase tables, so its just memory lookups
  Dirs[0] := Dn
PUB StepDir(dir)

  'lookup pointer to phase table basde on direction
  'then lookup the next phase value based on present phase value
  OUTA[PortPinL..PortPinH] := BYTE[Dirs[dir]][INA[PortPinL..PortPinH]]

DAT
'phase table lookup, for step up and step down, put the present
'value in the lookup to get the next value
'                0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
FullStepUp byte $1,$2,$4,$1,$8,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1
FullStepDn byte $8,$8,$1,$8,$2,$8,$8,$8,$4,$8,$8,$8,$8,$8,$8,$8
HalfStepUp byte $1,$3,$6,$2,$C,$1,$4,$1,$9,$1,$1,$1,$8,$1,$1,$1
HalfStepDn byte $9,$9,$3,$1,$6,$9,$2,$9,$C,$8,$9,$9,$4,$9,$9,$9
HiTqStepUp byte $3,$3,$3,$6,$3,$3,$C,$3,$3,$3,$3,$3,$9,$3,$3,$3
HiTqStepDn byte $9,$9,$9,$9,$9,$9,$3,$9,$9,$C,$9,$9,$6,$9,$9,$9
HalfSteps byte 1,3,2,6,4,12,8,9
FullSteps byte 1,2,4,8
HighTorqSteps byte 3,6,12,9

