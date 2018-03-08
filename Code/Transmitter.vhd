----------------------------------------------------------------------------
-- Transmitter.vhd
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.lfsr_pkg.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;


entity Transmitter is
generic (
   DPACK_LEN  : integer := 32;
   SYNC_CYCLE : integer := 4);														--DCM requires a lot more than 4, keeping it short here

port (
	clk,rst          :in    std_logic;
	crc_data,regdata :out   std_logic_vector(7 downto 0);						--For troubleshooting
	outr             :inout std_logic);												--Output

end Transmitter;

architecture Behavioral of Transmitter is
	signal sync_clk  : std_logic;														--elsewhere commented for now
	signal reg_shift : std_logic_vector(7 downto 0);
	signal reg_rst   : std_logic;
	signal reg_data  : std_logic_vector(7 downto 0);
	--signal pac_fault:std_logic;
begin
pac_proc : process(clk,rst) is
	variable byt_count : integer range 0 to 8:=0;								--smaller counter tracks bits
	variable pac_count : integer range 0 to 26:=0;								--Tracks bytes
	variable sync      : std_logic:='0';											--sync flag
	variable crc       : std_logic_vector(7 downto 0):="00000000";
	variable newcrc    : std_logic_vector(7 downto 0):="00000000";
begin

	if rising_edge(clk) then
		if rst='1' then
			byt_count := 0;
			pac_count := 0;
			newcrc    := x"00";
			crc       := x"00";
			outr      <= 'Z';
			reg_rst   <= '1';
			sync      := '1';												            --Always resets to sync
			reg_shift <= x"00";
			--pac_fault<='0';
		elsif sync='1' then
			pac_count := pac_count+1;
			if pac_count<DPACK_LEN then  								            --Greater then lenght of a single packet
				outr <= '0';

			elsif pac_count<DPACK_LEN+SYNC_CYCLE then
				--outr<=sync_clk;                         						--Output clock to Reciever MMCM for Sync
				outr <= '1';
			elsif pac_count<DPACK_LEN+SYNC_CYCLE+1 then
				outr      <= '0';
				sync      := '0';															--End sync
				pac_count := 0;                       								--Reset Counter
				reg_rst   <= '0';
			end if;
			
		elsif pac_count=0 then															--Start bit
			outr      <= '1';
			pac_count := pac_count+1;

		elsif pac_count=1 then															--Silence before storm
		outr      <= '0';
		pac_count := pac_count+1;

		elsif pac_count<18 then															--Stays in loop until 16x(8+1) bit completes
			if byt_count<8 then
				outr <= reg_data (byt_count);											--Output to OUTR sequentialy
				reg_shift (byt_count) <= '1';											--Shift target register

				if byt_count>0 then 														--Resets previous set Shift Bits
					reg_shift(byt_count-1) <= '0';
				end if;

				newcrc(0) := reg_data(byt_count) xor crc(7);						--CRC loops for every bit
				newcrc(1) := reg_data(byt_count) xor crc(0) xor crc(7);
				newcrc(2) := reg_data(byt_count) xor crc(1) xor crc(7);
				newcrc(3) := crc(2);
				newcrc(4) := crc(3);
				newcrc(5) := crc(4);
				newcrc(6) := crc(5);
				newcrc(7) := crc(6);
				crc       := newcrc;

				byt_count := byt_count+1;
			else																				--Extra clock cycle needed @ fast tranmission rates for reset
				byt_count := 0;
				outr      <= 'Z';
				pac_count := pac_count+1;
				reg_rst   <= '0';
				reg_shift(7 downto 0) <= x"00";
			end if;

		elsif pac_count<26 then															--Output CRC
				outr      <= crc(pac_count-18);
				pac_count := pac_count+1;
				reg_rst   <= '1';
	
		elsif pac_count=26 then															--1 cycles for Reciever to check CRC and drive the line
				outr      <= 'Z';
				reg_rst   <= '0';
				pac_count := pac_count+1;

		elsif pac_count=27	then														--Input from reciever
			--	pac_fault <= outr;
				pac_count := pac_count+1;

		elsif pac_count=28 then															--time to reset
				pac_count := 0;
				outr      <= 'Z';
				newcrc    := "00000000";
				crc       := "00000000";
				--pac_fault <= '0';
		end if;
			crc_data <= crc;																--Just for troubleshooting
			regdata  <= reg_data;
	end if;
end process;


reg_proc : process(reg_shift,reg_rst,reg_data,clk) is							--Process to shift,reset and updata data registers
		variable reg_0 : std_logic_vector(15 downto 0):=x"040C";
		variable reg_1 : std_logic_vector(15 downto 0):=x"F0A1";
		variable reg_2 : std_logic_vector(15 downto 0):=x"ABCD";
		variable reg_3 : std_logic_vector(15 downto 0):=x"BCDF";
		variable reg_4 : std_logic_vector(15 downto 0):=x"51A2";
		variable reg_5 : std_logic_vector(15 downto 0):=x"0AAA";
		variable reg_6 : std_logic_vector(15 downto 0):=x"98FF";
		variable reg_7 : std_logic_vector(15 downto 0):=x"1234";
      variable temp  : unsigned(15 downto 0);
begin
	if falling_edge(clk) then
		if reg_shift(0)='1' then
			reg_0       := many_to_one_fb(reg_0,"1100010111000101");			--"many_to_one_fb"	random shift function ,refer lfsr package
			reg_data(0) <= reg_0(15);													--updating data
		end if;

		if reg_shift(1)='1' then
			reg_1       := many_to_one_fb(reg_1,"1100010111000101");
			reg_data(1) <= reg_1(15);
		end if;

		if reg_shift(2)='1' then
			reg_2       := many_to_one_fb(reg_2,"1100010111000101");
			reg_data(2) <= reg_2(15);
		end if;

		if reg_shift(3)='1' then
			reg_3       := many_to_one_fb(reg_3,"1100010111000101");
			reg_data(3) <= reg_3(15);
		end if;

		if reg_shift(4)='1' then
			reg_4       := many_to_one_fb(reg_4,"1100010111000101");
			reg_data(4) <= reg_4(15);
		end if;

		if reg_shift(5)='1' then
			reg_5       := many_to_one_fb(reg_5,"1100010111000101");
			reg_data(5) <= reg_5(15);
		end if;

		if reg_shift(6)='1' then
			reg_6       := many_to_one_fb(reg_6,"1100010111000101");
			reg_data(6) <= reg_6(15);
		end if;

		if reg_shift(7)='1' then
			reg_7       := many_to_one_fb(reg_7,"1100010111000101");
			reg_data(7) <= reg_7(15);
		end if;



		  --temp:=shift_left(unsigned(reg_7),1);
		  --reg_7:=std_logic_vector(temp);
		  --reg_7:=many_to_one_fb(reg_7,"0101010111110101");
		  --reg_data(7)<=reg_7(15);

		if reg_rst='1' then
         reg_0 := x"040C";
			reg_1 := x"F0A1";
			reg_2 := x"ABCD";
			reg_3 := x"BCDF";
			reg_4 := x"51A2";
			reg_5 := x"0AAA";
			reg_6 := x"98FF";
			reg_7 := x"1234";

			reg_data(0) <= reg_0(15);
			reg_data(1) <= reg_1(15);
			reg_data(2) <= reg_2(15);
			reg_data(3) <= reg_3(15);
			reg_data(4) <= reg_4(15);
			reg_data(5) <= reg_5(15);
			reg_data(6) <= reg_6(15);
			reg_data(7) <= reg_7(15);
		end if;
	end if;

end process;

sync_clk <= clk;

end Behavioral;
