with Priorities;

package Tasks.Radio is
   task Radio with
     Priority => Priorities.Radio
   ;

   function Is_Enabled return Boolean;

   procedure Toggle;
end Tasks.Radio;
