----------------------------------------------------------------------------------
-- Company: CEI-UPM
-- Engineer: Carlos de Frutos Lopez
-- 
-- Create Date:    11:34:39 12/07/2012 
-- Design Name: 
-- Module Name:    ready_proc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: pone las señales de ready a '1'
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ready_proc is
    Port ( clk, resetn : in  std_logic;
           s_ready_ri : in std_logic;
           readyi : out std_logic
         );
end ready_proc;

architecture Behavioral of ready_proc is

type ready_proc_t is (ZERO, ONE);
signal s_ready_proci : ready_proc_t;

begin

  READY_PROCi : process( clk ) is
  begin
    if rising_edge(clk) then
      if resetn = '0' then --reset
          s_ready_proci <= ZERO;
          readyi <= '0';
      else
      case s_ready_proci is
        when ZERO =>
          readyi <= '0';
          if s_ready_ri = '1' then
          s_ready_proci <= ONE;
          end if;
        when ONE =>
          readyi <= '1';
        when others => null;
        end case;
      end if; --reset
    end if; --rising_edge(clk)
  end process READY_PROCi;

end Behavioral;

