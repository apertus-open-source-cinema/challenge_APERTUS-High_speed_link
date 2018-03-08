------------------------------------------------------------------------------
-- Transceiver.vhd
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

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

package lfsr_pkg is

    function rand_shift (DATA : std_logic_vector) return std_logic_vector;

end;

package body lfsr_pkg is

    function rand_shift (DATA : std_logic_vector) return std_logic_vector is
       variable feedback : std_logic;
       variable out_reg  : std_logic_vector(15 downto 0) := DATA;
    begin

       feedback := not (out_reg(15) xor out_reg(14));
       out_reg  := out_reg(14 downto 0) & feedback;

       return out_reg;

    end function;
end package body;
