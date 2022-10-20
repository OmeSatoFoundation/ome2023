# coding: utf-8
## @package EROLED096
#  This is a FaBoOLED_EROLED096 library for the FaBo OLED I2C Brick.
#
#  http://fabo.io/214.html
#
#  Released under APACHE LICENSE, VERSION 2.0
#
#  http://www.apache.org/licenses/
#
#  FaBo <info@fabo.io>

import smbus
import time

from .font_d import FONT
from .bmp_d  import BMP

## ER-OLED0.96 I2C Slave Address
SLAVE_ADDRESS = 0x3C

## smbus
bus = smbus.SMBus(1)

##  FaBo OLED I2C Controll class
class EROLED096:

    ## Constructor
    #  @param [in] address EROLED096 I2C slave address default:0x3c
    def __init__(self, address=SLAVE_ADDRESS):
        self.address = address
        self.cur_x   = 120
        self.cur_y   = 7
        self.map_x   = [120, 112, 104, 96, 88, 80, 72, 64, 56, 48, 40, 32, 24, 16, 8, 0]
        self.map_y   = [7, 6, 5, 4, 3, 2, 1, 0]

        self.configuration()
        self.clear()

    ## Set Configuration
    def configuration(self):
        # Initializing
        self.setCommand(0xAE)  # set display off
        self.setCommand(0xD5)  # set display clock divide ratio/oscillator frequency
        self.setCommand(0x80)  #
        self.setCommand(0xA8)  # set multiplex ratio
        self.setCommand(0x3F)  #
        self.setCommand(0xD3)  # set display offset
        self.setCommand(0x00)  #
        self.setCommand(0x40)  # set display start line
        self.setCommand(0x8D)  # set charge pump
        self.setCommand(0x14)  # generated by internal DC/DC circuit
        self.setCommand(0xA1)  # set segment re-map
        self.setCommand(0xC8)  # set com output scan direction
        self.setCommand(0xDA)  # set com pins hardware configuration
        self.setCommand(0x12)  #
        self.setCommand(0x81)  # set contrast control
        self.setCommand(0xCF)  #
        self.setCommand(0xD9)  # set pre-charge period
        self.setCommand(0xF1)  #
        self.setCommand(0xDB)  # set VCOMH deselect level
        self.setCommand(0x20)  #
        self.setCommand(0xA4)  # set entire display on/off
        self.setCommand(0xA6)  # set normal/inverse display
        # clear screen
        self.setCommand(0xAF)  # set display on

    # Show Bitmap
    def showBitmap(self):
        for i in xrange(8): # row/height/page
            self.setAddress(i,0,127)
            for j in xrange(128): # column
                self.writeData(BMP[(i*128)+j])

    ## Clear Screen
    def clear(self):
        for i in xrange(8): # row/height/page
            self.setAddress(i,0,127)
            for j in xrange(128): # column
                self.writeData(0x00)  # clear
        self.home()

    ## Set Cursor to Home
    def home(self):
        self.cur_x = 120
        self.cur_y = 7

    ## Set Cursor
    #  @param [in] col set column
    #  @param [in] row set row
    def setCursor(self, col, row):
        if (col >= 0) and (col <= 15) :
            self.cur_x = self.map_x[col]
        if (row >= 0) and (row <= 7) :
            self.cur_y = self.map_y[row]

    ## Set Command
    #  @param [in] value Command data (byte)
    def setCommand(self, value):
        self.send(value, 0x00)

    ## Set Address
    #  @param [in] row   set low
    #  @param [in] col_s start address
    #  @param [in] col_e end address
    def setAddress(self, row, col_s, col_e):
        data = [
            0xB0 | row, # set page start address (for page addressing mode)
            0x21,       # set column address
            col_s,      # column start address: 0-
            col_e       # column end   address: -127
        ]

        bus.write_i2c_block_data(self.address, 0x00, data)

    ## Write Display Data
    #  @param [in] value write value
    def writeData(self, value):
        self.send(value, 0x40)

    ## Write String Data
    #  @param [in] data string ,number, list Output data
    def write(self, data):
        if isinstance(data, (int, long, float)):
            out_str = str(data)
        else:
            out_str = data

        for chr in out_str:

            if isinstance(chr, (int, long, float)):
                out_chr = str(chr)
            else:
                out_chr = chr
            for c in out_chr:
                self.writeChar(ord(c))

    ## Write character
    #  @param [in] value output Character Code
    def writeChar(self, value):
        if (value>=0x20) and (value<=0x80):
            self.cur_x -= 8
            if self.cur_x >= 0 :
                self.setAddress(self.cur_y, self.cur_x+8, self.cur_x+8+8-1)
                self.writeData(0x00)
                self.writeData(0x00)
                for i in xrange(5):
                    self.writeData( FONT[(value*5)+i])
                self.writeData( 0x00 )
            else:
                self.cur_x = 0

        return 1

    ## Send I2C Data
    #  @param [in] value write value
    #  @param [in] mode  write mode
    def send(self, value, mode):
        bus.write_byte_data(self.address, mode, value)
