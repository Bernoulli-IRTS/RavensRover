with Ada.Real_Time;         use Ada.Real_Time;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Profiler is
   type Trace is record
      Name  : Unbounded_String;
      Start : Time;
      Dur   : Duration;
   end record;

#if PROFILING
   task ProfilerFlush with
     Priority => 1
   ;
#end if;

   -- Start a trace
   function StartTrace (Trace_Name : String) return Trace;
   -- Start a trace with existing start time
   function StartTrace (Trace_Name : String; Trace_Start : Time) return Trace;
   -- End the trace and submit
   procedure EndTrace (Data : in out Trace);
end Profiler;
