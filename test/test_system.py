#!/usr/bin/env python
# Import des modules
import RPi.GPIO as GPIO
import serial,time
import os
import sys

#Declaration du chemin du fichier a importer
sys.path.insert(1,'/home/pi/projet/Full_test/')

#Declaration du port TXRX
arduino = serial.Serial(port='/dev/ttyS0', baudrate=9600, timeout=.1)

#Main
if __name__ == '__main__':
    # Test du port TXRX si Nano connecte
    if arduino.isOpen():
        print("{} connected!".format(arduino.port))
    else:
        print("{} does not answer!".format(arduino.port))
