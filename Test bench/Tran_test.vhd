--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   02:56:14 03/07/2018
-- Design Name:
-- Module Name:   C:/VLSI PRT/8086/Test/Gsoc/Tran_test.vhd
-- Project Name:  Gsoc
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: Transceiver
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY Tran_test IS
END Tran_test;

ARCHITECTURE behavior OF Tran_test IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT Transceiver
    PORT(
         crcr : OUT  std_logic_vector(7 downto 0);
         crct : OUT  std_logic_vector(7 downto 0);
         clk : IN  std_logic;
         rst : IN  std_logic;
         outr : INOUT  std_logic;
         inr : IN  std_logic;
         regdata : OUT  std_logic_vector(7 downto 0);
         reg_out : OUT  std_logic_vector(7 downto 0);
         counter : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;


   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal inr : std_logic := '0';

	--BiDirs
   signal outr : std_logic;

 	--Outputs
   signal crcr : std_logic_vector(7 downto 0);
   signal crct : std_logic_vector(7 downto 0);
   signal regdata : std_logic_vector(7 downto 0);
   signal reg_out : std_logic_vector(7 downto 0);
   signal counter : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: Transceiver PORT MAP (
          crcr => crcr,
          crct => crct,
          clk => clk,
          rst => rst,
          outr => outr,
          inr => inr,
          regdata => regdata,
          reg_out => reg_out,
          counter => counter
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	rseeet:process
	begin
	wait for 300 ns;
	rst<='0';
	end process;

	inr_process: process(outr)
	begin
	if outr='1' then
		inr<='1';
	else
	   inr<='0';
	end if;
	end process;

   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;

      wait for clk_period*10;

      -- insert stimulus here

      wait;
   end process;

END;