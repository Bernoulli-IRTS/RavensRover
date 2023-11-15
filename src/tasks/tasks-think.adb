with Ada.Real_Time; use Ada.Real_Time;
with Drivers;       use Drivers;
with Tasks.Act;
with Tasks.Radio;
with Profiler;

package body Tasks.Think is

   task body Think is
      Last_Obstacle_Time : Time := Clock;
      Start              : Time := Clock;
      Obstacle           : Where_Obstacle;
      Last_Obstacle      : Where_Obstacle;
#if PROFILING
      Trace              : Profiler.Trace;
#end if;
   begin
      loop
         Start := Clock;
#if PROFILING
         Trace := Profiler.StartTrace ("Think", Start);
#end if;
         -- Skip if radio controlling is enabled
         if not Radio.Is_Enabled then
            -- Main block for thinking
            begin
               Obstacle := Is_Obstacle_Ahead;

               -- Keep track of last obstacle
               if Obstacle /= None then
                  Last_Obstacle := Obstacle;
                  Last_Obstacle_Time := Clock;
               end if;

               Act.Stop;
               if Clock - Last_Obstacle_Time < Milliseconds(400) then
                  if Last_Obstacle = Both or Last_Obstacle = Left then
                     Act.Set_Rotation (2_048);
                  elsif Last_Obstacle = Right then
                     Act.Set_Rotation (-2_048);
                  end if;
               else
                  Act.Set_Forward (2_048);
               end if;
            -- Handle exceptions from HC-SR04 not reading
            exception
               when E : HCSR04_Sensor_Except =>
                  Act.Stop;
            end;
         end if;

#if PROFILING
         Profiler.EndTrace (Trace);
#end if;

         delay until Start + Milliseconds (10);
      end loop;
   end Think;

   function Is_Obstacle_Ahead return Where_Obstacle is
      -- Read sensor data
      Left_Sensor  : HCSR04Distance := Sense.Get_Front_Left_Distance;
      Right_Sensor : HCSR04Distance := Sense.Get_Front_Right_Distance;
   begin
      -- Returns enumerator type according to what the sensor reads
      if Left_Sensor < 20.0 and Right_Sensor < 20.0 then
         return Both;
      elsif Left_Sensor < 20.0 then
         return Left;
      elsif Right_Sensor < 20.0 then
         return Right;
      end if;
      return None;
   end Is_Obstacle_Ahead;

end Tasks.Think;
