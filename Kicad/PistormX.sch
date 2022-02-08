EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Pistorm'X"
Date "2021-07-27"
Rev "0.1"
Comp "FLACO"
Comment1 "Pistorm adapter board with Xilinx CPLD"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 10000 1450 0    50   ~ 0
Pi : 24 I/O + 4 prog\n\nSD0-15\nSA0-2\nAUX0-1\nPICLK\nTDI TDO TCK TMS *\nSOE\nSWE
Text Notes 7450 2350 0    50   ~ 0
68000 : 54 I/O + 1 BERR + 3 FC + 3 bus control\nD0-15\nA1-23\nAS\nR/W\nUDS LDS\nDTACK\nRESET\nHALT\nE\nCLK\nIPL0-2\nVPA\nVMA\nBR BG BGACK *\nFC0-2 *\nBERR *\n \n\nBGACK need pullup for Gary
Text Notes 10000 2150 0    50   ~ 0
TQFP 100 = 81 IO pins
$Comp
L CPLD_Xilinx:XC95144XL-TQ100 U1
U 1 1 60F383C9
P 5700 4350
F 0 "U1" H 4950 7000 50  0000 C CNN
F 1 "XC95144XL-TQ100" H 4950 6900 50  0000 C CNN
F 2 "Package_QFP:TQFP-100_14x14mm_P0.5mm" H 5700 4350 50  0001 C CNN
F 3 "https://www.xilinx.com/support/documentation/data_sheets/ds056.pdf" H 5700 4350 50  0001 C CNN
	1    5700 4350
	1    0    0    -1  
$EndComp
$Comp
L Regulator_Linear:SPX3819M5-L-3-3 U2
U 1 1 60F48358
P 1800 950
F 0 "U2" H 1800 1292 50  0000 C CNN
F 1 "SPX3819M5-L-3-3" H 1800 1201 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 1800 1275 50  0001 C CNN
F 3 "https://www.exar.com/content/document.ashx?id=22106&languageid=1033&type=Datasheet&partnumber=SPX3819&filename=SPX3819.pdf&part=SPX3819" H 1800 950 50  0001 C CNN
	1    1800 950 
	1    0    0    -1  
$EndComp
$Comp
L Regulator_Linear:XC6206PxxxMR U3
U 1 1 60F4B22F
P 3350 850
F 0 "U3" H 3350 1092 50  0000 C CNN
F 1 "XC6206PxxxMR" H 3350 1001 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23" H 3350 1075 50  0001 C CIN
F 3 "https://www.torexsemi.com/file/xc6206/XC6206.pdf" H 3350 850 50  0001 C CNN
	1    3350 850 
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C1
U 1 1 60F4C4CC
P 1150 950
F 0 "C1" H 1242 996 50  0000 L CNN
F 1 "10u" H 1242 905 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 1150 950 50  0001 C CNN
F 3 "~" H 1150 950 50  0001 C CNN
	1    1150 950 
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C2
U 1 1 60F4DE58
P 2350 950
F 0 "C2" H 2442 996 50  0000 L CNN
F 1 "10u" H 2442 905 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 2350 950 50  0001 C CNN
F 3 "~" H 2350 950 50  0001 C CNN
	1    2350 950 
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0101
U 1 1 60F5016B
P 1150 850
F 0 "#PWR0101" H 1150 700 50  0001 C CNN
F 1 "+5V" H 1165 1023 50  0000 C CNN
F 2 "" H 1150 850 50  0001 C CNN
F 3 "" H 1150 850 50  0001 C CNN
	1    1150 850 
	1    0    0    -1  
$EndComp
Wire Wire Line
	1500 850  1150 850 
Connection ~ 1150 850 
Wire Wire Line
	2100 850  2350 850 
$Comp
L power:+3.3V #PWR0102
U 1 1 60F51142
P 2350 850
F 0 "#PWR0102" H 2350 700 50  0001 C CNN
F 1 "+3.3V" H 2365 1023 50  0000 C CNN
F 2 "" H 2350 850 50  0001 C CNN
F 3 "" H 2350 850 50  0001 C CNN
	1    2350 850 
	1    0    0    -1  
$EndComp
Connection ~ 2350 850 
$Comp
L power:GND #PWR0103
U 1 1 60F51860
P 1150 1250
F 0 "#PWR0103" H 1150 1000 50  0001 C CNN
F 1 "GND" H 1155 1077 50  0000 C CNN
F 2 "" H 1150 1250 50  0001 C CNN
F 3 "" H 1150 1250 50  0001 C CNN
	1    1150 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	2350 1050 2350 1250
