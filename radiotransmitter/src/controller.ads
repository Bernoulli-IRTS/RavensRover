with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Radio;
with Interfaces;    use Interfaces;
with Radio;

package Controller is
   -- Poll UART for commands
   procedure Poll_UART (Packet : in out MicroBit.Radio.RadioData);

   procedure Transmit_Move
     (Packet : in out MicroBit.Radio.RadioData; Forward : Radio.MoveSpeed;
      Right  :        Radio.MoveSpeed; Rotation : Radio.MoveSpeed);

   procedure Transmit_Speaker
     (Packet : in out MicroBit.Radio.RadioData; Pitch : Unsigned_16;
      Volume :        Unsigned_16);
end Controller;
