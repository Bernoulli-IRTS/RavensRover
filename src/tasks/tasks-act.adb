with Ada.Real_Time;  use Ada.Real_Time;

package body Tasks.Act is
   task body Act is
      Start : Time := Clock;
   begin
      loop
         Start := Clock;
         -- implementasjon
         delay until Start + Milliseconds (20);
      end loop;
   end Act;

   -- TODO make functions to set directions
   -- set forward
   -- set right
   -- set rotation

end Tasks.Act;
