with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.I2C;
with DFR0548;
with HAL;

package body Tasks.Act is
   MotorDriver    : DFR0548.MotorDriver (MicroBit.I2C.ControllerExt);
   Speed_Max      : constant := Integer (Speed'Last);
   Forward_Speed  : Speed    := 0;
   Right_Speed    : Speed    := 0;
   Rotation_Speed : Speed    := 0;

   function Speed_To_Wheel (Speed : Integer) return DFR0548.Wheel is
   begin
      return
        (HAL.UInt12 (if Speed > 0 then Speed else 0),
         HAL.UInt12 (if Speed < 0 then (abs Speed) else 0));
   end Speed_To_Wheel;

   task body Act is
      Start             : Time := Clock;
      Denominator       : Integer;
      Forward           : Integer;
      Right             : Integer;
      Rotation          : Integer;
      Motor_Right_Front : Integer;
      Motor_Right_Back  : Integer;
      Motor_Left_Front  : Integer;
      Motor_Left_Back   : Integer;
   begin
      -- Initialize motor driver
      if not MicroBit.I2C.InitializedExt then
         MicroBit.I2C.InitializeExt;
      end if;

      MotorDriver.Initialize;
      MotorDriver.Set_Frequency_Hz (50); -- Set prescaler

      loop
         Start       := Clock;
         Forward     := Integer (Forward_Speed);
         Right       := Integer (Right_Speed);
         Rotation    := Integer (Rotation_Speed);
         -- implementasjon
         Denominator := abs Forward + abs Right + abs Rotation;

         -- Ensure Denominator is at least Speed'Last (4095)
         if Denominator < Speed_Max then
            Denominator := Speed_Max;
         end if;

         Motor_Right_Front :=
           ((Forward - Right - Rotation) * Speed_Max) / Denominator;
         Motor_Right_Back  :=
           ((Forward + Right - Rotation) * Speed_Max) / Denominator;
         Motor_Left_Front  :=
           ((Forward + Right + Rotation) * Speed_Max) / Denominator;
         Motor_Left_Back   :=
           ((Forward - Right + Rotation) * Speed_Max) / Denominator;

         MotorDriver.Set_PWM_Wheels
           (Speed_To_Wheel (Motor_Right_Front),
            Speed_To_Wheel (Motor_Right_Back),
            Speed_To_Wheel (Motor_Left_Front),
            Speed_To_Wheel (Motor_Left_Back));

         delay until Start + Milliseconds (20);
      end loop;
   end Act;

   procedure Set_Forward (Forward : Speed) is
   begin
      Forward_Speed := Forward;
   end Set_Forward;

   procedure Set_Right (Right : Speed) is
   begin
      Right_Speed := Right;
   end Set_Right;

   procedure Set_Rotation (Rotation : Speed) is
   begin
      Rotation_Speed := Rotation;
   end Set_Rotation;

   procedure Stop is
   begin
      Forward_Speed  := 0;
      Right_Speed    := 0;
      Rotation_Speed := 0;
   end Stop;
end Tasks.Act;
