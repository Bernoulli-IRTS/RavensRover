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
   procedure Set_Forward(Forward : Speed) is begin
      null;
   end Set_Forward;

   procedure Set_Right(Right : Speed) is begin
      null;
   end Set_Right;

   procedure Set_Rotation(Rotation : Speed) is begin
     null;
   end Set_Rotation;

end Tasks.Act;
