# http://wiesel.ece.utah.edu/redmine/projects/hacks/wiki/How_to_use_Python_and_MIG_to_interact_with_a_TinyOS_application
import sys
import time

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

  counter = 0
  def receive(self, src, msg):
    if msg.get_amType() == DrugSchedulerMsg.AM_TYPE:
      print 'Received packet #: ', DrugDeliveryPC.counter, 'remaining: ', msg.get_amount(), '%'
      DrugDeliveryPC.counter += 1

  def send(self):
    time.sleep(2)
    payload = DrugSchedulerMsg.DrugSchedulerMsg()
    payload.set_amount(15)
    payload.set_time_interval(3)
    self.mif.sendMsg(self.tos_source, 0xFFFF, payload.get_amType(), 0, payload)

def main():
  if '-h' in sys.argv or len(sys.argv) < 2:
    print 'Usage: ...'
    sys.exit()
  dl = DrugDeliveryPC(sys.argv[1])
  dl.send()

if __name__ == '__main__':
  try:
    main()
  except KeyboardInterrupt:
    pass
