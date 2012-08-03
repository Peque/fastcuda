----------------------------------------------------------------------------------
-- Company: CEI-UPM
-- Engineer: Carlos de Frutos Lopez
-- 
-- Create Date:    11:34:39 05/03/2012 
-- Design Name: 
-- Module Name:    thread - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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

entity thread_burst is
    Port ( clk, resetn : in  std_logic;
           --from/to memory controller
           data_in_m : in std_logic_vector (31 downto 0);
           data_out_m : out std_logic_vector (31 downto 0);
           address_m : out std_logic_vector (31 downto 0);
           rd_req_m : out std_logic;
           wr_req_m : out std_logic;
           ack_m : in std_logic;
           burst_type : out std_logic;
           --from/to registers
           go_rd : in std_logic;
           go_wr : in std_logic;
           ready_r : out std_logic;
           address0_r : in std_logic_vector (31 downto 0)
         );
end thread_burst;

architecture Behavioral of thread_burst is

type state_t is (
    IDLE,
    READ_BURST, WAIT_RD_BURST,
    WRITE_BURST, WAIT_WR_BURST,
    DONE
    );
signal state : state_t;

begin

  thread_burst_SM: process(clk) is
  begin
    if ( clk'event and clk = '1' ) then
        if resetn = '0' then --reset
            state <= IDLE;
            data_out_m <= (others => '0');
            address_m <= (others => '0');
            rd_req_m <= '0';
            wr_req_m <= '0';
            ready_r <= '0';
            burst_type <= '0';
        
        else
           
            case state is
            
            when IDLE =>
                data_out_m <= (others => '0');
                address_m <= (others => '0');
                rd_req_m <= '0';
                wr_req_m <= '0';
                ready_r <= '0';
                burst_type <= '0';
                if go_rd = '1' then state <= READ_BURST;
                elsif go_wr = '1' then state <= WRITE_BURST;
                end if;
                
            when READ_BURST =>
                address_m <= address0_r;
                burst_type <= '1';
                rd_req_m <= '1';
                state <= WAIT_RD_BURST;
                
            when WAIT_RD_BURST =>
                if ack_m = '1' then --wait fow ack
                    rd_req_m <='0';
                    state <= DONE;
                end if;
            
            
            when WRITE_BURST =>
                address_m <= address0_r; --in address_a (could change)
					 wr_req_m <= '1';
                burst_type <= '1';
                --los datos los pone el controller
                state <= WAIT_WR_BURST;
                
            when WAIT_WR_BURST =>
                if ack_m = '1' then --wait for ack
                    wr_req_m <= '0';
                    state <= DONE;
                end if;
            
            
            when DONE =>
                ready_r <= '1';
                burst_type <= '0';
                state <= IDLE;
            
            when others => null;
        
            end case; --state
		
        end if; --resetn
    end if; --clk
  end process thread_burst_SM;


end Behavioral;

