with Ada.Real_Time;          use Ada.Real_Time;
with MicroBit.Accelerometer;
with MicroBit.Buttons;       use MicroBit.Buttons;
with MicroBit.Console;       use MicroBit.Console;
with MicroBit.Radio;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;
with Radio;                  use Radio;
with Controller;

with LSM303AGR; use LSM303AGR;

procedure Main with
  Priority => 0
is
   Button_A_Pin : constant := 5;
   -- Default packet
   Packet           : MicroBit.Radio.RadioData;
   Data             : All_Axes_Data;
   Forward          : Integer;
   Rotation         : Integer;
   Button_A_Pressed : Boolean;
   Button_B_Pressed : Boolean;
   Last_Transmit    : Time := Clock;
begin
   MicroBit.Radio.Setup
     (RadioFrequency => Radio.RadioFrequency, Length => Radio.Length,
      Version        => Radio.Version, Group => Radio.Group,
      Protocol       => Radio.Protocol);

   Packet.Length   := Radio.Length;
   Packet.Version  := Radio.Version;
   Packet.Group    := Radio.Group;
   Packet.Protocol := Radio.Protocol;

   loop
      begin
         Button_A_Pressed := State (Button_A) = Pressed;
         Button_B_Pressed := State (Button_B) = Pressed;

         if (Button_A_Pressed or Button_B_Pressed) and
           Clock - Last_Transmit > Milliseconds (10)
         then
            -- Get accelerometer data
            Data := MicroBit.Accelerometer.AccelData;

            -- Calculate Forward from Z axis if over 80 (threshold)
            if abs Data.Z > 80 then
               Forward :=
                 -Integer'Max
                   (Integer'Min (Integer (Data.Z) * 16, 4_095), -4_095);
            else
               Forward := 0;
            end if;

            -- Calculate Rotation from X axis if over 80 (threshold)
            if abs Data.X > 80 then
               Rotation :=
                 -Integer'Max
                   (Integer'Min (Integer (Data.X) * 16, 4_095), -4_095);
            else
               Rotation := 0;
            end if;

            Controller.Transmit_Move
              (Packet, MoveSpeed (Forward),
            -- If only A or B is held, move left/right

               (if Button_A_Pressed /= Button_B_Pressed then
                  (if Button_B_Pressed then 2_048 else -2_048)
                else 0),
               MoveSpeed (Rotation));

            Last_Transmit := Clock;
         end if;

         -- Poll UART
         Controller.Poll_UART (Packet);
      exception
         when others =>
            null; -- Ignore exceptions for now
      end;
   end loop;
end Main;
