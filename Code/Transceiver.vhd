------------------------------------------------------------------------------
-- Transceiver.vhd
--	 
--	Version 1.0
--
--  Copyright (C) 2018 Arun Malik
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------

-- Pins of our interest are "clk", "rst" == which are internally operated,
-- while "outr" and "inr" are connected to other transreciever or to each
-- other for testing maximum operation rate
-- Others pins are just there for simulation and troubleshooting

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VComponents.all;

entity Transceiver is
port(
	clk,rst   : in    std_logic;
	outr      : inout std_logic;
	inr       : in    std_logic;
	regdata   : out   std_logic_vector(7 downto 0);
	reg_out   : out   std_logic_vector(7 downto 0);
	counter   : out   std_logic_vector(7 downto 0);
	crcr,crct : out   std_logic_vector(7 downto 0));                  --CRC for receiver and transmitter respectively
end Transceiver;

architecture Behavioral of Transceiver is
component Transmitter
port(
	clk,rst   : in    std_logic;
   regdata   : out   std_logic_vector(7 downto 0);
	crc_data  : out   std_logic_vector(7 downto 0);
	outr      : inout std_logic);
end component;

component Receiver
port(
	inr     : in  std_logic;
	clk     : in  std_logic;
	crcr    : out std_logic_vector(7 downto 0);
	reg_out : out std_logic_vector(7 downto 0);
	counter : out std_logic_vector(7 downto 0));
end component;

begin
--  -- Clocking primitive
--  --------------------------------------
--
--  -- Instantiation of the DCM primitive
--  --    * Unused inputs are tied off
--  --    * Unused outputs are labeled unused
--  dcm_sp_inst: DCM_SP
--  generic map
--   (CLKDV_DIVIDE          => 2.000,
--    CLKFX_DIVIDE          => 1,
--    CLKFX_MULTIPLY        => 4,
--    CLKIN_DIVIDE_BY_2     => FALSE,
--    CLKIN_PERIOD          => 83.3333333333,
--    CLKOUT_PHASE_SHIFT    => "FIXED",
--    CLK_FEEDBACK          => "1X",
--    DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
--    PHASE_SHIFT           => 21,
--    STARTUP_WAIT          => FALSE)
--  port map
--   -- Input clock
--   (CLKIN                 => clk,
--    CLKFB                 => open,
--    -- Output clocks
--    CLK0                  => clk_1,
--    CLK90                 => open,
--    CLK180                => open,
--    CLK270                => open,
--    CLK2X                 => open,
--    CLK2X180              => open,
--    CLKFX                 => open,
--    CLKFX180              => open,
--    CLKDV                 => open,
--   -- Ports for dynamic phase shift
--    PSCLK                 => '0',
--    PSEN                  => '0',
--    PSINCDEC              => '0',
--    PSDONE                => open,
--   -- Other control and status signals
--    LOCKED                => clko,
--    STATUS                => open,
--    RST                   => rst_wire,
--   -- Unused pin, tie low
--    DSSEN                 => '0');

tr_map :Transmitter port map(
		clk      => clk,
		rst      => rst,
		crc_data => crct,
		regdata  => regdata,
		outr     => outr);

re_map :Receiver port map(
		clk     => clk,
		reg_out => reg_out,
		counter => counter,
		crcr    => crcr,
		inr     => inr);

end Behavioral;

