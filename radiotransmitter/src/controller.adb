with HAL;       use HAL;
with HAL.UART;  use HAL.UART;
with nRF.Device;
with nRF.Radio; use nRF.Radio;
with nRF.UART;  use nRF.UART;
with MicroBit.Console; -- Ensure UART is configured
with Radio;     use Radio;

package body Controller is
   UART : nRF.UART.UART_Device renames nRF.Device.UART_0;

   type UartUint16 is array (1 .. 3) of Unsigned_16;
   type UartInt16 is array (1 .. 3) of Integer_16;

   procedure Poll_UART (Packet : in out MicroBit.Radio.RadioData) is
      Buffer     : UART_Data_8b (1 .. 7);
      Uint16Data : UartUint16 with
        Import, Convention => Ada, Address => Buffer (2)'Address,
        Alignment          => 1;
      Int16Data  : UartInt16 with
        Import, Convention => Ada, Address => Buffer (2)'Address,
        Alignment          => 1;
      Start      : Time    := Clock;
      I          : Integer := 0;
   begin
      -- Manually implement the UART reading as the nRF.UART jank does not implement timeouts
      for B of Buffer loop
         while UART.Periph.EVENTS_RXDRDY = 0 loop
            -- Handle timeout
            if I mod 100 = 0 and Clock - Start > Milliseconds (10) then
               return;
            end if;

            I := I + 1;
         end loop;

         Start := Clock;
         B := UART.Periph.RXD.RXD;

         UART.Periph.EVENTS_RXDRDY := 0;
      end loop;

      -- Get kind of command
      case Buffer (1) is
         -- Move
         when 1 =>
            Transmit_Move
              (Packet, Radio.MoveSpeed (Int16Data (1)),
               Radio.MoveSpeed (Int16Data (2)),
               Radio.MoveSpeed (Int16Data (3)));
            -- Speaker
         when 2 =>
            Transmit_Speaker (Packet, Uint16Data (1), Uint16Data (2));
         when others =>
            null;
      end case;
   end Poll_UART;

   type MoveDataIndex is range 1 .. MovementSize;
   type MoveDataArray is array (MoveDataIndex) of UInt8;

   procedure Transmit_Move
     (Packet : in out MicroBit.Radio.RadioData; Forward : MoveSpeed;
      Right  :        MoveSpeed; Rotation : MoveSpeed)
   is
      Kind     : RadioKind := Move;
      KindData : UInt8 with
        Import, Convention => Ada, Address => Kind'Address, Alignment => 1;
      Move : Movement := (Forward => Forward, Right => Right, Rot => Rotation);
      MoveData : MoveDataArray with
        Import, Convention => Ada, Address => Move'Address, Alignment => 1;
   begin
      -- Set packet kind
      Packet.Payload (1) := KindData;
      -- Manually copy byte per byte as Payload_Data is already constrained...
      for I in MoveDataIndex'First .. MoveDataIndex'Last loop
         Packet.Payload (UInt8 (I + 1)) := MoveData (I);
      end loop;

      MicroBit.Radio.Transmit (Packet);
   end Transmit_Move;

   type SpeakerNoteIndex is range 1 .. SpeakerNoteSize;
   type SpeakerNoteArray is array (SpeakerNoteIndex) of UInt8;

   procedure Transmit_Speaker
     (Packet : in out MicroBit.Radio.RadioData; Pitch : Unsigned_16;
      Volume :        Unsigned_16)
   is
      Kind     : RadioKind   := SetSpeaker;
      KindData : UInt8 with
        Import, Convention => Ada, Address => Kind'Address, Alignment => 1;
      Note     : SpeakerNote := (Pitch => Pitch, Volume => Volume);
      NoteData : SpeakerNoteArray with
        Import, Convention => Ada, Address => Note'Address, Alignment => 1;
   begin
      -- Set packet kind
      Packet.Payload (1) := KindData;
      -- Manually copy byte per byte as Payload_Data is already constrained...
      for I in SpeakerNoteIndex'First .. SpeakerNoteIndex'Last loop
         Packet.Payload (UInt8 (I + 1)) := NoteData (I);
      end loop;

      MicroBit.Radio.Transmit (Packet);
   end Transmit_Speaker;
end Controller;
