with nRF.Radio; use nRF.Radio;
with HAL; use HAL;
with Radio; use Radio;

package body Controller is
   type MoveDataIndex is range 1 .. MovementSize;
   type MoveDataArray is array (MoveDataIndex) of Uint8;

   procedure Transmit_Move(Packet : in out MicroBit.Radio.RadioData; Forward : MoveSpeed; Right : MoveSpeed; Rotation : MoveSpeed) is
      Kind : RadioKind := Move;
      KindData : Uint8 with
        Import, Convention => Ada, Address => Kind'Address,
        Alignment          => 1;
      Move : Movement := (Forward => Forward, Right => Right, Rot => Rotation);
      MoveData : MoveDataArray with
        Import, Convention => Ada, Address => Move'Address,
        Alignment          => 1;
   begin
      -- Set packet kind
      Packet.Payload(1) := KindData;
      -- Manually copy byte per byte is Payload_Data is already constrained...
      for I in MoveDataIndex'First..MoveDataIndex'Last loop
         Packet.Payload(UInt8(I + 1)) := MoveData(I);
       end loop;

      MicroBit.Radio.Transmit(Packet);
   end Transmit_Move;
end Controller;
