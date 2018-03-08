----------------------------------------------------------------------------
-- Receiver.vhd
--
--  Version 1.0
--
--  Copyright (C) 2018 Arun Malik
--
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation, either version
--  2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Receiver is
generic (
  spack_len  : integer := 16;
  sync_cycle : integer := 4 );                      --DCM requires a lot more than 4, keeping it short here

port(
  inr          : in  std_logic;                     --Input
  clk          : in  std_logic;
  crcr,reg_out : out std_logic_vector(7 downto 0);  --For troubleshooting
  counter      : out std_logic_vector(7 downto 0)); --Error counter

end Receiver;

architecture Behavioral of Receiver is
  signal err_count : std_logic_vector(7 downto 0);
  signal reg_shift : std_logic_vector(7 downto 0);
  signal reg_rst   : std_logic;
  signal reg_data  : std_logic_vector(7 downto 0);
begin

pac_proc : process(inr,clk) is
  variable pac_count  : integer range 0 to 30   := 0;  --Tracks bytes
  variable sync_count : integer range 0 to 3000 := 0;
  variable byt_count  : integer range 0 to 8    := 0;
  variable sync_flag  : std_logic               := '0';
  variable sync       : std_logic               := '1'; --sync flag
  variable crc        : std_logic_vector(7 downto 0) := "00000000";
  variable newcrc     : std_logic_vector(7 downto 0) := "00000000";
begin

  if falling_edge(clk) then
     if sync = '0' then                                 --Detection loop , if reset is requested by transmitter
        sync_count := sync_count + 1;

        if inr = '1' then                               --Sets flag whenever clock edge is encountered ,means no reset
           sync_flag := '1';
        end if;

        if sync_count>spack_len and sync_flag='0'  then
           sync      := '1';
           pac_count := 0;

        elsif sync_count>spack_len then
           sync_count := 0;
           sync_flag  := '0';
        end if;

    else                                                 --reset loop

       if inr = '1' and sync_flag = '0' then
         --Configure MMCM
          sync_count := 0;
          sync_flag  := '1';
       else
          sync_count := sync_count + 1;
       end if;

       if sync_count = sync_cycle + 1 and sync_flag = '1' then
          sync      := '0';
          pac_count := 0;
          reg_rst   <= '0';
          sync_flag := '0';
          err_count <= x"00";
          newcrc    := x"00";
          crc       := x"00";
          reg_shift <= x"00";
          reg_data  <= x"00";
          --Remove clk from MMCM
        end if;
     end if;

      if sync = '0' then                                  --start recieving packet, if not in sync stage
         if pac_count < 2 then                            --Leaving first 2 bits
            pac_count := pac_count + 1;

         elsif pac_count  < 18 then
            if byt_count < 8 then
               reg_data (byt_count)  <= inr;
               reg_shift (byt_count) <= '1';

               if byt_count > 0 then                      --need to remove
                  reg_shift(byt_count-1) <= '0';
               end if;

               newcrc(0) := inr xor crc(7);               --Calculating crc
               newcrc(1) := inr xor crc(0) xor crc(7);
               newcrc(2) := inr xor crc(1) xor crc(7);
               newcrc(3) := crc(2);
               newcrc(4) := crc(3);
               newcrc(5) := crc(4);
               newcrc(6) := crc(5);
               newcrc(7) := crc(6);
               crc       := newcrc;
               byt_count := byt_count + 1;

            elsif byt_count = 8 then
               pac_count             := pac_count + 1;
               reg_shift(7 downto 0) <= x"00";
               byt_count             := 0;
            end if;

        elsif pac_count < 26 then
           crc(pac_count - 18) := crc(pac_count - 18) xor inr;  --xoring crc tranmitted with calculated, correct if 0
           pac_count           := pac_count + 1;

        elsif pac_count < 28 then
           pac_count := pac_count + 1;
           if crc=x"00" then
              --inr<='0';                    Left for now

           else
              err_count <= err_count + 1;
              --inr     <= '1';
              crc       := x"00";
           end if;

        elsif pac_count < 29 then
           pac_count := 0;
           newcrc    := "00000000";
           crc       := "00000000";
        end if;
      end if;

      crcr    <= crc;                                        --Troubleshooting
      reg_out <= reg_data;
  end if;

end process;

reg_proc : process(reg_shift,reg_rst,reg_data,clk) is        --Process to shift,reset and updata data registers
  variable reg_0 : std_logic_vector(15 downto 0) := x"0000";
  variable reg_1 : std_logic_vector(15 downto 0) := x"0000";
  variable reg_2 : std_logic_vector(15 downto 0) := x"0000";
  variable reg_3 : std_logic_vector(15 downto 0) := x"0000";
  variable reg_4 : std_logic_vector(15 downto 0) := x"0000";
  variable reg_5 : std_logic_vector(15 downto 0) := x"0000";
  variable reg_6 : std_logic_vector(15 downto 0) := x"0000";
  variable reg_7 : std_logic_vector(15 downto 0) := x"0000";
  variable temp  : unsigned(15 downto 0);
begin

  if rising_edge(clk) then                                  --Shifting and updating
     if reg_shift(0) = '1' then
        temp     := shift_left(unsigned(reg_0),1);
        reg_0    := std_logic_vector(temp);
        reg_0(0) := reg_data(0);
     end if;

     if reg_shift(1) = '1' then
        temp     := shift_left(unsigned(reg_1),1);
        reg_1    := std_logic_vector(temp);
        reg_1(0) := reg_data(1);
     end if;

     if reg_shift(2) = '1' then
        temp     := shift_left(unsigned(reg_2),1);
        reg_2    := std_logic_vector(temp);
        reg_2(0) := reg_data(2);
     end if;

     if reg_shift(3) = '1' then
        temp     := shift_left(unsigned(reg_3),1);
        reg_3    := std_logic_vector(temp);
        reg_3(0) := reg_data(3);
     end if;

     if reg_shift(4) = '1' then
        temp     := shift_left(unsigned(reg_4),1);
        reg_4    := std_logic_vector(temp);
        reg_4(0) := reg_data(4);
     end if;

     if reg_shift(5) = '1' then
        temp     := shift_left(unsigned(reg_5),1);
        reg_5    := std_logic_vector(temp);
        reg_5(0) := reg_data(5);
     end if;

     if reg_shift(6) = '1' then
        temp     := shift_left(unsigned(reg_6),1);
        reg_6    := std_logic_vector(temp);
        reg_6(0) := reg_data(6);
     end if;

     if reg_shift(7) = '1' then
        temp     := shift_left(unsigned(reg_7),1);
        reg_7    := std_logic_vector(temp);
        reg_7(0) := reg_data(7);
     end if;

  end if;

  if reg_rst = '1' then
     reg_0 := x"0000";
     reg_1 := x"0000";
     reg_2 := x"0000";
     reg_3 := x"0000";
     reg_4 := x"0000";
     reg_5 := x"0000";
     reg_6 := x"0000";
     reg_7 := x"0000";
   end if;

end process;

  counter <= err_count;

end Behavioral;
