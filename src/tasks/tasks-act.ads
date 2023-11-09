with Priorities;

package Tasks.Act is
   task Act with
     Priority => Priorities.Act
   ;
   subtype Speed is Integer range -4_095 .. 4_095;

   procedure Set_Forward (Forward : Speed);

   procedure Set_Right (Right : Speed);

   procedure Set_Rotation (Rotation : Speed);

   procedure Stop;
end Tasks.Act;
