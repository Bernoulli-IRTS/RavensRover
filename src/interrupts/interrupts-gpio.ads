with Ada.Interrupts.Names;
with Ada.Real_Time; use Ada.Real_Time;
with System;

-- GPIO Interrupt handler for taking the exact time of pulses
package Interrupts.GPIO is
   -- The nRF GPIO_Pin_Index goes from 0 to 47, but that is larger than the 32-bit latch we use
   type Pin_Index is range 0 .. 31;
   -- The different kinds of configs a pulse watching interrupt will have
   type Pin_Interrupt_Config is (None, PulseHigh, PulseLow);
   -- The kind of edge the pulse last triggered and interrupt with
   type Pulse_Edge is (Unknown, Rising, Falling);

   type Pin_Pulse is record
      Timestamp : Time;
      Duration  : Time_Span;
      Edge      : Pulse_Edge;
   end record;

   -- Protected interrupt handler for nRF GPIOTE interrupts
   protected InterruptHandler is
      pragma Interrupt_Priority (System.Interrupt_Priority'First);

   private
      procedure ISR;
      pragma Attach_Handler (ISR, Ada.Interrupts.Names.GPIOTE_Interrupt);
   end InterruptHandler;
end Interrupts.GPIO;
