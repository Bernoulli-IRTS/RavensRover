with Ada.Real_Time;          use Ada.Real_Time;
with MicroBit.Radio;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;
with Radio;
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
      Version        => Radio.Version, Group => Radio.Group, Protocol => Radio.Protocol);

   Packet.Length := Radio.Length;
   Packet.Version:= Radio.Version;
   Packet.Group := Radio.Group;
   Packet.Protocol := Radio.Protocol;

   loop
      if Set(Button_A_Pin) then
         Controller.Transmit_Move(Packet, 4095, 0, 0);
      end if;

      delay To_Duration(Milliseconds (10));
   end loop;
end Main;
