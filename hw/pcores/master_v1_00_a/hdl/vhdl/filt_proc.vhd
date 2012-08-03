----------------------------------------------------------------------------------
-- Company: CEI-UPM
-- Engineer: Carlos de Frutos Lopez
-- 
-- Create Date:    11:34:39 12/07/2012 
-- Design Name: 
-- Module Name:    filt_proc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: da el dato a quien corresponda, según addr count
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

entity filt_proc is
    Port ( clk, resetn : in  std_logic;
           s_burst_type : in std_logic;
           bus2ip_mstrd_src_rdy_n : in std_logic;
           s_address_count : in std_logic_vector(31 downto 0);			  
           s_address_m0 : in std_logic_vector(31 downto 0);
           s_address_m1 : in std_logic_vector(31 downto 0);
           s_address_m2 : in std_logic_vector(31 downto 0);
           s_address_m3 : in std_logic_vector(31 downto 0);
           s_data_in_m : in std_logic_vector(31 downto 0);
           s_ack_m : in std_logic;
			  s_wr_req_m0 : in std_logic;
			  s_wr_req_m1 : in std_logic;
			  s_wr_req_m2 : in std_logic;
			  s_wr_req_m3 : in std_logic;
			  identif : in std_logic_vector(3 downto 0);
			  s_data_in_m0 : out std_logic_vector(31 downto 0);
           s_data_in_m1 : out std_logic_vector(31 downto 0);
           s_data_in_m2 : out std_logic_vector(31 downto 0);
           s_data_in_m3 : out std_logic_vector(31 downto 0);
			  s_ack_m0 : out std_logic;
			  s_ack_m1 : out std_logic;
			  s_ack_m2 : out std_logic;
			  s_ack_m3 : out std_logic
         );
end filt_proc;

architecture Behavioral of filt_proc is

begin

  FILT_PROC : process( clk ) is
  begin
	if rising_edge(clk) then
		if resetn = '0' then --reset
			s_data_in_m0 <= x"00000000";
			s_data_in_m1 <= x"00000000";
			s_data_in_m2 <= x"00000000";
			s_data_in_m3 <= x"00000000";
			s_ack_m0 <= '0';
			s_ack_m1 <= '0';
			s_ack_m2 <= '0';
			s_ack_m3 <= '0';
		else
			if s_burst_type = '0' then
				if ((not(s_wr_req_m0)) and (not(s_wr_req_m1)) and (not(s_wr_req_m2)) and (not(s_wr_req_m3))) = '1' then --READ
					if s_address_count = s_address_m0 then
						s_data_in_m0 <= s_data_in_m;
						s_ack_m0 <= s_ack_m;
					else
						s_data_in_m0 <= x"00000000";
						s_ack_m0 <= '0';
					end if;
					if s_address_count = s_address_m1 then
						s_data_in_m1 <= s_data_in_m;
						s_ack_m1 <= s_ack_m;
					else
						s_data_in_m1 <= x"00000000";
						s_ack_m1 <= '0';
					end if;
					if s_address_count = s_address_m2 then
						s_data_in_m2 <= s_data_in_m;
						s_ack_m2 <= s_ack_m;
					else
						s_data_in_m2 <= x"00000000";
						s_ack_m2 <= '0';
					end if;
					if s_address_count = s_address_m3 then
						s_data_in_m3 <= s_data_in_m;
						s_ack_m3 <= s_ack_m;
					else
						s_data_in_m3 <= x"00000000";
						s_ack_m3 <= '0';
					end if;
				else -- WRITE:
					if s_address_count = s_address_m0 then
						s_ack_m0 <= s_ack_m;
					else
						s_ack_m0 <= '0';
					end if;
					if s_address_count = s_address_m1 then
						s_ack_m1 <= s_ack_m;
					else
						s_ack_m1 <= '0';
					end if;
					if s_address_count = s_address_m2 then
						s_ack_m2 <= s_ack_m;
					else
						s_ack_m2 <= '0';
					end if;
					if s_address_count = s_address_m3 then
						s_ack_m3 <= s_ack_m;
					else
						s_ack_m3 <= '0';
					end if;
				end if; --R/W
			else --burst_type = '1'
				if ((not(s_wr_req_m0)) and (not(s_wr_req_m1)) and (not(s_wr_req_m2)) and (not(s_wr_req_m3))) = '1' then --READ
					if ((s_address_count = s_address_m0)and(bus2ip_mstrd_src_rdy_n = '0')) then
						s_data_in_m0 <= s_data_in_m;
						s_ack_m0 <= '1';
					else
						s_data_in_m0 <= x"00000000";
						s_ack_m0 <= '0';
					end if;
					if ((s_address_count = s_address_m1)and(bus2ip_mstrd_src_rdy_n = '0')) then
						s_data_in_m1 <= s_data_in_m;
						s_ack_m1 <= '1';
					else
						s_data_in_m1 <= x"00000000";
						s_ack_m1 <= '0';
					end if;
					if ((s_address_count = s_address_m2)and(bus2ip_mstrd_src_rdy_n = '0')) then
						s_data_in_m2 <= s_data_in_m;
						s_ack_m2 <= '1';
					else
						s_data_in_m2 <= x"00000000";
						s_ack_m2 <= '0';
					end if;
					if ((s_address_count = s_address_m3)and(bus2ip_mstrd_src_rdy_n = '0')) then
						s_data_in_m3 <= s_data_in_m;
						s_ack_m3 <= '1';
					else
						s_data_in_m3 <= x"00000000";
						s_ack_m3 <= '0';
					end if;
				else -- WRITE
					if ((s_ack_m = '1') and (identif = "1111")) then
						s_ack_m0 <= '1';
						s_ack_m1 <= '1';
						s_ack_m2 <= '1';
						s_ack_m3 <= '1';
					elsif ((s_ack_m = '1') and (identif = "0111")) then
						s_ack_m0 <= '1';
						s_ack_m1 <= '1';
						s_ack_m2 <= '1';
						s_ack_m3 <= '0';
					elsif ((s_ack_m = '1') and (identif = "1110")) then
						s_ack_m0 <= '0';
						s_ack_m1 <= '1';
						s_ack_m2 <= '1';
						s_ack_m3 <= '1';
					elsif ((s_ack_m = '1') and (identif = "0011")) then
						s_ack_m0 <= '1';
						s_ack_m1 <= '1';
						s_ack_m2 <= '0';
						s_ack_m3 <= '0';
					elsif ((s_ack_m = '1') and (identif = "0110")) then
						s_ack_m0 <= '0';
						s_ack_m1 <= '1';
						s_ack_m2 <= '1';
						s_ack_m3 <= '0';
					elsif ((s_ack_m = '1') and (identif = "1100")) then
						s_ack_m0 <= '0';
						s_ack_m1 <= '0';
						s_ack_m2 <= '1';
						s_ack_m3 <= '1';
					else
						s_ack_m0 <= '0';
						s_ack_m1 <= '0';
						s_ack_m2 <= '0';
						s_ack_m3 <= '0';
					end if;
				end if; --R/W
			end if; --burst type
		end if; --reset
	end if; --rising_edge(clk)
  end process FILT_PROC;

end Behavioral;

