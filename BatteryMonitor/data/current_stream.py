#!/usr/bin/env python
# encoding: utf-8

from pylab import *
from current import *
import sys
import time

def main():
    """Read stream from stdin and convert to ma
    :returns: @todo

    """
    last_ma_raw = -1
    last_ts_raw = -1
    first_pass = False
    while True:
        line = sys.stdin.readline().strip().split()
        if len(line) == 5:
            ma_raw = int(line[1])
            ts_raw = int(line[0])
            ts = time.time()
            if last_ma_raw == -1:
                last_ma_raw = ma_raw
                last_ts_raw = ts_raw
                first_pass = True
            #elif ma_raw < last_ma_raw-10:
            elif ma_raw != last_ma_raw:
                #print last_ts_raw, last_ma_raw, ts_raw, ma_raw
                #print ts_raw-last_ts_raw ,ma_raw -  last_ma_raw
                if not first_pass:
                    ma = calc_current_formula((ts_raw-last_ts_raw)/1000., ma_raw - last_ma_raw)
                    print "{:.2f} {:.3f}".format(ts,ma)
                else:
                    first_pass = False
                last_ma_raw = ma_raw
                last_ts_raw = ts_raw
            #print line



if __name__ == '__main__':
    main()
