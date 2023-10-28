with Ada.Real_Time;  use Ada.Real_Time;
with Drivers.HCSR04;
with MicroBit.Types; use MicroBit.Types;
use MicroBit;
with MicroBit.Console; use MicroBit.Console;

package body Tasks.Sense is
   -- Indexes of sensors
   Front_Right_Index : constant := 0;
   Front_Left_Index  : constant := 1;
   -- Setup sensor configuration
   package HCSR04Sensor is new Drivers.HCSR04
     (
      (Front_Right_Index => -- Front right
         (Echo_Pin => MB_P0, Trigger_Pin => MB_P2),
       Front_Left_Index  => -- Front left
         (Echo_Pin => MB_P1, Trigger_Pin => MB_P13)));

   -- Sense task body, trigging the HC-SR04 ultrasonic sensor
   task body Sense is
      Start : Time := Clock;
   begin
      loop
         Start := Clock;
         -- Trigger an ultrasonic sensor
         HCSR04Sensor.Trigger;
         -- Delay 60ms using delay until to reduce jitter
         delay until Start + Milliseconds (60);
      end loop;
   end Sense;

   function Is_Working return Boolean is
   begin
      return HCSR04Sensor.Get_Working;
   end Is_Working;

   function Get_Front_Right_Distance return HCSR04Distance is
   begin
      return HCSR04Sensor.Get_Distance (Front_Right_Index);
   end Get_Front_Right_Distance;

   function Get_Front_Left_Distance return HCSR04Distance is
   begin
      return HCSR04Sensor.Get_Distance (Front_Left_Index);
   end Get_Front_Left_Distance;
end Tasks.Sense;
