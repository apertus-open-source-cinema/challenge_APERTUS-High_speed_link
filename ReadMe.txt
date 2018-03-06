High speed serial link designed for APERTUS


 Functionality
  1. Full duplex (2 lvds pair),can work with single lvds pair with little modification.
  2. CRC check for error detection, with counter.
  3. Only one-sided reset required
  4. Random data generator
  5. Link sync after every reset
  6. Retransmission of corrupted packets.

  Due to event driven nature of vhdl ,tried to keep RTL as close to schematic as possible to reach tight timing constrains

  Since I am new to Zync architecture , removed every architecture specific clocking resources such as MMCMn and DCM because they are not yet tested on real hardware. Memory buffer to hold packets has not yet implemented ,so retransmission is not yet possible, only signal is sent to transmitter.

  Rough schematics mentioned with real signal names in schematic folder.
