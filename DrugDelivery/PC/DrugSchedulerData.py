# http://wiesel.ece.utah.edu/redmine/projects/hacks/wiki/How_to_use_Python_and_MIG_to_interact_with_a_TinyOS_application
import sys

import DrugSchedulerData
from tinyos.message import *
from tinyos.message.Message import *
from tinyos.message.SerialPacket import *
from tinyos.packet.Serial import Serial

class DrugSchedulerData:
  def __init__(self, motestring):
    self.mif = MoteIF.MoteIF()
    self.tos_source = self.mif.addSource(motestring)
    # self.mif.addListener(self, DrugSchedulerData.DrugSchedulerData)

def main():
  if '-h' in sys.argv or len(sys.argv) < 2:
    print 'Usage: ...'
    sys.exit()
  dl = DrugSchedulerData(sys.argv[1])
  # dl.send_msg()

if __name__ == '__main__':
  try:
    main()
  except KeyboardInterrupt:
    pass
