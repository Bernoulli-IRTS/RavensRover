with nRF.GPIO; use nRF.GPIO;

-- HC-SR04 driver
generic
   Pins : HCSR04Pins;
package Drivers.HCSR04 is
   -- Range of measurements
   type SensorIndex is new Integer range Pins'First .. Pins'Last;

   -- Get the distance reading from sensor
   function Get_Distance (Sensor : SensorIndex) return HCSR04Distance;

   -- Trigger the next sensor, should not be done more often than every 60ms
   -- Will block at least 10 us
   procedure Trigger;
end Drivers.HCSR04;
