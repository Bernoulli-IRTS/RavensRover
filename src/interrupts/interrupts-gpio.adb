with Ada.Text_IO;
with HAL;
with Interfaces;                use Interfaces;
with nRF.Events;
with nRF.GPIO.Tasks_And_Events; use nRF.GPIO;
with nRF.Interrupts;
with NRF_SVD.GPIO;              use NRF_SVD.GPIO;
with Profiler;

package body Interrupts.GPIO is
   type Pin_Pulse_Configurations is array (Pin_Index) of Pin_Pulse_Config;

   -- Keep track of the pin pulse configurations
   Pulse_Configurations : Pin_Pulse_Configurations := (others => Pulse_None);

   type Pin_GPIOTE_Channel is record
      Set  : Boolean;
      Chan : Tasks_And_Events.GPIOTE_Channel;
   end record;

   type Pin_GPIOTE_Channels is array (Pin_Index) of Pin_GPIOTE_Channel;

   Pins_GPIOTE_Channels : Pin_GPIOTE_Channels :=
     (others => (Set => False, Chan => Tasks_And_Events.GPIOTE_Channel'Last));

   -- Just start top down
   Next_GPIIOTE_Channel : Tasks_And_Events.GPIOTE_Channel :=
     Tasks_And_Events.GPIOTE_Channel'Last;

   procedure Configure_Interrupt_Pin
     (Pin : GPIO_Point; Config : Pin_Pulse_Config)
   is
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

      -- Allocate channel so we can ack
      Pins_GPIOTE_Channels (I) := (Set => True, Chan => Next_GPIIOTE_Channel);

      Tasks_And_Events.Enable_Event
        (Chan     => Next_GPIIOTE_Channel, GPIO_Pin => Pin.Pin,
         Polarity => Tasks_And_Events.Any_Change);

      Tasks_And_Events.Enable_Channel_Interrupt (Next_GPIIOTE_Channel);

      -- Decrement for next pin
      Next_GPIIOTE_Channel :=
        Tasks_And_Events.GPIOTE_Channel (Integer (Next_GPIIOTE_Channel) - 1);
   end Configure_Interrupt_Pin;

   protected body InterruptHandler is
      function Get_Pulse (Pin : GPIO_Point) return Pin_Pulse is
         I : Pin_Index := Pin_Index (Pin.Pin);
      begin
         return Pulses (I);
      end Get_Pulse;

      procedure ISR is
         latch_reg : LATCH_Register;
         gpio_bit  : Unsigned_32;
         high      : Boolean;

         -- Handle edge of pulse
         procedure Handle_Edge (I : Pin_Index; edge_high : Boolean) is
            is_start : Boolean;
            edge     : Pulse_Edge;
         begin
            edge := (if edge_high then Pulse_Rising else Pulse_Falling);

            -- Find out if this is the starting edge
            is_start := edge_high = (Pulse_Configurations (I) = Pulse_High);

            -- Handle start of pulses
            if (is_start) then
               -- Update pulse with start timestamp and edge direction
               Pulses (I).Timestamp := Clock;
               Pulses (I).Edge      := edge;
            else
               -- End the pulse with a duration
               Pulses (I).Duration := Clock - Pulses (I).Timestamp;
               Pulses (I).Edge     := edge;
            end if;
         end Handle_Edge;
      begin
         -- Disable interrupt handler in ISR
         nRF.Events.Disable_Interrupt (nRF.Events.GPIOTE_PORT);
         nRF.Events.Clear (nRF.Events.GPIOTE_PORT);

         -- Get a copy of the interrupt latch reg
         latch_reg         := GPIO_Periph.LATCH;
         -- Reset latch register (writing to bit will reset)
         GPIO_Periph.LATCH := latch_reg;

         -- Loop through every GPIO pin in latch register
         for I in Pin_Index loop
            -- Ensure the channel is setup and it is an event for that channel otherwise
            -- `Tasks_And_Events.Acknowledge_Channel_Interrupt` will raise
            if Pins_GPIOTE_Channels (I).Set and
              Tasks_And_Events.Channel_Event_Set
                (Pins_GPIOTE_Channels (I).Chan)
            then
               -- Find the mask for checking if the pin has met it's sense critea
               gpio_bit := Shift_Left (Unsigned_32 (1), Integer (I));

               -- Check if bit for pin is set, and if so handle the edge
               if (Unsigned_32 (latch_reg.Val) and gpio_bit) /= 0 then
                  -- Check if it ia high edge by reading the in register
                  high :=
                    (Unsigned_32 (GPIO_Periph.IN_k.Val) and gpio_bit) /= 0;

                  Handle_Edge (I, high);
               end if;

               -- Acknowledge the channel interrupt
               Tasks_And_Events.Acknowledge_Channel_Interrupt
                 (Pins_GPIOTE_Channels (I).Chan);
            end if;
         end loop;
         -- Clear events and re-enable interrupt as the ISR is done
         nRF.Events.Enable_Interrupt (nRF.Events.GPIOTE_PORT);
      end ISR;
   end InterruptHandler;
end Interrupts.GPIO;
