#!/usr/bin/env python
# encoding: utf-8

# Author: Addisu Z. Taddese
# Vanderbilt University

import sys
import numpy as np

vhex = lambda x: int(x,16)

seq = np.loadtxt(sys.argv[1], usecols=(4,), converters={4:vhex})

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

print "Total received packets:", seq.size
print "Total lost packets:", tot_lost_pkts
print "Total packets:", tot_lost_pkts + seq.size
print "Loss percentage: {:.2f}%".format(100.0 * tot_lost_pkts/(tot_lost_pkts + seq.size))

