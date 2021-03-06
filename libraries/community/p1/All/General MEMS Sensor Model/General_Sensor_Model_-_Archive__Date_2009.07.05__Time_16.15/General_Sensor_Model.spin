{{
┌────────────────────────────────┬──────────────────┬────────────────────┐
│ General_Sensor_Model.spin v2.0 │ Author:I.Kövesdi │ Rel.: 05 July 2009 │
├────────────────────────────────┴──────────────────┴────────────────────┤
│                    Copyright (c) 2009 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│  This  menu-driven, datalogging PST application includes three steps of│
│ the make and use of a simple and general mathematical sensor model for │
│ any kind of 3-axis MEMS sensors in embedded applications. The theory   │
│ works well with 3-axis Accelero, Gyro and Magnetic MEMS devices. This  │
│ demo is for the Hitachi H48C 3-axis Accelerometer Moduls. The results  │
│ are the "Proof of Concept" of the method in real practice where the    │
│ original 10% accuracy of the sensors was improved to reach ±1mg (0.2%).│
│  The General Sensor Model contains a real-time Temperature Correction  │
│ procedure, which is excersized here, too. This object uses the uM-FPU  │
│ 3.1 Floating Point Coprocessor, but that feature is not essential for  │
│ the implementation of the General Sensor Model math at lower sensor    │
│ data rates (<100Hz) for a single sensor.                               │
│                                                                        │
│  In this upgrade the System Boot EEPROM on I/O pins 28/29 is used to   │
│ store the data during calibration, parameter calculation and model     │
│ application. This is much more convenient than the manual recording and│
│ data retyping was in the previous versions.                            │  
│                                                                        │
├────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                 │
│  The General Sensor Model contains Bias Compensation, Axis Scale       │
│ Factors, Axis Misalignment and Axis Crosstalk compensation and run-time│
│ Temperature Correction in a compact and simple form. This boiled down  │
│ form is especially well suited for embedded applications with usually  │
│ limited resources. First, Bias is compensated as                       │
│                                                                        │
│                       Value = Raw_Reading - Bias                       │
│                                                                        │
│ for each axis, then an Ellipsoid to Sphere backtransformation is       │
│ applied on the vector of the three values. This linear transformation  │
│ is a simple [3-by-3] matrix [[A]], by which the vector is multiplied.  │
│ In the case of 3-axis magnetometers this General Sensor Model covers   │
│ Hard- and Soft Iron Compensations, too. Finally, temperature correction│
│ is done with a simple scalar multiplication of the spherified data     │
│ vector, from which the distortions have been already removed.          │
│   In summary                                                           │
│                                                                        │
│      [Calibrated vector] = [[A]] * ([Raw Vector] - [Bias Vector])      │
│                                                                        │
│ and the temperature correction factor is calculated on the fly, then   │
│ applied as                                                             │
│                                                                        │
│         [Calibrated vector] = Temp_Corr * [Calibrated vector]          │
│                                                                        │
│  The mathematical background of this simplicity (y=A*(x-b)) is based on│  
│ the observation that the many aforementioned distortion effects to be  │
│ compensated, can be expressed one by one in matrix form. In the General│
│ Sensor Model we directly measure with the calibration the final single │
│ product matrix of those many matrices. In this way we do not have to   │
│ bother with the separate details of formalism beyond those different   │
│ imperfections.                                                         │
│  This object contains the necessary procedure templates to make your   │
│ own application with any 3-axis MEMS sensors. Each following step is   │
│ well separated and commented in the code. With a minimum effort of     │
│ commenting and decommenting, you can taylor the program for the        │
│ particular task with your H48C. For other type of sensors, you have to │
│ use the appropriate drivers and timings.                               │
│                                                                        │
│ Step 1. Acquire steady data for calibration                            │
│ ===========================================                            │
│  Here you can collect acceleration data in several steady poses of the │
│ H48C modul. You do not have at all to strive for exact alignments, but │
│ I recommend to expand a sphere almost uniformly with the measured      │
│ vectors. Some systematic method of axis and pose changes will help a   │           
│ lot to achieve that. I attached picture of the tools I used in the     │
│ calibrations.                                                          │
│  This liberty of the alignments during calibration is especially       │
│ convenient in the tuning of 3-axis magnetometers, since you do not have│   
│ to know where Magnetic North is for the alignments! Again, the point is│
│ to cover the sphere approximately uniformly. Here, of course, you have │
│ to know the 3D magnitude of the Earth's magnetic field at your place. I│
│ used the IGRF-10 and the WMM2005 models to calculate that value for    │
│ Budapest, Hungary. You can find dozens of calculators on the web to get│
│ the average magnitude of B around you.                                 │
│                                                                        │
│  One really important thing:                                           │
│  ---------------------------                                           │
│  You have to collect the static calibration data with stabilized       │
│ electronics and at the same sensor temperature! The "same" means here  │
│ within 1 degree of celsius or better. Disobeying this requirement may  │
│ seriously undermine the quality of your results. The good news are that│
│ after the uniform temperature calibration, precise and full automatic  │
│ temperature correction can be done during the real measurements at the │
│ unpredictable or changing temperatures in the rough and uncontrolled   │
│ field of the application. This automatic temperature correction has of │
│ vital importance for MEMS sensors that are usually more of sensors for │
│ temperature than sensors of the measured physical effect. Even the so  │
│ called "temperature compensated" H48C "accelerates" heavily if you put │
│ your finger on it very carefully. MEMS Gyros are even worst in this    │
│ respect because of their inherently less robust, more complicated and  │
│ more temperature sensitive internal structure then those of the MEMS   │
│ accelerometers with usually simpler design and fabrication.            │
│                                                                        │
│ Step 2. Calculate the parameters of the General Sensor Model           │
│ ============================================================           │
│  The General Sensor Model contains twelve steady parameters. The Bias  │
│ vector adds three ones and the [[A]] matrix contributes with nine.     │
│ These parameters are constant for a particular piece of sensor. To find│
│ these parameters you are provided with a general Least-Squares         │           
│ Parameter optimizer. First you have to enter your correct and double   │
│ checked calibration data into the DAT section.                         │
│   The Least-Squares Parameter Optimizer does its job in two shots. It  │
│ computes preliminary Biases and Scale factors first, then calculates   │
│ the twelve general parameters in the second run, initiating from the   │
│ previous results.                                                      │
│  The evident outliers from the fit (if there are some) usually identify│
│ temperature instability or not stabilized data. Check and correct those│
│ cases, but do not remove valid data because of its somewhat larger     │
│ residual error. Nothing is perfect, including your sensor, and such    │
│ data carries important information, too.                               │                                          │
│                                                                        │  
│ Step 3. Verify the General Sensor Model Calibration                    │
│ ===================================================                    │
│  Hard work is over. Here you have only to see and enjoy the high       │
│ accuracy of the General Sensor Model calibration while noticing the    │
│ beneficial effect of the real-time temperature correction. This        │
│ correction is calculated on the fly during normal operation. The       │
│ previously homogenized scales and axes of the General Sensor Model     │
│ makes this simple first-order temperature correction very effective.   │
│                                                                        │     
├────────────────────────────────────────────────────────────────────────┤
│ Note:                                                                  │
│  In PST check the [10] = Line Feed option in the Preferences/Function  │
│ window.                                                                │
│                                                                        │ 
└────────────────────────────────────────────────────────────────────────┘

Hardware:

Orientation of axes of H48C 3-axis accelerometer module (from above)

    X
    ^   
    │      Y
    │    /
    │   /  
    │  /  /      /  
    │ /  /     o/   White reference mark on module (Pin #1) 
    │/     
    └──────────> X     


    
                 ┌──────────────────────┐
                 │                      │
                 │                 │   
                 │                      │            
     Zero-G  ──│4•    ┌──H48C──┐    •3│──  Vss                                    
                 │      │ y      │      │                   
        CS\  ──│5•    │       │    •2│──  DIO                
                 │      │ └──x  │      │                                       
        Vdd  ──│6•    └────────┘    •1│──  CLK                              
                 │  ┌┐┌┐                │
                 │             │                                         
                 │   └┘                o│  White reference mark on module
                 └──────────────────────┘

          Z axis is pointing towards the reader


Schematics

                                     5V
               ┌──────────────────┐  │  (Note: the pins of the H48C are             
               │                  │  │   directly connected to the Prop's
               │       H48C       │  │   pins, since the module  uses an 
               │                  │  │   on board 3.3V regulator for 
               │                  │  │   signal conditioning.)                                                                     
            ┌──┤GND|3        6|VDD├──┘                                     
            │  │                  │                                             
              │ CS|5 DIO|2 CLK|1 │                                          
           GND └───┬─────┬─────┬──┘     
    │              │     │     │       
    │              │     │     │       
   1├A0────────────┘     │     │       
    │                    │     │
   2├A1──────────────────┘     │
P   │                          │                  5V
8  3├A2────────────────────────┘                  │
X   │                                      10K    │        
3  4├A3───────────────────────────────┳─────────┫
2   │                                 │           │
A  5├A4──────────────────────┐        │           │
    │                        │        │           │ 
   6├A5───────┳─────┐        │        │           │
    │         │     │        │        │           │
              │  ┌──┴────────┴────────┴──┐        │                               
            1K  │SIN|12  SCLK|16 /MCLR|1│        │                  
              │  │                       │        │
              │  │                18|AVDD├────────┫       
              └──┤SOUT|11          14|VDD├────────┘
                 │                       │         
                 │       uM-FPU 3.1      │
                 │                       │                                                                                           
              ┌──┤CS|4                   │         
              ┣──┤SERIN|9                │             
              ┣──┤AVSS|17                │         
              ┣──┤VSS|13                 │         
              │  └───────────────────────┘
             GND

The CS pin of the FPU is tied to LOW to select SPI mode at Reset and must
remain LOW during operation. For this Demo the 2-wire SPI connection was
used, where the SOUT and SIN pins were connected through a 1K resistor and
the DIO pin(6) of the Propeller was connected to the SIN(12) of the FPU.
}}


CON

_CLKMODE = XTAL1 + PLL16X
_XINFREQ = 5_000_000

'--------------------------------Hardware---------------------------------
_H48C_CS     = 0                     'PROP pin to CS pin  of H48C SPI  
_H48C_DIO    = 1                     'PROP pin to DIO pin of H48C SPI
_H48C_CLK    = 2                     'Prop Pin to CLK pin of H48C SPI
_H48C_DWELL  = 6                     'Internal Dwell Line for synchronized
                                     'readings for several sensors. Not
                                     'used here, but we have to specify it
                                     'for the H48_Sync_Driver

_FPU_MCLR    = 3                     'PROP pin to MCLR pin of FPU
_FPU_CLK     = 4                     'PROP pin to SCLK pin of FPU 
_FPU_DIO     = 5                     'PROP pin to SIN(-1K-SOUT) of FPU


'-----------FPU registers for the Acquire Steady Data section-------------
'Low-pass digital filter calculations
_LpA0        = 1
_LpB1        = 2 
_Ax_Xn       = 3 
_Ay_Xn       = 4 
_Az_Xn       = 5 
_Ax_LpYn     = 6 
_Ay_LpYn     = 7 
_Az_LpYn     = 8 
_Ax_LpYnm1   = 9 
_Ay_LpYnm1   = 10
_Az_LpYnm1   = 11
'Magnitude of readings
_Magn        = 12


'-----FPU registers for Least Squares Optimize and Verify sections--------
'G reference
_G_Magn_Ref  = 16                    'Magnitude of local g reference
'Raw data vector                     'H48C readings
_d_x         = 17                   
_d_y         = 18
_d_z         = 19
'Transformed data vector
_td_0        = 20
_td_1        = 21
_td_2        = 22
'Calibration factors
'First round calibration parameters
'Scale factors
_F_x         = 23                    'Scale factor for x axis
_F_y         = 24                    'Scale factor for y axis
_F_z         = 25                    'Scale factor for z axis
'Biases
_B_x         = 26                    'Bias value for x axis
_B_y         = 27                    'Bias value for y axis
_B_z         = 28                    'Bias value for z axis
'Second round calibration parameters
'Ellipsoid to sphere linear transformation matrix
_A_00        = 29
_A_01        = 30
_A_02        = 31
_A_10        = 32
_A_11        = 33
_A_12        = 34
_A_20        = 35
_A_21        = 36
_A_22        = 37
'Optimization steps of calibration parameters
'Steps for first phase scales
_S_F_x       = 38                                                 
_S_F_y       = 39                                                   
_S_F_z       = 40                                                   
'Steps for biases 
_S_B_x       = 41                                                
_S_B_y       = 42                                               
_S_B_z       = 43                                                
'Steps for ellipsoid to sphere backtransformation matrix
_S_A_00      = 44                                                
_S_A_01      = 45
_S_A_02      = 46
_S_A_10      = 47
_S_A_11      = 48
_S_A_12      = 49
_S_A_20      = 50
_S_A_21      = 51
_S_A_22      = 52
'Registers for magnitude calculations
_A2_x        = 53
_A2_y        = 54
_A2_z        = 55
_G_Magn_Raw  = 56     
_G_Magn_Calc = 57
'Registers for temperature compensation
_Sum_Of_Magn = 58
_n_Of_TCSamp = 59
_Aver_Magn   = 60
_Temp_Corr   = 61
'Registers for iteration control
_Error       = 62
_Best_Error  = 63
_Prev_Error  = 64
'Register for the actual number of calibration data points
_N_Of_Pos    = 65
'Maximum of calibration data points
_MAX_POS     = 128


'----------------------------EEPROM Base Addresses------------------------
'_EEPROM_POSE = $7000                       'For 32K 24LS256 Boot EEPROM
'_EEPROM_CALIB = _EEPROM_POSE + $800        'For 32K 24LS256 Boot EEPROM
_EEPROM_POSE  = $8000                      'For 64K 24LS512 Boot EEPROM
_EEPROM_CALIB = _EEPROM_POSE + $1000       'For 64K 24LS512 Boot EEPROM

'Data collection modes
_NEWCOLL     = 0
_APPEND      = 1 

'Temperature compensation parameters
_TC_MARGIN   = 0.25            'Magnitude deviation limit to allow
                               'compensation [m/sec^2]
_TC_TIME     = 8               'Temp. comp. update averaging time [sec]

'Iteration limits of the Least-Squares optimizer
_Eps         = 1.0E-6
_Max_Iter    = 512


OBJ

'UART---------------------------------------------------------------------
PST         : "Parallax Serial Terminal"  'From Parallax Inc.
                                          'v1.0

'Device drivers-----------------------------------------------------------                  
FPU         : "FPU_SPI_Driver"            'v2.0  
H48         : "H48C_Sync_Driver"          'v2.0
SYSEEPROM   : "64K_BootEEPROM_Driver"     'v1.0


VAR

'For the Main Section
LONG     eepr, h48c, fpu3
LONG     cog_ID

'For the Least-Squares Section
LONG     n_Of_Pos  
LONG     aX[_MAX_POS]                   'Arrays of calibration data
LONG     aY[_MAX_POS]
LONG     aZ[_MAX_POS]
LONG     ccount                         'No. of states within Eps 

'For the Verify Calibration section
LONG     max_Of_TCSamp
LONG     n_Of_TCSamp

LONG     cal_Pars[12]



DAT '------------------------Start of SPIN code---------------------------
  
  
PUB DoIt | oK, i, k, np, q                              
'-------------------------------------------------------------------------
'----------------------------------┌──────┐-------------------------------
'----------------------------------│ DoIt │-------------------------------
'----------------------------------└──────┘-------------------------------
'-------------------------------------------------------------------------
''     Action: - Starts driver objects
''             - Makes a MASTER CLEAR of the FPU
''             - Calls pivot procedures of the General Sensor Model
''             - Frees COGs
'' Parameters: None
''     Result: None
''+Reads/Uses: /Hardware constants from CON section
''    +Writes: cog_ID, fpu3, h48c
''      Calls: Parallax Serial Terminal--------->PST.Start
''                                               PST.Str
''                                               PST.Char
''             FPU_SPI_Driver ------------------>FPU.StartCOG
''                                               FPU.StopCOG
''             H48C_SPI_Driver------------------>H48.StartCOG
''                                               H48.StopCOG
''             FPU_Check
''             Acquire_Steady_Data
''             Least_Squares_Optimize
''             Verify_Calibration
''             Measure
'-------------------------------------------------------------------------
'Start Parallax Serial Terminal debug terminal
PST.Start(57600)
  
WAITCNT(6 * CLKFREQ + CNT)
PST.Char(PST#CS)
PST.Str(STRING("General Sensor Model Demo started..."))
PST.Chars(PST#NL, 2) 

WAITCNT(CLKFREQ + CNT)

fpu3 := FALSE  
h48c := FALSE
eepr := FALSE

'Start System EEPROM Driver
eepr := SYSEEPROM.Init
IF (eepr)
  PST.Str(STRING("System Boot EEPROM is present.")) 
ELSE
  PST.Str(STRING("System Boot EEPROM is NOT present!"))
PST.Chars(PST#NL, 2) 
WAITCNT(CLKFREQ + CNT)   

'Start H48C Driver
h48c := H48.StartCOG(_H48C_CS,_H48C_DIO,_H48C_CLK,_H48C_DWELL,@cog_ID)
IF (h48c)
  PST.Str(STRING("H48C Synchron Driver started in COG "))
  PST.Dec(cog_ID)
ELSE
  PST.Str(STRING("H48C Synchron Driver Start failed!"))
PST.Chars(PST#NL, 2) 
WAITCNT(CLKFREQ + CNT)   
  
'FPU Master Clear...
PST.Str(STRING( "FPU MASTER CLEAR", PST#NL, PST#NL))
OUTA[_FPU_MCLR]~~ 
DIRA[_FPU_MCLR]~~
OUTA[_FPU_MCLR]~
WAITCNT(CLKFREQ + CNT)
OUTA[_FPU_MCLR]~~
DIRA[_FPU_MCLR]~

fpu3 := FPU.StartCOG(_FPU_DIO, _FPU_CLK, @cog_ID)

IF fpu3
  PST.Str(STRING("FPU Driver started in COG "))
  PST.Dec(cog_ID)
ELSE
  PST.Str(STRING("FPU Driver Start failed!"))
PST.Chars(PST#NL, 2) 
WAITCNT(CLKFREQ + CNT)     


IF (eepr AND fpu3 AND h48c)           'Everybody is on board, let's start

  FPU_Check
  
  REPEAT
    PST.Char(PST#CS)
    'Main menu loop
    PST.Str(STRING("Select with the keys:"))
    PST.Chars(PST#NL, 2) 
    PST.Str(STRING("   D -------> [D]isplay calibration data collection"))
    PST.Chars(PST#NL, 2)
    PST.Str(STRING("   A -------> [A]ppend new data to collection"))
    PST.Chars(PST#NL, 2)
    PST.Str(STRING("   N -------> [N]ew calibration data collection"))
    PST.Chars(PST#NL, 2)
    PST.Str(STRING("   C -------> [C]alculate calibration parameters"))
    PST.Chars(PST#NL, 2)
    PST.Str(STRING("   P -------> [P]arameters of calibration"))
    PST.Chars(PST#NL, 2)
    PST.Str(STRING("   V -------> [V]erify calibration with LP filter"))
    PST.Chars(PST#NL, 2)
    PST.Str(STRING("   M -------> [M]easure without digital filter"))
    PST.Chars(PST#NL, 2)
    PST.Str(STRING("   Q -------> [Q]uit"))

    REPEAT
      np := FALSE
      'Check for options
      IF PST.RxCount > 0
        k := PST.CharIn | 32
        PST.RxFlush
        
        'PST.Char(PST#NL)
        'PST.DeC(k)
        'WAITCNT(CLKFREQ/4 + CNT)
        
        np := TRUE
        CASE k
          100:
            Display_Stored_Data 
          97:
            Acquire_Steady_Data(10, 3600, _APPEND)
          110:
            Acquire_Steady_Data(10, 3600, _NEWCOLL)
          99:
            Least_Squares_Optimize
          112:
            PST.Char(PST#CS)
            PST.Str(STRING("Calibration Parameters"))
            PST.Chars(PST#NL, 2)
            Load_LinTrans_Pars
            Disp_LinTrans_Pars
            PST.Chars(PST#NL, 2)
            PST.Str(STRING("Press any key to continue...")) 
            PST.RxFlush 
            PST.CharIn            
          118:
            Verify_Calibration(10, 600)
          109:
            Measure(5, 600)
          113:
            q := TRUE
             
      IF (np)
        QUIT

    IF (q)
      QUIT
        
  FPU.StopCOG
  H48.StopCOG
  PST.Chars(PST#NL, 2)
  PST.Str(STRING("General Sensor Model Demo terminated normally..."))
ELSE
  PST.Chars(PST#NL, 2)
  PST.Str(STRING("Some error occured. Check system and try again..."))
  IF fpu3
    FPU.StopCOG
  IF h48c
    H48.StopCOG

WAITCNT(CLKFREQ + CNT)
PST.Stop    
'-------------------------------------------------------------------------    


PRI FPU_Check | oKay, char, strPtr
'-------------------------------------------------------------------------
'-------------------------------┌───────────┐-----------------------------
'-------------------------------│ FPU_Check │-----------------------------
'-------------------------------└───────────┘-----------------------------
'-------------------------------------------------------------------------
'     Action: -Makes a software reset of the FPU
'             -Cheks response to _SYNC command 
' Parameters: None
'     Result: Boolean
'+Reads/Uses: /Some constants from the FPU object
'    +Writes: None
'      Calls: Parallax Serial Terminal->PST.Str
'                                   PST.Dec
'             FPU_SPI_Driver ------>FPU.Reset
'                                   FPU.ReadSyncChar
'                                   FPU.WriteCmd
'                                   FPU.ReadStr
'-------------------------------------------------------------------------
PST.Char(PST#CS)
PST.Str(STRING("Check FPU readiness"))
PST.Chars(PST#NL, 2)
oKay := FPU.Reset

IF okay
  PST.Str(STRING("FPU Software Reset done..."))
  PST.Chars(PST#NL, 2)
ELSE
  PST.Str(STRING("FPU Software Reset failed..."))
  PST.Chars(PST#NL, 2)
  PST.Str(STRING("Please check hardware and restart..."))
  REPEAT                   'Until power-off or reset

WAITCNT(CLKFREQ + CNT)

char := FPU.ReadSyncChar
PST.Str(STRING("Response to _SYNC: "))
PST.Dec(char)
IF (char == FPU#_SYNC_CHAR)
  PST.Str(STRING("      (OK)"))
  PST.Chars(PST#NL, 2)
  WAITCNT(CLKFREQ + CNT)   
ELSE
  PST.Str(STRING("     Not OK!"))   
  PST.Chars(PST#NL, 2)
  PST.Str(STRING("Please check hardware and restart..."))
  
  REPEAT                   'Until power-off or reset
'-------------------------------------------------------------------------


DAT '---------------Start of Acquire Steady data Section------------------


PRI Acquire_Steady_Data(ra,du,mo)|t,dT,n,fLpA0,fLpB1,a1X,a1Y,a1Z,a1T,k,ea
'-------------------------------------------------------------------------
'-------------------------┌─────────────────────┐-------------------------
'-------------------------│ Acquire_Steady_Data │-------------------------
'-------------------------└─────────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: -Reads H48C 3-axis accelerometer module
'             -Applies low-pass filter
'             -Displays filtered data
' Parameters: -Rate in Hz
'             -Duration in seconds
'             -Data collection mode
'                    0=Overwrite
'                    1=Append
'     Result: None
'+Reads/Uses: /CONstants from FPU driver
'    +Writes: None
'      Calls: Parallax Serial Terminal-------->PST.Str
'                                              PST.Dec
'             H48C_SPI_Driver----------------->H48.Read_Acc
'             FPU_SPI_Driver ----------------->FPU.WriteCmd
'                                              FPU.WriteCmdByte
'                                              FPU.WriteCmdFloat
'                                              FPU.Wait
'                                              FPU.ReadReg
'                                              FPU.ReadRaFloatAsStr
'            64_SysEEPROM_Driver-------------->SYSEEPROM.Write 
'-------------------------------------------------------------------------
'Read Number of positions from EEPROM
'Read Number of Positions stored in EEPROM
SYSEEPROM.Read(@n_Of_Pos.BYTE[0], @n_Of_Pos.BYTE[3], _EEPROM_POSE)

IF mo == 0
  n_Of_Pos := 0
  SYSEEPROM.Write(@n_Of_Pos.BYTE[0], @n_Of_Pos.BYTE[3], _EEPROM_POSE) 
  
  
PST.Char(PST#CS)
PST.Str(STRING("Acquiring static Ax, Ay, Az data at "))
PST.Dec(ra)
PST.Str(STRING(" Hz with low-pass filtering."))
PST.Char(PST#NL)
PST.Str(STRING("---------------------------------------"))
PST.Str(STRING("---------------------------"))
PST.Char(PST#NL) 
PST.Str(STRING("Store values after Magnitude stabilized within "))
PST.Str(STRING("±1 for >5 seconds."))   
PST.Chars(PST#NL, 2)

PST.Str(STRING("Select with the keys:"))
PST.Chars(PST#NL, 2)  
PST.Str(STRING("   S -------> [S]tore Current Data into EEPROM"))
PST.Char(PST#NL)
PST.Str(STRING("   R -------> [R]emove Previous Data from EEPROM"))
PST.Char(PST#NL)
PST.Str(STRING("   Q -------> [Q]uit Data Collection"))
PST.Chars(PST#NL, 2)

WAITCNT(CLKFREQ + CNT)

'Parameters for a single pole recursive filter with a -3dB cutoff
'frequency f at 2% of the sample rate can be obtained calculating
'X from the equation
'
'           X = exp{-π*f}
'where  
'           f = 0.02
'Then
'           X = 9.3910137E-1
'
'And the Low-pass filter coefficients
' 
'          A0 = 1 - X        = 6.0898633E-2
'          A1 = 0
'          B1 = X            = 9.3910137E-1
'
'Note that A1 equals zero for the low-pass filter 
'
'High-pass filter coefficients (not used here but for the completness...)
'
'          A0 = (1 + X) / 2  =  9.6955068E-1
'          A1 = -A0          = -9.6955068E-1
'          B1 = X            =  9.3910137E-1
'
'Filtered Y(n) values are calculated from the measured  X(n), X(n-1)
'and from the previously calculated Y(n-1) with the formula
'
'        Y(n) = A0*X(n) + A1*X(n-1) + B1*Y(n-1)
' 
'These digital filters mimic the response of RC analog filters
'     
'        For low-pass                   For high-pass
'
'         ────┳──                    ─────┳── 
'                                               
'                ┴                              ┴        
'
'Set up low-pass filter parameters for X = 9.3910137E-1
fLpA0 :=  6.0898633E-2
fLpB1 :=  9.3910137E-1

'Load them into the FPU
FPU.WriteCmdByte(FPU#_SELECTA, _LpA0)
FPU.WriteCmdFloat(FPU#_FWRITEA, fLpA0)   'Low-pass A0
FPU.WriteCmdByte(FPU#_SELECTA, _LpB1)
FPU.WriteCmdFloat(FPU#_FWRITEA, fLpB1)   'Low-pass B1
  
'Clear Ax_LpYn ... Az_LpYnm1 FPU registers
REPEAT n from 6 to 11                    'Take care of this when you
                                         'change FPU register allocation
  FPU.WriteCmdByte(FPU#_SELECTA, n)           
  FPU.WriteCmd(FPU#_CLRA)

'Display data header
PST.Char(PST#NL)
PST.Str(STRING("     Ax      Ay      Az     Magnitude ", PST#NL))
PST.Str(STRING("=====================================", PST#NL))

'Prepare timing for "rate" Hz measurements for "duration" seconds
n := ra * du
t := CNT
dT := CLKFREQ / ra
      
REPEAT n

  WAITCNT(t + dT)

  'Read acceleration values from H48C
  H48.Read_Acceleration(@a1X, @a1Y, @a1Z, @a1T)

  'Increment WAITCNT delay parameter with dTime  
  t += dT
  
  'Do low-pass digital filtering
  
  'First shift previous  Y(n) values into Y(n-1) registers
  'For LpY values
  FPU.WriteCmdByte(FPU#_SELECTA, _Ax_LpYnm1)                     
  FPU.WriteCmdByte(FPU#_FSET, _Ax_LpYn)        'Ax_LpYnm1=Ax_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Ay_LpYnm1)                       
  FPU.WriteCmdByte(FPU#_FSET, _Ay_LpYn)        'Ay_LpYnm1=Ay_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Az_LpYnm1)                     
  FPU.WriteCmdByte(FPU#_FSET, _Az_LpYn)        'Az_LpYnm1=Az_LpYn
  
  'Load new acceleration readings into FPU and convert them to float 
  FPU.WriteCmdByte(FPU#_SELECTA, _Ax_Xn)
  FPU.WriteCmdLong(FPU#_LWRITEA, a1X)
  FPU.WriteCmd(FPU#_FLOAT)
  FPU.WriteCmdByte(FPU#_SELECTA, _Ay_Xn)
  FPU.WriteCmdLong(FPU#_LWRITEA, a1Y)
  FPU.WriteCmd(FPU#_FLOAT)
  FPU.WriteCmdByte(FPU#_SELECTA, _Az_Xn)
  FPU.WriteCmdLong(FPU#_FWRITEA, a1Z)
  FPU.WriteCmd(FPU#_FLOAT)
    
  'Now apply low-pass filter. I.e. calculate filtered Y(n) values from
  'the measured  X(n) and from the previously calculated Y(n-1)
  'as  LpY(n) = LpA0*X(n) + LpB1*LpY(n-1)
  
  'Ax_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Ax_LpYn)       
  FPU.WriteCmdByte(FPU#_FSET, _Ax_Xn)
  FPU.WriteCmdByte(FPU#_FMUL, _LpA0)           'Ax_LpYn=Ax_Xn*LpA0
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Ax_LpYnm1,_LpB1) 'Ax_LpYn +=Ax_LpYnm1*LpB1  

  'Ay_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Ay_LpYn)
  FPU.WriteCmdByte(FPU#_FSET, _Ay_Xn)
  FPU.WriteCmdByte(FPU#_FMUL, _LpA0)           'Ay_LpYn=Ay_Xn*LpA0
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Ay_LpYnm1,_LpB1) 'Ay_LpYn +=Ay_LpYnm1*LpB1 
  
  'Az_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Az_LpYn)
  FPU.WriteCmdByte(FPU#_FSET, _Az_Xn)
  FPU.WriteCmdByte(FPU#_FMUL, _LpA0)           'Az_LpYn=Az_Xn*LpA0 
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Az_LpYnm1,_LpB1) 'Az_LpYn +=Az_LpYnm1*LpB1 
  
  'Calculate magnitude of data vector
  FPU.WriteCmdByte(FPU#_SELECTA, _Magn)
  FPU.WriteCmdByte(FPU#_FSET, _Ax_LpYn)
  FPU.WriteCmdByte(FPU#_FMUL, _Ax_LpYn)
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Ay_LpYn,_Ay_LpYn)
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Az_LpYn,_Az_LpYn)
  FPU.WriteCmd(FPU#_SQRT)
  
 'Read and display low-pass filtered acceleration readings from the FPU
  FPU.WriteCmdByte(FPU#_SELECTA, _Ax_LpYn)
  PST.Str(FPU.ReadRaFloatAsStr(70))
  PST.Str(STRING(" "))
  FPU.WriteCmdByte(FPU#_SELECTA, _Ay_LpYn)
  PST.Str(FPU.ReadRaFloatAsStr(70))
  PST.Str(STRING(" "))
  FPU.WriteCmdByte(FPU#_SELECTA, _Az_LpYn)
  PST.Str(FPU.ReadRaFloatAsStr(70))
  PST.Str(STRING("  "))
  FPU.WriteCmdByte(FPU#_SELECTA, _Magn)
  PST.Str(FPU.ReadRaFloatAsStr(90))

  'Check for options
  IF PST.RxCount > 0
    k := PST.CharIn | 32
    PST.RxFlush
    CASE k
      115:
        'Read LP filtered acceleration values to store
        FPU.WriteCmdByte(FPU#_SELECTA, _Ax_LpYn)
        FPU.Wait
        FPU.WriteCmd(FPU#_FREADA)
        a1X := FPU.Readreg
        FPU.WriteCmdByte(FPU#_SELECTA, _Ay_LpYn)
        FPU.Wait
        FPU.WriteCmd(FPU#_FREADA) 
        a1Y := FPU.Readreg
        FPU.WriteCmdByte(FPU#_SELECTA, _Az_LpYn)
        FPU.Wait
        FPU.WriteCmd(FPU#_FREADA) 
        a1Z := FPU.Readreg
        'Store calibration values in EEPROM
        'Calculate addresses
        ea := _EEPROM_POSE + 4 + 12 * n_Of_Pos
        'Write Ax
        SYSEEPROM.Write(@a1X.BYTE[0], @a1X.BYTE[3], ea)
        'Write Ay
        SYSEEPROM.Write(@a1Y.BYTE[0], @a1Y.BYTE[3], ea + 4)
        'Write Az
        SYSEEPROM.Write(@a1Z.BYTE[0], @a1Z.BYTE[3], ea + 8)
        'Update Number Of Samples
        n_Of_Pos++
        'Write Number of Samples into EEPROM
        SYSEEPROM.Write(@n_Of_Pos.BYTE[0], @n_Of_Pos.BYTE[3], _EEPROM_POSE)
        PST.Str(STRING("   Pos "))
        PST.Dec(n_Of_Pos)
        PST.Str(STRING(" Stored"))   
        WAITCNT(CLKFREQ / 4 + CNT)
        t := CNT
      114:
        IF (n_Of_Pos>0)
          n_Of_Pos--
          SYSEEPROM.Write(@n_Of_Pos.BYTE[0], @n_Of_Pos.BYTE[3], _EEPROM_POSE)   
      113:
        QUIT
      OTHER:  

  PST.Str(STRING("                 ", PST#NL, PST#MU))   
'-------------------------------------------------------------------------


PRI Display_Stored_Data | n, ea, x, y, z
'-------------------------------------------------------------------------
'-------------------------┌─────────────────────┐-------------------------
'-------------------------│ Display_Stored_Data │-------------------------
'-------------------------└─────────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: -Reads data from EEPROM and displays it
' Parameters: None
'     Result: None
'     +Reads: None
'      +Uses: - _EEPROM_POSE
'             - CONstants from SYSEEPROM,PST drivers
'    +Writes: n_Of_Pos
'      Calls: PST------------------>PST.Str
'                                   PST.Char 
'                                   PST.Dec
'             SYSEEPROM------------>SYSEEPROM.Read
'-------------------------------------------------------------------------

PST.Char(PST#CS)
PST.Str(STRING("EEPROM Data"))
PST.Chars(PST#NL, 2)
'Read Number of Samples stored
SYSEEPROM.Read(@n_Of_Pos.BYTE[0], @n_Of_Pos.BYTE[3], _EEPROM_POSE)
PST.Str(STRING("Number of Stored Samples = "))
PST.DEC(n_Of_Pos)
PST.Chars(PST#NL, 2)
'Display Data
n := 1
REPEAT n_Of_Pos
  IF (n < 10)
    PST.Str(STRING(" "))   
  PST.DEC(n)
  PST.Str(STRING("  "))
  ea := _EEPROM_POSE + 4 + 12 * (n - 1)
  SYSEEPROM.Read(@x.BYTE[0], @x.BYTE[3], ea)
  SYSEEPROM.Read(@y.BYTE[0], @y.BYTE[3], ea + 4)
  SYSEEPROM.Read(@z.BYTE[0], @z.BYTE[3], ea + 8)
  PST.Str(FloatToString(x, 81))
  PST.Str(FloatToString(y, 81))
  PST.Str(FloatToString(z, 81))
  n++
  PST.Char(PST#NL)

PST.Char(PST#NL)
PST.Str(STRING("Press any key to continue..."))
PST.RxFlush
PST.CharIn
'------------------------------------------------------------------------- 


DAT '--------Start of Least-Squares Parameter Optimization Section--------


PRI Initialize_Least_Squares | i, ea, x, y, z
'-------------------------------------------------------------------------
'---------------------┌──────────────────────────┐------------------------
'---------------------│ Initialize_Least_Squares │------------------------
'---------------------└──────────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: From the DAT section data:
'             - Writes magnitude of local reference g into FPU
'             - Writes initial values of parameters into FPU registers
'             - Writes initial values of parameter steps into FPU regs
'             Then
'             - Writes Number of static calibration data into FPU     
'             - Writes static calibration data into HUB/aX,aY,aZ arrays
'             - Calculates initial RMS error
'             - Clears ccount counter                
' Parameters: None
'     Result: None
'+Reads/Uses: -Data from DAT section 
'             -/CONstants from FPU driver
'    +Writes: -FPU registers for data, parameters and steps
'             -HUB/aX,aY,aZ arrays
'      Calls: FPU_SPI_Driver --------------->FPU.WriteCmd
'                                            FPU.WriteCmdByte
'                                            FPU.WriteCmdFloat
'                                            FPU.WriteCmdCntFloat
'                                            FPU.Conv_LONG2FLOAT
'             Calc_Error_ScaleBias
'-------------------------------------------------------------------------
'Load magnitude of local reference g into FPU
FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Ref)
FPU.WriteCmdFloat(FPU#_FWRITEA, g_Magn_Ref)

'Write initial values of parameters into FPU registers
'Number of parameters are 3 + 3 + 9 = 15
FPU.WriteCmdByte(FPU#_SELECTX, _F_x) 
FPU.WriteCmdCntFloats(FPU#_WRBLK, 15, @f_X)

'Write initial values of parameter steps into FPU registers
'Number of parameter steps are 3 + 3 + 9 = 15
FPU.WriteCmdByte(FPU#_SELECTX, _S_F_x) 
FPU.WriteCmdCntFloats(FPU#_WRBLK, 15, @step_Fx)

'Store No of positions into FPU
'Read Number of Positions stored in EEPROM
SYSEEPROM.Read(@n_Of_Pos.BYTE[0], @n_Of_Pos.BYTE[3], _EEPROM_POSE)
FPU.WriteCmdByte(FPU#_SELECTA, _N_Of_Pos)
FPU.WriteCmdLong(FPU#_LWRITEA, n_Of_Pos)
FPU.WriteCmd(FPU#_FLOAT)

'Read static pose acceleration values from EEPROM
REPEAT i FROM 0 TO (n_Of_Pos-1)
  ea := _EEPROM_POSE + 4 + 12 * i 
  SYSEEPROM.Read(@x.BYTE[0], @x.BYTE[3], ea)
  SYSEEPROM.Read(@y.BYTE[0], @y.BYTE[3], ea + 4)
  SYSEEPROM.Read(@z.BYTE[0], @z.BYTE[3], ea + 8)
  aX[i] := x
  aY[i] := y 
  aZ[i] := z

'Calculate so far best (i.e. 1st) Error
Calc_Error_ScaleBias
'Best Error = Prev Error = Error
FPU.WriteCmdByte(FPU#_SELECTA, _Best_Error)  ':Best Error
FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error
FPU.WriteCmdByte(FPU#_SELECTA, _Prev_Error)  ':Prev Error
FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error

ccount~                                      'Clear counter
'-------------------------------------------------------------------------


PRI Least_Squares_Optimize | oKay
'-------------------------------------------------------------------------
'-----------------------┌────────────────────────┐------------------------
'-----------------------│ Least_Squares_Optimize │------------------------
'-----------------------└────────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: -Displays measured g magnitudes before calibration
'             -Calculates Simple Sensor Model parameters for a H48C module
'             -Displays calibrated g magnitudes with this Simple Model
'             -Displays Simple Sensor Model parameters  
'             -Calculates General Sensor Model parameters for H48C module
'             -Displays calibrated g magnitudes with this General Model
'             -Displays General Sensor Model parameters 
' Parameters: None
'     Result: None
'+Reads/Uses: -/CONstants from FPU driver
'             -Some FPU registers
'    +Writes: -Some FPU registers
'      Calls: Parallax Serial Terminal---------->PST.Str
'                                            PST.Char
'             FPU_SPI_Driver --------------->FPU.WriteCmd
'                                            FPU.WriteCmdByte
'                                            FPU.WriteCmdFloat
'                                            FPU.ReadRaFloatAsStr
'             Initialize_Least_Squares
'             Disp_G_ScaleBias
'             Disp_Error_ScaleBias
'             Opt_ScaleBias
'             Disp_ScaleBias_Pars
'             Opt_LinTrans
'             Disp_G_LinTrans
'             Disp_LinTrans_Pars
'-------------------------------------------------------------------------
PST.Char(PST#CS)

Initialize_Least_Squares

PST.Str(STRING("Reference G magnitude = "))
FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Ref)
PST.Str(FPU.ReadRaFloatAsStr(74))
PST.Str(STRING(PST#NL, PST#NL))
WAITCNT(CLKFREQ + CNT)

PST.Str(STRING("G magnitudes before calibration:"))
PST.Chars(PST#NL, 2)
Disp_G_ScaleBias
PST.Chars(PST#NL, 2)
Disp_Error_ScaleBias
WAITCNT(8 * CLKFREQ + CNT)

'First find the Scale and Bias calibration factors to begin with
oKay := Opt_ScaleBias

IF oKay
  PST.Char(PST#CS)
  PST.Str(STRING("G magnitudes after Bias and Scale calibration:"))
  PST.Chars(PST#NL, 2)

  Disp_G_ScaleBias
  PST.Chars(PST#NL, 2)
  Disp_Error_ScaleBias
  WAITCNT(8 * CLKFREQ + CNT)

  PST.Char(PST#CS)
  PST.Str(STRING("Bias and Scale parameters:"))
  PST.Chars(PST#NL, 2)  
  Disp_ScaleBias_Pars
  WAITCNT(8 * CLKFREQ + CNT)  
ELSE
  PST.Char(PST#CS)
  PST.Str(STRING("Bias and Scale iteration did not converged."))
  PST.Chars(PST#NL, 2)  
  REPEAT                         'Until power off or reset

'Now optimize the Ellipsoid to Sphere backtransformation matrix starting
'from the just now detemined Biases and Scales

'Initialize parameters
'Biases remain in their place. Copy scale factors  into the diagonal
'of [[A]] matrix
FPU.WriteCmdByte(FPU#_SELECTA, _A_00)
FPU.WriteCmdByte(FPU#_FSET, _F_x)
FPU.WriteCmdByte(FPU#_SELECTA, _A_11)
FPU.WriteCmdByte(FPU#_FSET, _F_y)
FPU.WriteCmdByte(FPU#_SELECTA, _A_22)
FPU.WriteCmdByte(FPU#_FSET, _F_z)  

Calc_Error_LinTrans
'Best Error = Prev Error = Error
FPU.WriteCmdByte(FPU#_SELECTA, _Best_Error)  ':Best Error
FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error
FPU.WriteCmdByte(FPU#_SELECTA, _Prev_Error)  ':Prev Error
FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error

ccount~                                      'Clear counter

'Get General Sensor model parameters
oKay := Opt_LinTrans

IF oKay
  PST.Char(PST#CS)
  PST.Str(STRING("G magnitudes after Ellipsoid to Sphere "))
  PST.Str(STRING("backtransformation:"))
  PST.Chars(PST#NL, 2)

  Disp_G_LinTrans
  PST.Chars(PST#NL, 2) 
  Disp_Error_LinTrans
  Save_Lintrans_Pars 
  WAITCNT(16 * CLKFREQ + CNT)
  PST.Char(PST#CS)
  PST.Str(STRING("Calibration Parameters:"))
  PST.Chars(PST#NL, 2)
  Load_LinTrans_Pars   
  Disp_Lintrans_Pars  
  WAITCNT(8 * CLKFREQ + CNT) 
ELSE
  PST.Char(PST#CS)
  PST.Str(STRING("Bias and Lin.Transf iteration did not converged."))
  PST.Chars(PST#NL, 2) 
  REPEAT                         'Until power off or reset
'-------------------------------------------------------------------------


PRI Opt_ScaleBias : oKay | i, p, c
'-------------------------------------------------------------------------
'-----------------------------┌───────────────┐---------------------------
'-----------------------------│ Opt_ScaleBias │---------------------------
'-----------------------------└───────────────┘---------------------------
'-------------------------------------------------------------------------
'     Action: Optimizes Scale and Bias calibration parameters for the
'             Simple Sensor Model
' Parameters: None
'     Result: TRUE if converged else FALSE
'+Reads/Uses: - /CONstants from FPU driver
'             - /Raw acceleration readings                   in HUB
'             - /Starting values of calibration parameters   in FPU
'             - /Starting values of Steps                    in FPU
'    +Writes: Scale and Bias Parameters                     in FPU  
'      Calls: Parallax Serial Terminal---------->PST.Str
'                                            PST.Char
'             FPU_SPI_Driver --------------->FPU.WriteCmd
'                                            FPU.WriteCmdByte
'                                            FPU.WriteCmdFloat
'                                            FPU.ReadRaFloatAsStr
'             Impr_Par_ScaleBias
'             Disp_Error_ScaleBias
'             Check_Convergence
'       Note: Optimized Scale and Bias parameters are left in FPU  
'-------------------------------------------------------------------------
i~
c := FALSE   
REPEAT _Max_Iter                                 'Optimization loop

  i++
  
  IF (i > _MAX_ITER)
    QUIT
  
  REPEAT p FROM 1 TO 6                           'Improve all parameters 
    Impr_Par_ScaleBias(p)                        'sequentially

  PST.Char(PST#CS)
  PST.Str(STRING("Optimizing Bias and Scale parameters... "))
  PST.Chars(PST#NL, 2) 
  PST.Str(STRING("Iteration "))
  PST.Dec(i)
  PST.Chars(PST#NL, 2) 
  Disp_Error_ScaleBias
    
  c := Check_Convergence                         'Check convergence

  IF c                                           
    QUIT                                         'Quit if converged
  ELSE
    'Copy Error to Previous Error then repeat optimization loop
    FPU.WriteCmdByte(FPU#_SELECTA, _Prev_Error)  ':Previous Error
    FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error  

    
RETURN c                               'TRUE if converged else FALSE
'-------------------------------------------------------------------------


PRI Opt_LinTrans : oKay | i, p, c
'-------------------------------------------------------------------------
'-----------------------------┌──────────────┐----------------------------
'-----------------------------│ Opt_LinTrans │----------------------------
'-----------------------------└──────────────┘----------------------------
'-------------------------------------------------------------------------
'     Action: Optimizes the Ellipsoid to Sphere linear transformation
'             parameters 
' Parameters: None              
'     Result: TRUE if converged else FALSE 
'+Reads/Uses: - /CONstants from FPU driver
'             - /Raw acceleration readings                   in HUB
'             - /Starting values of calibration parameters   in FPU
'             - /Starting values of Steps                    in FPU
'    +Writes: Bias and LinTrans Parameters                  in FPU
'      Calls: Parallax Serial Terminal---------->PST.Str
'             FPU_SPI_Driver ------------------->FPU.WriteCmd
'                                                FPU.WriteCmdByte
'                                                FPU.WriteCmdFloat
'                                                FPU.ReadRaFloatAsStr
'             Impr_Par_Lintrans
'             Disp_Error_Lintrans
'             Check_Convergence 
'       Note: Optimized Scale and LinTrans parameters are left in FPU       
'-------------------------------------------------------------------------
i~
c := FALSE   
REPEAT _Max_Iter                                 'Optimization loop

  i++
  
  IF (i > _MAX_ITER)
    QUIT
  
  REPEAT p FROM 1 TO 12                         'Improve the parameters 
    Impr_Par_Lintrans(p)                        'sequentially

  PST.Char(PST#CS)
  PST.Str(STRING("2nd Round: Optimizing Ellipsoid to Sphere"))
  PST.Str(STRING(" backtransformation... "))
  PST.Chars(PST#NL, 2) 
  PST.Str(STRING("Iteration "))
  PST.Dec(i)
  PST.Chars(PST#NL, 2) 
  Disp_Error_LinTrans
    
  c := Check_Convergence                         'Check convergence

  IF c                                           
    QUIT                                         'Quit if converged
  ELSE
    'Copy Error to Previous Error then repeat optimization loop
    FPU.WriteCmdByte(FPU#_SELECTA, _Prev_Error)  ':Previous Error
    FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error  

    
RETURN c                               'TRUE if converged else FALSE
'-------------------------------------------------------------------------


PRI Impr_Par_ScaleBias(index) | ip, is, ne, be, t 
'-------------------------------------------------------------------------
'--------------------------┌────────────────────┐-------------------------
'--------------------------│ Impr_Par_ScaleBias │-------------------------
'--------------------------└────────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: Improves a single calibration parameter in two trials for
'             the Simple Sensor Model 
' Parameters: Index of parameter to be improved
'     Result: None  
'+Reads/Uses: /CONstants from FPU driver
'    +Writes: Improved or unchanged calibration parameter in the FPU 
'      Calls: Parallax Serial Terminal---------->PST.Str
'                                                PST.Char
'             FPU_SPI_Driver ------------------->FPU.WriteCmd
'                                                FPU.WriteCmdByte
'                                                FPU.ReadReg
'                                                FPU.Float_GT
'             Calc_Error_ScaleBias
'       Note: Improvement is not always successful. Step is decreased
'             accordingly
'-------------------------------------------------------------------------
'Calculate parameter and step index of FPU registers
ip := _F_x + index - 1
is := _S_F_x + index - 1

'Parameter = Parameter + Step
FPU.WriteCmdByte(FPU#_SELECTA, ip)           ':Parameter
FPU.WriteCmdByte(FPU#_FADD, is)              '=Parameter + Step

'Calculate new Error
Calc_Error_ScaleBias

'Read error values from FPU
FPU.WriteCmdByte(FPU#_SELECTA, _Error)
FPU.Wait 
FPU.WriteCmd(FPU#_FREADA)
ne := FPU.ReadReg

FPU.WriteCmdByte(FPU#_SELECTA, _Best_Error) 
FPU.Wait
FPU.WriteCmd(FPU#_FREADA)
be := FPU.ReadReg

'Compare (actual) Error and Best Error 
'If (Best Error > Error) then 
IF FPU.Float_GT(be, ne, 0.0)
  'I was a succesful trial!
  'Best Error = Error
  FPU.WriteCmdByte(FPU#_SELECTA, _Best_Error)  ':Best Error
  FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error
  'Step = Step * 2
  FPU.WriteCmdByte(FPU#_SELECTA, is)           ':Step
  FPU.WriteCmdByte(FPU#_FMULI, 2)              '=Step*2
ELSE
  'Check the other direction. Parameter = Parameter - 2 * Step
  FPU.WriteCmdByte(FPU#_SELECTA, ip)           ':Parameter
  FPU.WriteCmdByte(FPU#_FSUB, is)              '=Parameter-Step
  FPU.WriteCmdByte(FPU#_FSUB, is)              '=Parameter-Step
  
  'Calculate new Error
  Calc_Error_ScaleBias
  
  'Read error value (Best Error is in "HUB/be" already)
  FPU.WriteCmdByte(FPU#_SELECTA, _Error)
  FPU.Wait 
  FPU.WriteCmd(FPU#_FREADA)
  ne := FPU.ReadReg

  'Compare (actual) Error and Best Error
  'If (Best Error > Error) then
  IF FPU.Float_GT(be, ne, 0.0)
    'Best Error = Error
    FPU.WriteCmdByte(FPU#_SELECTA, _Best_Error)  ':Best Error
    FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error
    'Increase Step size
    FPU.WriteCmdByte(FPU#_SELECTA, is)           ':Step
    FPU.WriteCmdByte(FPU#_FMULI, 2)              '=Step*2
  ELSE
    'Restore original Parameter as trials were not fortunate
    FPU.WriteCmdByte(FPU#_SELECTA, ip)           ':Parameter
    FPU.WriteCmdByte(FPU#_FADD, is)              '=Parameter+Step
    'Decrease Step size
    FPU.WriteCmdByte(FPU#_SELECTA, is)           ':Step
    FPU.WriteCmdByte(FPU#_FDIVI, 2)              '=Step/2    
'-------------------------------------------------------------------------


PRI Impr_Par_LinTrans(index) | ip, is, ne, be, t 
'-------------------------------------------------------------------------
'---------------------------┌───────────────────┐-------------------------
'---------------------------│ Impr_Par_LinTrans │-------------------------
'---------------------------└───────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: Improves a single calibration parameter in two trials using
'             the linear transformation scheme
' Parameters: Index of parameter to be improved
'     Result: None
'+Reads/Uses: /CONstants from FPU driver
'    +Writes: Improved or unchanged calibration parameter in FPU
'      Calls: Parallax Serial Terminal---------->PST.Str
'             FPU_SPI_Driver ------------------->FPU.WriteCmd
'                                                FPU.WriteCmdByte
'                                                FPU.WriteCmdFloat
'                                                FPU.ReadRaFloatAsStr
'             Calc_Error_LinTrans 
'       Note: Improvement is not always successful. Step is decreased 
'             accordingly
'-------------------------------------------------------------------------
'Calculate parameter and step index of FPU registers
ip := _B_x + index - 1
is := _S_B_x + index - 1

'Parameter = Parmeter + Step
FPU.WriteCmdByte(FPU#_SELECTA, ip)           ':Parameter
FPU.WriteCmdByte(FPU#_FADD, is)              '=Parameter + Step

'Calculate new Error
Calc_Error_LinTrans

'Read error values
FPU.WriteCmdByte(FPU#_SELECTA, _Error)
FPU.Wait 
FPU.WriteCmd(FPU#_FREADA)
ne := FPU.ReadReg

FPU.WriteCmdByte(FPU#_SELECTA, _Best_Error) 
FPU.Wait
FPU.WriteCmd(FPU#_FREADA)
be := FPU.ReadReg

'Compare (actual) Error and Best Error 
'If (Best Error > Error) then   
IF FPU.Float_GT(be, ne, 0.0)
  'I was a succesful trial!
  'Best Error = Error
  FPU.WriteCmdByte(FPU#_SELECTA, _Best_Error)  ':Best Error
  FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error
  'Increase Step = Step * 2
  FPU.WriteCmdByte(FPU#_SELECTA, is)           ':Step
  FPU.WriteCmdByte(FPU#_FMULI, 2)              '=Step*2
ELSE
  'Check the other direction. Parameter = Parameter - 2 * Step
  '                           Parameter = Orig.Par. - Step 
  FPU.WriteCmdByte(FPU#_SELECTA, ip)           ':Parameter
  FPU.WriteCmdByte(FPU#_FSUB, is)              '=Parameter-Step
  FPU.WriteCmdByte(FPU#_FSUB, is)              '=Parameter-Step
  
  'Calculate new Error
  Calc_Error_LinTrans 
  
  'Read error value (Best Error is in "HUB/be" already)
  FPU.WriteCmdByte(FPU#_SELECTA, _Error)
  FPU.Wait 
  FPU.WriteCmd(FPU#_FREADA)
  ne := FPU.ReadReg

  'Compare (actual) Error and Best Error 
  'If (Best Error > Error) then
  IF FPU.Float_GT(be, ne, 0.0)
    'It was a succesful trial
    'Best Error = Error
    FPU.WriteCmdByte(FPU#_SELECTA, _Best_Error)  ':Best Error
    FPU.WriteCmdByte(FPU#_FSET, _Error)          '=Error
    'Increase Step = Step * 2        
    FPU.WriteCmdByte(FPU#_SELECTA, is)           ':Step
    FPU.WriteCmdByte(FPU#_FMULI, 2)              '=Step*2
  ELSE
    'Restore original Parameter value as trials were not fortunate
    FPU.WriteCmdByte(FPU#_SELECTA, ip)           ':Parameter
    FPU.WriteCmdByte(FPU#_FADD, is)              '=Parameter+Step
    'Decrease Step size for next round
    FPU.WriteCmdByte(FPU#_SELECTA, is)           ':Step
    FPU.WriteCmdByte(FPU#_FDIVI, 2)              '=Step/2    
'-------------------------------------------------------------------------


PRI Calc_G_ScaleBias(pos) | p
'-------------------------------------------------------------------------
'---------------------------┌──────────────────┐--------------------------
'---------------------------│ Calc_G_ScaleBias │--------------------------
'---------------------------└──────────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Calculates adjusted g value from measured acceleration data
' Parameters: Position index of measurement
'     Result: None
'+Reads/Uses: /CONstants from FPU driver, FPU registers
'    +Writes: Calculated magnitude of g for that position in FPU 
'      Calls: FPU_SPI_Driver --------------->FPU.WriteCmdByte
'                                            FPU.WriteCmdFloat
'                                            FPU.WriteCmd
'-------------------------------------------------------------------------
p := pos - 1
FPU.WriteCmdByte(FPU#_SELECTA, _A2_x)        'Calculate Ax squared
FPU.WriteCmdFloat(FPU#_FWRITEA, aX[p])       '=Ax(Raw Ax count in position)
FPU.WriteCmdByte(FPU#_FSUB, _B_x)            '=Ax - Bx 
FPU.WriteCmdByte(FPU#_FMUL, _F_x)            '=Fx*(Ax - Bx)
FPU.WriteCmdByte(FPU#_FMUL, _A2_x)           '=Fx*(Ax - Bx)*Fx*(Ax - Bx)

FPU.WriteCmdByte(FPU#_SELECTA, _A2_y)        'Calculate Ay squared
FPU.WriteCmdFloat(FPU#_FWRITEA, aY[p])       '=Ay(Raw Ay count in position)
FPU.WriteCmdByte(FPU#_FSUB, _B_y)            '=Ay - By 
FPU.WriteCmdByte(FPU#_FMUL, _F_y)            '=Fy*(Ay - By)
FPU.WriteCmdByte(FPU#_FMUL, _A2_y)           '=Fy*(Ay - By)*Fy*(Ay - By)

FPU.WriteCmdByte(FPU#_SELECTA, _A2_z)        'Calculate Az squared
FPU.WriteCmdFloat(FPU#_FWRITEA, aZ[p])       '=Az(Raw Az count in position)
FPU.WriteCmdByte(FPU#_FSUB, _B_z)            '=Az - Bz 
FPU.WriteCmdByte(FPU#_FMUL, _F_z)            '=Fz*(Az - Bz)
FPU.WriteCmdByte(FPU#_FMUL, _A2_z)           '=Fz*(Az - Bz)*Fz*(Az - Bz)
FPU.WriteCmdByte(FPU#_SELECTA,_G_Magn_Calc)  'Magnitude of calculated g
FPU.WriteCmdByte(FPU#_FSET, _A2_x)           '=Ax2
FPU.WriteCmdByte(FPU#_FADD, _A2_y)           '=Ax2+Ay2
FPU.WriteCmdByte(FPU#_FADD, _A2_z)           '=Ax2+Ay2+Az2
FPU.WriteCmd(FPU#_SQRT)                      '=SQRT(Ax2+Ay2+Az2)
'-------------------------------------------------------------------------


PRI Calc_G_LinTrans(pos) | p
'-------------------------------------------------------------------------
'----------------------------┌─────────────────┐--------------------------
'----------------------------│ Calc_G_LinTrans │--------------------------
'----------------------------└─────────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Calculates adjusted g value from measured acceleration data
' Parameters: Position of measurement
'     Result: None
'+Reads/Uses: /CONstants from FPU driver, FPU registers
'    +Writes: Calculated magnitude of g for that position in FPU register
'      Calls: FPU_SPI_Driver --------------->FPU.WriteCmdByte
'                                            FPU.WriteCmdFloat
'                                            FPU.WriteCmd
'                                            FPU.WriteCmd3Bytes
'       Note: No temperature correction here in the calibration.
'-------------------------------------------------------------------------
p := pos - 1
'Calculate biased reading vector
FPU.WriteCmdByte(FPU#_SELECTA, _d_x)         ':Biased Ax count
FPU.WriteCmdFloat(FPU#_FWRITEA, aX[p])       '=Ax(Raw Ax count in position)
FPU.WriteCmdByte(FPU#_FSUB, _B_x)            '=Ax - Bx

FPU.WriteCmdByte(FPU#_SELECTA, _d_y)         ':Biased Ay count
FPU.WriteCmdFloat(FPU#_FWRITEA, aY[p])       '=Ay(Raw Ay count in position)
FPU.WriteCmdByte(FPU#_FSUB, _B_y)            '=Ay - By

FPU.WriteCmdByte(FPU#_SELECTA, _d_z)         ':Biased Az count
FPU.WriteCmdFloat(FPU#_FWRITEA, aZ[p])       '=Az(Raw Az count in position)
FPU.WriteCmdByte(FPU#_FSUB, _B_z)            '=Az - Bz

'Apply Ellipsoid to Sphere backtransformation
FPU.WriteCmd3Bytes(FPU#_SELECTMA,_td_0,3,1)  'Select MA 
FPU.WriteCmd3Bytes(FPU#_SELECTMB,_A_00,3,3)  'Select MB
FPU.WriteCmd3Bytes(FPU#_SELECTMC,_d_x,3,1)   'Select MC     
FPU.WriteCmdByte(FPU#_MOP,FPU#_MX_MULTIPLY)  'MA=MB*MC 

'Calculate magnitude of calculated g
FPU.WriteCmdByte(FPU#_SELECTA, _A2_x)        ':Ax2
FPU.WriteCmdByte(FPU#_FSET,_td_0)            '=_td_0
FPU.WriteCmdByte(FPU#_FMUL,_td_0)            '=_td_0*_td_0  
FPU.WriteCmdByte(FPU#_SELECTA, _A2_y)        ':Ay2
FPU.WriteCmdByte(FPU#_FSET,_td_1)            '=_td_1  
FPU.WriteCmdByte(FPU#_FMUL,_td_1)            '=_td_1*_td_1  
FPU.WriteCmdByte(FPU#_SELECTA, _A2_z)        ':Az2
FPU.WriteCmdByte(FPU#_FSET,_td_2)            '=_td_2  
FPU.WriteCmdByte(FPU#_FMUL,_td_2)            '=_td_2*_td_2
FPU.WriteCmdByte(FPU#_SELECTA,_G_Magn_Calc)  ':Magnitude of calculated g
FPU.WriteCmdByte(FPU#_FSET, _A2_x)           '=Ax2
FPU.WriteCmdByte(FPU#_FADD, _A2_y)           '=Ax2+Ay2
FPU.WriteCmdByte(FPU#_FADD, _A2_z)           '=Ax2+Ay2+Az2
FPU.WriteCmd(FPU#_SQRT)                      '=SQRT(Ax2+Ay2+Az2)
'-------------------------------------------------------------------------


PRI Calc_Error_ScaleBias | p
'-------------------------------------------------------------------------
'-------------------------┌──────────────────────┐------------------------
'-------------------------│ Calc_Error_ScaleBias │------------------------
'-------------------------└──────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Calculates the RMS error of calculated g magnitudes with the
'             actual calibration parameters of the Simple Sensor Model
' Parameters: None
'     Result: None
'+Reads/Uses: -/CONstants from FPU driver
'             -FPU registers
'    +Writes: FPU registers
'      Calls: FPU_SPI_Driver --------------->FPU.WriteCmdByte
'                                            FPU.WriteCmd
'             Calc_G_ScaleBias
'       Note: RMS error is left in FPU        
'-------------------------------------------------------------------------
FPU.WriteCmdByte(FPU#_SELECTA, _Error)     
FPU.WriteCmd(FPU#_CLRA)                         'Error=0

REPEAT p FROM 1 TO n_Of_Pos
  Calc_G_ScaleBias(p)                           'Calculate magnitude of g
  FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Calc)  ':CalcG
  FPU.WriteCmdByte(FPU#_FSUB, _G_Magn_Ref)      '=CalcG-RefG
  FPU.WriteCmdByte(FPU#_FMUL, _G_Magn_Calc)     '=(CalcG-RefG)^2
  FPU.WriteCmdByte(FPU#_SELECTA, _Error)        ':Error
  FPU.WriteCmdByte(FPU#_FADD, _G_Magn_Calc)     '=Error+(CalcG-RefG)^2

FPU.WriteCmdByte(FPU#_FDIV, _N_Of_Pos)
FPU.WriteCmd(FPU#_SQRT)  
'-------------------------------------------------------------------------


PRI Calc_Error_LinTrans | p
'-------------------------------------------------------------------------
'--------------------------┌─────────────────────┐------------------------
'--------------------------│ Calc_Error_LinTrans │------------------------
'--------------------------└─────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Calculates the RMS error of calculated g magnitudes with the
'             actual calibration parameters of the General Sensor Model
' Parameters: None
'     Result: None
'+Reads/Uses: -CONstants from FPU driver
'             -/FPU registers
'    +Writes: FPU registers
'      Calls: FPU_SPI_Driver --------------->FPU.WriteCmdByte
'                                            FPU.WriteCmd
'             Calc_G_LinTrans
'       Note: RMS error is left in FPU        
'-------------------------------------------------------------------------
FPU.WriteCmdByte(FPU#_SELECTA, _Error)     
FPU.WriteCmd(FPU#_CLRA)                         'Error=0

REPEAT p FROM 1 TO n_Of_Pos
  Calc_G_LinTrans(p)                            'Calculate magnitude of g
  FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Calc)  ':CalcG
  FPU.WriteCmdByte(FPU#_FSUB, _G_Magn_Ref)      '=CalcG-RefG
  FPU.WriteCmdByte(FPU#_FMUL, _G_Magn_Calc)     '=(CalcG-RefG)^2
  FPU.WriteCmdByte(FPU#_SELECTA, _Error)        ':Error
  FPU.WriteCmdByte(FPU#_FADD, _G_Magn_Calc)     '=Error+(CalcG-RefG)^2

FPU.WriteCmdByte(FPU#_FDIV, _N_Of_Pos)
FPU.WriteCmd(FPU#_SQRT)  
'-------------------------------------------------------------------------


PRI Check_Convergence : oK | be, pe, cc
'-------------------------------------------------------------------------
'--------------------------┌───────────────────┐--------------------------
'--------------------------│ Check_Convergence │--------------------------
'--------------------------└───────────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Checks the convergence of the parameter improvement process 
' Parameters: None
'     Result: TRUE if converged else FALSE
'+Reads/Uses: -/FPU regs/CONstants from FPU driver
'             -/HUB/_Best_Error, _Prev_Error
'             -/HUB/ccount
'             -/_Eps  
'    +Writes: None
'      Calls: FPU_SPI_Driver --------------->FPU.WriteCmdByte
'                                            FPU.Wait
'                                            FPU.WriteCmd
'                                            FPU.ReadReg
'                                            FPU.Float_EQ
'       Note: If Best Error is closer to Error then Eps in a series of six
'             contiguos runs then we take the iteration as converged
'-------------------------------------------------------------------------
FPU.WriteCmdByte(FPU#_SELECTA, _Best_Error)
FPU.Wait 
FPU.WriteCmd(FPU#_FREADA)
be := FPU.ReadReg

FPU.WriteCmdByte(FPU#_SELECTA, _Prev_Error) 
FPU.Wait
FPU.WriteCmd(FPU#_FREADA)
pe := FPU.ReadReg

oK := FPU.Float_EQ(pe, be, _Eps)

IF oK  
  ccount++                                  'Increase counter
  IF (ccount>6)
    oK := TRUE
  ELSE
    oK := FALSE
ELSE
  ccount~
         
RETURN oK  
'-------------------------------------------------------------------------


PRI Disp_G_ScaleBias | i, j
'-------------------------------------------------------------------------
'-----------------------------┌──────────────────┐------------------------
'-----------------------------│ Disp_G_ScaleBias │------------------------
'-----------------------------└──────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Displays g magnitudes calculated with Simple Sensor Model  
' Parameters: None
'     Result: None
'+Reads/Uses: -/Some FPU registers
'             -/Some FPU CONstants  
'    +Writes: None
'      Calls: Parallax Serial Terminal---------->PST.Str
'                                                PST.Dec
'                                                PST.Char  
'             FPU_SPI_Driver ------------------->FPU.WriteCmdByte
'                                                FPU.ReadRaFloatAsStr
'             Calc_G_ScaleBias
'-------------------------------------------------------------------------
j~
REPEAT i FROM 1 TO n_Of_pos
  Calc_G_ScaleBias(i)
  j++
  FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Calc)  
  CASE j
    1:
      CASE i
        1..8:
          PST.Str(STRING("G"))
          PST.Dec(i)
          PST.Str(STRING(".."))
          PST.Dec(i + 3)
          PST.Str(STRING(":   "))
          PST.Str(FPU.ReadRaFloatAsStr(74))
          PST.Str(STRING(" "))
        9..12:
          PST.Str(STRING("G"))
          PST.Dec(i)
          PST.Str(STRING(".."))
          PST.Dec(i + 3)
          PST.Str(STRING(":  "))
          PST.Str(FPU.ReadRaFloatAsStr(74))
          PST.Str(STRING(" "))
        OTHER:
          PST.Str(STRING("G"))
          PST.Dec(i)
          PST.Str(STRING(".."))
          PST.Dec(i + 3)
          PST.Str(STRING(": "))
          PST.Str(FPU.ReadRaFloatAsStr(74))
          PST.Str(STRING(" "))  
    2, 3:
      PST.Str(FPU.ReadRaFloatAsStr(74))
      PST.Str(STRING(" "))  
    4:
      PST.Str(FPU.ReadRaFloatAsStr(74))
      PST.Char(PST#NL)
      j~       
'-------------------------------------------------------------------------


PRI Disp_G_LinTrans | i, j
'-------------------------------------------------------------------------
'-----------------------------┌─────────────────┐-------------------------
'-----------------------------│ Disp_G_LinTrans │-------------------------
'-----------------------------└─────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: Displays g magnitudes obtained with the General Sensor Model     
' Parameters: None
'     Result: None
'+Reads/Uses: -/Some FPU registers
'             -/Some FPU constants  
'    +Writes: None
'      Calls: Parallax Serial Terminal---------->PST.Str
'                                                PST.Dec
'                                                PST.Char
'             FPU_SPI_Driver ------------------->FPU.WriteCmdByte
'                                                FPU.ReadRaFloatAsStr
'             Calc_G_LinTrans 
'-------------------------------------------------------------------------
j~
REPEAT i FROM 1 TO n_Of_pos
  Calc_G_LinTrans(i)
  j++
  FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Calc)  
  CASE j
    1:
      CASE i
        1..8:
          PST.Str(STRING("G"))
          PST.Dec(i)
          PST.Str(STRING(".."))
          PST.Dec(i + 3)
          PST.Str(STRING(":   "))
          PST.Str(FPU.ReadRaFloatAsStr(74))
          PST.Str(STRING(" "))
        9..12:
          PST.Str(STRING("G"))
          PST.Dec(i)
          PST.Str(STRING(".."))
          PST.Dec(i + 3)
          PST.Str(STRING(":  "))
          PST.Str(FPU.ReadRaFloatAsStr(74))
          PST.Str(STRING(" "))
        OTHER:
          PST.Str(STRING("G"))
          PST.Dec(i)
          PST.Str(STRING(".."))
          PST.Dec(i + 3)
          PST.Str(STRING(": "))
          PST.Str(FPU.ReadRaFloatAsStr(74))
          PST.Str(STRING(" "))  
    2, 3:
      PST.Str(FPU.ReadRaFloatAsStr(74))
      PST.Str(STRING(" "))  
    4:
      PST.Str(FPU.ReadRaFloatAsStr(74))
      PST.Char(PST#NL)
      j~       
'-------------------------------------------------------------------------


PRI Disp_Error_ScaleBias
'-------------------------------------------------------------------------
'------------------------┌──────────────────────┐-------------------------
'------------------------│ Disp_Error_ScaleBias │-------------------------
'------------------------└──────────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: Displays Standard error: SQRT(sum of squared errors/npoints)
'             calculated with the Simple Sensor Model   
' Parameters: None
'     Result: None
'+Reads/Uses: -/Some FPU registers
'             -/Some FPU constants  
'    +Writes: None
'      Calls: Parallax Serial Terminal---------->PST.Str
'                                                PST.Char
'             FPU_SPI_Driver ------------------->FPU.WriteCmdByte
'                                                FPU.ReadRaFloatAsStr
'             Calc_Error_ScaleBias
'-------------------------------------------------------------------------
Calc_Error_ScaleBias
PST.Str(STRING("Standard Error = "))
FPU.WriteCmdByte(FPU#_SELECTA, _Error)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
'-------------------------------------------------------------------------


PRI Disp_Error_LinTrans
'-------------------------------------------------------------------------
'-------------------------┌─────────────────────┐-------------------------
'-------------------------│ Disp_Error_LinTrans │-------------------------
'-------------------------└─────────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: Displays Standard error: SQRT(sum of squared errors/npoints)
'             calculated with the General Sensor Model    
' Parameters: None
'     Result: None
'+Reads/Uses: -/Some FPU registers
'             -/Some FPU constants  
'    +Writes: None
'      Calls: Parallax Serial Terminal---------->PST.Str
'                                                PST.Char
'             FPU_SPI_Driver ------------------->FPU.WriteCmdByte
'                                                FPU.ReadRaFloatAsStr
'             Calc_Error_LinTrans 
'-------------------------------------------------------------------------
Calc_Error_LinTrans
PST.Str(STRING("Standard Error = "))
FPU.WriteCmdByte(FPU#_SELECTA, _Error)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
'-------------------------------------------------------------------------


PRI Disp_ScaleBias_Pars
'-------------------------------------------------------------------------
'--------------------------┌─────────────────────┐------------------------
'--------------------------│ Disp_ScaleBias_Pars │------------------------
'--------------------------└─────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Displays Scale and Bias calibration parameters for the
'             Simple Sensor model
' Parameters: None
'     Result: None
'+Reads/Uses: -/Some FPU registers
'             -/Some FPU constants
'    +Writes: None
'      Calls: Parallax Serial Terminal---------->PST.Str
'                                                PST.Char   
'             FPU_SPI_Driver ------------------->FPU.WriteCmdByte
'                                                FPU.ReadRaFloatAsStr
'-------------------------------------------------------------------------
PST.Str(STRING("Bx = "))
FPU.WriteCmdByte(FPU#_SELECTA, _B_x)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("By = "))
FPU.WriteCmdByte(FPU#_SELECTA, _B_y)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("Bz = "))
FPU.WriteCmdByte(FPU#_SELECTA, _B_z)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Char(PST#NL)
PST.Str(STRING("Fx = "))
FPU.WriteCmdByte(FPU#_SELECTA, _F_x)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("Fy = "))
FPU.WriteCmdByte(FPU#_SELECTA, _F_y)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("Fz = "))
FPU.WriteCmdByte(FPU#_SELECTA, _F_z)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
'-------------------------------------------------------------------------


PRI Disp_LinTrans_Pars
'-------------------------------------------------------------------------
'----------------------------┌────────────────────┐-----------------------
'----------------------------│ Disp_LinTrans_Pars │-----------------------
'----------------------------└────────────────────┘-----------------------
'-------------------------------------------------------------------------
'     Action: Displays Bias and Ellipsoid to Sphere backtransformation
'             parameters for the General Sensor model   
' Parameters: None
'     Result: None
'+Reads/Uses: -/Some FPU registers
'             -/Some FPU CONstants
'    +Writes: None
'      Calls: Parallax Serial Terminal---------->PST.Str
'                                                PST.Char   
'             FPU_SPI_Driver ------------------->FPU.WriteCmdByte
'                                                FPU.ReadRaFloatAsStr
'-------------------------------------------------------------------------
PST.Str(STRING("Bx = "))
FPU.WriteCmdByte(FPU#_SELECTA, _B_x)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("By = "))
FPU.WriteCmdByte(FPU#_SELECTA, _B_y)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("Bz = "))
FPU.WriteCmdByte(FPU#_SELECTA, _B_z)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Chars(PST#NL, 2)  
PST.Str(STRING("A[1,1] = "))
FPU.WriteCmdByte(FPU#_SELECTA, _A_00)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("A[1,2] = "))
FPU.WriteCmdByte(FPU#_SELECTA, _A_01)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("A[1,3] = "))
FPU.WriteCmdByte(FPU#_SELECTA, _A_02)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("A[2,1] = "))
FPU.WriteCmdByte(FPU#_SELECTA, _A_10)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("A[2,2] = "))
FPU.WriteCmdByte(FPU#_SELECTA, _A_11)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("A[2,3] = "))
FPU.WriteCmdByte(FPU#_SELECTA, _A_12)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("A[3,1] = "))
FPU.WriteCmdByte(FPU#_SELECTA, _A_20)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("A[3,2] = "))
FPU.WriteCmdByte(FPU#_SELECTA, _A_21)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Char(PST#NL)
PST.Str(STRING("A[3,3] = "))
FPU.WriteCmdByte(FPU#_SELECTA, _A_22)
PST.Str(FPU.ReadRaFloatAsStr(0))  
'-------------------------------------------------------------------------


PRI Save_LinTrans_Pars | ea, x, i
'-------------------------------------------------------------------------
'----------------------------┌────────────────────┐-----------------------
'----------------------------│ Save_LinTrans_Pars │-----------------------
'----------------------------└────────────────────┘-----------------------
'-------------------------------------------------------------------------
'     Action: - Reads calibration parameters from FPU
'             - Writes calibration parameters into System EEPROM   
' Parameters: None
'     Result: None
'       Uses: _EEPROM_CALIB
'     +Reads: FPU registers
'    +Writes: - cal_Pars
'             - Sytem EEPROM 
'      Calls: FPU_SPI_Driver --------------->FPU.ReadRegs
'                                            FPU.Reset
'                                            SYSEEPROM.Write
'-------------------------------------------------------------------------
'Read calibration parameters from FPU
FPU.ReadRegs(_B_x, 12, @cal_Pars)
FPU.Reset                        

'Write calibration parameters from HUB into EEPROM
REPEAT i FROM 0 TO 11
  x := cal_Pars[i]
  SYSEEPROM.Write(@x.BYTE[0], @x.BYTE[3], _EEPROM_CALIB + 4 * i)
'-------------------------------------------------------------------------


DAT '----------------Start of Verify Calibration Section------------------


PRI Load_LinTrans_Pars | i, x
'-------------------------------------------------------------------------
'--------------------------┌────────────────────┐-------------------------
'--------------------------│ Load_LinTrans_Pars │-------------------------
'--------------------------└────────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: - Loads magnitude of local  g into FPU
'             - Reads calibration parameter block from EEPROM
'             - Writes calibration parameter block into FPU   
' Parameters: None
'     Result: None
'+Reads/Uses: -DAT/Calibration parameters
'             -/CONstants from FPU driver
'    +Writes: Corresponding FPU registers
'      Calls: FPU_SPI_Driver ---------->FPU.WriteCmdByte  
'                                       FPU.WriteCmdFloat
'             64K_SystemEEPROM_Driver-->SYSEEPROM.Read
'-------------------------------------------------------------------------
'Load magnitude of local reference g into FPU
FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Ref)
FPU.WriteCmdFloat(FPU#_FWRITEA, g_Magn_Ref)

'Read General Sensor Model calibration parameter block from EEPROM
REPEAT i FROM 0 TO 11
  SYSEEPROM.Read(@x.BYTE[0], @x.BYTE[3], _EEPROM_CALIB + 4 * i)
  cal_Pars[i] := x

'Write calibration parameter block into FPU  
FPU.WriteCmdByte(FPU#_SELECTX, _B_x) 
FPU.WriteCmdCntFloats(FPU#_WRBLK, 12, @cal_Pars)
'-------------------------------------------------------------------------


PRI Verify_Calibration(r,d)|time,dTime,n,fLpA0,fLpB1,a1X,a1Y,a1Z,a1T,m,oK
'-------------------------------------------------------------------------
'--------------------------┌────────────────────┐-------------------------
'--------------------------│ Verify_Calibration │-------------------------
'--------------------------└────────────────────┘-------------------------
'-------------------------------------------------------------------------
'     Action: - Loads General Sensor Model's calibration parameters
'             - Prepares real time temperature correction update
'             - Reads H48C 3-axis accelerometer module
'             - Applies General Sensor model to raw data
'             - Updates real-time temperature correction if applicable
'             - Applies low-pass filter to calibrated values
'             - Displays calibrated values
' Parameters: - Rate in Hz
'             - Duration in seconds
'     Result: None
'+Reads/Uses: /CONstants from FPU driver
'    +Writes: None
'      Calls: Parallax Serial Terminal----->PST.Str
'                                           PST.Dec
'                                           PST.Char
'                                           PST.Chars
'                                           PST.RxFlush
'             H48C_SPI_Driver-------------->H48.Read_Acc
'             FPU_SPI_Driver -------------->FPU.WriteCmd
'                                           FPU.WriteCmdByte
'                                           FPU.WriteCmdFloat
'                                           FPU.Float_EQ
'                                           FPU.Wait
'                                           FPU.ReadRaFloatAsStr
'             Load_LinTrans_Pars
'             Disp_Lintrans_Pars
'             Apply_LinTrans
'             Update_TempCorr 
'-------------------------------------------------------------------------
'Load General Sensor Model's calibration parameters
Load_LinTrans_Pars    

'Prepare real time temperature correction
FPU.WriteCmdByte(FPU#_SELECTX, _Sum_Of_Magn)
FPU.WriteCmd(FPU#_CLRX)                    'Clear _Sum_Of_Magn
FPU.WriteCmd(FPU#_CLRX)                    'Clear _n_Of_TCSamp

FPU.WriteCmdByte(FPU#_SELECTA, _Temp_Corr) 'Init correction factor
FPU.WriteCmdFloat(FPU#_FWRITEA, tcorr)

max_Of_TCSamp := r * _TC_TIME
n_Of_TCSamp := 0

PST.Char(PST#CS)
PST.Str(STRING("General Sensor Model parameters read from the"))
PST.Str(STRING(" System Boot EEPROM"))
PST.Chars(PST#NL, 2)  
Disp_LinTrans_Pars
PST.Chars(PST#NL, 2)  
PST.Str(STRING("Temp.Corr. = "))
FPU.WriteCmdByte(FPU#_SELECTA, _Temp_Corr)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Chars(PST#NL, 2)  
PST.Str(STRING("Please, check these to be correct for the "))
PST.Str(STRING("actual H48C sensor."))
WAITCNT(8 * CLKFREQ + CNT)

fLpA0 :=  6.0898633E-2
fLpB1 :=  9.3910137E-1

'Load them into the FPU
FPU.WriteCmdByte(FPU#_SELECTA, _LpA0)
FPU.WriteCmdFloat(FPU#_FWRITEA, fLpA0)   'Low-pass A0
FPU.WriteCmdByte(FPU#_SELECTA, _LpB1)
FPU.WriteCmdFloat(FPU#_FWRITEA, fLpB1)   'Low-pass B1

'Clear Ax_Xn ... Az_LpYnm1 FPU registers
REPEAT n FROM _Ax_Xn TO (_Ax_Xn + 8)
  FPU.WriteCmdByte(FPU#_SELECTA, n)           
  FPU.WriteCmd(FPU#_CLRA)

'Prepare display header
PST.Char(PST#CS)
PST.Str(STRING("Acquiring ==H48C== Ax, Ay, Az data at "))
PST.Dec(r)
PST.Str(STRING(" Hz with low-pass filtering."))
PST.Char(PST#NL)
PST.Str(STRING("---------------------------------------"))
PST.Str(STRING("---------------------------"))
PST.Char(PST#NL) 
PST.Str(STRING("Check Magnitude after it is stabilized within "))
PST.Str(STRING("±0.01 for >5 seconds."))   
PST.Char(PST#NL)

WAITCNT(CLKFREQ + CNT)

'Display data header
PST.Char(PST#NL)
PST.Str(STRING("     Ax      Ay      Az     Magnitude ", PST#NL))
PST.Str(STRING("=====================================", PST#NL))

'Prepare timing for "rate" Hz measurements for "duration" seconds
n := r * d
time := CNT
dTime := CLKFREQ / r
PST.RxFlush
      
REPEAT n

  WAITCNT(time + dTime)

  'Read acceleration values from H48C
  H48.Read_Acceleration(@a1X, @a1Y, @a1Z, @a1T)

  'Increment WAITCNT delay parameter with dTime  
  time += dTime

  'Load raw acceleraton readings into FPU
  FPU.WriteCmdByte(FPU#_SELECTA, _d_x)
  FPU.WriteCmdLong(FPU#_LWRITEA, a1X)
  FPU.WriteCmd(FPU#_FLOAT)
  FPU.WriteCmdByte(FPU#_SELECTA, _d_y)
  FPU.WriteCmdLong(FPU#_LWRITEA, a1Y)
  FPU.WriteCmd(FPU#_FLOAT)
  FPU.WriteCmdByte(FPU#_SELECTA, _d_z)
  FPU.WriteCmdLong(FPU#_FWRITEA, a1Z)
  FPU.WriteCmd(FPU#_FLOAT)

  'Apply Bias, Ellipsoid to Sphere backtransformation and temp. correction
  Apply_LinTrans

  'Update temperature correction factor
  oK := Update_Temp_Corr
                                                   
  'Do low-pass digital filtering------------------------------------------

  'First shift previous  Y(n) values into Y(n-1) registers
  'For LpY values
  FPU.WriteCmdByte(FPU#_SELECTA, _Ax_LpYnm1)                     
  FPU.WriteCmdByte(FPU#_FSET, _Ax_LpYn)        'Ax_LpYnm1=Ax_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Ay_LpYnm1)                       
  FPU.WriteCmdByte(FPU#_FSET, _Ay_LpYn)        'Ay_LpYnm1=Ay_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Az_LpYnm1)                     
  FPU.WriteCmdByte(FPU#_FSET, _Az_LpYn)        'Az_LpYnm1=Az_LpYn
  
  'Load new acceleration components into FPU 
  FPU.WriteCmdByte(FPU#_SELECTA, _Ax_Xn)
  FPU.WriteCmdByte(FPU#_FSET, _td_0)
  FPU.WriteCmdByte(FPU#_SELECTA, _Ay_Xn)
  FPU.WriteCmdByte(FPU#_FSET, _td_1)
  FPU.WriteCmdByte(FPU#_SELECTA, _Az_Xn)
  FPU.WriteCmdByte(FPU#_FSET, _td_2)
      
  'Now apply low-pass filter. I.e. calculate filtered Y(n) values from
  'the measured  X(n) and from the previously calculated Y(n-1)
  'as  LpY(n) = LpA0*X(n) + LpB1*LpY(n-1)
    
   'Ax_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Ax_LpYn)       
  FPU.WriteCmdByte(FPU#_FSET, _Ax_Xn)
  FPU.WriteCmdByte(FPU#_FMUL, _LpA0)           'Ax_LpYn=Ax_Xn*LpA0
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Ax_LpYnm1,_LpB1) 'Ax_LpYn +=Ax_LpYnm1*LpB1  

  'Ay_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Ay_LpYn)
  FPU.WriteCmdByte(FPU#_FSET, _Ay_Xn)
  FPU.WriteCmdByte(FPU#_FMUL, _LpA0)           'Ay_LpYn=Ay_Xn*LpA0
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Ay_LpYnm1,_LpB1) 'Ay_LpYn +=Ay_LpYnm1*LpB1 
  
  'Az_LpYn
  FPU.WriteCmdByte(FPU#_SELECTA, _Az_LpYn)
  FPU.WriteCmdByte(FPU#_FSET, _Az_Xn)
  FPU.WriteCmdByte(FPU#_FMUL, _LpA0)           'Az_LpYn=Az_Xn*LpA0 
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Az_LpYnm1,_LpB1) 'Az_LpYn +=Az_LpYnm1*LpB1 

  'Calculate magnitude of data vector
  FPU.WriteCmdByte(FPU#_SELECTA, _Magn)
  FPU.WriteCmdByte(FPU#_FSET, _Ax_LpYn)
  FPU.WriteCmdByte(FPU#_FMUL, _Ax_LpYn)
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Ay_LpYn,_Ay_LpYn)
  FPU.WriteCmd2Bytes(FPU#_FMAC,_Az_LpYn,_Az_LpYn)
  FPU.WriteCmd(FPU#_SQRT)

 'Read and display low-pass filtered acceleration readings from the FPU
  FPU.WriteCmdByte(FPU#_SELECTA, _Ax_LpYn)
  PST.Str(FPU.ReadRaFloatAsStr(73))
  PST.Str(STRING(" "))
  FPU.WriteCmdByte(FPU#_SELECTA, _Ay_LpYn)
  PST.Str(FPU.ReadRaFloatAsStr(73))
  PST.Str(STRING(" "))
  FPU.WriteCmdByte(FPU#_SELECTA, _Az_LpYn)
  PST.Str(FPU.ReadRaFloatAsStr(73))
  PST.Str(STRING("  "))
  FPU.WriteCmdByte(FPU#_SELECTA, _Magn)  
  PST.Str(FPU.ReadRaFloatAsStr(92))

  IF n_Of_TCSamp > max_Of_TCSamp / 2
    PST.Str(STRING("   Temp.Corr.="))
    FPU.WriteCmdByte(FPU#_SELECTA, _Temp_Corr)
    PST.Str(FPU.ReadRaFloatAsStr(53))
    PST.Str(STRING(" Update is ON"))
  IF NOT oK  
    PST.Str(STRING("   Temp.Corr.="))
    FPU.WriteCmdByte(FPU#_SELECTA, _Temp_Corr)
    PST.Str(FPU.ReadRaFloatAsStr(53))
    PST.Str(STRING("                ", PST#NL, PST#MU))
  ELSE
    PST.Str(STRING(PST#NL, PST#MU))

  IF (PST.RxCount > 0)
    QUIT            
'-------------------------------------------------------------------------


PRI Measure(rate, duration)| time, dTime, n, a1X, a1Y, a1Z, a1T, oK
'-------------------------------------------------------------------------
'--------------------------------┌─────────┐------------------------------
'--------------------------------│ Measure │------------------------------
'--------------------------------└─────────┘------------------------------
'-------------------------------------------------------------------------
'     Action: - Loads General Sensor Model's calibration parameters
'             - Prepares real time temperature correction update
'             - Reads H48C 3-axis accelerometer module
'             - Applies General Sensor model to raw data
'             - Updates real-time temperature correction if applicable
'             - Displays calibrated values
' Parameters: - Rate in Hz
'             - Duration in seconds
'     Result: None
'+Reads/Uses: /CONstants from FPU driver
'    +Writes: None
'      Calls: Parallax Serial Terminal----->PST.Str
'                                           PST.Dec
'                                           PST.Char
'             H48C_SPI_Driver-------------->H48.Read_Acceleration
'             FPU_SPI_Driver -------------->FPU.WriteCmd
'                                           FPU.WriteCmdByte
'                                           FPU.WriteCmdFloat
'                                           FPU.Float_EQ
'                                           FPU.Wait
'                                           FPU.ReadRaFloatAsStr
'             Load_LinTrans_Pars
'             Disp_Lintrans_Pars
'             Apply_LinTrans
'             Update_Temp_Corr 
'-------------------------------------------------------------------------
'Load General Sensor Model's calibration parameters
Load_LinTrans_Pars    

'Prepare real time temperature correction update
FPU.WriteCmdByte(FPU#_SELECTX, _Sum_Of_Magn)
FPU.WriteCmd(FPU#_CLRX)                    'Clear _Sum_Of_Magn
FPU.WriteCmd(FPU#_CLRX)                    'Clear _n_Of_Pos

FPU.WriteCmdByte(FPU#_SELECTA, _Temp_Corr) 'Initialize correction factor
FPU.WriteCmdFloat(FPU#_FWRITEA, 1.0)

max_Of_TCSamp := rate * _TC_TIME
n_Of_TCSamp := 0

PST.Char(PST#CS)
PST.Str(STRING("General Sensor Model parameters read from the"))
PST.Str(STRING(" System EEPROM"))
PST.Chars(PST#NL, 2)  
Disp_LinTrans_Pars
PST.Chars(PST#NL, 2)  
PST.Str(STRING("Temp.Corr. = "))
FPU.WriteCmdByte(FPU#_SELECTA, _Temp_Corr)
PST.Str(FPU.ReadRaFloatAsStr(0))
PST.Chars(PST#NL, 2)  
PST.Str(STRING("Please, check these to be correct for the "))
PST.Str(STRING("actual H48C sensor."))
WAITCNT(8 * CLKFREQ + CNT)

'Prepare display header
PST.Char(PST#CS)
PST.Str(STRING("Acquiring =H48C= Ax, Ay, Az data at "))
PST.Dec(rate)
PST.Str(STRING(" Hz without digital filtering."))
PST.Char(PST#NL)
PST.Str(STRING("---------------------------------------"))
PST.Str(STRING("----------------------------"))
PST.Char(PST#NL) 

WAITCNT(CLKFREQ + CNT)

'Display data header
PST.Char(PST#NL)
PST.Str(STRING("     Ax      Ay      Az     Magnitude ", PST#NL))
PST.Str(STRING("=====================================", PST#NL))

'Prepare timing for "rate" Hz measurements for "duration" seconds
n := rate * duration
time := CNT
dTime := CLKFREQ / rate
PST.RxFlush
      
REPEAT n

  WAITCNT(time + dTime)

  'Read acceleration values from H48C
  H48.Read_Acceleration(@a1X, @a1Y, @a1Z, @a1T)

  'Increment WAITCNT delay parameter with dTime  
  time += dTime

  'Load raw acceleraton readings into FPU
  FPU.WriteCmdByte(FPU#_SELECTA, _d_x)
  FPU.WriteCmdLong(FPU#_LWRITEA, a1X)
  FPU.WriteCmd(FPU#_FLOAT)
  FPU.WriteCmdByte(FPU#_SELECTA, _d_y)
  FPU.WriteCmdLong(FPU#_LWRITEA, a1Y)
  FPU.WriteCmd(FPU#_FLOAT)
  FPU.WriteCmdByte(FPU#_SELECTA, _d_z)
  FPU.WriteCmdLong(FPU#_FWRITEA, a1Z)
  FPU.WriteCmd(FPU#_FLOAT)

  'Apply Bias, Ellipsoid to Sphere backtransformation and temperature
  'correction factor
  Apply_LinTrans

  'Update temperature correction factor
  oK := Update_Temp_Corr
 
  'Display calibrated and unfiltered acceleration readings
  FPU.WriteCmdByte(FPU#_SELECTA, _td_0)
  PST.Str(FPU.ReadRaFloatAsStr(73))
  PST.Str(STRING(" "))
  FPU.WriteCmdByte(FPU#_SELECTA, _td_1)
  PST.Str(FPU.ReadRaFloatAsStr(73))
  PST.Str(STRING(" "))
  FPU.WriteCmdByte(FPU#_SELECTA, _td_2)
  PST.Str(FPU.ReadRaFloatAsStr(73))
  PST.Str(STRING("  "))
  FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Calc)  
  PST.Str(FPU.ReadRaFloatAsStr(92))
  
  IF n_Of_TCSamp > max_Of_TCSamp / 2
    PST.Str(STRING("   Temp.Corr.="))
    FPU.WriteCmdByte(FPU#_SELECTA, _Temp_Corr)
    PST.Str(FPU.ReadRaFloatAsStr(53))
    PST.Str(STRING(" Update is ON"))
  IF NOT oK  
    PST.Str(STRING("   Temp.Corr.="))
    FPU.WriteCmdByte(FPU#_SELECTA, _Temp_Corr)
    PST.Str(FPU.ReadRaFloatAsStr(53))
    PST.Str(STRING("               ", PST#NL, PST#MU))
  ELSE
    PST.Str(STRING(PST#NL, PST#MU))

  IF (PST.RxCount > 0)
    QUIT           
'-------------------------------------------------------------------------


PRI Apply_LinTrans
'-------------------------------------------------------------------------
'-----------------------------┌────────────────┐--------------------------
'-----------------------------│ Apply_LinTrans │--------------------------
'-----------------------------└────────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Calculates General Sensor model calibrated acceleration from 
'             the measured raw H48C readings
' Parameters: None
'     Result: None
'+Reads/Uses: /CONstants from FPU driver, FPU registers
'    +Writes: -Calculated acceleration in FPU registers
'             -Magnitude of calculated acceleration before and after
'             temperature correction in FPU registers
'      Calls: FPU_SPI_Driver --------------->FPU.WriteCmdByte
'                                            FPU.WriteCmd3Bytes
'                                            FPU.WriteCmd
'       Note: Temperature correction factor is applied, too.
'-------------------------------------------------------------------------
'Calculate biased reading vector
FPU.WriteCmdByte(FPU#_SELECTA, _d_x)         ':Biased Ax count
FPU.WriteCmdByte(FPU#_FSUB, _B_x)            '=Ax - Bx

FPU.WriteCmdByte(FPU#_SELECTA, _d_y)         ':Biased Ay count
FPU.WriteCmdByte(FPU#_FSUB, _B_y)            '=Ay - By

FPU.WriteCmdByte(FPU#_SELECTA, _d_z)         ':Biased Az count
FPU.WriteCmdByte(FPU#_FSUB, _B_z)            '=Az - Bz

'Apply Ellipsoid to Sphere backtransformation
FPU.WriteCmd3Bytes(FPU#_SELECTMA,_td_0,3,1)  'Select MA 
FPU.WriteCmd3Bytes(FPU#_SELECTMB,_A_00,3,3)  'Select MB
FPU.WriteCmd3Bytes(FPU#_SELECTMC,_d_x,3,1)   'Select MC     
FPU.WriteCmdByte(FPU#_MOP,FPU#_MX_MULTIPLY)  'MA=MB*MC

'Calculate magnitude of calibrated but not temperature corrected
'acceleration
FPU.WriteCmdByte(FPU#_SELECTA, _A2_x)        ':Ax2
FPU.WriteCmdByte(FPU#_FSET, _td_0)           '=_td_0
FPU.WriteCmdByte(FPU#_FMUL, _td_0)           '=_td_0*_td_0  
FPU.WriteCmdByte(FPU#_SELECTA, _A2_y)        ':Ay2
FPU.WriteCmdByte(FPU#_FSET, _td_1)           '=_td_1  
FPU.WriteCmdByte(FPU#_FMUL, _td_1)           '=_td_1*_td_1  
FPU.WriteCmdByte(FPU#_SELECTA, _A2_z)        ':Az2
FPU.WriteCmdByte(FPU#_FSET, _td_2)           '=_td_2  
FPU.WriteCmdByte(FPU#_FMUL, _td_2)           '=_td_2*_td_2
FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Raw)  ':Magnitude of raw g
FPU.WriteCmdByte(FPU#_FSET, _A2_x)           '=Ax2
FPU.WriteCmdByte(FPU#_FADD, _A2_y)           '=Ax2+Ay2
FPU.WriteCmdByte(FPU#_FADD, _A2_z)           '=Ax2+Ay2+Az2
FPU.WriteCmd(FPU#_SQRT)                      '=SQRT(Ax2+Ay2+Az2)

'Apply temperature correction
FPU.WriteCmdByte(FPU#_LOAD, _Temp_Corr)      'Reg[0]=Reg[_Temp_Corr]
FPU.WriteCmdByte(FPU#_MOP,FPU#_SCALAR_MUL)   'MA=tc*MA

'Calculate magnitude of General Sensor Model acceleration with temp. corr.
FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Calc) ': _G_Magn_Calc
FPU.WriteCmdByte(FPU#_FSET, _G_Magn_Raw)     '=_G_Magn_Raw
FPU.WriteCmdByte(FPU#_FMUL, _Temp_Corr)      '=_G_Magn_Raw * _Temp_Corr
'-------------------------------------------------------------------------


PRI Update_Temp_Corr : oK | m
'-------------------------------------------------------------------------
'---------------------------┌─────────────────┐---------------------------
'---------------------------│ Update_Temp_Corr│---------------------------
'---------------------------└─────────────────┘---------------------------
'-------------------------------------------------------------------------
'     Action: Updates temperature correction factor when steady and near g
'             acceleration detected
' Parameters: None
'     Result: TRUE if update is in progress else FALSE
'+Reads/Uses: -/CONstants from FPU driver, FPU registers
'             -CONstants from HUB: _TC_MARGIN
'             -max_Of_Samp global variable 
'    +Writes: n_Of_Pos   global variable 
'      Calls: FPU_SPI_Driver --------------->FPU.WriteCmdByte
'                                            FPU.Wait 
'                                            FPU.Float_EQ
'       Note: -A simple multiplicative temperature correction factor is
'             calculated. Since the sensor's readings are bias corrected
'             and the axes are orthogonalized and the scales are
'             homogenized with the Ellipsoid to Sphere backtransformation,
'             this first order temperature correction is equally effective
'             for all axes.
'             -The _TC_MARGIN and _TC_TIME parameters can be adjusted for
'             a given application.
'-------------------------------------------------------------------------
'Check not corrected magnitude--------------------------------------------
FPU.WriteCmdByte(FPU#_SELECTA, _G_Magn_Raw)
FPU.Wait 
FPU.WriteCmd(FPU#_FREADA)
m := FPU.ReadReg
oK := FPU.Float_EQ(m, g_Magn_Ref, _TC_MARGIN)

'Check steady direction---------------------------------------------------
'This is not yet implemented. It will detect slow turns with large radius
'and will switch off temperature compensation update in that case, too.
'Idea behind the algorithm: Long term average of scalar product with some
'previous (e.g. 20 msec before) vector should be very close to 1 in linear
'steady state of motion. In turn not, since the direction of acceleration
'changes continuously during that period.    

IF oK
  'Then close to steady state: Do magnitude averaging
  FPU.WriteCmdByte(FPU#_SELECTA, _Sum_Of_Magn)
  FPU.WriteCmdByte(FPU#_FADD, _G_Magn_Raw)
  FPU.WriteCmdByte(FPU#_SELECTA, _n_Of_TCSamp)
  FPU.WriteCmdByte(FPU#_FADDI, 1)
  n_Of_TCSamp++
  IF n_Of_TCSamp => max_Of_TCSamp
    'Update temperature correction factor
    'Calculate average magnitude
    FPU.WriteCmdByte(FPU#_SELECTA, _Aver_Magn) 
    FPU.WriteCmdByte(FPU#_FSET, _Sum_Of_Magn)
    FPU.WriteCmdByte(FPU#_FDIV,_n_Of_TCSamp)
    'Calculate new temperature correction factor
    FPU.WriteCmdByte(FPU#_SELECTA, _Temp_Corr)
    FPU.WriteCmdByte(FPU#_FSET, _G_Magn_Ref)
    FPU.WriteCmdByte(FPU#_FDIV, _Aver_Magn)
    'Prepare next averaging round
    n_Of_TCSamp~                               'Clear HUB/n_Of_TCSamp
    FPU.WriteCmdByte(FPU#_SELECTX,_Sum_Of_Magn)
    FPU.WriteCmd(FPU#_CLRX)                    'Clear FPU/_Sum_Of_Magn
    FPU.WriteCmd(FPU#_CLRX)                    'Clear FPU/_n_Of_TCSamp
ELSE
  'Reset averaging, as dynamic motion detected. During that period the
  'General Sensor Model will use the last actual temp. corr. factor 
  n_Of_TCSamp~                                 'Clear HUB/n_Of_TCSamp
  FPU.WriteCmdByte(FPU#_SELECTX, _Sum_Of_Magn)
  FPU.WriteCmd(FPU#_CLRX)                      'Clear FPU/_Sum_Of_Magn
  FPU.WriteCmd(FPU#_CLRX)                      'Clear FPU/_n_Of_TCSamp

RETURN oK  
'-------------------------------------------------------------------------                                                   


DAT 'Utilities  


PRI FloatToString(floatV, format)
'-------------------------------------------------------------------------
'-----------------------------┌───────────────┐---------------------------
'-----------------------------│ FloatToString │---------------------------
'-----------------------------└───────────────┘---------------------------
'-------------------------------------------------------------------------
'     Action: Converts a HUB/floatV into string within FPU then loads it
'             back into HUB
' Parameters: -Float value
'             -Format code in FPU convention
'    Results: Pointer to string in HUB
'+Reads/Uses: FPUMAT#_FWRITE, FPUMAT#_SELECTA 
'    +Writes: FPU Reg: 127
'      Calls: FPU_Matrix_Driver------->FPUMAT.WriteCmdByte 
'                                      FPUMAT.WriteCmdFloat
'                                      FPUMAT.ReadRaFloatAsStr
'       Note: For debug and test purposes
'-------------------------------------------------------------------------
FPU.WriteCmdByte(FPU#_SELECTA, 127)
FPU.WriteCmdFloat(FPU#_FWRITEA, floatV)
RESULT := FPU.ReadRaFloatAsStr(format) 
'-------------------------------------------------------------------------


DAT '--------------------Reference g value in [m/s2]----------------------

g_Magn_Ref LONG   9.806  'You have to enter the magnitude of g in  your
                         'location. For a simple and good approximation
                         'look in the last sections of the attached PDF
                         'document. This value is for Budapest/Hungary


DAT'---------------------Inital values of parameters----------------------
'They are adjusted for H48C readings, so you can leave them as they are

'------------------Initial values of scale parameters---------------------
f_X        LONG   7.1E-3
f_Y        LONG   7.1E-3
f_Z        LONG   7.1E-3
'-------------------Initial values of bias parameters---------------------
b_X        LONG   0.0
b_Y        LONG   0.0
b_Z        LONG   0.0
'-------------Initial values for linear transformation matrix-------------
a_00       LONG   7.1E-3 
a_01       LONG   0.0
a_02       LONG   0.0
a_10       LONG   0.0
a_11       LONG   7.1E-3 
a_12       LONG   0.0
a_20       LONG   0.0
a_21       LONG   0.0
a_22       LONG   7.1E-3 


DAT '-----------------Initial values of parameter steps-------------------
'They are adjusted for H48C readings, so you can leave them as they are
  
'------------------Initial steps for scale parameters--------------------- 
step_Fx    LONG   1.0E-5
step_Fy    LONG   1.0E-5
step_Fz    LONG   1.0E-5
'-------------------Initial steps for bias parameters---------------------
step_Bx    LONG   10.0
step_By    LONG   10.0
step_Bz    LONG   10.0
'--------------Initial steps for linear transformation matrix-------------
step_a_00  LONG   1.0E-6
step_a_01  LONG   1.0E-6
step_a_02  LONG   1.0E-6
step_a_10  LONG   1.0E-6
step_a_11  LONG   1.0E-6   
step_a_12  LONG   1.0E-6
step_a_20  LONG   1.0E-6
step_a_21  LONG   1.0E-6
step_a_22  LONG   1.0E-6


'Initial value of the temperature correction factor. Program will adjust
'it later during measurements between somewhere 0.98 and 1.02. Tipical
'value was 0.997 at 28 C application after a 24 C calibration.
tcorr      LONG   1.0


DAT '---------------------------MIT License-------------------------------

{{

┌────────────────────────────────────────────────────────────────────────┐
│                        TERMS OF USE: MIT License                       │                                                            
├────────────────────────────────────────────────────────────────────────┤
│  Permission is hereby granted, free of charge, to any person obtaining │
│ a copy of this software and associated documentation files (the        │ 
│ "Software"), to deal in the Software without restriction, including    │
│ without limitation the rights to use, copy, modify, merge, publish,    │
│ distribute, sublicense, and/or sell copies of the Software, and to     │
│ permit persons to whom the Software is furnished to do so, subject to  │
│ the following conditions:                                              │
│                                                                        │
│  The above copyright notice and this permission notice shall be        │
│ included in all copies or substantial portions of the Software.        │  
│                                                                        │
│  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND        │
│ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     │
│ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. │
│ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   │
│ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   │
│ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      │
│ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 │
└────────────────────────────────────────────────────────────────────────┘
}}                  