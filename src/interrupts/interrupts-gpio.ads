with Ada.Interrupts.Names;
with Ada.Real_Time; use Ada.Real_Time;
with nRF.GPIO;      use nRF.GPIO;
with System;

-- GPIO Interrupt handler for taking the exact time of pulses
package Interrupts.GPIO is
   -- The nRF GPIO_Pin_Index goes from 0 to 47, but that is larger than the 32-bit latch we use
   type Pin_Index is range 0 .. 31;
   -- The different kinds of configs a pulse watching interrupt will have
   type Pin_Pulse_Config is (Pulse_None, Pulse_High, Pulse_Low);
   -- The kind of edge the pulse last triggered and interrupt with
   type Pulse_Edge is (Pulse_Unknown, Pulse_Rising, Pulse_Falling);

   type Pin_Pulse is record
      Timestamp : Time;
      Duration  : Time_Span;
      Edge      : Pulse_Edge;
   end record;

   type Pin_Pulses is array (Pin_Index) of Pin_Pulse;

   -- Configure the kind of pulses the interrupt handler should detect on a pin
   procedure Configure_Interrupt_Pin
     (Pin : GPIO_Point; Config : Pin_Pulse_Config);

   -- Protected interrupt handler for nRF GPIOTE interrupts
   protected InterruptHandler is
      pragma Interrupt_Priority (250);

      function Get_Pulse (Pin : GPIO_Point) return Pin_Pulse;
   private
      Pulses : Pin_Pulses :=
        (others =>
           (Timestamp => Time_First, Duration => Time_Span_Last,
            Edge      => Pulse_Unknown));

      procedure ISR;
      pragma Attach_Handler (ISR, Ada.Interrupts.Names.GPIOTE_Interrupt);
   end InterruptHandler;
end Interrupts.GPIO;
