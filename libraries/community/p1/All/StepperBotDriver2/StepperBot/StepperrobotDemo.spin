



{{ **************************************************************************************
   *                                                                                    *     
   *  Stepper Motor Robot - Demo of Line Finding/Following Via Infrared Sensors with    *
   *                        Collision Avoidance via a Ping Sensor and Sound Effects via *
   *                        a Sound Pal                                                 *
   *                                                                                    *
   *  Using Propeller Board of Education, 28BYJ48-12-300 Motor, ULN2003 Motor Controller*
   *        SoundPal, ROHM RPR-359 Reflective Infrared Sensors, Ping Sensor,            *
   *        9.6 V Rechargable, Foam Rollers(for Feed Motor), Toy Wheels and Homemade    *
   *        Chassis                                                                     * 
   *                                                                                    *
   *  Each step is 5.626 degrees / 64 (gear reduction) or 0.087890625 degrees           *
   *  The coils are energized in 8 steps or 0.703125 degrees (8*0.087890625 degrees)    *
   *  Each revolution is 360 degrees/0.087890625 degrees/rev or 4096 steps or           *
   *  512 8-steps cycles.  This code uses a 4 step coil sequence which is slightly      *
   *  faster with less torque by skipping 1/2 steps.                                    *
   *                                                                                    *
   *  This code launches a control method for each motor in an independent cog.  The    *
   *  main code commands the motors by updating parameters of speed, distance, direction*
   *  distance to the target, and brakes.  The motor updates the main code and allows   *
   *  coordination by passing parameters back of remaining distance, remaining distance *
   *  to target and motor in motion.  The main code using a control loop to read        *
   *  sensors, determine status, define needed action and coordinate commands between   *
   *  motors.                                                                           *    
   *                                                                                    *
   *  Gregg Erickson - 2013 (MIT License)  - Updated 5/1/13                             *
   *                                                                                    *
   **************************************************************************************
                 
   Vdd(5.0v)--> ULN2003(s), SoundPal, Ping for Power
   P0..P3 --> ULN2003 Control Pins for Right Motor 
   P4..P7 --> ULN2003 Control Pins for Left Motor
   P8..P9 <-- 100 Ohm <-- Vdd(3.3) or <--Vss for Binary Selection of Mailbox 
   P10..P11 <-- 100 Ohms <-- IRSensor Output --> 100K ohms --> Vdd(5.0v)
   P12..P13 --> Sensor Indicator LEDs --> 100 Ohms --> Vss
   P14 <-- 1000K <-- Ping Signal Pin
   P16..P19 --> ULN2003 Control Pins for Feed Motor

                
}}

        

CON
        _clkmode = xtal1 + pll16x   ' Set Prop to Maximum Clock Speed
        _XinFREQ = 5_000_000
  
                                    ' Case Constants for Motor Commands of Move Methods Copied from StepperBotDriver
                                    
        RightTurn=1                 ' Pivot to the Right by Stopping the Right Wheel and Forward on the Left
        LeftTurn=0                  ' Pivot to the Left by Stopping the Left Wheel and Forward on the Right
        Straight=2                  ' Both Wheel Same Direction and Speed
        RightTwist=3                ' Twist Right by Reversing Right Wheel and Forward on the Left Wheel
        LeftTwist=4                 ' Twist Left by Reversing Left Wheel and Forward on the Right Wheel
        LeftCurve=5                 ' Curve Left by Running Left Wheel Proportionally Slower than the Right
        RightCurve=6                ' Curve Right by Running Right Wheel Proportionally Slower than the Left
        DumpRight=7                 ' Dump Right by Rotating Dispensing Motor
        DumpLeft=8                  ' Dump Left by Rotating Dispensing Motor 


                                    ' Stepper Motor Sequence to Distance Conversion Ratios Copied from StepperBotDriver
    
        InchTicks=53                ' Motor Sequences to Move a Wheel 1 inch
        CentiTicks=21               ' Motor Sequences to Move a Wheel 1 Centimeter
        RevTicks=512                ' Motor Sequences to Rotate a Wheel 360 Degrees
        TwistDegTicks=3             ' Motor Sequences to Rotate 1 Degree Using 2 Wheels
        TurnDegTicks=6              ' Motor Sequences to Pivot 1 Degree Using 1 Wheel  

        MailBoxSpacing=13           ' Target Distance in Centimeters from End of Line
        RotationOffset=9            ' Offset of Sensor from End of Line after 180 Degree Rotation
        DumpOffset=15               ' Offset from Sensor to Feed Dispensor

                                    ' Pins for Inputs and Outputs

        PingPin=15                  ' Pin for Ping Sensor 
        LeftIRPin=10                ' Pins for IR Sensor 
        RightIRPin=11         
        LeftLED=12                  ' Pins for (IR Sensor) Indicators
        RightLED=13

                                    ' Stepper Sequence Constants
        Full=0
        Half=1
        Wave=2                            
 
        