Wire Wire Line
	2350 1250 1800 1250
Connection ~ 1800 1250
Wire Wire Line
	1800 1250 1150 1250
Wire Wire Line
	1150 1250 1150 1050
Wire Wire Line
	1500 950  1500 850 
Connection ~ 1500 850 
NoConn ~ 2100 950 
Connection ~ 1150 1250
$Comp
L power:+3.3V #PWR0104
U 1 1 60F5891B
P 3800 850
F 0 "#PWR0104" H 3800 700 50  0001 C CNN
F 1 "+3.3V" H 3815 1023 50  0000 C CNN
F 2 "" H 3800 850 50  0001 C CNN
F 3 "" H 3800 850 50  0001 C CNN
	1    3800 850 
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0105
U 1 1 60F592DD
P 2900 850
F 0 "#PWR0105" H 2900 700 50  0001 C CNN
F 1 "+5V" H 2915 1023 50  0000 C CNN
F 2 "" H 2900 850 50  0001 C CNN
F 3 "" H 2900 850 50  0001 C CNN
	1    2900 850 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0106
U 1 1 60F5989D
P 3350 1150
F 0 "#PWR0106" H 3350 900 50  0001 C CNN
F 1 "GND" H 3355 977 50  0000 C CNN
F 2 "" H 3350 1150 50  0001 C CNN
F 3 "" H 3350 1150 50  0001 C CNN
	1    3350 1150
	1    0    0    -1  
$EndComp
Wire Wire Line
	3650 850  3800 850 
Wire Wire Line
	2900 850  3050 850 
Text Notes 2950 1450 0    50   ~ 0
alternative footprint
$Comp
L power:+3.3V #PWR0107
U 1 1 60F5C93E
P 5400 1650
F 0 "#PWR0107" H 5400 1500 50  0001 C CNN
F 1 "+3.3V" H 5415 1823 50  0000 C CNN
F 2 "" H 5400 1650 50  0001 C CNN
F 3 "" H 5400 1650 50  0001 C CNN
	1    5400 1650
	1    0    0    -1  
$EndComp
Wire Wire Line
	6000 1650 5900 1650
Connection ~ 5400 1650
Connection ~ 5500 1650
Wire Wire Line
	5500 1650 5400 1650
Connection ~ 5600 1650
Wire Wire Line
	5600 1650 5500 1650
Connection ~ 5700 1650
Wire Wire Line
	5700 1650 5600 1650
Connection ~ 5800 1650
Wire Wire Line
	5800 1650 5700 1650
Connection ~ 5900 1650
Wire Wire Line
	5900 1650 5800 1650
$Comp
L power:GND #PWR0108
U 1 1 60F5D7F9
P 5400 7050
F 0 "#PWR0108" H 5400 6800 50  0001 C CNN
F 1 "GND" H 5405 6877 50  0000 C CNN
F 2 "" H 5400 7050 50  0001 C CNN
F 3 "" H 5400 7050 50  0001 C CNN
	1    5400 7050
	1    0    0    -1  
$EndComp
Wire Wire Line
	6100 7050 6000 7050
Connection ~ 5400 7050
Connection ~ 5500 7050
Wire Wire Line
	5500 7050 5400 7050
Connection ~ 5600 7050
Wire Wire Line
	5600 7050 5500 7050
Connection ~ 5700 7050
Wire Wire Line
	5700 7050 5600 7050
Connection ~ 5800 7050
Wire Wire Line
	5800 7050 5700 7050
Connection ~ 5900 7050
Wire Wire Line
	5900 7050 5800 7050
Connection ~ 6000 7050
Wire Wire Line
	6000 7050 5900 7050
$Comp
L power:GND #PWR0109
U 1 1 60F63025
P 2500 6750
F 0 "#PWR0109" H 2500 6500 50  0001 C CNN
F 1 "GND" H 2505 6577 50  0000 C CNN
F 2 "" H 2500 6750 50  0001 C CNN
F 3 "" H 2500 6750 50  0001 C CNN
	1    2500 6750
	1    0    0    -1  
$EndComp
Wire Wire Line
	2600 6750 2500 6750
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 60F63FBD
P 2600 6750
F 0 "#FLG0101" H 2600 6825 50  0001 C CNN
F 1 "PWR_FLAG" V 2600 6878 50  0000 L CNN
F 2 "" H 2600 6750 50  0001 C CNN
F 3 "~" H 2600 6750 50  0001 C CNN
	1    2600 6750
	0    1    1    0   
