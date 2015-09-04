# http://wiesel.ece.utah.edu/redmine/projects/hacks/wiki/How_to_use_Python_and_MIG_to_interact_with_a_TinyOS_application
import sys
import time

from Tkinter import *

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

  def send(self, interval, amount):
    # time.sleep(2)
    payload = DrugSchedulerMsg.DrugSchedulerMsg()
    payload.set_time_interval(interval)
    payload.set_amount(amount)
    self.mif.sendMsg(self.tos_source, 0xFFFF, payload.get_amType(), 0, payload)

class Application(Frame):
  def __init__(self, master, motestring):
    self.dl = DrugDeliveryPC(sys.argv[1])
    self.root = master
    Frame.__init__(self, master)
    self.pack(padx = 10, pady = 20)
    self.createWidgets()

  def send_schedule(self):
    interval = int(self.interval.get())
    amount = int(self.amount.get())
    self.dl.send(interval, amount)

  def quit(self, event=None):
    self.root.destroy()

  def createWidgets(self):

    self.createInputArea()
    self.createInfoArea()

    self.bind_all("<q>", self.quit)

  def createInputArea(self):
    input_frame = Frame(self, bd=15)
    label_interval = Label(input_frame, text='Every')
    self.interval = Entry(input_frame, width=4)
    label_amount = Label(input_frame, text='seconds')
    self.amount = Entry(input_frame, width=4)
    label_perc = Label(input_frame, text='%', padx=5)
    send = Button(input_frame, text='Send', command=self.send_schedule)
    label_interval.pack(side=LEFT)
    self.interval.pack(side=LEFT)
    label_amount.pack(side=LEFT)
    self.amount.pack(side=LEFT)
    label_perc.pack(side=LEFT)
    send.pack()
    input_frame.pack()

  def createInfoArea(self):
    info_frame = Frame(self, bd=15, bg='blue')
    label = Label(info_frame, text='Information')
    text = Label(info_frame, text='...', bd=5, bg='gray')
    label.pack()
    text.pack()
    info_frame.pack()


def main():
  if '-h' in sys.argv or len(sys.argv) < 2:
    print 'Usage: ...'
    sys.exit()
  root = Tk()
  root.title('Scheduler')
  app = Application(root, sys.argv[1])
  app.mainloop()

if __name__ == '__main__':
  try:
    main()
  except KeyboardInterrupt:
    pass
