# PwmHAATestAppC
The application generates a PWM signal on two GPIO pins. The first pin is directly controlled by the timer module while 
the second pin, an LED, is toggled from an event triggered by the timer. For this application, Timer_B was used since 
all the timer modules in Timer_A are used up by TinyOS.

The timers in the MSP430F5520 have 3 modes of counting time. These are:

 * Up mode: Timer counts up to ``TBxCCR0``
 * Continuous mode: Timer counts up to the value set by ``CNTL`` (``CNTL`` is only available in Timer_B. In Timer_A this 
   mode counts up to 0xffff)
 * Up/down mode: Timer counts up to ``TBxCCR0`` and down to 0000h

Each compare block also has 8 output modes that can be used to generate PMW signals. These modes determine the behaviour 
of the output signal in relation to ``TBxCCR0`` and ``TBxCCRn,`` where ``TBxCCRn`` is the compare register associated 
with the nth compare module. Events can be triggered when the value of the timer reaches these two registers.

For a flexible PWM output, it is necessary to use the 'Up mode' since it allows for changing the frequency of the signal 
as well as the duty cycle. More precisely, changing ``TBxCCR0`` changes the frequency while changing ``TBxCCRn`` changes 
the duty cycle. On the other hand, if 'Continuous mode' were used, the frequency of the PWM output is solely determined 
by the frequency of the timer, which is in turn determined by the source of the timer's input clock.

Timer_B has one timer with 7 capture/compare blocks. In this application, compare blocks 0 and 1 are used to generate a 
PWM signal that varies in duty cycle with time. TinyOS interfaces ``Timer``, ``TimerControl`` and ``TimerCompare`` are 
used to set the appropriate registers. The interfaces are provided by the components ``Msp430Timer``, ``Msp430TimerControl``,
and ``Msp430TimerCompare``. These interfaces provide convenient functionality to set the timers in compare mode, enable 
interrupts and set the period registers. The output mode, however, has to be set in a less convenient manner by 
instantiating a ``msp430_compare_control_t`` data structure and setting the appropriate values followed by calling the 
``setControl`` function with the data structure as an argument. The following listing demonstrates the set of function 
calls to initialize the timer to function as a PWM generator.
    
```C
    // Instantiate data structure to set output mode
    typedef msp430_compare_control_t cc_t;
    cc_t x;

    // Change capture/compare block to compare mode and enable interrupts
    call TimerControl0.setControlAsCompare();
    call TimerControl0.enableEvents();
    call TimerControl1.setControlAsCompare();
    call TimerControl1.enableEvents();

    // Set period registers
    call TimerCompare0.setEvent(0x1ff);
    call TimerCompare1.setEvent(0x001);

    x = call TimerControl1.getControl();
    x.outmod = 3; // Enable set/reset output mode
    call TimerControl1.setControl(x);

    // Set clock source
    call TimerB.setClockSource(1);
    
    // Start timer
    call TimerB.setMode(1);
```

Additionally, the output pin associated with compare block 1 has to be configured to be in module mode and set to 
output.

```C
    // Assuming P4_0 is wired to Port40 and it is the correct pin (with a compare peripheral)
    call P4_0.selectModuleFunc();
    call P4_0.makeOutput();
```