$EndComp
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 60F67F88
P 2600 1950
F 0 "#FLG0102" H 2600 2025 50  0001 C CNN
F 1 "PWR_FLAG" V 2600 2078 50  0000 L CNN
F 2 "" H 2600 1950 50  0001 C CNN
F 3 "~" H 2600 1950 50  0001 C CNN
	1    2600 1950
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0110
U 1 1 60F6975B
P 2500 1950
F 0 "#PWR0110" H 2500 1800 50  0001 C CNN
F 1 "+5V" H 2515 2123 50  0000 C CNN
F 2 "" H 2500 1950 50  0001 C CNN
F 3 "" H 2500 1950 50  0001 C CNN
	1    2500 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	2600 1950 2500 1950
Text Label 3500 2150 0    50   ~ 0
A1
Text Label 3500 2250 0    50   ~ 0
A2
Text Label 3500 2350 0    50   ~ 0
A3
Text Label 3500 2450 0    50   ~ 0
A4
Text Label 3500 2550 0    50   ~ 0
A5
Text Label 3500 2650 0    50   ~ 0
A6
Text Label 3500 2750 0    50   ~ 0
A7
Text Label 3500 2850 0    50   ~ 0
A8
Text Label 3500 2950 0    50   ~ 0
A9
Text Label 3500 3050 0    50   ~ 0
A10
Text Label 3500 3150 0    50   ~ 0
A11
Text Label 3500 3250 0    50   ~ 0
A12
Text Label 3500 3350 0    50   ~ 0
A13
Text Label 3500 3450 0    50   ~ 0
A14
Text Label 3500 3550 0    50   ~ 0
A15
Text Label 3500 3650 0    50   ~ 0
A16
Text Label 3500 3750 0    50   ~ 0
A17
Text Label 3500 3850 0    50   ~ 0
A18
Text Label 3500 3950 0    50   ~ 0
A19
Text Label 3500 4050 0    50   ~ 0
A20
Text Label 3500 4150 0    50   ~ 0
A21
Text Label 3500 4250 0    50   ~ 0
A22
Text Label 3500 4350 0    50   ~ 0
A23
Text Label 3500 4550 0    50   ~ 0
D0
Text Label 3500 4650 0    50   ~ 0
D1
Text Label 3500 4750 0    50   ~ 0
D2
Text Label 3500 4850 0    50   ~ 0
D3
Text Label 3500 4950 0    50   ~ 0
D4
Text Label 3500 5050 0    50   ~ 0
D5
Text Label 3500 5150 0    50   ~ 0
D6
Text Label 3500 5250 0    50   ~ 0
D7
Text Label 3500 5350 0    50   ~ 0
D8
Text Label 3500 5450 0    50   ~ 0
D9
Text Label 3500 5550 0    50   ~ 0
D10
Text Label 3500 5650 0    50   ~ 0
D11
Text Label 3500 5750 0    50   ~ 0
D12
Text Label 3500 5850 0    50   ~ 0
D13
Text Label 3500 5950 0    50   ~ 0
D14
Text Label 3500 6050 0    50   ~ 0
D15
Text Label 3500 6550 0    50   ~ 0
RW
Text Label 3500 6250 0    50   ~ 0
_AS
Text Label 3500 6350 0    50   ~ 0
_UDS
Text Label 3500 6450 0    50   ~ 0
_LDS
Text Label 1500 5650 2    50   ~ 0
_RST
Text Label 1500 5150 2    50   ~ 0
_DTACK
Text Label 1500 3950 2    50   ~ 0
E
Text Label 1500 5550 2    50   ~ 0
_HALT
Text Label 1500 2150 2    50   ~ 0
CLK7
Text Label 1500 2450 2    50   ~ 0
_IPL0
Text Label 1500 2550 2    50   ~ 0
_IPL1
Text Label 1500 2650 2    50   ~ 0
_IPL2
Text Label 1500 3850 2    50   ~ 0
_VMA
Text Label 1500 4050 2    50   ~ 0
_VPA
$Comp
L power:+5V #PWR0111
U 1 1 60F80612
P 750 2650
F 0 "#PWR0111" H 750 2500 50  0001 C CNN
F 1 "+5V" H 765 2823 50  0000 C CNN
F 2 "" H 750 2650 50  0001 C CNN
F 3 "" H 750 2650 50  0001 C CNN
	1    750  2650
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R1
U 1 1 60F8143B
P 750 2750
F 0 "R1" H 809 2796 50  0000 L CNN
F 1 "10k" H 809 2705 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" H 750 2750 50  0001 C CNN
F 3 "~" H 750 2750 50  0001 C CNN
	1    750  2750
	1    0    0    -1  
