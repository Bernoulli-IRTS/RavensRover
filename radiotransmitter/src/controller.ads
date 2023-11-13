with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Radio;
with Radio;

package Controller is
   procedure Transmit_Move
     (Packet : in out MicroBit.Radio.RadioData; Forward : Radio.MoveSpeed;
      Right  :        Radio.MoveSpeed; Rotation : Radio.MoveSpeed);
end Controller;
