#!/usr/bin/env python
# encoding: utf-8

import os
import sys
import time
import struct
import math
from tinyos.message import *
from tinyos.message.Message import *
from tinyos.message.SerialPacket import *
from tinyos.packet.Serial import Serial

import InclinometerDemo
from Constants import Constants


class DataLogger:

    def __init__(self, motestring):
        self.mif = MoteIF.MoteIF()
        self.tos_source = self.mif.addSource(motestring)
        self.mif.addListener(self, InclinometerDemo.InclinometerDemo)

    def receive(self, src, msg):
        if msg.get_amType() == InclinometerDemo.AM_TYPE:
            x = float(msg.get_x())
            xangle = math.degrees(math.asin(x/Constants.NORMALIZATION))
            print "{:.4f}\t{}\t{:.3f}".format(time.time(), x, xangle)

        sys.stdout.flush()

    def main_loop(self):
        while 1:
            time.sleep(1)

def main():

    if '-h' in sys.argv or len(sys.argv) < 2:
        print "Usage:", sys.argv[0], "sf@localhost:9002"
        sys.exit()

    dl = DataLogger(sys.argv[1])
    dl.main_loop()  # don't expect this to return...

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