$EndComp
Wire Wire Line
	1500 2850 750  2850
NoConn ~ 1500 3050
NoConn ~ 1500 2950
$Comp
L Connector_Generic:Conn_01x06 J3
U 1 1 60F8DD48
P 8100 6050
F 0 "J3" H 8180 6042 50  0000 L CNN
F 1 "PROG" H 8180 5951 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical" H 8100 6050 50  0001 C CNN
F 3 "~" H 8100 6050 50  0001 C CNN
	1    8100 6050
	1    0    0    -1  
$EndComp
Text Label 6700 6450 0    50   ~ 0
TDI
Text Label 6700 6550 0    50   ~ 0
TMS
Text Label 6700 6650 0    50   ~ 0
TCK
Text Label 6700 6750 0    50   ~ 0
TDO
Text Label 7900 6050 2    50   ~ 0
TDI
Text Label 7900 6150 2    50   ~ 0
TMS
Text Label 7900 6350 2    50   ~ 0
TCK
Text Label 7900 6250 2    50   ~ 0
TDO
$Comp
L power:GND #PWR0112
U 1 1 60F910F4
P 7900 5950
F 0 "#PWR0112" H 7900 5700 50  0001 C CNN
F 1 "GND" V 7905 5822 50  0000 R CNN
F 2 "" H 7900 5950 50  0001 C CNN
F 3 "" H 7900 5950 50  0001 C CNN
	1    7900 5950
	0    1    1    0   
$EndComp
$Comp
L power:+3.3V #PWR0113
U 1 1 60F92458
P 7900 5850
F 0 "#PWR0113" H 7900 5700 50  0001 C CNN
F 1 "+3.3V" H 7915 6023 50  0000 C CNN
F 2 "" H 7900 5850 50  0001 C CNN
F 3 "" H 7900 5850 50  0001 C CNN
	1    7900 5850
	1    0    0    -1  
$EndComp
$Comp
L Connector:Raspberry_Pi_2_3 J2
U 1 1 60F9C7E5
P 8950 4250
F 0 "J2" H 8300 5600 50  0000 C CNN
F 1 "Raspberry_Pi_2_3" H 8300 5550 50  0000 C CNN
F 2 "Connector_PinSocket_2.54mm:PinSocket_2x20_P2.54mm_Vertical" H 8950 4250 50  0001 C CNN
F 3 "https://www.raspberrypi.org/documentation/hardware/raspberrypi/schematics/rpi_SCH_3bplus_1p0_reduced.pdf" H 8950 4250 50  0001 C CNN
	1    8950 4250
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0114
U 1 1 60FB9082
P 8750 2950
F 0 "#PWR0114" H 8750 2800 50  0001 C CNN
F 1 "+5V" H 8765 3123 50  0000 C CNN
F 2 "" H 8750 2950 50  0001 C CNN
F 3 "" H 8750 2950 50  0001 C CNN
	1    8750 2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	8850 2950 8750 2950
Connection ~ 8750 2950
$Comp
L power:GND #PWR0115
U 1 1 60FBFFE4
P 8550 5550
F 0 "#PWR0115" H 8550 5300 50  0001 C CNN
F 1 "GND" H 8555 5377 50  0000 C CNN
F 2 "" H 8550 5550 50  0001 C CNN
F 3 "" H 8550 5550 50  0001 C CNN
	1    8550 5550
	1    0    0    -1  
$EndComp
Wire Wire Line
	9250 5550 9150 5550
Connection ~ 8550 5550
Connection ~ 8650 5550
Wire Wire Line
	8650 5550 8550 5550
Connection ~ 8750 5550
Wire Wire Line
	8750 5550 8650 5550
Connection ~ 8850 5550
Wire Wire Line
	8850 5550 8750 5550
Connection ~ 8950 5550
Wire Wire Line
	8950 5550 8850 5550
Connection ~ 9050 5550
Wire Wire Line
	9050 5550 8950 5550
Connection ~ 9150 5550
Wire Wire Line
	9150 5550 9050 5550
