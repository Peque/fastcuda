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

entity thread is
    Port ( clk, resetn : in  std_logic;
           --from/to memory controller
           data_in_m : in std_logic_vector (31 downto 0);
           data_out_m : out std_logic_vector (31 downto 0);
           address_m : out std_logic_vector (31 downto 0);
           rd_req_m : out std_logic;
           wr_req_m : out std_logic;
           ack_m : in std_logic;
           --from/to registers
           go_r : in std_logic;
           ready_r : out std_logic;
           address_a_r : in std_logic_vector (31 downto 0);
--           address_b_r : in std_logic_vector (31 downto 0)
			  DATA_DEBUG : out std_logic_vector (31 downto 0)
         );
end thread;

architecture Behavioral of thread is

type state_t is (
    IDLE,
    READ_A, WAIT_RD_A,
    --READ_B, WAIT_RD_B, HAVE_B,
    WRITE_C, WAIT_WR,
	 READ_C, WAIT_RD_C,
	 DONE
    );
signal state : state_t;
signal aux : std_logic_vector (31 downto 0);
--signal aux2 : std_logic_vector (31 downto 0);


begin

thread_SM: process(clk) is
begin
    if ( clk'event and clk = '1' ) then
        if resetn = '0' then --reset
            aux <= (others => '0');
--            aux2 <= (others => '0');
            state <= IDLE;
            data_out_m <= (others => '0');
            address_m <= (others => '0');
            rd_req_m <= '0';
            wr_req_m <= '0';
            ready_r <= '0';
				DATA_DEBUG <= (others => '0');
        
        else
           
            case state is
            
            when IDLE =>
                ready_r <= '0';
                aux <= (others => '0');
--                aux2 <= (others => '0');
                data_out_m <= (others => '0');
                address_m <= (others => '0');
                rd_req_m <= '0';
                wr_req_m <= '0';
                ready_r <= '0';
					 DATA_DEBUG <= (others => '0');
					 
                if go_r = '1' then state <= READ_A;
                end if;
                
            when READ_A =>
                address_m <= address_a_r;
                rd_req_m <= '1';
                state <= WAIT_RD_A;
                
            when WAIT_RD_A =>
                if ack_m = '1' then --wait for ack
                  rd_req_m <='0';
						aux <= data_in_m;
						DATA_DEBUG <= data_in_m;
						state <= WRITE_C;
                end if;
                

                
--            when READ_B =>
--                address_m <= address_b_r;
--                rd_req_m <= '1';
--                state <= WAIT_RD_B;
--                
--            when WAIT_RD_B =>
--                if ack_m = '1' then --wait fow ack
--                    rd_req_m <='0';
--                    state <= HAVE_B;
--                end if;
--                
--            when HAVE_B =>
--                aux2 <= aux + data_in_m;
--                state <= WRITE_C;
                
            when WRITE_C =>
                address_m <= address_a_r; --in address_a (could change)
					 data_out_m <= address_a_r-x"C0000000"+x"0000009"; --random number
                wr_req_m <= '1';
                state <= WAIT_WR;
                
            when WAIT_WR =>
                if ack_m = '1' then --wait for ack
                    wr_req_m <= '0';
                    state <= READ_C;
                end if;
                
					 
				when READ_C =>
                address_m <= address_a_r;
                rd_req_m <= '1';
                state <= WAIT_RD_C;
                
            when WAIT_RD_C =>
                if ack_m = '1' then --wait for ack
                  rd_req_m <='0';
						aux <= data_in_m;
						DATA_DEBUG <= data_in_m;
						state <= DONE;
                end if;


            when DONE =>
                ready_r <= '1';
                state <= DONE;
					 
            when others => null;
        
            end case; --state
		
        end if; --resetn
    end if; --clk
end process thread_SM;


end Behavioral;

