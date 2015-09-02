# http://wiesel.ece.utah.edu/redmine/projects/hacks/wiki/How_to_use_Python_and_MIG_to_interact_with_a_TinyOS_application
import sys

import DrugSchedulerMsg
from tinyos.message import *
from tinyos.message.Message import *
from tinyos.message.SerialPacket import *
from tinyos.packet.Serial import Serial

class DrugDeliveryPC:
  def __init__(self, motestring):
    self.mif = MoteIF.MoteIF()
    self.tos_source = self.mif.addSource(motestring)
    self.mif.addListener(self, DrugSchedulerMsg.DrugSchedulerMsg)

  def receive(self, src, msg):
    print 'receive'
    print msg.get_amType()
    if msg.get_amType() == DrugSchedulerMsg.AM_TYPE:
      print msg

def main():
  if '-h' in sys.argv or len(sys.argv) < 2:
    print 'Usage: ...'
    sys.exit()
  dl = DrugDeliveryPC(sys.argv[1])
  # dl.send_msg()

if __name__ == '__main__':
  try:
    main()
  except KeyboardInterrupt:
    pass