Text Label 8150 3350 2    50   ~ 0
SD6
Text Label 8150 3450 2    50   ~ 0
SD7
Text Label 8150 3850 2    50   ~ 0
SD10
Text Label 8150 4550 2    50   ~ 0
SD15
Text Label 8150 4650 2    50   ~ 0
TMS
Text Label 8150 4750 2    50   ~ 0
TDO
Text Label 9750 4450 0    50   ~ 0
SD0
Text Label 9750 4350 0    50   ~ 0
SWE
Text Label 9750 3450 0    50   ~ 0
AUX1
Text Label 9750 4950 0    50   ~ 0
SD4
Text Label 8150 3650 2    50   ~ 0
SD8
Text Label 8150 4150 2    50   ~ 0
SD12
Text Label 8150 4250 2    50   ~ 0
SD13
Text Label 8150 4850 2    50   ~ 0
TCK
Text Label 8150 4050 2    50   ~ 0
SD11
Text Label 9750 4150 0    50   ~ 0
SOE
Text Label 9750 4050 0    50   ~ 0
SA0
Text Label 9750 3350 0    50   ~ 0
AUX0
Text Label 9750 4750 0    50   ~ 0
SD3
Text Label 9750 4550 0    50   ~ 0
SD1
Text Label 9750 4650 0    50   ~ 0
SD2
Text Label 8150 4450 2    50   ~ 0
SD14
Text Label 8150 4950 2    50   ~ 0
TDI
Text Label 8150 3750 2    50   ~ 0
SD9
Text Label 9750 3950 0    50   ~ 0
PICLK
Text Label 9750 3750 0    50   ~ 0
SA1
Text Label 9750 3650 0    50   ~ 0
SA2
Text Label 9750 5050 0    50   ~ 0
SD5
$Comp
L power:+3.3V #PWR0116
U 1 1 60FD1C97
P 9050 2600
F 0 "#PWR0116" H 9050 2450 50  0001 C CNN
F 1 "+3.3V" H 9065 2773 50  0000 C CNN
F 2 "" H 9050 2600 50  0001 C CNN
F 3 "" H 9050 2600 50  0001 C CNN
	1    9050 2600
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP1
U 1 1 60FD2B58
P 9050 2700
F 0 "JP1" V 9004 2748 50  0000 L CNN
F 1 "self-power" V 9095 2748 50  0000 L CNN
F 2 "Jumper:SolderJumper-2_P1.3mm_Open_RoundedPad1.0x1.5mm" H 9050 2700 50  0001 C CNN
F 3 "~" H 9050 2700 50  0001 C CNN
	1    9050 2700
	0    1    1    0   
$EndComp
Wire Wire Line
	9050 2950 9050 2800
Wire Wire Line
	9150 2950 9050 2950
