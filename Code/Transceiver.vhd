--
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
	crcr,crct :out std_logic_vector(7 downto 0); --CRC for receiver and transmitter respectively
	clk,rst   :in std_logic;
	outr      :inout std_logic;
	inr       :in std_logic;
	regdata,reg_out,counter:out std_logic_vector(7 downto 0)

	);


end Transceiver;

architecture Behavioral of Transceiver is

component Transmitter
port (
	clk,rst   :in std_logic;

	regdata   :out std_logic_vector(7 downto 0);
	crc_data  :out std_logic_vector(7 downto 0);
	outr      :inout std_logic);
end component;

component Receiver
port(
	inr    :in std_logic;
	clk    :in    std_logic;
	crcr:out std_logic_vector(7 downto 0);
	reg_out:out   std_logic_vector(7 downto 0);
	counter:out   std_logic_vector(7 downto 0));
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







--DCM_SP_inst : DCM
--   generic map (
--      CLKDV_DIVIDE => 2.0, --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
--                           --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
--      CLKFX_DIVIDE => 2,   --  Can be any interger from 1 to 32
--      CLKFX_MULTIPLY => 2, --  Can be any integer from 1 to 32
--      CLKIN_DIVIDE_BY_2 => False, --  TRUE/FALSE to enable CLKIN divide by two feature
--      CLKIN_PERIOD => 10.0, --  Specify period of input clock
--      CLKOUT_PHASE_SHIFT => "FIXED", --  Specify phase shift of "NONE", "FIXED" or "VARIABLE"
--      CLK_FEEDBACK => "1X",         --  Specify clock feedback of "NONE", "1X" or "2X"
--      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
--                                             --     an integer from 0 to 15
--      DFS_FREQUENCY_MODE => "LOW",     -- "HIGH" or "LOW" frequency mode for
--                                                       -- frequency synthesis
--      DLL_FREQUENCY_MODE => "LOW",     -- "HIGH" or "LOW" frequency mode for DLL
--      DUTY_CYCLE_CORRECTION => TRUE, --  Duty cycle correction, TRUE or FALSE
--      FACTORY_JF => X"C080",          --  FACTORY JF Values
--      PHASE_SHIFT => 30,        --  Amount of fixed phase shift from -255 to 255
--      STARTUP_WAIT => FALSE) --  Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
--   port map (
----      CLK0 => CLK0,     -- 0 degree DCM CLK ouptput
----      CLK180 => CLK180, -- 180 degree DCM CLK output
----      CLK270 => CLK270, -- 270 degree DCM CLK output
----      CLK2X => CLK2X,   -- 2X DCM CLK output
----      CLK2X180 => CLK2X180, -- 2X, 180 degree DCM CLK out
----      CLK90 => CLK90,   -- 90 degree DCM CLK output
----      CLKDV => CLKDV,   -- Divided DCM CLK out (CLKDV_DIVIDE)
--      CLKFX => clk_1,   -- DCM CLK synthesis out (M/D)
----      CLKFX180 => CLKFX180, -- 180 degree CLK synthesis out
--      LOCKED => clko, -- DCM LOCK status output
----      PSDONE => PSDONE, -- Dynamic phase adjust done output
----      STATUS => STATUS, -- 8-bit DCM status bits output
----      CLKFB => CLKFB,   -- DCM clock feedback
--     CLKIN =>  clk,   -- Clock input (from IBUFG, BUFG or DCM)
----      PSCLK => PSCLK,   -- Dynamic phase adjust clock input
----      PSEN => PSEN,     -- Dynamic phase adjust enable input
----      PSINCDEC => PSINCDEC, -- Dynamic phase adjust increment/decrement
--      RST => rst_wire        -- DCM asynchronous reset input
--   );

tr_map :Transmitter port map(
		clk => clk,
		rst => rst,
		crc_data => crct,
		regdata=>regdata,
		outr=> outr);

re_map :Receiver port map(
		clk => clk,
		reg_out => reg_out,
		counter=> counter,
		crcr=>crcr,
		inr => inr);




end Behavioral;
