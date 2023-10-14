with Drivers.HCSR04;
with MicroBit.Types; use MicroBit.Types;
use MicroBit;
with MicroBit.Console; use MicroBit.Console;

package body Tasks.Sense is
   -- Sense task body, trigging the HC-SR04 ultrasonic sensor
   task body Sense is
      package HCSR04Sensor is new Drivers.HCSR04 (MB_P0, (0 => MB_P1));
   begin
      loop
         -- Trigger an ultrasonic sensor
         HCSR04Sensor.Trigger;
         -- Delay 60ms
         delay 0.06;

         if HCSR04Sensor.Get_Working then
            Put_Line ("WORKING");

            Put_Line
              ("Distance: " &
               HCSR04Sensor.Distance_cm'Image (HCSR04Sensor.Get_Distance (0)));
         else
            Put_Line ("Not working");
         end if;
      end loop;
   end Sense;
end Tasks.Sense;
