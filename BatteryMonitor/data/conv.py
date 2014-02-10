#!/usr/bin/env python
# encoding: utf-8

# Temperature conversion for LTC2942
# T = 600K * x/0xffff

# Voltage conversion
# V = 6 * x/0xffff
import argparse

parser = argparse.ArgumentParser(description='Convert Temperature/Voltage ADC readings')
group = parser.add_mutually_exclusive_group()
group.add_argument('-v', dest='voltage',  action='store_true', help="Voltage conversion")
group.add_argument('-t', dest='temperature', action='store_true', help="Temperature conversion")

args = parser.parse_args()

while True:
    try:
        data = raw_input()
    except:
        break

    try:
        x = int(data)
        if args.voltage:
            V = 6 * float(x)/0xffff
            print "{} {:.2f}".format(x, V) # Celcius
        else: # Default to temperature
            T = 600 * float(x)/0xffff
            print "{} {:.2f}".format(x, T - 273) # Celcius


    except:
        pass
