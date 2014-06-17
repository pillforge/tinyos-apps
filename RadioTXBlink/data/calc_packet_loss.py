#!/usr/bin/env python
# encoding: utf-8

# Author: Addisu Z. Taddese
# Vanderbilt University

import argparse
import sys
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('file', help='File name')
parser.add_argument('-p', dest='plot', action='store_true', help='Plot data')

args = parser.parse_args()
vhex = lambda x: int(x,16)

try:
    seq = np.loadtxt(args.file, usecols=(4,), converters={4:vhex})
except:
    seq = np.loadtxt(args.file, usecols=(4,), skiprows=1, converters={4:vhex})

dseq = np.diff(seq)

# The packet losses result in diffs > 1 or wrapped negative values. When there
# is no packet loss, the values are 1 so we first subtract 1 to normalize the
# values so we can later just sum this to get the total number of lost packets.
# For the negative values, we can then add 256 to make them positive. Instead
# of separating the negatives and positives, we can apply the modulo operator
# so that the positive numbers are unaffected.
#
lost_pkts = (dseq + 255)%256

tot_lost_pkts = np.sum(lost_pkts)

if tot_lost_pkts == 0:
    loss_perc = 0
else:
    loss_perc = 100.0 * 1/(1 + seq.size/tot_lost_pkts)

print "Total received packets:", seq.size
print "Total lost packets:", tot_lost_pkts
print "Total packets:", tot_lost_pkts + seq.size
#print "Loss percentage: {:.3f}%".format(100.0 * tot_lost_pkts/(tot_lost_pkts + seq.size))
print "Loss percentage: {:.3f}%".format(loss_perc)


print lost_pkts[lost_pkts > 0]
# More analysis
# straight losses
if tot_lost_pkts > 0:
    for i in range(1,11):
        i_straight = np.where(lost_pkts == i)[0].size
        print "{} consecutive losses: {} = {:.3f}% of total loss".format(
            i,i_straight, 100.0*i_straight*i/tot_lost_pkts)

    more_than_i = np.where(lost_pkts > 10)[0].size
    print ">{} consecutive losses: {} = {:.3f}% of total loss".format(
        10,more_than_i, 100.0*more_than_i/tot_lost_pkts)


if args.plot:
    import pylab as plt
    # Historgram of consecutive/in a row losses
    plt.figure()
    #plt.hist(lost_pkts, bins=np.arange(1,11), rwidth=0.5, align='left',
            #weights=100.0*np.ones(lost_pkts.size)/tot_lost_pkts)
    plt.hist(lost_pkts, bins=np.arange(1,11), rwidth=0.5, align='left')
    plt.xticks(np.arange(11))
    plt.ylabel("Percentage of consecutive losses")
    plt.xlabel("Events")

    # Cumulative sum plot
    #
    plt.figure()
    plt.plot(np.cumsum(lost_pkts))
    plt.ylabel("Cumulative losses")
    plt.xlabel("Events")

    # Percentage Cumulative
    plt.figure()
    plt.plot(100.0 * 1/(1.0 + np.arange(1,seq.size)/np.cumsum(lost_pkts)))
    plt.axhline(y=loss_perc,c='r')
    plt.ylabel("Percentage of cumulative losses")
    plt.xlabel("Events")
    plt.show()
