with Drivers; use Drivers;
with Priorities;

package Tasks.Sense is
   -- Task to make the rover "sense" the environment through sensors
   task Sense with
     Priority => Priorities.Sense
   ;

   -- Utility functions for later stages to get data
   -- Get front left distance
   function Get_Front_Left_Distance return HCSR04Distance;
   -- Get front right distance
   function Get_Front_Right_Distance return HCSR04Distance;
end Tasks.Sense;