Connection ~ 9050 2950
Text Label 4700 5650 2    50   ~ 0
A1
Text Label 4700 5550 2    50   ~ 0
A2
Text Label 4700 5450 2    50   ~ 0
A3
Text Label 4700 5350 2    50   ~ 0
A4
Text Label 6700 4050 0    50   ~ 0
A5
Text Label 6700 3950 0    50   ~ 0
A6
Text Label 4700 3650 2    50   ~ 0
A7
Text Label 4700 3750 2    50   ~ 0
A8
Text Label 4700 3950 2    50   ~ 0
A9
Text Label 4700 1950 2    50   ~ 0
A10
Text Label 4700 2050 2    50   ~ 0
A11
Text Label 4700 2250 2    50   ~ 0
A12
Text Label 4700 2550 2    50   ~ 0
A13
Text Label 4700 2750 2    50   ~ 0
A14
Text Label 4700 2950 2    50   ~ 0
A15
Text Label 4700 4450 2    50   ~ 0
A16
Text Label 4700 4550 2    50   ~ 0
A17
Text Label 4700 4750 2    50   ~ 0
A18
Text Label 4700 4950 2    50   ~ 0
A19
Text Label 6700 1950 0    50   ~ 0
A20
Text Label 6700 2450 0    50   ~ 0
A21
Text Label 6700 2750 0    50   ~ 0
A22
Text Label 6700 4350 0    50   ~ 0
A23
Text Label 6700 5850 0    50   ~ 0
D5
Text Label 6700 5750 0    50   ~ 0
D6
Text Label 6700 5650 0    50   ~ 0
D7
Text Label 6700 5550 0    50   ~ 0
D8
Text Label 6700 5450 0    50   ~ 0
D9
Text Label 6700 5350 0    50   ~ 0
D10
Text Label 6700 5150 0    50   ~ 0
D11
Text Label 6700 5050 0    50   ~ 0
D12
Text Label 6700 4950 0    50   ~ 0
D13
Text Label 6700 4850 0    50   ~ 0
D14
Text Label 6700 4750 0    50   ~ 0
D15
Text Label 4700 3850 2    50   ~ 0
SA2
Text Label 4700 4050 2    50   ~ 0
SA1
Text Label 4700 4250 2    50   ~ 0
PICLK
Text Label 4700 2450 2    50   ~ 0
SD9
Text Label 4700 2850 2    50   ~ 0
SD14
Text Label 4700 4650 2    50   ~ 0
SD2
Text Label 4700 4850 2    50   ~ 0
SD1
Text Label 4700 5050 2    50   ~ 0
SD3
Text Label 6700 2150 0    50   ~ 0
AUX0
Text Label 6700 2350 0    50   ~ 0
SA0
Text Label 6700 2650 0    50   ~ 0
SOE
Text Label 6700 2850 0    50   ~ 0
SD5
Text Label 6700 4450 0    50   ~ 0
SD11
Text Label 6700 3750 0    50   ~ 0
CLK7
Text Label 4700 3150 2    50   ~ 0
_RST
Text Label 4700 2150 2    50   ~ 0
SD6
Text Label 4700 2350 2    50   ~ 0
SD7
Text Label 4700 2650 2    50   ~ 0
SD10
Text Label 4700 4350 2    50   ~ 0
SD15
Text Label 4700 5150 2    50   ~ 0
SD0
Text Label 4700 3350 2    50   ~ 0
E
Text Notes 1600 3150 2    50   ~ 0
R1 should not be required
Text Notes 10900 3400 2    50   ~ 0
AUX 0-1 Not required ?
Text Label 10250 6250 2    50   ~ 0
_IPL0
Text Label 10250 6350 2    50   ~ 0
_IPL1
Text Label 10250 6450 2    50   ~ 0
_IPL2
$Comp
L power:+5V #PWR0117
U 1 1 60F926B8
P 10500 5750
F 0 "#PWR0117" H 10500 5600 50  0001 C CNN
F 1 "+5V" H 10515 5923 50  0000 C CNN
F 2 "" H 10500 5750 50  0001 C CNN
F 3 "" H 10500 5750 50  0001 C CNN
	1    10500 5750
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Pack04 RN1
U 1 1 60F93140
P 10700 5950
F 0 "RN1" H 10888 5996 50  0000 L CNN
F 1 "10k" H 10888 5905 50  0000 L CNN
F 2 "Resistor_SMD:R_Array_Convex_4x0603" V 10975 5950 50  0001 C CNN
F 3 "~" H 10700 5950 50  0001 C CNN
	1    10700 5950
	1    0    0    -1  
$EndComp
Wire Wire Line
	10700 5750 10600 5750
Connection ~ 10500 5750
Connection ~ 10600 5750
Wire Wire Line
	10600 5750 10500 5750
Wire Wire Line
	10250 6250 10500 6250
Wire Wire Line
	10500 6250 10500 6150
Wire Wire Line
	10250 6350 10600 6350
Wire Wire Line
	10600 6350 10600 6150
Wire Wire Line
	10250 6450 10700 6450
Wire Wire Line
	10700 6450 10700 6150
Text Label 6700 2250 0    50   ~ 0
AUX1
Text Label 6700 3850 0    50   ~ 0
_HALT
Text Label 4700 3450 2    50   ~ 0
_VPA
Text Label 4700 3250 2    50   ~ 0
_VMA
Text Label 4700 6050 2    50   ~ 0
_IPL2
Text Label 4700 6150 2    50   ~ 0
_IPL1
Text Label 4700 6250 2    50   ~ 0
_IPL0
Text Label 6700 4650 0    50   ~ 0
SD13
Text Label 6700 4550 0    50   ~ 0
SD12
Text Label 6700 4250 0    50   ~ 0
SD8
Text Label 6700 2550 0    50   ~ 0
SD4
Connection ~ 2500 6750
Connection ~ 2600 1950
Connection ~ 2600 6750
Connection ~ 2500 1950
$Comp
L CPU_NXP_68000:68000D J1
U 1 1 60F34DDA
P 2500 4350
F 0 "J1" H 1950 6750 50  0000 C CNN
F 1 "68000D socket" H 1950 6650 50  0000 C CNN
F 2 "Sassa:DIP-64_W22.86mm_BigPads1.4" H 2500 4350 50  0001 C CNN
F 3 "https://www.nxp.com/docs/en/reference-manual/MC68000UM.pdf" H 2500 4350 50  0001 C CNN
	1    2500 4350
	1    0    0    -1  
