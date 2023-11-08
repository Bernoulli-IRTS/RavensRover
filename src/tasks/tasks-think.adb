with Ada.Real_Time; use Ada.Real_Time;
with Drivers;       use Drivers;
with Tasks.Act;

package body Tasks.Think is

   task body Think is
      Start : Time := Clock;
      Obstacle : Where_Obstacle;
   begin
      -- Initial delay, seems to decrease the chance of triggering overcurrent
      delay(3.0);
      loop
         Start := Clock;
         Obstacle := Is_Obstacle_Ahead;

         Act.Stop;
         if Sense.Is_Working then
            if Obstacle = Both or Obstacle = Left then
               Act.Set_Rotation(2_048);
            elsif Obstacle = Right then
               Act.Set_Rotation(-2_048);
            else
               Act.Set_Forward(2_048);
            end if;
         end if;

         delay until Start + Milliseconds (10);
      end loop;
   end Think;

   function Is_Obstacle_Ahead return Where_Obstacle is
      -- Read sensor data
      Left_Sensor  : HCSR04Distance := Sense.Get_Front_Left_Distance;
      Right_Sensor : HCSR04Distance := Sense.Get_Front_Right_Distance;
   begin
      -- Returns enumerator type according to what the sensor reads
      if Left_Sensor < 10.0 and Right_Sensor < 10.0 then
         return Both;
      elsif Left_Sensor < 10.0 then
         return Left;
      elsif Right_Sensor < 10.0 then
         return Right;
      end if;
      return None;
   end Is_Obstacle_Ahead;


end Tasks.Think;
