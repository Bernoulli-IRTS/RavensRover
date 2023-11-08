with Drivers; use Drivers;

package Tasks.Sense is
   -- Task to make the rover "sense" the environment through sensors
   task Sense with
     Priority => 4
   ;

   -- Utility functions for later stages to get data
   -- Return if the sense task is working reliably, won't return true until first success cycle
   function Is_Working return Boolean;
   -- Get front left distance
   function Get_Front_Left_Distance return HCSR04Distance;
   -- Get front right distance
   function Get_Front_Right_Distance return HCSR04Distance;
end Tasks.Sense;
