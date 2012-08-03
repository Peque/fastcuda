----------------------------------------------------------------------------------
-- Company: CEI-UPM
-- Engineer: Carlos de Frutos Lopez
-- 
-- Create Date:    11:34:39 05/03/2012 
-- Design Name: 
-- Module Name:    controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Controlador, propiamente dicho. Capa más cercana a la memoria
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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller is
  generic
  (
    C_MST_NATIVE_DATA_WIDTH        : integer              := 32;
    C_MST_LENGTH_WIDTH             : integer              := 12;
    C_MST_AWIDTH                   : integer              := 32
--    C_NUM_REG                      : integer              := 6;
--    C_SLV_DWIDTH                   : integer              := 32
  );
    Port ( 
           --from/to thread
           data_t2c : in std_logic_vector (31 downto 0);
           data_c2t : out std_logic_vector (31 downto 0);
           address_t2c : in std_logic_vector (31 downto 0);
           rd_req_t2c : in std_logic;
           wr_req_t2c : in std_logic;
           ack_c2t : out std_logic;
           -----
           burst_type : in std_logic; --'1'=burst_si, '0'=burst_no
			  burst_length : in std_logic_vector(11 downto 0);
			  data_to_write_burst : in std_logic_vector(16*32-1 downto 0);
			  -----
           address_count : out std_logic_vector (31 downto 0);
			  -----
			  DEBUG_ESTADO : out std_logic_vector (4 downto 0);
           --from/to bus
           Bus2IP_Clk                     : in  std_logic;
           Bus2IP_Resetn                  : in  std_logic;
--           Bus2IP_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
--           Bus2IP_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
--           Bus2IP_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
--           Bus2IP_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
--           IP2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
--           IP2Bus_RdAck                   : out std_logic;
--           IP2Bus_WrAck                   : out std_logic;
--           IP2Bus_Error                   : out std_logic;
           ip2bus_mstrd_req               : out std_logic;
           ip2bus_mstwr_req               : out std_logic;
           ip2bus_mst_addr                : out std_logic_vector(C_MST_AWIDTH-1 downto 0);
           ip2bus_mst_be                  : out std_logic_vector((C_MST_NATIVE_DATA_WIDTH/8)-1 downto 0);
           ip2bus_mst_length              : out std_logic_vector(C_MST_LENGTH_WIDTH-1 downto 0);
           ip2bus_mst_type                : out std_logic;
           ip2bus_mst_lock                : out std_logic;
           ip2bus_mst_reset               : out std_logic;
           bus2ip_mst_cmdack              : in  std_logic;
           bus2ip_mst_cmplt               : in  std_logic;
           bus2ip_mst_error               : in  std_logic;
--           bus2ip_mst_rearbitrate         : in  std_logic;
--           bus2ip_mst_cmd_timeout         : in  std_logic;
           bus2ip_mstrd_d                 : in  std_logic_vector(C_MST_NATIVE_DATA_WIDTH-1 downto 0);
--           bus2ip_mstrd_rem               : in  std_logic_vector((C_MST_NATIVE_DATA_WIDTH)/8-1 downto 0);
           bus2ip_mstrd_sof_n             : in  std_logic;
           bus2ip_mstrd_eof_n             : in  std_logic;
           bus2ip_mstrd_src_rdy_n         : in  std_logic;
--           bus2ip_mstrd_src_dsc_n         : in  std_logic;
           ip2bus_mstrd_dst_rdy_n         : out std_logic;
           ip2bus_mstrd_dst_dsc_n         : out std_logic;
           ip2bus_mstwr_d                 : out std_logic_vector(C_MST_NATIVE_DATA_WIDTH-1 downto 0);
           ip2bus_mstwr_rem               : out std_logic_vector((C_MST_NATIVE_DATA_WIDTH)/8-1 downto 0);
           ip2bus_mstwr_src_rdy_n         : out std_logic;
           ip2bus_mstwr_src_dsc_n         : out std_logic;
           ip2bus_mstwr_sof_n             : out std_logic;
           ip2bus_mstwr_eof_n             : out std_logic;
           bus2ip_mstwr_dst_rdy_n         : in  std_logic
--           bus2ip_mstwr_dst_dsc_n         : in  std_logic
         );
end controller;

