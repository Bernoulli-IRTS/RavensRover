with Ada.Real_Time; use Ada.Real_Time;
with Drivers;       use Drivers;
with Tasks.Act;
with Profiler;

package body Tasks.Think is

   task body Think is
      Start    : Time := Clock;
      Obstacle : Where_Obstacle;
#if PROFILING
      Trace    : Profiler.Trace;
#end if;
   begin
      -- Initial delay, seems to decrease the chance of triggering overcurrent
      delay (1.0);
      loop
         Start := Clock;
#if PROFILING
         Trace := Profiler.StartTrace ("Think", Start);
#end if;
         -- Main block for thinking
         begin
            Obstacle := Is_Obstacle_Ahead;

            Act.Stop;
            if Obstacle = Both or Obstacle = Left then
               Act.Set_Rotation (2_048);
            elsif Obstacle = Right then
               Act.Set_Rotation (-2_048);
            else
               Act.Set_Forward (2_048);
            end if;
            -- Handle exceptions from HC-SR04 not reading
         exception
            when E : HCSR04_Sensor_Except =>
               Act.Stop;
         end;

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
