with MicroBit.TimeHighspeed; use MicroBit.TimeHighspeed;
with Interrupts.GPIO;

package body Drivers.HCSR04 is
   Current_Index : Integer := Trigger_Pins'First;

   procedure Trigger is
      Trigger_Pin : GPIO_Point := Trigger_Pins (Current_Index);
   begin
      -- Trigger the trigger pin high
      Trigger_Pin.Set;
      -- Wait ~10us per HC-SR04 datasheet
      Delay_Us (10);
      -- Trigger the trigger pin low
      Trigger_Pin.Clear;

      -- As there is no way to gurantee the array index range will be zero based mod is pretty much useless here
      Current_Index :=
        (if Current_Index = Trigger_Pins'Last then Trigger_Pins'First
         else Current_Index + 1);
   end Trigger;
end Drivers.HCSR04;
