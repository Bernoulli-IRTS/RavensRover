with nRF.GPIO; use nRF.GPIO;

package Drivers is
   type HCSR04Pin is record
      Echo_Pin    : GPIO_Point;
      Trigger_Pin : GPIO_Point;
   end record;

   type HCSR04Pins is array (Integer range <>) of HCSR04Pin;

   type HCSR04Distance is new Float range 0.0 .. 400.0;

   type PinArray is array (Integer range <>) of GPIO_Point;
end Drivers;
