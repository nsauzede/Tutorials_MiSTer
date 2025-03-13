# SPI sequence
STATE_Whoami => STATE_Whoami_Wait => STATE_Init
0x8f00          RnW=1   MnS=0   16      =>      0x0f    R WHO_AM_I      =>      0x33
STATE_Init => STATE_Init_Wait => STATE_Init1
0x2077          RnW=0   MnS=0   16      =>      0x20    W CTRL_REG1     <=      0x77
STATE_Init1 => STATE_Init1_Wait => STATE_Init2
0x1fc0          RnW=0   MnS=0   16      =>      0x1f    W TEMP_CFG_REG  <=      0xc0
STATE_Init2 => STATE_Init2_Wait => STATE_Read
0x2388          RnW=0   MnS=0   16      =>      0x23    W CTRL_REG4     <=      0x88
STATE_Read => STATE_Read_Wait => STATE_LEDout
0xe80000        RnW=1   MnS=1   24      =>      0x28    R OUT_X_L       =>      0x009a
...
