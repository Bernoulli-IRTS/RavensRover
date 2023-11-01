with Ada.Real_Time; use Ada.Real_Time;
with Drivers; use Drivers;

package body Tasks.Think is
   
   task body Think is
      Start : Time := Clock;
   begin
      loop
         Start := Clock;
         -- 8) here goes implementation
         delay until Start + Milliseconds (10);
      end loop;
   end Think;
   
   function Is_Obstacle_Ahead return Where_Obstacle is
      -- Read sensor data
      Left_Sensor : HCSR04Distance := Sense.Get_Front_Left_Distance;
      Right_Sensor : HCSR04Distance := Sense.Get_Front_Right_Distance;
   begin
      -- Returns enumerator type according to what the sensor reads
      if Left_Sensor > 10.0 and Right_Sensor > 10.0 then
         return Both;
      elsif Left_Sensor > 10.0 then
         return Left;
      elsif Right_Sensor > 10.0 then
         return Right;
      end if;
      return None;
   end Is_Obstacle_Ahead;
   
end Tasks.Think;
