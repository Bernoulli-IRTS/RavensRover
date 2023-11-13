with Ada.Real_Time;          use Ada.Real_Time;
with MicroBit.Radio;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;
with MicroBit.Buttons;       use MicroBit.Buttons;
with Radio;                  use Radio;
with Controller;

procedure Main with
  Priority => 0
is
   Button_A_Pin : constant := 5;
   -- Default packet
   Packet : MicroBit.Radio.RadioData;
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
      if State (Button_A) = Pressed then
         Controller.Transmit_Move (Packet, 4_095, 0, 0);
      end if;

      if State (Button_B) = Pressed then
         Controller.Transmit_Move (Packet, -4_095, 0, 0);
      end if;

      delay To_Duration (Milliseconds (10));
   end loop;
end Main;
