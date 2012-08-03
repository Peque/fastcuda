----------------------------------------------------------------------------------
-- Company: CEI-UPM
-- Engineer: Carlos de Frutos Lopez
-- 
-- Create Date:    11:34:39 12/07/2012 
-- Design Name: 
-- Module Name:    wr_req_proc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: controla los wr req
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

entity wr_req_proc is
    Port ( clk, resetn : in  std_logic;
           s_wr_req_mi_bis : in std_logic;
           s_ack_mi : in std_logic;
           s_ack_t : in std_logic;
           s_wr_req_mi : out std_logic
         );
end wr_req_proc;

architecture Behavioral of wr_req_proc is

type wr_req_proc_t is (IDLE, ASKING, WAITING);
signal s_wr_req_proci : wr_req_proc_t;

begin

  WR_REQ_PROCi : process( clk ) is
  begin
	if rising_edge(clk) then
		if resetn = '0' then --reset
		  s_wr_req_proci <= IDLE;
		  s_wr_req_mi <= '0';
		else
		  case s_wr_req_proci is
		  when IDLE =>
			if s_wr_req_mi_bis = '1' then
				s_wr_req_mi <= '1';
				s_wr_req_proci <= ASKING;
			end if;
		  when ASKING =>
			if s_ack_mi = '1' then
				s_wr_req_mi <= '0';
				s_wr_req_proci <= WAITING;
			end if;
		  when WAITING =>
			if s_ack_t = '1' then
				s_wr_req_proci <= IDLE;
			end if;
		  when others => null;
        end case;
		end if; --reset
	end if; --rising_edge(clk)
  end process WR_REQ_PROCi;

end Behavioral;

