# APERTUS-High_speed_link
APERTUS : Qualification task for gsoc T871 Task3

Functionality
  1. Full duplex (2 lvds pair),can work with single lvds pair with little modification.
  2. CRC check for error detection, with counter.
  3. Only one-sided reset required
  4. Random data generator
  5. Link sync after every reset
  6. Retransmission of corrupted packets.

  Due to event driven nature of vhdl ,tried to keep RTL as close to schematic as possible to reach tight timing constrains

Removed every architecture specific clocking resources such as MMCMn and DCM because they are not tested on real hardware. Memory buffer to hold packets has not been implemented(Not mentioned in Task) ,so retransmission is not yet possible, only signal is sent to transmitter.

Rough schematics mentioned with real signal names in schematic folder.
