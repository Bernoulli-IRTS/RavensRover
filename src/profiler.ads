with Ada.Real_Time;         use Ada.Real_Time;
with Ada.Strings.Bounded; use Ada.Strings.Bounded;
with Priorities;

package Profiler is
   package TaskName is new
     Ada.Strings.Bounded.Generic_Bounded_Length
       (Max => 8);
   use TaskName;

   type Trace is record
      Name  : TaskName.Bounded_String  ;
      Start : Time;
      Dur   : Duration;
   end record;

#if PROFILING
   task ProfilerFlush with
     Priority => Priorities.Profiling
   ;
#end if;

   -- Start a trace
   function StartTrace (Trace_Name : String) return Trace;
   -- Start a trace with existing start time
   function StartTrace (Trace_Name : String; Trace_Start : Time) return Trace;
   -- End the trace and submit
   procedure EndTrace (Data : in out Trace);
end Profiler;
