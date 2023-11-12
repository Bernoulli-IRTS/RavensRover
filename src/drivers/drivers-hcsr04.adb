with Ada.Real_Time;          use Ada.Real_Time;
with MicroBit.TimeHighspeed; use MicroBit.TimeHighspeed;
with Interrupts.GPIO;        use Interrupts.GPIO;

package body Drivers.HCSR04 is
   Current_Index  : Integer := Pins'First;
   Previous_Index : Integer := Pins'First;
   Last_Trigger   : Time    := Time_First;

   type WorkingArray is array (SensorIndex) of Boolean;
   Working : WorkingArray := (others => False);
   pragma Atomic (Working);

   function Get_Distance (Sensor : SensorIndex) return HCSR04Distance is
      -- Get pulse from protected InterruptHandler
      Pulse    : Pin_Pulse :=
        InterruptHandler.Get_Pulse (Pins (Integer (Sensor)).Echo_Pin);
      Distance : Float;
   begin
      -- Throw exception if the sensor is not working
      if not Working (Sensor) then
         raise HCSR04_Sensor_Except
           with "Erroring reading sensor at index: " &
           SensorIndex'Image (Sensor);
      end if;

      -- Calculate Distance from duration
      Distance := Float (To_Duration (Pulse.Duration)) * (1_000_000.0 / 58.0);

      -- Check if out of range or not
      return
        (if Distance > Float (HCSR04Distance'Last) then HCSR04Distance'Last
         else HCSR04Distance (Distance));
   end Get_Distance;

   procedure Trigger is
      Trigger_Pin    : GPIO_Point := Pins (Current_Index).Trigger_Pin;
      -- Get the previous pulse
      Previous_Pulse : Pin_Pulse  :=
        InterruptHandler.Get_Pulse (Pins (Previous_Index).Echo_Pin);
   begin
      -- Check if the last measurement succeeded by timestamp, duration and if the edge is the correct one
      Working (SensorIndex (Previous_Index)) :=
        not
        (Last_Trigger > Previous_Pulse.Timestamp or
         Previous_Pulse.Duration = Time_Span_Last or
         Previous_Pulse.Edge /= Pulse_Falling);

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