$EndComp
Text Label 1500 3350 2    50   ~ 0
FC0
Text Label 1500 3450 2    50   ~ 0
FC1
Text Label 1500 3550 2    50   ~ 0
FC2
Text Label 1500 4950 2    50   ~ 0
BERR
$Comp
L Device:C_Small C3
U 1 1 61015A90
P 4600 950
F 0 "C3" H 4692 996 50  0000 L CNN
F 1 "100n" H 4692 905 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 4600 950 50  0001 C CNN
F 3 "~" H 4600 950 50  0001 C CNN
	1    4600 950 
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C4
U 1 1 610175A6
P 5000 950
F 0 "C4" H 5092 996 50  0000 L CNN
F 1 "100n" H 5092 905 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 5000 950 50  0001 C CNN
F 3 "~" H 5000 950 50  0001 C CNN
	1    5000 950 
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C5
U 1 1 61017E0C
P 5400 950
F 0 "C5" H 5492 996 50  0000 L CNN
F 1 "100n" H 5492 905 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 5400 950 50  0001 C CNN
F 3 "~" H 5400 950 50  0001 C CNN
	1    5400 950 
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C6
U 1 1 61018A27
P 5800 950
F 0 "C6" H 5892 996 50  0000 L CNN
F 1 "100n" H 5892 905 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 5800 950 50  0001 C CNN
F 3 "~" H 5800 950 50  0001 C CNN
	1    5800 950 
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR01
U 1 1 6101924A
P 4600 850
F 0 "#PWR01" H 4600 700 50  0001 C CNN
F 1 "+3.3V" H 4615 1023 50  0000 C CNN
F 2 "" H 4600 850 50  0001 C CNN
F 3 "" H 4600 850 50  0001 C CNN
	1    4600 850 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR02
U 1 1 61019ABF
P 4600 1050
F 0 "#PWR02" H 4600 800 50  0001 C CNN
F 1 "GND" H 4605 877 50  0000 C CNN
F 2 "" H 4600 1050 50  0001 C CNN
F 3 "" H 4600 1050 50  0001 C CNN
	1    4600 1050
	1    0    0    -1  
$EndComp
Wire Wire Line
	5800 850  5400 850 
Connection ~ 4600 850 
Connection ~ 5000 850 
Wire Wire Line
	5000 850  4600 850 
Connection ~ 5400 850 
Wire Wire Line
	5400 850  5000 850 
Wire Wire Line
	5800 1050 5400 1050
Connection ~ 4600 1050
Connection ~ 5000 1050
Wire Wire Line
	5000 1050 4600 1050
Connection ~ 5400 1050
Wire Wire Line
	5400 1050 5000 1050
$Comp
L Mechanical:MountingHole H2
U 1 1 61027D73
P 650 7600
F 0 "H2" H 750 7646 50  0000 L CNN
F 1 "MountingHole" H 750 7555 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.5mm" H 650 7600 50  0001 C CNN
F 3 "~" H 650 7600 50  0001 C CNN
	1    650  7600
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H1
U 1 1 6102A214
P 650 7400
F 0 "H1" H 750 7446 50  0000 L CNN
F 1 "MountingHole" H 750 7355 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.5mm" H 650 7400 50  0001 C CNN
F 3 "~" H 650 7400 50  0001 C CNN
	1    650  7400
	1    0    0    -1  
$EndComp
Text Label 6700 2050 0    50   ~ 0
SWE
Text Label 6700 3250 0    50   ~ 0
_AS
Text Label 6700 3550 0    50   ~ 0
RW
Text Label 6700 3350 0    50   ~ 0
_UDS
Text Label 6700 3450 0    50   ~ 0
_LDS
Text Label 6700 3650 0    50   ~ 0
_DTACK
Text Label 6700 3150 0    50   ~ 0
D0
Text Label 6700 5950 0    50   ~ 0
D4
Text Label 6700 6050 0    50   ~ 0
D3
Text Label 6700 6150 0    50   ~ 0
D2
Text Label 6700 6250 0    50   ~ 0
D1
$Comp
L Device:C_Small C7
U 1 1 6151AB58
P 6200 950
F 0 "C7" H 6292 996 50  0000 L CNN
F 1 "100n" H 6292 905 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 6200 950 50  0001 C CNN
F 3 "~" H 6200 950 50  0001 C CNN
	1    6200 950 
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C8
U 1 1 6151B4CF
P 6600 950
F 0 "C8" H 6692 996 50  0000 L CNN
F 1 "100n" H 6692 905 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 6600 950 50  0001 C CNN
F 3 "~" H 6600 950 50  0001 C CNN
	1    6600 950 
	1    0    0    -1  
