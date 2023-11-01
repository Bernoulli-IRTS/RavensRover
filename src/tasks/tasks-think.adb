with Ada.Real_Time; use Ada.Real_Time;
with Drivers;       use Drivers;
with Tasks.Act;

package body Tasks.Think is

   task body Think is
      Start : Time := Clock;
   begin
      loop
         Start := Clock;
         delay (3.0);
         Act.Set_Rotation (2_048);
         delay (0.5);
         Act.Stop;
         delay (3.0);
         Act.Set_Rotation (-2_048);
         delay (0.5);
         Act.Stop;
         delay (0.5);
         Act.Set_Forward (1_048);
         delay (0.5);
         Act.Stop;
         delay (0.5);
         Act.Set_Forward (-1_048);
         delay (0.5);
         Act.Stop;
         delay (0.5);
         Act.Set_Right (1_048);
         delay (0.5);
         Act.Stop;
         delay (0.5);
         Act.Set_Right (-1_048);
         delay (0.5);
         Act.Stop;
         delay (0.5);

         delay until Start + Milliseconds (10);
      end loop;
   end Think;

   function Is_Obstacle_Ahead return Where_Obstacle is
      -- Read sensor data
      Left_Sensor  : HCSR04Distance := Sense.Get_Front_Left_Distance;
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
