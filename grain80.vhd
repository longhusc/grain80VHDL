------------------------------------------------------------------------
-- MODULE: GRAIN80
--
-- DESCRIPTION: Stream Cipher Grain 80 (Synthesizable code)
--
-- LANGUAGE: VHDL-93
--
-- CREATED: Oct 2009
--
-- AUTHOR: Saied H. Khayat
-- URL: https://github.com/saiedhk/grain80VHDL
--   
-- Copyright Notice: Free use of this library is permitted under
-- the guidelines and in accordance with the MIT License (MIT).
-- http://opensource.org/licenses/MIT
--
-----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity GRAIN80 is
    generic (
        N : integer := 80;  -- LFSR size
    );
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        load  : in  std_logic;
        init  : in  std_logic;
        din   : in  std_logic;
        dout  : out std_logic
    );
end GRAIN80;


---------------------------------------
architecture RTL of GRAIN80 is
    signal sreg   : std_logic_vector(N-1 downto 0);  -- LFSR
    signal breg   : std_logic_vector(N-1 downto 0);  -- NFSR
    signal sregIn : std_logic;
    signal bregIn : std_logic;
    signal z      : std_logic;

    function HFUNC( x0,x1,x2,x3,x4 : std_logic ) return std_logic is
    begin
        return x1 xor x4  xor (x0 and x3) xor
                (x2 and x3) xor (x3 and x4) xor
                (x0 and x1 and x2) xor
                (x0 and x2 and x3) xor
                (x0 and x2 and x4) xor
                (x1 and x2 and x4) xor
                (x2 and x3 and x4);
    end;

----------------------
begin -- architecture
----------------------

LLFSR: process(CLK)
begin
    if rising_edge(CLK) then
        sreg <= sregIn & sreg(N-1 downto 1);
    end if;
end process;


sin <=  (sreg(N-80) xor sreg(N-67)) xor
        (sreg(N-57) xor sreg(N-42)) xor
        (sreg(N-29) xor sreg(N-18));


process(load,init,sin,din)
begin
    if load='1' then
        sregIn <= din;
    elsif init='1' then
        sregIn <= sin xor z;
    else
        sregIn <= sin;
    end if;
end process;


LNFSR: process(CLK)
begin
    if rising_edge(CLK) then
        breg <= bregIn & breg(N-1 downto 1);
    end if;
end process;


bin <= breg(62) xor
       breg(60) xor breg(52) xor
       breg(45) xor breg(37) xor
       breg(33) xor breg(28) xor
       breg(21) xor breg(14) xor
       breg(09) xor breg(0)  xor
      (breg(63) and breg(60))xor
      (breg(37) and breg(33))xor
      (breg(15) and breg(9)) xor
      (breg(60) and breg(52) and breg(45))xor
      (breg(33) and breg(28) and breg(21))xor
      (breg(63) and breg(45) and breg(28) and breg(9)) xor
      (breg(60) and breg(52) and breg(37) and breg(33))xor
      (breg(63) and breg(60) and breg(21) and breg(15))xor
      (breg(63) and breg(60) and breg(52) and breg(45) and breg(37))xor
      (breg(33) and breg(28) and breg(21) and breg(15) and breg(9)) xor
      (breg(52) and breg(45) and breg(37) and breg(33) and breg(28) and breg(21));


process(load,init,bin,sreg)
begin
    if load='1' then
        bregIn <= sreg(0);
    elsif init='1' then
        bregIn = sreg(0) xor bin xor z;
    else
        bregIn = sreg(0) xor bin;
    end if;
end process;


z <= breg(1) xor breg(2) xor breg(4) xor
     breg(10) xor breg(31) xor breg(43) xor breg(56) xor
     HFUNC(sreg(3),sreg(25),sreg(46),sreg(64),breg(63));


LDOUT: process (CLK)
begin
    if rising_edge(CLK) then
        DOUT <= z;
    end if;
end process;



end RTL; -- architecture