Var
      ' These Motor Variable MUST Be in Order of Left, Right, Feed

        Long LeftPin,RightPin,FeedPin                  ' First Pin of Each Motor
        Long LeftSteps,RightSteps,FeedSteps            ' Steps per Rotation 4 or 8
        Long LeftSpeed, RightSpeed,FeedSpeed           ' Speed of Each Motor, 0 to 500 (Max Limit for Specific Motor)
        Long LeftDist, RightDist,FeedDist              ' Primary Count for Maximum Distance for Motor to Drive, each step is ~1/4 inches
        Long LeftTarget,RightTarget,FeedTarget         ' Secondary Count of Distance for Motor Drive to Target, Secondary Maximum
        Long LeftBrake, RightBrake,FeedBrake           ' Set Brakes When Not in Motion by Energizing All Coils, 1=Energized, 0=Off
        Long LeftOdometer,RightOdometer,FeedOdometer   ' Odometer
        Long LeftTrip, RightTrip,FeedTrip              ' Trip Odometer 
        Long LeftLock,RightLock,FeedLock               ' In Motion Flags, True or False

      ' Line Sensor and Targeting Variables

        Long IRSensor,ActualIRSensor,LastValid         ' IR Sensor Value, Actual Reading and Previous Reading
                                                       ' where 0=Neither Sensor Sees the Line, 1=Line to Right, 2=Line to Left, 3=Both on Line                                                                                                                                                
        Byte EndofLine,BeginOfLine,BeginFinal          ' Status of Line Detection for Special Cases
        Long TargetDistance                            ' Distance to Target 


      ' Ranging Variables  
        Long Range                                     ' Range in Centimeters by Png Sensor
        Long MailBox,MailBoxDistance                   ' Mailbox Number and Calculated Distance
        Long TurnRatio, TurnCount                      ' Wheel Ratio and Counter
          
OBJ

       Drive: "StepperBotDriver2"                      ' Object to Run a Stepper Motor Robot with IR Line Sensor and Ping Ranging
       Serial: "FullDuplexSerial"                      ' Serial Object For Debugging
       SoundPal : "SoundPAL"                           ' SoundPal Object for Sound Effects


Pub Main
                                                                                                         
'--------------------------------------------------------------------------------------------------------------
'-------------------- Set Initializing Variables --------------------------------------------------------------
'--------------------------------------------------------------------------------------------------------------

      LeftPin:=4                          ' Define First of 4 Pins for Each Motor
      RightPin:=0
      FeedPin:=16
            
      LeftSteps:=Full                        ' Define Number of Steps per Cycle for Each Motor
      RightSteps:=Full
      FeedSteps:=half                     

      TurnCount:=0                        ' Initial Zero for Rotation Counter
      TurnRatio:=100                        ' Initial Ratio of Opposite Side Wheel Rotations During Turns
      IRSensor:=0
      LastValid:=0                        ' Initial Last Valid Condition of IR Sensors, No Line Sensed

      BeginFinal:=false                   ' Initial Condition is Beginning of Line Not Found
      EndofLine:=false                    ' Initial Condition is End of Line Not Found

                                                                              
      Mailbox:=ina[9..8]+1                                                    ' Read MailBox Number in Binary from Pins 8 & 9
                                                                              ' The four mailboxes can now be selected ( 00,01,10,11)
                                                                              ' by setting the input to 2 pins. (The mailbox number -1 in binary)
                                                                              ' to ground or Vdd
      MailBoxDistance:=Mailbox*MailBoxSpacing                                 ' Calculate Offset of Mailbox from End of the Line  
      TargetDistance:=(MailBoxDistance-RotationOffset+DumpOffset)*Centiticks   'Distance of Target After End of Line Found, In Centimeters with Offset After Rotation

      LeftTarget:=6000                    ' Set Maximum Target Distance for Each Motor
      RightTarget:=6000
      FeedTarget:=6000
                                                   
