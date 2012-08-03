----------------------------------------------------------------------------------
-- Company: CEI-UPM
-- Engineer: Carlos de Frutos Lopez
-- 
-- Create Date:    11:34:39 12/07/2012 
-- Design Name: 
-- Module Name:    decod_proc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: detecta cuándo merece la pena hacer un burst
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

entity decod_proc is
    Port ( clk, resetn : in std_logic;
			  s_rd_req_m0 : in std_logic;
			  s_rd_req_m1 : in std_logic;
			  s_rd_req_m2 : in std_logic;
			  s_rd_req_m3 : in std_logic;
			  s_wr_req_m0 : in std_logic;
			  s_wr_req_m1 : in std_logic;
			  s_wr_req_m2 : in std_logic;
			  s_wr_req_m3 : in std_logic;
			  s_address_m0 : in std_logic_vector(31 downto 0);
			  s_address_m1 : in std_logic_vector(31 downto 0);
			  s_address_m2 : in std_logic_vector(31 downto 0);
			  s_address_m3 : in std_logic_vector(31 downto 0);
			  s_data_out_m0 : in std_logic_vector(31 downto 0);
			  s_data_out_m1 : in std_logic_vector(31 downto 0);
			  s_data_out_m2 : in std_logic_vector(31 downto 0);
			  s_data_out_m3 : in std_logic_vector(31 downto 0);
           s_rd_req_m : out std_logic;
			  s_wr_req_m : out std_logic;
           s_address_m : out std_logic_vector(31 downto 0);
			  s_data_out_m : out std_logic_vector(31 downto 0);
           s_burst_type : out std_logic;
           burst_length : out std_logic_vector(11 downto 0);
			  data_to_write_burst : out std_logic_vector(32*16-1 downto 0);
			  identif : out std_logic_vector(3 downto 0)
         );
end decod_proc;

architecture Behavioral of decod_proc is

