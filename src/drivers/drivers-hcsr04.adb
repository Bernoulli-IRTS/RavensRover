with Ada.Real_Time;          use Ada.Real_Time;
with MicroBit.TimeHighspeed; use MicroBit.TimeHighspeed;
with Interrupts.GPIO;        use Interrupts.GPIO;

package body Drivers.HCSR04 is
   Current_Index  : Integer := Trigger_Pins'First;
   Previous_Index : Integer := Trigger_Pins'First;
   Last_Trigger   : Time    := Time_First;

   type DistancesArray is
     array (Trigger_Pins'First .. Trigger_Pins'Last) of Distance_cm;

   -- Keep track of the pin pulse configurations
   Distances   : DistancesArray := (others => Distance_cm'First);
   -- Keep track of if an echo failed during this loop
   Failed_Loop : Boolean        := False;
   -- Sets true if there are successful reading
   Working     : Boolean        := True;
   -- Don't fail the first one just because there is no previous trigger
   First       : Boolean        := True;

   function Get_Distance (Sensor : SensorIndex) return Distance_cm is
   begin
      return Distances (Integer (Sensor));
   end Get_Distance;

   function Get_Working return Boolean is
   begin
      return Working;
   end Get_Working;

   procedure Trigger is
      Trigger_Pin    : GPIO_Point := Trigger_Pins (Current_Index);
      -- Get the previous pulse
      Previous_Pulse : Pin_Pulse  := InterruptHandler.Get_Pulse (Echo_Pin);
      Distance       : Float;
   begin
      -- Check if the last measurement succeeded by timestamp, duration and if the edge is the correct one
      if Last_Trigger > Previous_Pulse.Timestamp or
        Previous_Pulse.Duration = Time_Span_Last or
        Previous_Pulse.Edge /= Pulse_Falling
      then
         -- Don't fail the first cycle
         if First then
            -- Setup the interrupt handler to keep track of high pulses on the echo pin
            Configure_Pin (Echo_Pin, Pulse_High);

            First := False;
         else
            -- Failed reading
            Failed_Loop                := True;
            Working                    := False;
            Distances (Previous_Index) := 0.0;
         end if;
      else
         -- Calculate distance in cm
         Distance :=
           Float (To_Duration (Previous_Pulse.Duration)) / (1_000.0 * 58.0);

         -- Update with new reading
         if Distance > Float (Distance_cm'Last) then
            Distances (Previous_Index) := Distance_cm'Last;
         else
            Distances (Previous_Index) := Distance_cm (Distance);
         end if;
      end if;

      -- Trigger the trigger pin high
      Trigger_Pin.Set;
      -- Wait ~10us per HC-SR04 datasheet
      Delay_Us (10);
      -- Trigger the trigger pin low
      Trigger_Pin.Clear;

      Last_Trigger := Clock;

      -- Keep track of the previous index
      Previous_Index := Current_Index;
      -- As there is no way to gurantee the array index range will be zero based mod is pretty much useless here
      Current_Index  :=
        (if Current_Index = Trigger_Pins'Last then Trigger_Pins'First
         else Current_Index + 1);

      -- Reset failed loop if at start
      if Current_Index = Trigger_Pins'First then
         Working     := not Failed_Loop;
         Failed_Loop := False;
      end if;
   end Trigger;
end Drivers.HCSR04;
