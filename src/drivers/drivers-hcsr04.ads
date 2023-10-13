with nRF.GPIO; use nRF.GPIO;

-- HC-SR04 driver
generic
   --type TriggerPins is private; -- is array (Positive range <>) of GPIO_Point;
   Echo_Pin : GPIO_Point;
   Trigger_Pins : PinArray;
package Drivers.HCSR04 is
   -- Trigger the next sensor, should not be done more often than every 60ms
   -- Will block at least 10 us
   procedure Trigger;
end Drivers.HCSR04;
