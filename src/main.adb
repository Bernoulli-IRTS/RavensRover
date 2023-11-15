with Ada.Real_Time;    use Ada.Real_Time;
with MicroBit.Buttons; use MicroBit.Buttons;
with Tasks.Act;
with Tasks.Radio;
with Tasks.Sense;
with Tasks.Think;
with Profiler;

-- Main procedure of RavensRover, it has the lowest priority and does nothing meaningful other letting one toggle the radio being enabled
-- It is not considered a real-time task by us!
procedure Main with
  Priority => 0
is
   Start        : Time;
   Last_A_Press : Time := Clock;
begin
   -- Do a loop in main otherwise the micro:bit will constantly reset
   loop
      Start := Clock;

      if State (Button_A) = Pressed then
         -- Debounce
         if Start - Last_A_Press > Milliseconds (400) then
            Tasks.Radio.Toggle;
         end if;

         Last_A_Press := Start;
      end if;

      delay until Start + Milliseconds (10);
   end loop;
end Main;
