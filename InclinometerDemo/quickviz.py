#!/usr/bin/env python
# encoding: utf-8


import os
import sys
import time
import struct
import math
import serial
from pyqtgraph.Qt import QtGui, QtCore
import numpy as np
import pyqtgraph as pg
from collections import deque
from tinyos.message import *
from tinyos.message.Message import *
from tinyos.message.SerialPacket import *
from tinyos.packet.Serial import Serial

import InclinometerDemo
from Constants import Constants

app = QtGui.QApplication([])

win = pg.GraphicsWindow(title="QuickViz")
win.resize(1000,600)
win.setWindowTitle('QuickViz Accelerometer')

BUF_SIZE = 500

px = win.addPlot(title="Axis X")
xcurve = px.plot(pen='y')

xdata = deque(np.zeros(BUF_SIZE), maxlen=BUF_SIZE)

tstamp = deque(np.arange(BUF_SIZE), maxlen=BUF_SIZE)

px.enableAutoRange('y', False)  ## stop auto-scaling after the first data set is plotted

px.setYRange(-90,90)

px.setMouseEnabled(x=False, y=True)

class DataLogger:
    def __init__(self, motestring):
        self.mif = MoteIF.MoteIF()
        self.tos_source = self.mif.addSource(motestring)
        self.mif.addListener(self, InclinometerDemo.InclinometerDemo)

    def receive(self, src, msg):
        if msg.get_amType() == InclinometerDemo.AM_TYPE:
            x = float(msg.get_x())
            gravity = x/Constants.NORMALIZATION
            if gravity > 1:
                gravity = 1
            elif gravity < -1:
                gravity = -1
            xangle = math.degrees(math.asin(gravity))
            cur_time = time.time()
            print "{:.4f}\t{}\t{:.3f}".format(cur_time, x, xangle)
            xdata.append(xangle);
            #tstamp.append(cur_time)

        sys.stdout.flush()
    def stop(self):
        """Remove listener
        :returns: @todo

        """
        self.tos_source.cancel()

def update():
    global curve, data
    xcurve.setData(tstamp, xdata)

timer = QtCore.QTimer()
timer.timeout.connect(update)
timer.start(5)

## Start Qt event loop unless running in interactive mode or using pyside.
def main():

    if '-h' in sys.argv or len(sys.argv) < 2:
        print "Usage:", sys.argv[0], "sf@localhost:9002"
        sys.exit()

    dl = DataLogger(sys.argv[1])
    QtGui.QApplication.instance().exec_()
    dl.stop()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass

