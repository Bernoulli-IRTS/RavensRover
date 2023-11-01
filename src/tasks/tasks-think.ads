with Tasks.Sense;

package Tasks.Think is
   -- Task to "think" what the rover will do before it acts
   task Think with 
     Priority => 1
   ;
   
   -- Enumerator type for where an obstacle is located
   type Where_Obstacle is (Both, Left, Right, None);
   -- Returns true if distance < 10cm, else false
   function Is_Obstacle_Ahead return Where_Obstacle;

end Tasks.Think;