'--------------------- Start Objects & Methods ------------------------------------------------------------------

      SoundPal.start(14)                                                                     ' Start SoundPal Object for Sound Effects
 '     SoundPal.sendstr(string("=", SoundPal#play, SoundPal#charge, SoundPal#EOF, "!"))       ' Play Charge While Objects Starting Up
      Drive.FlashBrakes(LeftPin,RightPin,5,3)                                               ' Flash Brakes to Indicate Power to All Drive Motor Coil
      Serial.start(31,30,0,115_200)                                                          ' Start Serial for Debugging 
                                                                                             ' Start StepperBotDriver Objects Methods for Robot Control
      Drive.StartPing(PingPin,@Range)                                                        ' Start Ping for Ranging
      Drive.StartIrLineSensor(LeftIRPin,RightIRPin,LeftLED,RightLED,@ActualIrSensor)         ' Start IR Line Sensor 
      Drive.StartMotor(@LeftSteps,@LeftPin,@LeftSpeed,@LeftDist,@LeftTarget,@LeftOdometer,@LeftTrip,@LeftBrake,@LeftLock)' Start Motors & Controller
 
                                                                                                        
'--------------------------------------------------------------------------------------------------------------
'----------------------------  Line Following Command Loop ----------------------------------------------------
'--------------------------------------------------------------------------------------------------------------  

Drive.Autobrake(false)                            ' Verify Both Brakes are Off
Drive.Move(Straight,800,2000*CentiTicks,100)        ' Launch Robot in Straight line

                                                                                                                     
repeat
  serial.dec(turnratio)
  serial.tx($0D)
  serial.tx($0A)
   
'------------- Read Sensors and Set Indicators  ------------------------------------------------------------------

   IRsensor:=ActualIRsensor

 
'---------------- Begin and End of Line Special Conditions -------------------------------------------------------

  If Not(BeginOfLine) and IRSensor==0    ' If Line Not Found Yet (Sensors Zero), Override Sensor to Go Straight (Sensor Status = 3)
     IRSensor:=3

  Else                                   ' Once Line is Found (Sensors not zero), Stop Overriding Sensor and Remember the Line was Found
     BeginOfLine:=true
     
        
   
  if Not (EndofLine)                     ' If The End of Line Not Found, Travel to Target Unknown so Keep Resetting Target Distance
        LeftTarget:=1000
        RightTarget:=1000


  if (LeftTarget==0 or RightTarget==0)  and TargetDistance>0   ' Special Case if at Target 
     
     LeftDist:=0                                               ' Stop both Motors in Case Second is Still in Motion
     RightDist:=0
  
     If MailBox//2==1                                          ' Dump Card with Direction Based Upon Odd or Even Number
        Drive.Move(DumpLeft,800,400,100)                         '      Odd Dump Left
     else
        Drive.Move(DumpRight,800,400,100)                        '      Even Dump Right
                                                            
     waitcnt(clkfreq*7+cnt)                                    ' Pause While Dumping Card
     
     EndofLine:=false                                          ' Reset the End of Line Status to Allow Travel Back to Beginning
     TargetDistance:=0                                         ' Set Target Distance to Zero so Robot Stops at Next End of Line Event 
     LeftTarget:=1000                                          ' Reset Target Distances to Allow Forward Movement
     RightTarget:=1000
     LeftSteps:=Wave
     RightSteps:=Wave
     Drive.Move(Straight,800,1000,100)                           ' Restart Forward Movement
     

  