begin

  DECOD_PROC : process( clk ) is
  begin
	if rising_edge(clk) then
		if resetn = '0' then --reset
			s_rd_req_m <= '0';
			s_wr_req_m <= '0';
			s_address_m <= x"00000000";
			s_data_out_m <= x"00000000";
			s_burst_type <= '0';
			burst_length <= x"000";
			data_to_write_burst <= (others => '0');
			identif <= "0000";
		else
			-- READ
			if (((s_rd_req_m0 = '1') and (s_rd_req_m1 = '1') and (s_address_m0(31 downto 6) = s_address_m1(31 downto 6))) or
				 ((s_rd_req_m0 = '1') and (s_rd_req_m2 = '1') and (s_address_m0(31 downto 6) = s_address_m2(31 downto 6))) or
				 ((s_rd_req_m0 = '1') and (s_rd_req_m3 = '1') and (s_address_m0(31 downto 6) = s_address_m3(31 downto 6)))) 
				then
				 s_rd_req_m <= '1';
				 s_wr_req_m <= '0';
				 s_address_m(31 downto 6) <= s_address_m0(31 downto 6); s_address_m(5 downto 0) <= "000000";
				 s_data_out_m <= x"00000000";
				 s_burst_type <= '1';
			elsif (((s_rd_req_m1 = '1') and (s_rd_req_m2 = '1') and (s_address_m1(31 downto 6) = s_address_m2(31 downto 6))) or
				    ((s_rd_req_m1 = '1') and (s_rd_req_m3 = '1') and (s_address_m1(31 downto 6) = s_address_m3(31 downto 6))))
				then
				 s_rd_req_m <= '1';
				 s_wr_req_m <= '0';
				 s_address_m(31 downto 6) <= s_address_m1(31 downto 6); s_address_m(5 downto 0) <= "000000";
				 s_data_out_m <= x"00000000";
				 s_burst_type <= '1';
			elsif ((s_rd_req_m2 = '1') and (s_rd_req_m3 = '1') and (s_address_m2(31 downto 6) = s_address_m3(31 downto 6))) then
				 s_rd_req_m <= '1';
				 s_wr_req_m <= '0';
				 s_address_m(31 downto 6) <= s_address_m2(31 downto 6); s_address_m(5 downto 0) <= "000000";
				 s_data_out_m <= x"00000000";
				 s_burst_type <= '1';
			elsif s_rd_req_m0 = '1' then
				s_rd_req_m <= '1';
				s_wr_req_m <= '0';
				s_address_m <= s_address_m0;
				s_data_out_m <= x"00000000";
				s_burst_type <= '0';
			elsif s_rd_req_m1 = '1' then
				s_rd_req_m <= '1';
				s_wr_req_m <= '0';
				s_address_m <= s_address_m1;
				s_data_out_m <= x"00000000";
				s_burst_type <= '0';
			elsif s_rd_req_m2 = '1' then
				s_rd_req_m <= '1';
				s_wr_req_m <= '0';
				s_address_m <= s_address_m2;
				s_data_out_m <= x"00000000";
				s_burst_type <= '0';
			elsif s_rd_req_m3 = '1' then
				s_rd_req_m <= '1';
				s_wr_req_m <= '0';
				s_address_m <= s_address_m3;
				s_data_out_m <= x"00000000";
				s_burst_type <= '0';
			-- WRITE
			elsif ((s_wr_req_m0 = '1') and (s_wr_req_m1 = '1') and (s_wr_req_m2 = '1') and (s_wr_req_m3 = '1') and
					(s_address_m1 = (s_address_m0+x"4")) and (s_address_m2 = (s_address_m1+x"4")) and (s_address_m3 = (s_address_m2+x"4")))
			  then --todos burst
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m0;
				data_to_write_burst(32*4-1 downto 0) <= s_data_out_m3&s_data_out_m2&s_data_out_m1&s_data_out_m0;
				data_to_write_burst(32*16-1 downto 32*4) <= (others => '0');
				s_burst_type <= '1';
				burst_length <= x"004";
				identif <= "1111";
			elsif ((s_wr_req_m0 = '1') and (s_wr_req_m1 = '1') and (s_wr_req_m2 = '1') and
					(s_address_m1 = (s_address_m0+x"4")) and (s_address_m2 = (s_address_m1+x"4")))
			  then --el cuarto descolgado
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m0;
				data_to_write_burst(32*3-1 downto 0) <= s_data_out_m2&s_data_out_m1&s_data_out_m0;
				data_to_write_burst(32*16-1 downto 32*3) <= (others => '0');
				s_burst_type <= '1';
				burst_length <= x"003";
				identif <= "0111";
			elsif ((s_wr_req_m1 = '1') and (s_wr_req_m2 = '1') and (s_wr_req_m3 = '1') and
					(s_address_m2 = (s_address_m1+x"4")) and (s_address_m3 = (s_address_m2+x"4")))
			  then --el primero descolgado
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m1;
				data_to_write_burst(32*3-1 downto 0) <= s_data_out_m3&s_data_out_m2&s_data_out_m1;
				data_to_write_burst(32*16-1 downto 32*3) <= (others => '0');
				s_burst_type <= '1';
				burst_length <= x"003";
				identif <= "1110";
			elsif ((s_wr_req_m0 = '1') and (s_wr_req_m1 = '1') and
					(s_address_m1 = (s_address_m0+x"4")) and  (not(s_address_m2 = (s_address_m1+x"4"))))
			  then --el primero y el segundo (tercero descolgado)
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m0;
				data_to_write_burst(32*2-1 downto 0) <= s_data_out_m1&s_data_out_m0;
				data_to_write_burst(32*16-1 downto 32*2) <= (others => '0');
				s_burst_type <= '1';
				burst_length <= x"002";
				identif <= "0011";
			elsif ((s_wr_req_m1 = '1') and (s_wr_req_m2 = '1') and
					(not(s_address_m1 = (s_address_m0+x"4"))) and (s_address_m2 = (s_address_m1+x"4")) and  (not(s_address_m3 = (s_address_m2+x"4"))))
			  then --el segundo y el tercero
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m1;
				data_to_write_burst(32*2-1 downto 0) <= s_data_out_m2&s_data_out_m1;
				data_to_write_burst(32*16-1 downto 32*2) <= (others => '0');
				s_burst_type <= '1';
				burst_length <= x"002";
				identif <= "0110";
			elsif ((s_wr_req_m2 = '1') and (s_wr_req_m3 = '1') and
					(not(s_address_m2 = (s_address_m1+x"4"))) and (s_address_m3 = (s_address_m2+x"4")))
			  then --el tercero y el cuarto
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m2;
				data_to_write_burst(32*2-1 downto 0) <= s_data_out_m3&s_data_out_m2;
				data_to_write_burst(32*16-1 downto 32*2) <= (others => '0');
				s_burst_type <= '1';
				burst_length <= x"002";
				identif <= "1100";
			elsif s_wr_req_m0 = '1' then
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m0;
				s_data_out_m <= s_data_out_m0;
				s_burst_type <= '0';
			elsif s_wr_req_m1 = '1' then
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m1;
				s_data_out_m <= s_data_out_m1;
				s_burst_type <= '0';
			elsif s_wr_req_m2 = '1' then
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m2;
				s_data_out_m <= s_data_out_m2;
				s_burst_type <= '0';
			elsif s_wr_req_m3 = '1' then
				s_wr_req_m <= '1';
				s_rd_req_m <= '0';
				s_address_m <= s_address_m3;
				s_data_out_m <= s_data_out_m3;
				s_burst_type <= '0';
			else
				s_rd_req_m <= '0';
				s_wr_req_m <= '0';
				s_address_m <= x"00000000";
				s_data_out_m <= x"00000000";
				s_burst_type <= '0';
				burst_length <= x"000";
				identif <= "0000";
			end if;
		end if; --reset
	end if; --rising_edge(clk)
  end process DECOD_PROC;
  
end Behavioral;

