from pylab import *

prescaler = 1.0

def _calc_current(t_ms, mah_raw):
    """Calculate current based on accumulated charge

    :t_ms: Timestamps in milliseconds
    :mah_raw: raw mAh readings
    :returns: mA

    """
    return mah_raw*0.085*3600*prescaler/(128*t_ms/1000.0)

def calc_current(x):
    """@todo: Docstring for calc_current.

    :x: @todo
    :returns: @todo

    """
    # Find intervals
    intervals = diff(x, axis=0)
    # Return timestamps and current
    return x[1:,0], _calc_current(intervals[:,0], intervals[:,1])

def parse_data(file_path):
    """Read data, parse it and prepare it for current calculation

    :file_path: @todo
    :returns: @todo

    """
    data = loadtxt(file_path)
    ch_changes = abs(diff(data[:,1])) > 0
    data_filt = data[ch_changes]

    return data_filt
