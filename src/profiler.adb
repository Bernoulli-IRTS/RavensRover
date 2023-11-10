with Ada.Real_Time;    use Ada.Real_Time;
with Ada.Containers.Vectors;
with MicroBit.Console; use MicroBit.Console;

package body Profiler is
   SubmitBufferSize : constant := 16;
   type SubmitBufferIndex is mod SubmitBufferSize;
   type SubmitBufferArray is array (SubmitBufferIndex) of Trace;
   -- Ring buffer based queue
   SubmitBuffer : SubmitBufferArray :=
     (others =>
        (Name => To_Unbounded_String (""), Start => Clock,
         Dur  => Duration'First));
   Head         : SubmitBufferIndex := SubmitBufferIndex'First;
   Tail         : SubmitBufferIndex := SubmitBufferIndex'First;

   function StartTrace (Trace_Name : String) return Trace is
   begin
      return
        (Name => To_Unbounded_String (Trace_Name), Start => Clock,
         Dur  => Duration'First);
   end StartTrace;

   function StartTrace (Trace_Name : String; Trace_Start : Time) return Trace
   is
   begin
      return
        (Name => To_Unbounded_String (Trace_Name), Start => Trace_Start,
         Dur  => Duration'First);
   end StartTrace;

   procedure EndTrace (Data : in out Trace) is
      Current_Tail : SubmitBufferIndex := Tail;
   begin
      Data.Dur := To_Duration (Clock - Data.Start);
      if (Current_Tail + 1) /= Head then
         Tail                        := Current_Tail + 1;
         SubmitBuffer (Current_Tail) := Data;
      end if;
   end EndTrace;

#if PROFILING
   task body ProfilerFlush is
      Start  : Time;
      Data   : Trace;
      Popped : Boolean := False;
   begin
      loop
         Start := Clock;

         while Tail /= Head loop
            Data := SubmitBuffer (Head);

            Put_Line
              (ASCII.ENQ & To_String (Data.Name) & ASCII.NUL &
               Time'Image (Data.Start) & ASCII.NUL &
               Integer'Image (Integer (Float (Data.Dur) * 1_000_000.0)));

            Head := Head + 1;
         end loop;

         delay until Start + Milliseconds (20);
      end loop;
   end ProfilerFlush;
#end if;
end Profiler;
