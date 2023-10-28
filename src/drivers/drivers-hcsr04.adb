with Ada.Real_Time;          use Ada.Real_Time;
with MicroBit.TimeHighspeed; use MicroBit.TimeHighspeed;
with Interrupts.GPIO;        use Interrupts.GPIO;

package body Drivers.HCSR04 is
   Current_Index  : Integer := Pins'First;
   Previous_Index : Integer := Pins'First;
   Last_Trigger   : Time    := Time_First;

   type DistancesArray is array (Pins'First .. Pins'Last) of HCSR04Distance;

   -- Keep track of the pin pulse configurations
   Distances   : DistancesArray := (others => HCSR04Distance'First);
   -- Keep track of if an echo failed during this loop
   Failed_Loop : Boolean        := False;
   -- Sets true if there are successful readings through a reading cycle
   Working     : Boolean        := False;
   -- Don't fail the first one just because there is no previous trigger
   First       : Boolean        := True;

   function Get_Distance (Sensor : SensorIndex) return HCSR04Distance is
   begin
      return Distances (Integer (Sensor));
   end Get_Distance;

   function Get_Working return Boolean is
   begin
      return Working;
   end Get_Working;

   procedure Trigger is
      Trigger_Pin    : GPIO_Point := Pins (Current_Index).Trigger_Pin;
      -- Get the previous pulse
      Previous_Pulse : Pin_Pulse  :=
        InterruptHandler.Get_Pulse (Pins (Previous_Index).Echo_Pin);
      Distance       : Float;
   begin
      -- Check if the last measurement succeeded by timestamp, duration and if the edge is the correct one
      if Last_Trigger > Previous_Pulse.Timestamp or
        Previous_Pulse.Duration = Time_Span_Last or
        Previous_Pulse.Edge /= Pulse_Falling
      then
         -- Failed reading
         Failed_Loop                := True;
         Working                    := False;
         Distances (Previous_Index) := 0.0;
      else
         -- Calculate distance in cm
         Distance :=
           Float (To_Duration (Previous_Pulse.Duration)) *
           (1_000_000.0 / 58.0);

         -- Update with new reading
         if Distance > Float (HCSR04Distance'Last) then
            Distances (Previous_Index) := HCSR04Distance'Last;
         else
            Distances (Previous_Index) := HCSR04Distance (Distance);
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
        (if Current_Index = Pins'Last then Pins'First else Current_Index + 1);

      -- Reset failed loop if at start
      if Current_Index = Pins'First then
         Working     := not Failed_Loop;
         Failed_Loop := False;
      end if;
   end Trigger;

   -- Variables used for init
   GPIO_Config : GPIO_Configuration;
begin
   -- Configure trigger pin outputs
   for Pin of Pins loop
      Configure_Interrupt_Pin (Pin.Echo_Pin, Pulse_High);

      GPIO_Config.Mode         := Mode_Out;
      GPIO_Config.Resistors    := No_Pull;
      GPIO_Config.Input_Buffer := Input_Buffer_Disconnect;
      GPIO_Config.Sense        := Sense_Disabled;
      Pin.Trigger_Pin.Configure_IO (GPIO_Config);
   end loop;
end Drivers.HCSR04;
