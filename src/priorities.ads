package Priorities is
   -- Allow to insert profiling trace submission as lowest priority
#if PROFILING
   Base      : constant := 1;
   Profiling : constant := 1;
#else
   Base      : constant := 0;
#end if;

   -- Task priorities
   Sense : constant := Base + 3;
   Think : constant := Base + 2;
   Act   : constant := Base + 1;
end Priorities;
