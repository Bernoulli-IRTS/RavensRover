with Priorities;
with Tasks.Sense;

package Tasks.Think is
   -- Task to "think" what the rover will do before it acts
   task Think with
     Priority => Priorities.Think
   ;

   -- Enumerator type for where an obstacle is located
   type Where_Obstacle is (Both, Left, Right, None);
   -- Returns enumerator type Where_Obstacle
   function Is_Obstacle_Ahead return Where_Obstacle;

end Tasks.Think;
