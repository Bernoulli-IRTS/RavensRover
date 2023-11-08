with Tasks.Act;
with Tasks.Sense;
with Tasks.Think;
with Profiler;

-- Main procedure of RavensRover, it has the lowest priority and does nothing meaningful other than spinning so there is no reset
procedure Main with
  Priority => 0
is
begin
   -- Do a loop in main otherwise the micro:bit will constantly reset
   loop
      null;
   end loop;
end Main;
