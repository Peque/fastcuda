----------------------------------------------------------------------------------
-- Company: CEI-UPM
-- Engineer: Carlos de Frutos Lopez
-- 
-- Create Date:    11:34:39 12/07/2012 
-- Design Name: 
-- Module Name:    ack_proc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: genera los ack bis (para mantener la sincronización)
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

entity ack_proc is
    Port ( clk, resetn : in  std_logic;
			  s_ack_t : in  std_logic;
			  s_ack_m : in std_logic;
			  s_ack_m0 : in  std_logic;
			  s_ack_m1 : in  std_logic;
			  s_ack_m2 : in  std_logic;
			  s_ack_m3 : in  std_logic;
			  s_data_in_m0 : in  std_logic_vector(31 downto 0);
			  s_data_in_m1 : in  std_logic_vector(31 downto 0);
			  s_data_in_m2 : in  std_logic_vector(31 downto 0);
			  s_data_in_m3 : in  std_logic_vector(31 downto 0);
			  s_ack_m_bis : out std_logic;
			  s_ack_m0_bis : out std_logic;
			  s_ack_m1_bis : out std_logic;
			  s_ack_m2_bis : out std_logic;
			  s_ack_m3_bis : out std_logic;
			  s_data_in_m0_bis : out std_logic_vector(31 downto 0);
			  s_data_in_m1_bis : out std_logic_vector(31 downto 0);
			  s_data_in_m2_bis : out std_logic_vector(31 downto 0);
			  s_data_in_m3_bis : out std_logic_vector(31 downto 0)
         );
end ack_proc;

architecture Behavioral of ack_proc is

begin

  ACK_PROC : process( clk ) is
  begin
	if rising_edge(clk) then
		if resetn = '0' then --reset
			s_ack_m_bis <= '0';
			s_ack_m0_bis <= '0'; s_data_in_m0_bis <= x"00000000";
			s_ack_m1_bis <= '0'; s_data_in_m1_bis <= x"00000000";
			s_ack_m2_bis <= '0'; s_data_in_m2_bis <= x"00000000";
			s_ack_m3_bis <= '0'; s_data_in_m3_bis <= x"00000000";
		else
			if s_ack_t = '1' then
			  s_ack_m_bis <= '0';
			  s_ack_m0_bis <= '0';
			  s_ack_m1_bis <= '0';
			  s_ack_m2_bis <= '0';
			  s_ack_m3_bis <= '0';
			  s_data_in_m0_bis <= x"00000000";
			  s_data_in_m1_bis <= x"00000000";
			  s_data_in_m2_bis <= x"00000000";
			  s_data_in_m3_bis <= x"00000000";
			end if;
			if s_ack_m0 = '1' then
			  s_ack_m0_bis <= '1';
			  s_data_in_m0_bis <= s_data_in_m0;
			end if;
			if s_ack_m1 = '1' then
			  s_ack_m1_bis <= '1';
			  s_data_in_m1_bis <= s_data_in_m1;
			end if;
			if s_ack_m2 = '1' then
			  s_ack_m2_bis <= '1';
			  s_data_in_m2_bis <= s_data_in_m2;
			end if;
			if s_ack_m3 = '1' then
			  s_ack_m3_bis <= '1';
			  s_data_in_m3_bis <= s_data_in_m3;
			end if;
			if s_ack_m = '1' then
			  s_ack_m_bis <= '1';
			end if;
		end if; --reset
	end if; --rising_edge(clk)
  end process ACK_PROC;

end Behavioral;

