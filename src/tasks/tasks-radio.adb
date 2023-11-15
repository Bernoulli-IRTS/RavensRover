with Ada.Real_Time;          use Ada.Real_Time;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;
with MicroBit.Radio;
with Profiler;
with Radio;                  use Radio;
with Tasks.Act;

package body Tasks.Radio is
   Enabled : Boolean := True;
   pragma Atomic (Enabled);

   Speaker_Pin : constant := 27;
   Last_Msg    : Time     := Clock;

   -- Handle move packets
   procedure HandleMove (Packet : MicroBit.Radio.RadioData) is
      Move : Movement with
        Import, Convention => Ada, Address => Packet.Payload (2)'Address,
        Alignment          => 1;
   begin
      Act.Set_Forward (Act.Speed (Move.Forward));
      Act.Set_Right (Act.Speed (Move.Right));
      Act.Set_Rotation (Act.Speed (Move.Rot));
   end HandleMove;

   -- Handle set speaker packets
   procedure HandleSetSpeaker (Packet : MicroBit.Radio.RadioData) is
      Note : SpeakerNote with
        Import, Convention => Ada, Address => Packet.Payload (2)'Address,
        Alignment          => 1;
   begin
      if Integer (Note.Pitch) = 0 then
         Set (Speaker_Pin, False);
      else
         Write (Speaker_Pin, Analog_Value (Note.Volume));

         Set_Analog_Period_Us (1_000_000 / Natural (Note.Pitch));
      end if;
   end HandleSetSpeaker;

   -- Handle packet and find kind of packet
   procedure HandlePacket (Packet : MicroBit.Radio.RadioData) is
      Kind : RadioKind with
        Import, Convention => Ada, Address => Packet.Payload (1)'Address;
   begin
      -- Narrow down what data the payload contains
      case Kind is
         when Stop =>
            Act.Stop;
         when Move =>
            HandleMove (Packet);
         when SetSpeaker =>
            HandleSetSpeaker (Packet);

            -- Ignore
         when others =>
            null;
      end case;
   end HandlePacket;

   task body Radio is
      Start           : Time;
      Radio_Receiving : Boolean := False;
      Enabled         : Boolean;
      RadioPacket     : MicroBit.Radio.RadioData;
#if PROFILING
      Trace           : Profiler.Trace;
#end if;
   begin
      MicroBit.Radio.Setup
        (RadioFrequency => RadioFrequency, Length => Length,
         Version        => Version, Group => Group, Protocol => Protocol);

      loop
         Start   := Clock;
#if PROFILING
         Trace   := Profiler.StartTrace ("Radio", Start);
#end if;
         -- Check if Radio is enabled
         Enabled := Is_Enabled;
         begin
            -- Enable or disable radio RX depending on if Radio is enabled
            if Radio_Receiving /= Enabled then
               if Enabled then
                  MicroBit.Radio.StartReceiving;
               else
                  MicroBit.Radio.StopReceiving;
               end if;

               Radio_Receiving := Enabled;
            end if;

            -- Logic for when radio is enabled
            if Enabled then
               -- Read data from Radio
               while MicroBit.Radio.DataReady loop
                  HandlePacket (MicroBit.Radio.Receive);
                  Last_Msg := Start;
               end loop;

               -- Automatically stop if no msg in 100ms (Safety)
               if Start - Last_Msg > Milliseconds (100) then
                  Act.Stop;
               end if;
            end if;
            -- Handle exceptions from radio
         exception
            when others =>
               if Enabled then
                  Act.Stop;
               end if;
         end;
#if PROFILING
         Profiler.EndTrace (Trace);
#end if;
         delay until Start + Milliseconds (10);
      end loop;
   end Radio;

   function Is_Enabled return Boolean is
   begin
      return Enabled;
   end Is_Enabled;

   procedure Toggle is begin
      Enabled := not Enabled;
   end Toggle;
end Tasks.Radio;
