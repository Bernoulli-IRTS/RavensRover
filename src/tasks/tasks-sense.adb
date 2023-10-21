with Drivers.HCSR04;
with MicroBit.Types; use MicroBit.Types;
use MicroBit;
with MicroBit.Console; use MicroBit.Console;

package body Tasks.Sense is
   -- Sense task body, trigging the HC-SR04 ultrasonic sensor
   task body Sense is
      package HCSR04Sensor is new Drivers.HCSR04
        ((0 => (Echo_Pin => MB_P0, Trigger_Pin => MB_P2), -- Both
          1 => (Echo_Pin => MB_P1, Trigger_Pin => MB_P13)));
   begin
      loop
         -- Trigger an ultrasonic sensor
         HCSR04Sensor.Trigger;
         -- Delay 60ms
         delay 1.0; --0.06;

         if HCSR04Sensor.Get_Working then
            Put_Line ("WORKING");
         else
            Put_Line ("Not working");
         end if;

         Put_Line
           ("Distance 1: " &
            HCSR04Sensor.Distance_cm'Image (HCSR04Sensor.Get_Distance (0)));

         -- Ignore if there is no sensor 1
         begin
            Put_Line
              ("Distance 2: " &
               HCSR04Sensor.Distance_cm'Image (HCSR04Sensor.Get_Distance (1)));
         exception
            when Constraint_Error =>
               null;
         end;

         Put_Line ("");
      end loop;
   end Sense;
end Tasks.Sense;
