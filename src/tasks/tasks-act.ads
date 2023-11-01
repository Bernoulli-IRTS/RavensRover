

package Tasks.Act is
   task Act with
     Priority => 2;
   type Speed is range -4096..4096;

   procedure Set_Forward(Forward : Speed);

   procedure Set_Right(Right : Speed);

   procedure Set_Rotation(Rotation : Speed);


end Tasks.Act;
