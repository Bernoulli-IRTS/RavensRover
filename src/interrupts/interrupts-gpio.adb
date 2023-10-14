with Interfaces;   use Interfaces;
with nRF.Events;
with nRF.Interrupts;
with NRF_SVD.GPIO; use NRF_SVD.GPIO;

package body Interrupts.GPIO is
   type Pin_Pulse_Configurations is array (Pin_Index) of Pin_Pulse_Config;

   -- Keep track of the pin pulse configurations
   Pulse_Configurations : Pin_Pulse_Configurations := (others => Pulse_None);

   procedure Configure_Pin (Pin : GPIO_Point; Config : Pin_Pulse_Config) is
      -- Get the pin index, technically this can out of range since GPIO_Pin_Index goes up to 47
      -- However the MicroBit pins should be within!
      I : Pin_Index := Pin_Index (Pin.Pin);

      GPIO_Config : GPIO_Configuration;
   begin
      Pulse_Configurations (I) := Config;

      -- Create GPIO configuration
      GPIO_Config.Mode         := Mode_In;
      GPIO_Config.Input_Buffer := Input_Buffer_Connect;

      case Config is
         when Pulse_High =>
            GPIO_Config.Resistors := Pull_Down;
            GPIO_Config.Sense     := Sense_For_High_Level;
         when Pulse_Low =>
            GPIO_Config.Resistors := Pull_Up;
            GPIO_Config.Sense     := Sense_For_Low_Level;
         when Pulse_None =>
            GPIO_Config.Sense := Sense_Disabled;
      end case;

      Pin.Configure_IO (GPIO_Config);
   end Configure_Pin;

   protected body InterruptHandler is
      function Get_Pulse (Pin : GPIO_Point) return Pin_Pulse is
         I : Pin_Index := Pin_Index (Pin.Pin);
      begin
         return Pulses (I);
      end Get_Pulse;

      procedure ISR is
         latch_reg : LATCH_Register;
         gpio_bit  : Unsigned_32;

         -- Handle edge of pulse
         procedure Handle_Edge (I : Pin_Index; pulse_high : Boolean) is
            edge : Pulse_Edge;
            P : Integer := Integer (I); -- Just cast this here for convenience
         begin
            -- Figure out the direction of the edge by looking at the GPIO sense register
            edge :=
              (if GPIO_Periph.PIN_CNF (P).SENSE = Low then Pulse_Falling
               else Pulse_Rising);

            -- Handle start of pulses
            if (edge = Pulse_Rising and pulse_high) or
              (edge = Pulse_Falling and not pulse_high)
            then
               -- Update pulse with start timestamp and edge direction
               Pulses (I).Timestamp := Clock;
               Pulses (I).Edge      := edge;
               Pulses (I).Duration  := Time_Span_Last;

               -- Update sense pull + internal pull for detecting end of pulse
               if pulse_high then
                  GPIO_Periph.PIN_CNF (P).SENSE := Low;
                  GPIO_Periph.PIN_CNF (P).PULL  := Pullup;
               else
                  GPIO_Periph.PIN_CNF (P).SENSE := High;
                  GPIO_Periph.PIN_CNF (P).PULL  := Pulldown;
               end if;
               -- Handle end of pulses
            elsif (edge = Pulse_Falling and pulse_high) or
              (edge = Pulse_Rising and not pulse_high)
            then
               -- End the pulse with a duration
               Pulses (I).Duration := Clock - Pulses (I).Timestamp;
               Pulses (I).Edge     := edge;

               -- Update sense pull + internal pull for detecting start of pulse
               if pulse_high then
                  GPIO_Periph.PIN_CNF (P).SENSE := High;
                  GPIO_Periph.PIN_CNF (P).PULL  := Pulldown;
               else
                  GPIO_Periph.PIN_CNF (P).SENSE := Low;
                  GPIO_Periph.PIN_CNF (P).PULL  := Pullup;
               end if;
            end if;
         end Handle_Edge;
      begin
         -- Disable interrupt handler in ISR
         nRF.Events.Disable_Interrupt (nRF.Events.GPIOTE_PORT);

         -- Get a copy of the interrupt latch reg
         latch_reg         := GPIO_Periph.LATCH;
         -- Reset latch register (writing to bit will reset)
         GPIO_Periph.LATCH := latch_reg;

         -- Loop through every GPIO pin in latch register
         for I in Pin_Index loop
            -- Find the mask for checking if the pin has met it's sense critea
            gpio_bit := Shift_Left (Unsigned_32 (1), Integer (I));

            -- Check if bit for pin is set, and if so handle the edge
            if (Unsigned_32 (latch_reg.Val) and gpio_bit) /= 0 then
               -- Handle the different pulse configurations
               case Pulse_Configurations (I) is
                  when Pulse_High =>
                     Handle_Edge (I, True);
                  when Pulse_Low =>
                     Handle_Edge (I, False);
                  when Pulse_None =>
                     null;
               end case;
            end if;
         end loop;

         -- Clear events and re-enable interrupt as the ISR is done
         nRF.Events.Clear (nRF.Events.GPIOTE_PORT);
         nRF.Events.Enable_Interrupt (nRF.Events.GPIOTE_PORT);
      end ISR;
   end InterruptHandler;

begin
   -- Setup interrupt handler
   nRF.Events.Disable_Interrupt (nRF.Events.GPIOTE_PORT);
   GPIO_Periph.DETECTMODE.DETECTMODE := NRF_SVD.GPIO.Default;

   -- Clear and enable GPIOTE events
   nRF.Events.Clear (nRF.Events.GPIOTE_PORT);
   nRF.Events.Enable_Interrupt (nRF.Events.GPIOTE_PORT);
   nRF.Interrupts.Enable (nRF.Interrupts.GPIOTE_Interrupt);
end Interrupts.GPIO;
