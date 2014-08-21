from pylab import *

prescaler = 1.0

def calc_current_formula(t_s, mah_raw):
    """Calculate current based on accumulated charge

    :t_s: Timestamps in seconds
    :mah_raw: raw mAh readings
    :returns: mA

    Rsense = 100mOhms

    """
    rsense = 150.0
    return -mah_raw*0.085*3600*prescaler*50/(rsense*128*t_s)

def calc_current(x):
    """@todo: Docstring for calc_current.

    :x: @todo
    :returns: @todo

    """
    # First find where the charge changes
    ch_diff_ind = abs(diff(x[:,1])) > 0
    xx = x[ch_diff_ind]
    # Find intervals
    intervals = diff(xx, axis=0)
    ## Return timestamps and current
    return ch_diff_ind, xx[1:,0], calc_current_formula(intervals[:,0], intervals[:,1])

def parse_data(file_path, step=1):
    """Read data, parse it and prepare it for current calculation

    :file_path: @todo
    :returns: @todo

    """
    data = loadtxt(file_path)
    #ch_changes = abs(diff(data[:,1])) > 0
    #data_filt = data[ch_changes]
    #data_filt = data[::step]
    data_filt = data

    return data_filt