'------------------ Change Motor Controls Based upon Sensor Readings --------------------------------------------


  if range>5     ' Proceed if No Objects Close

                                 
     Case IRsensor                                         ' Selection Move Based Upon IR Sensor

     
      0:  ' Twist Towards Last Valid Direction if No Line  -----------------------------------------------
          If EndOfLine
            LeftSteps:=Half
            RightSteps:=Half
          Else
             LeftSteps:=Full
             RightSteps:=Full
                    
          TurnCount:=TurnCount+1                                  ' Increment Counter to Measure Turn Angle
                                                                     
          If LastValid==2                                         ' Turn in Direction of Last Valid Turn
              Drive.Move(LeftTwist,300,110*TwistDegTicks,100)             ' If Left then Turn Left         
          Else                                                          
              Drive.Move(RightTwist,300,110*TwistDegTicks,100)            ' If Right then Turn Right

          If TurnCount>450                                        ' Test Counter to Determine if 180 Degress at End of Course
              EndofLine:=true                                            ' If Turn> 120 Degrees Assume the End of Line is True
              BeginFinal:=true                                           ' Begin Final Target Countdown
        
      
          LastValid:=0                                            ' Note This as Last Valid Sensor Reading  
          
      1:  'Turn to the Right, Optional Proportional Rate  ----------------------------------------------------
          If EndOfLine
            LeftSteps:=Half
            RightSteps:=Half
          else
            LeftSteps:=Full
            RightSteps:=Wave
      
          If LastValid==1                                         ' Turn Tighter with Time
            TurnRatio:=TurnRatio-1#>0
          Else
             TurnRatio:=80
        
          Drive.Move(RightCurve,800,30000,TurnRatio)                   ' Proportional Right Turn if Left Sensor Sees a Reflection from the Board
          waitcnt(clkfreq/500+cnt)
          LastValid:=1                                            ' Note This as Last Valid Sensor Reading
       
        
           

      2:  'Turn to the Left, Optional Proportional Rate  ------------------------------------------------------
         If EndOfLine
            LeftSteps:=Half
            RightSteps:=Half
         else
            LeftSteps:=Wave
            RightSteps:=Full
      
         If Lastvalid==2                                          ' Turn Tighter with Time 
            TurnRatio:=TurnRatio-1#>0
         Else
             TurnRatio:=80
        
         Drive.Move(LeftCurve,800,30000,TurnRatio)                     ' Proportional Left Turn if the Right Sensor See a Reflection from the Board                                                                   
         waitcnt(clkfreq/500+cnt) 
         LastValid:=2                                             ' Note This as Last Valid Sensor Reading
        

      3:  'Continue Straight, Set Final Target Distance Just Once if Begin Final if is Needed -------------------


         If EndOfLine
            LeftSteps:=Half
            RightSteps:=Half
         Else
            LeftSteps:=Wave
            RightSteps:=Wave
      
         TurnRatio:=TurnRatio+1<#100
         Drive.Move(Straight,800,3000,100)                            ' Straight Along Line if Both Sensors Don't See a Reflection from the Board
         Lastvalid:=3                                               ' Note This as Last Valid Sensor Reading
         TurnCount:=0                                               ' Clear Turn Counter for Short Turns
         
         
         If EndOfLine 
             If BeginFinal                                          ' If Countdown Started Then Load Distance Once
                LeftTarget:=TargetDistance
                LeftSteps:=half
                RightTarget:=TargetDistance
                RightSteps:=half
                BeginFinal:=false
        
        
      OTHER: ' Other Sensor Readings (e.g. Sensor Overrides) -----------------------------------------------------

      
  Else   ' Stop/Pause for Obstacles if Needed -----------------------------------------------------------------
        
      LeftDist:=0                                                  ' Stop Motors by Setting Distance to Zero     
      RightDist:=0
      Drive.FlashBrakes(LeftPin,RightPin,1,8)                      ' Flash Brakes as an Indicator of an Obstacle

Pub PauseTillDone  '' Wait for Motors to Complete Actions

     repeat                                      ' Loop
         waitcnt(clkfreq/1000+cnt)
     while LeftLock or RightLock or FeedLock     ' While Any of the Motors in Motion



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
 