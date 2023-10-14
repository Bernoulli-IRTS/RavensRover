with nRF.Events;
with nRF.Interrupts;
with NRF_SVD.GPIO; use NRF_SVD.GPIO;

package body Interrupts.GPIO is

   protected body InterruptHandler is
      procedure ISR is
         latch_reg : LATCH_Register;
      begin
         -- Disable interrupt handler in ISR
         nRF.Events.Disable_Interrupt (nRF.Events.GPIOTE_PORT);

         -- Get a copy of the interrupt latch reg
         latch_reg         := GPIO_Periph.LATCH;
         -- Reset latch register
         GPIO_Periph.LATCH := GPIO_Periph.LATCH;

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