architecture Behavioral of controller is


  type master_read_burst_sm_t is (
    MASTER_IDLE, 
    MASTER_CMD_READ,  MASTER_WAIT_CMD_READ,  MASTER_READ,
    MASTER_CMD_READ_BURST,  MASTER_WAIT_CMD_READ_BURST,  MASTER_READ_BURST,
    MASTER_CMD_WRITE, MASTER_WAIT_CMD_WRITE, MASTER_WRITE, 
    MASTER_CMD_WRITE_BURST, MASTER_WAIT_CMD_WRITE_BURST, MASTER_WRITE_BURST, 
    MASTER_FINISH, MASTER_DONE, MASTER_DONE2, MASTER_DONE3
  );
  signal master_read_burst_sm : master_read_burst_sm_t;
  
  signal s_address_t2c : std_logic_vector(31 downto 0);


--  type array_of_words is array(natural range <>) of std_logic_vector(C_MST_NATIVE_DATA_WIDTH-1 downto 0);
--  signal buffer_lectura : array_of_words(0 to 255);
--  signal buffer_out : std_logic_vector (16*32-1 downto 0);

begin

 CONTROLLER_PROC : process( Bus2IP_Clk ) is
    variable n : integer;
	 variable burst_length_v : integer;
	 
  begin
    if rising_edge(Bus2IP_Clk) then
      if Bus2IP_Resetn = '0' then --reset
--        buffer_out <= (others => '0');
--        data_read_burst <= (others => '0');
        ack_c2t <= '0';
        data_c2t <= (others => '0');
        master_read_burst_sm <= MASTER_IDLE;
        n := 0;
		  burst_length_v := 0;
		  address_count <= (others => '0');
		  s_address_t2c <= (others => '0');
        
        ip2bus_mstrd_req       <= '0';
        ip2bus_mstwr_req       <= '0';
        ip2bus_mst_addr        <= (others => '0');
        ip2bus_mst_be          <= (others => '0');
        ip2bus_mst_length      <= (others => '0');
        ip2bus_mst_type        <= '0';
        ip2bus_mst_lock        <= '0';
        ip2bus_mst_reset       <= '1';  -- reset master axi
        ip2bus_mstrd_dst_rdy_n <= '1';
        ip2bus_mstrd_dst_dsc_n <= '1';
        ip2bus_mstwr_d         <= (others => '0');
        ip2bus_mstwr_rem       <= (others => '0');
        ip2bus_mstwr_src_rdy_n <= '1';
        ip2bus_mstwr_src_dsc_n <= '1';
        ip2bus_mstwr_sof_n     <= '1';
        ip2bus_mstwr_eof_n     <= '1';
        
      else
		
        ip2bus_mst_reset       <= '0';

		  
		
        case master_read_burst_sm is
        
        when MASTER_IDLE =>
		  DEBUG_ESTADO <= "00000";
