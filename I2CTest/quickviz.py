#!/usr/bin/env python
# encoding: utf-8


import serial
from pyqtgraph.Qt import QtGui, QtCore
import numpy as np
import pyqtgraph as pg
from collections import deque
import time

app = QtGui.QApplication([])

#port, baud = '/dev/ttyUSB0', 115200
port, baud = '/dev/ttyUSB0', 1000000

ser = serial.Serial(port, baud)

win = pg.GraphicsWindow(title="Basic plotting examples")
win.resize(1000,600)
win.setWindowTitle('pyqtgraph example: Plotting')

BUF_SIZE = 500
#BUF_SIZE = 128

px = win.addPlot(title="Gyro Axis X")
xcurve = px.plot(pen='y')
a_px = win.addPlot(title="Axis X")
a_xcurve = a_px.plot(pen='y')

win.nextRow()

py = win.addPlot(title="Gyro Axis Y")
a_py = win.addPlot(title="Axis Y")
ycurve = py.plot(pen='y')
a_ycurve = a_py.plot(pen='y')

win.nextRow()

pz = win.addPlot(title="Gyro Axis Z")
a_pz = win.addPlot(title="Axis Z")
zcurve = pz.plot(pen='y')
a_zcurve = a_pz.plot(pen='y')


xdata = deque(np.zeros(BUF_SIZE), maxlen=BUF_SIZE)
a_xdata = deque(np.zeros(BUF_SIZE), maxlen=BUF_SIZE)
ydata = deque(np.zeros(BUF_SIZE), maxlen=BUF_SIZE)
a_ydata = deque(np.zeros(BUF_SIZE), maxlen=BUF_SIZE)
zdata = deque(np.zeros(BUF_SIZE), maxlen=BUF_SIZE)
a_zdata = deque(np.zeros(BUF_SIZE), maxlen=BUF_SIZE)

tstamp = deque(np.arange(BUF_SIZE), maxlen=BUF_SIZE)

px.enableAutoRange('y', True)  ## stop auto-scaling after the first data set is plotted
a_px.enableAutoRange('y', True)  ## stop auto-scaling after the first data set is plotted
py.enableAutoRange('y', True)  ## stop auto-scaling after the first data set is plotted
a_py.enableAutoRange('y', True)  ## stop auto-scaling after the first data set is plotted
pz.enableAutoRange('y', True)  ## stop auto-scaling after the first data set is plotted
a_pz.enableAutoRange('y', True)  ## stop auto-scaling after the first data set is plotted
# a b c d e f g h i j k l m n o p q r s t u v w x y z

#px.setYRange(-28,28)
#a_px.setYRange(-28,28)
#py.setYRange(-28,28)
#a_py.setYRange(-28,28)
#pz.setYRange(-28,28)
#a_pz.setYRange(-28,28)

px.setMouseEnabled(x=False, y=True)
a_px.setMouseEnabled(x=False, y=True)
py.setMouseEnabled(x=False, y=True)
a_py.setMouseEnabled(x=False, y=True)
pz.setMouseEnabled(x=False, y=True)
a_pz.setMouseEnabled(x=False, y=True)

ACCEL_NORM = 2.0/0x8000
def read_data():
    global last_ts, ts_mean
    raw = ser.readline().strip()
    try:
        ts_board, gx,gy,gz,ax,ay,az = map(lambda x: int(x.strip()), raw.split())
        xdata.append(gx)
        ydata.append(gy)
        zdata.append(gz)
        a_xdata.append(ax*ACCEL_NORM)
        a_ydata.append(ay*ACCEL_NORM)
        a_zdata.append(az*ACCEL_NORM)
        tstamp.append(tstamp[-1]+1)

        ts = time.time()
        if last_ts == 0:
            last_ts = ts

        ts_diff = ts-last_ts
        ts_mean = (ts_mean*mean_samples + ts_diff)/(mean_samples+1)
        #print "{:d} {:.3f} {:.3f} {:.3f}".format(ts_board, ts,ts_diff, ts_mean)
        print "{:.3f}".format(ts_mean)
        last_ts = ts
    except KeyboardInterrupt:
        raise
    except StandardError as e:
        print e
        print raw
        print raw.split()

last_ts = 0
ts_mean = 0
mean_samples = 10
def update():
    global curve, data
    xcurve.setData(tstamp, xdata)
    a_xcurve.setData(tstamp, a_xdata)
    ycurve.setData(tstamp, ydata)
    a_ycurve.setData(tstamp, a_ydata)
    zcurve.setData(tstamp, zdata)
    a_zcurve.setData(tstamp, a_zdata)


timer = QtCore.QTimer()
timer.timeout.connect(update)
timer.start(50)

timer2 = QtCore.QTimer()
timer2.timeout.connect(read_data)
timer2.start(1)


## Start Qt event loop unless running in interactive mode or using pyside.
if __name__ == '__main__':
    QtGui.QApplication.instance().exec_()

