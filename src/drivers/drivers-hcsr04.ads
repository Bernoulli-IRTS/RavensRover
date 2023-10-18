with nRF.GPIO; use nRF.GPIO;

-- HC-SR04 driver
generic
   Pins : HCSR04Pins;
package Drivers.HCSR04 is
   -- Range of measurements
   type Distance_cm is new Float range 0.0 .. 400.0;

   type SensorIndex is new Integer range Pins'First .. Pins'Last;

   -- Get the distance reading from sensor
   function Get_Distance (Sensor : SensorIndex) return Distance_cm;
   -- Get if all the sensors are currently working
   function Get_Working return Boolean;

   -- Trigger the next sensor, should not be done more often than every 60ms
   -- Will block at least 10 us
   procedure Trigger;
end Drivers.HCSR04;
