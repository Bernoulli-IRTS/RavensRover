with Interfaces; use Interfaces;

package Radio is
   type RadioKind is (Stop, Move, SetSpeaker);
   for RadioKind'Size use 8; -- This is in bits!
   for RadioKind use (Stop => 0, Move => 1, SetSpeaker => 2);
   RadioKindSize : constant := 1;

   type MoveSpeed is new Integer_16 range -4_096 .. 4_096;

   type Movement is record
      Forward : MoveSpeed;
      Right   : MoveSpeed;
      Rot     : MoveSpeed;
   end record;
   MovementSize : constant := 2 * 3;
   pragma Pack (Movement);

   type SpeakerNote is record
      Pitch  : Unsigned_16;
      Volume : Unsigned_16;
   end record;
   SpeakerNoteSize : constant := 2 * 2;
   pragma Pack (SpeakerNote);

   RadioFrequency : constant := 2_407;
   -- Static MicroBit radio header size (3 bytes)
   HeaderSize     : constant := 3;
   Length         : constant := -- Total length of packet
     HeaderSize + RadioKindSize + Integer'Max (MovementSize, SpeakerNoteSize);
   -- Values taken from wireless_radio example
   Version        : constant := 12;
   Protocol       : constant := 14;
   -- Our group
   Group          : constant := 37;
end Radio;