--		    buffer_out <= (others => '0');
--          data_read_burst <= (others => '0');
          ack_c2t <= '0';
          data_c2t <= (others => '0');
          n := 0;
			 burst_length_v := 0;
			 address_count <= (others => '0');
          if ((rd_req_t2c = '1')and(burst_type = '0')) then  -- read, no burst
				s_address_t2c <= address_t2c;
            master_read_burst_sm <= MASTER_CMD_READ;
			 elsif ((rd_req_t2c = '1')and(burst_type = '1')) then  -- read, burst
				s_address_t2c <= address_t2c;
			   master_read_burst_sm <= MASTER_CMD_READ_BURST;
          elsif ((wr_req_t2c = '1')and(burst_type = '0')) then	--write, no burst
				s_address_t2c <= address_t2c;
			   master_read_burst_sm <= MASTER_CMD_WRITE;
          elsif ((wr_req_t2c = '1')and(burst_type = '1')) then	--write, burst
			   s_address_t2c <= address_t2c;
				burst_length_v := conv_integer(burst_length);
			   master_read_burst_sm <= MASTER_CMD_WRITE_BURST;
			 end if;
        
        
        
        when MASTER_CMD_READ =>
		  DEBUG_ESTADO <= "00001";
          ip2bus_mstrd_req <= '1';  -- read request
          ip2bus_mst_type  <= '0';  -- burst_type='0' => no / burst_type='1' => yes
          ip2bus_mst_addr   <= s_address_t2c;  -- address = input data---------------------------------------------------------------------------------------
			 address_count <= s_address_t2c; ---------------------------------------------------------------------------------------
          ip2bus_mst_be     <= "1111";  -- read/write all 4 bytes
                    
          ip2bus_mstrd_dst_rdy_n <= '0';  -- set "ready" flag
          
          master_read_burst_sm <= MASTER_WAIT_CMD_READ;
          
        when MASTER_CMD_READ_BURST =>  
		  DEBUG_ESTADO <= "00010";
          n := 0;
          ip2bus_mstrd_req <= '1';  -- read request
          ip2bus_mst_type  <= '1';  -- burst_type='0' => no / burst_type='1' => yes
          ip2bus_mst_addr   <= s_address_t2c;  -- address = input data---------------------------------------------------------------------------------------
			 address_count <= s_address_t2c; ---------------------------------------------------------------------------------------
          ip2bus_mst_be     <= "1111";  -- read/write all 4 bytes
          ip2bus_mst_length <= x"040";--conv_std_logic_vector(NUM_THREADS*4, 12);-- 16 std_logic_vectors * 4 bytes read = 64 = 0x40--4 std_logic_vectors * 4 bytes read = 16 = 0x10--
			 
          ip2bus_mstrd_dst_rdy_n <= '0';  -- set "ready" flag
          
          master_read_burst_sm <= MASTER_WAIT_CMD_READ_BURST;
                  
        when MASTER_WAIT_CMD_READ =>
		  DEBUG_ESTADO <= "00011";
          if bus2ip_mst_cmdack = '1' then  -- wait for Command Ack
            ip2bus_mstrd_req <= '0';
            ip2bus_mst_type  <= '0';
            master_read_burst_sm <= MASTER_READ;
          end if;
          
        when MASTER_WAIT_CMD_READ_BURST =>
		  DEBUG_ESTADO <= "00100";
          if bus2ip_mst_cmdack = '1' then  -- wait for Command Ack
            ip2bus_mstrd_req <= '0';
            ip2bus_mst_type  <= '0';
            master_read_burst_sm <= MASTER_READ_BURST;
          end if;
                  
        when MASTER_READ =>
		  DEBUG_ESTADO <= "00101";
          if bus2ip_mstrd_src_rdy_n = '0' then  -- bus has "valid data" flag set
				data_c2t <= bus2ip_mstrd_d; --got it! - store it. And it goes to the thread----------------------------------------------------------
            ip2bus_mstrd_dst_rdy_n <= '1';  -- clear "ready" flag
            master_read_burst_sm <= MASTER_FINISH;
          end if;
        
        when MASTER_READ_BURST =>
		  DEBUG_ESTADO <= "00111";
          if bus2ip_mstrd_src_rdy_n = '0' then  -- bus has "valid data" flag set
            if bus2ip_mstrd_sof_n = '0' then
              n := 0;
            else
              n := n + 1;
            end if;
            data_c2t <= bus2ip_mstrd_d;
				address_count <= s_address_t2c + conv_std_logic_vector(4*n, 32); -------------------------------------------------------------------------
            if bus2ip_mstrd_eof_n = '0' then --if n = 15 then
             ip2bus_mstrd_dst_rdy_n <= '1'; -- clear "ready" flag
             master_read_burst_sm <= MASTER_FINISH;
            end if;
          end if;
          

        

        
        when MASTER_CMD_WRITE =>
		  DEBUG_ESTADO <= "01000";
          ip2bus_mstwr_req <= '1';  -- write request
          ip2bus_mst_type  <= '0';  -- burst_type='0' => no / burst_type='1' => yes
          ip2bus_mst_addr   <= s_address_t2c;  -- address = input data-----------------------------------------------------------------------------
			 address_count <= s_address_t2c;-----------------------------------------------------------------------------------------
          ip2bus_mst_be     <= "1111";  -- read/write all 4 bytes
          ip2bus_mstwr_d    <= data_t2c;  -- data to write--------------------------------------------------------------------------------------
          ip2bus_mstwr_rem  <= "0000";  -- ...it's like this in the example
          ip2bus_mstwr_src_rdy_n <= '0';  -- set "valid data" flag
          ip2bus_mstwr_sof_n     <= '0';  -- this is the first data beat
          ip2bus_mstwr_eof_n     <= '0';  -- this is the last data beat
          
          master_read_burst_sm <= MASTER_WAIT_CMD_WRITE;
          
        when MASTER_CMD_WRITE_BURST =>
		  DEBUG_ESTADO <= "01001";
          n := 0;
          ip2bus_mst_length <= conv_std_logic_vector(4*burst_length_v,12);  -- array of 16 std_logic_vectors * 4 bytes written = 64 = 0x40------------------------------
			 ip2bus_mstwr_req <= '1';  -- write request
          ip2bus_mst_type  <= '1';  -- burst_type='0' => no / burst_type='1' => yes
          ip2bus_mst_addr   <= s_address_t2c;  -- address = input data-----------------------------------------------------------------------------
          ip2bus_mst_be     <= "1111";  -- read/write all 4 bytes
          ip2bus_mstwr_d    <= data_to_write_burst(32*n+31 downto 32*n); -- data to write--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~--~
          ip2bus_mstwr_rem  <= "0000";  -- ...it's like this in the example
          ip2bus_mstwr_src_rdy_n <= '0';  -- set "valid data" flag
          ip2bus_mstwr_sof_n     <= '0';  -- this is the first data beat
          
          master_read_burst_sm <= MASTER_WAIT_CMD_WRITE_BURST;
                    
        when MASTER_WAIT_CMD_WRITE =>
		  DEBUG_ESTADO <= "01011";
          if bus2ip_mst_cmdack = '1' then  -- wait for Command Ack
            ip2bus_mstwr_req <= '0';
            ip2bus_mst_type  <= '0';
            master_read_burst_sm <= MASTER_WRITE;
          end if;
          
        when MASTER_WAIT_CMD_WRITE_BURST =>
		  DEBUG_ESTADO <= "01100";
          if bus2ip_mst_cmdack = '1' then  -- wait for Command Ack
            ip2bus_mstwr_req <= '0';
            ip2bus_mst_type  <= '0';
            master_read_burst_sm <= MASTER_WRITE_BURST;
          end if;
          
        when MASTER_WRITE =>  -- bus has set the "ok I got your data" flag
		  DEBUG_ESTADO <= "01101";
          if bus2ip_mstwr_dst_rdy_n = '0' then
            ip2bus_mstwr_src_rdy_n <= '1';  -- clear "valid data" flag
            ip2bus_mstwr_sof_n     <= '1';  -- clear "first data beat" flag
            ip2bus_mstwr_eof_n     <= '1';  -- clear "last data beat" flag
          
            master_read_burst_sm <= MASTER_FINISH;
          end if;
        
        when MASTER_WRITE_BURST =>  -- bus has set the "ok I got your data" flag
		  DEBUG_ESTADO <= "01111";
          if bus2ip_mstwr_dst_rdy_n = '0' then
           n := n + 1;
           ip2bus_mstwr_d <= data_to_write_burst(32*n+31 downto 32*n);  -- data to write----------------------------------------------------------------
           ip2bus_mstwr_sof_n     <= '1';  -- clear "first data beat" flag
           if (n = burst_length_v - 1) then
             ip2bus_mstwr_eof_n     <= '0';  -- this is the last data beat;
           end if;
           if (n = burst_length_v) then
             ip2bus_mstwr_src_rdy_n <= '1';  -- clear "valid data" flag
             ip2bus_mstwr_eof_n     <= '1';  -- clear "last data beat" flag
             master_read_burst_sm <= MASTER_FINISH;
           end if;
			  
			  
          end if;
     
	  
        when MASTER_FINISH =>
		  DEBUG_ESTADO <= "10000";
          if bus2ip_mst_cmplt = '1' then
            master_read_burst_sm <= MASTER_DONE;
            ack_c2t <= '1';
          end if;
			         
        when MASTER_DONE =>
		  DEBUG_ESTADO <= "10001";
            ack_c2t <= '0';
				master_read_burst_sm <= MASTER_DONE2;
				
		  when MASTER_DONE2 =>
		  DEBUG_ESTADO <= "10010";
            master_read_burst_sm <= MASTER_DONE3;
				
		  when MASTER_DONE3 =>
		  DEBUG_ESTADO <= "10011";
            master_read_burst_sm <= MASTER_IDLE;				
				
        when others => DEBUG_ESTADO <= "11111"; --null;
        
        end case;  -- master_read_burst_sm
		
      end if;  -- Bus2IP_Resetn
    end if;  -- rising_edge(Bus2IP_Clk)
  end process CONTROLLER_PROC;
  
  
  
end Behavioral;

