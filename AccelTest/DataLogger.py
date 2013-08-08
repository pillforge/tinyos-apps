import os
import sys
import time
import struct
import math

#tos stuff
import AccelTest
from tinyos.message import *
from tinyos.message.Message import *
from tinyos.message.SerialPacket import *
from tinyos.packet.Serial import Serial

class DataLogger:
    def __init__(self, motestring):
        self.mif = MoteIF.MoteIF()
        self.tos_source = self.mif.addSource(motestring)
        self.mif.addListener(self, AccelTest.AccelTest)

    def receive(self, src, msg):
        if msg.get_amType() == AccelTest.AM_TYPE:
            print "{:.4f}\t{}\t{}\t{}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}".format(
                time.time(),
                msg.get_accel_x(), msg.get_accel_y(), msg.get_accel_z(), 
                msg.get_angle_x(), msg.get_angle_y(), msg.get_angle_z(),
                math.degrees(msg.get_angle_x()), math.degrees(msg.get_angle_y()), math.degrees(msg.get_angle_z()),)

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