$EndComp
Wire Wire Line
	6600 850  6200 850 
Connection ~ 5800 850 
Connection ~ 6200 850 
Wire Wire Line
	6200 850  5800 850 
Wire Wire Line
	6600 1050 6200 1050
Connection ~ 5800 1050
Connection ~ 6200 1050
Wire Wire Line
	6200 1050 5800 1050
$Comp
L Mechanical:Fiducial FID1
U 1 1 6100F603
P 650 7200
F 0 "FID1" H 735 7246 50  0000 L CNN
F 1 "Logo" H 735 7155 50  0000 L CNN
F 2 "Sassa:PistormX" H 650 7200 50  0001 C CNN
F 3 "~" H 650 7200 50  0001 C CNN
	1    650  7200
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP5
U 1 1 618C0E0C
P 900 4950
F 0 "JP5" H 900 5135 50  0000 C CNN
F 1 "BERR" H 900 5044 50  0000 C CNN
F 2 "Jumper:SolderJumper-2_P1.3mm_Open_RoundedPad1.0x1.5mm" H 900 4950 50  0001 C CNN
F 3 "~" H 900 4950 50  0001 C CNN
	1    900  4950
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP2
U 1 1 618C5E3E
P 900 3350
F 0 "JP2" H 900 3535 50  0000 C CNN
F 1 "FC0" H 900 3444 50  0000 C CNN
F 2 "Jumper:SolderJumper-2_P1.3mm_Open_RoundedPad1.0x1.5mm" H 900 3350 50  0001 C CNN
F 3 "~" H 900 3350 50  0001 C CNN
	1    900  3350
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP3
U 1 1 618C6B4D
P 900 3600
F 0 "JP3" H 900 3785 50  0000 C CNN
F 1 "FC1" H 900 3694 50  0000 C CNN
F 2 "Jumper:SolderJumper-2_P1.3mm_Open_RoundedPad1.0x1.5mm" H 900 3600 50  0001 C CNN
F 3 "~" H 900 3600 50  0001 C CNN
	1    900  3600
	1    0    0    -1  
$EndComp
$Comp
L Device:Jumper_NO_Small JP4
U 1 1 618C6EFB
P 900 3850
F 0 "JP4" H 900 4035 50  0000 C CNN
F 1 "FC2" H 900 3944 50  0000 C CNN
F 2 "Jumper:SolderJumper-2_P1.3mm_Open_RoundedPad1.0x1.5mm" H 900 3850 50  0001 C CNN
F 3 "~" H 900 3850 50  0001 C CNN
	1    900  3850
	1    0    0    -1  
$EndComp
Text Label 800  3350 2    50   ~ 0
FC0-
Text Label 800  3600 2    50   ~ 0
FC1-
Text Label 800  3850 2    50   ~ 0
FC2-
Wire Wire Line
	1500 3350 1000 3350
Wire Wire Line
	1500 3450 1100 3450
Wire Wire Line
	1100 3450 1100 3600
Wire Wire Line
	1100 3600 1000 3600
Wire Wire Line
	1500 3550 1200 3550
Wire Wire Line
	1200 3550 1200 3850
Wire Wire Line
	1200 3850 1000 3850
Wire Wire Line
	1500 4950 1000 4950
Text Label 800  4950 2    50   ~ 0
BERR-
Text Label 4700 3550 2    50   ~ 0
BERR-
Text Label 4700 5950 2    50   ~ 0
FC2-
Text Label 4700 5850 2    50   ~ 0
FC1-
Text Label 4700 5750 2    50   ~ 0
FC0-
Text Notes 10100 5500 0    50   ~ 0
Pullup already present on\nthe Amiga motherboard
Text Notes 9700 2750 0    50   ~ 0
pi 3.3v regulator should\nnot be powerful enough
$EndSCHEMATC
