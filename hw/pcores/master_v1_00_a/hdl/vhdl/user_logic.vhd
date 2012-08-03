------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2011 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Wed Apr 18 15:27:26 2012 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.srl_fifo_f;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_MST_NATIVE_DATA_WIDTH      -- Internal bus width on user-side
--   C_MST_LENGTH_WIDTH           -- Master interface data bus width
--   C_MST_AWIDTH                 -- Master-Intf address bus width
--   C_NUM_REG                    -- Number of software accessible registers
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Resetn                -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
--   ip2bus_mstrd_req             -- 
--   ip2bus_mstwr_req             -- 
--   ip2bus_mst_addr              -- 
--   ip2bus_mst_be                -- 
--   ip2bus_mst_length            -- 
--   ip2bus_mst_type              -- 
--   ip2bus_mst_lock              -- 
--   ip2bus_mst_reset             -- 
--   bus2ip_mst_cmdack            -- 
--   bus2ip_mst_cmplt             -- 
--   bus2ip_mst_error             -- 
--   bus2ip_mst_rearbitrate       -- 
--   bus2ip_mst_cmd_timeout       -- 
--   bus2ip_mstrd_d               -- 
--   bus2ip_mstrd_rem             -- 
--   bus2ip_mstrd_sof_n           -- 
--   bus2ip_mstrd_eof_n           -- 
--   bus2ip_mstrd_src_rdy_n       -- 
--   bus2ip_mstrd_src_dsc_n       -- 
--   ip2bus_mstrd_dst_rdy_n       -- 
--   ip2bus_mstrd_dst_dsc_n       -- 
--   ip2bus_mstwr_d               -- 
--   ip2bus_mstwr_rem             -- 
--   ip2bus_mstwr_src_rdy_n       -- 
--   ip2bus_mstwr_src_dsc_n       -- 
--   ip2bus_mstwr_sof_n           -- 
--   ip2bus_mstwr_eof_n           -- 
--   bus2ip_mstwr_dst_rdy_n       -- 
--   bus2ip_mstwr_dst_dsc_n       -- 
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_MST_NATIVE_DATA_WIDTH        : integer              := 32;
    C_MST_LENGTH_WIDTH             : integer              := 12;
    C_MST_AWIDTH                   : integer              := 32;
    C_NUM_REG                      : integer              := 6;
    C_SLV_DWIDTH                   : integer              := 32
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    --USER ports added here
    address_in_0 : in std_logic_vector(31 downto 0); --register0
    address_in_1 : in std_logic_vector(31 downto 0); --register1
    address_in_2 : in std_logic_vector(31 downto 0); --register2
    address_in_3 : in std_logic_vector(31 downto 0); --register3
	 go : in std_logic;                               --register4
	 ready : out std_logic;                           --register5
	 DEBUG_signal : out std_logic_vector(250 downto 0);
	  -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Resetn                  : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    Bus2IP_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
    Bus2IP_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    Bus2IP_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    IP2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic;
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
    bus2ip_mst_rearbitrate         : in  std_logic;
    bus2ip_mst_cmd_timeout         : in  std_logic;
    bus2ip_mstrd_d                 : in  std_logic_vector(C_MST_NATIVE_DATA_WIDTH-1 downto 0);
    bus2ip_mstrd_rem               : in  std_logic_vector((C_MST_NATIVE_DATA_WIDTH)/8-1 downto 0);
    bus2ip_mstrd_sof_n             : in  std_logic;
    bus2ip_mstrd_eof_n             : in  std_logic;
    bus2ip_mstrd_src_rdy_n         : in  std_logic;
    bus2ip_mstrd_src_dsc_n         : in  std_logic;
    ip2bus_mstrd_dst_rdy_n         : out std_logic;
    ip2bus_mstrd_dst_dsc_n         : out std_logic;
    ip2bus_mstwr_d                 : out std_logic_vector(C_MST_NATIVE_DATA_WIDTH-1 downto 0);
    ip2bus_mstwr_rem               : out std_logic_vector((C_MST_NATIVE_DATA_WIDTH)/8-1 downto 0);
    ip2bus_mstwr_src_rdy_n         : out std_logic;
    ip2bus_mstwr_src_dsc_n         : out std_logic;
    ip2bus_mstwr_sof_n             : out std_logic;
    ip2bus_mstwr_eof_n             : out std_logic;
    bus2ip_mstwr_dst_rdy_n         : in  std_logic;
    bus2ip_mstwr_dst_dsc_n         : in  std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Resetn : signal is "RST";
  attribute SIGIS of ip2bus_mst_reset: signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is
--READY_PROC0, 1, 2 y 3 --> pone las señales de ready a '1'
--RD_REQ_PROC0, 1, 2 y 3 --> controla los rd req
--DECOD_PROC --> detecta cuándo merece la pena hacer un burst
--FILT_PROC --> da el dato a quien corresponda, según addr count
--ACK_PROC --> genera los ack bis (para mantener la sincronización)
--WR_REQ_PROC0, 1, 2 y 3 --> controla los wr req
 
    COMPONENT thread
    PORT(
         clk : IN  std_logic;
         resetn : IN  std_logic;
         -- from/to memory controller
         data_in_m : IN  std_logic_vector(31 downto 0);
         data_out_m : OUT  std_logic_vector(31 downto 0);
         address_m : OUT  std_logic_vector(31 downto 0);
         rd_req_m : OUT  std_logic;
         wr_req_m : OUT  std_logic;
         ack_m : IN  std_logic;
         -- from/to registers
         go_r : IN  std_logic;
         ready_r : OUT  std_logic;
         address_a_r : IN  std_logic_vector(31 downto 0);
--         address_b_r : IN  std_logic_vector(31 downto 0)
			DATA_DEBUG : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
    
    COMPONENT controller
    PORT(
         -- from/to thread
         data_t2c : in std_logic_vector (31 downto 0);
         data_c2t : out std_logic_vector (31 downto 0);
         address_t2c : in std_logic_vector (31 downto 0);
         rd_req_t2c : in std_logic;
			wr_req_t2c : in std_logic;
         ack_c2t : out std_logic;
			------
         burst_type : in std_logic;
         burst_length : in std_logic_vector(11 downto 0);
			data_to_write_burst : in std_logic_vector(16*32-1 downto 0);
         ------
			address_count : out std_logic_vector (31 downto 0);
			------
			DEBUG_ESTADO : out std_logic_vector (4 downto 0);
         -- from/to bus
         Bus2IP_Clk                     : in  std_logic;
         Bus2IP_Resetn                  : in  std_logic;
--         Bus2IP_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
--         Bus2IP_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
--         Bus2IP_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
--         Bus2IP_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
--         IP2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
--         IP2Bus_RdAck                   : out std_logic;
--         IP2Bus_WrAck                   : out std_logic;
--         IP2Bus_Error                   : out std_logic;
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
--         bus2ip_mst_rearbitrate         : in  std_logic;
--         bus2ip_mst_cmd_timeout         : in  std_logic;
         bus2ip_mstrd_d                 : in  std_logic_vector(C_MST_NATIVE_DATA_WIDTH-1 downto 0);
--         bus2ip_mstrd_rem               : in  std_logic_vector((C_MST_NATIVE_DATA_WIDTH)/8-1 downto 0);
         bus2ip_mstrd_sof_n             : in  std_logic;
         bus2ip_mstrd_eof_n             : in  std_logic;
         bus2ip_mstrd_src_rdy_n         : in  std_logic;
--         bus2ip_mstrd_src_dsc_n         : in  std_logic;
         ip2bus_mstrd_dst_rdy_n         : out std_logic;
         ip2bus_mstrd_dst_dsc_n         : out std_logic;
         ip2bus_mstwr_d                 : out std_logic_vector(C_MST_NATIVE_DATA_WIDTH-1 downto 0);
         ip2bus_mstwr_rem               : out std_logic_vector((C_MST_NATIVE_DATA_WIDTH)/8-1 downto 0);
         ip2bus_mstwr_src_rdy_n         : out std_logic;
         ip2bus_mstwr_src_dsc_n         : out std_logic;
         ip2bus_mstwr_sof_n             : out std_logic;
         ip2bus_mstwr_eof_n             : out std_logic;
         bus2ip_mstwr_dst_rdy_n         : in  std_logic
--         bus2ip_mstwr_dst_dsc_n         : in  std_logic
        );
    END COMPONENT;
    
	 
	 COMPONENT ready_proc --pone las señales de ready a '1'
    PORT(
         clk : IN  std_logic;
         resetn : IN  std_logic;
         s_ready_ri : IN std_logic;
         readyi : OUT std_logic
        );
    END COMPONENT;


	 COMPONENT rd_req_proc --controla los rd req
    PORT(
         clk : IN  std_logic;
         resetn : IN  std_logic;
         s_rd_req_mi_bis : IN std_logic;
         s_ack_mi : IN std_logic;
         s_ack_t : IN std_logic;
         s_rd_req_mi : OUT std_logic
        );
    END COMPONENT;
	 
	 
	 COMPONENT decod_proc --detecta cuándo merece la pena hacer un burst
    PORT(
         clk : IN  std_logic;
         resetn : IN  std_logic;
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
    END COMPONENT;
	 
	 
	 COMPONENT filt_proc --da el dato a quien corresponda, según addr count
    PORT(
         clk : IN  std_logic;
         resetn : IN  std_logic;
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
    END COMPONENT;
	 
	 
	 COMPONENT ack_proc --genera los ack bis (para mantener la sincronización)
    PORT(
         clk : IN  std_logic;
         resetn : IN  std_logic;
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
    END COMPONENT;
	 
	 
	 COMPONENT wr_req_proc --controla los wr req
    PORT(
         clk : IN  std_logic;
         resetn : IN  std_logic;
         s_wr_req_mi_bis : in std_logic;
         s_ack_mi : in std_logic;
         s_ack_t : in std_logic;
         s_wr_req_mi : out std_logic
        );
    END COMPONENT;
	 
 
  --USER signal declarations added here, as needed for user logic

  --signals for controller:
  signal s_rd_req_m : std_logic;
  signal s_wr_req_m : std_logic;
  signal s_address_m : std_logic_vector(31 downto 0);
  signal s_data_in_m : std_logic_vector(31 downto 0);
  signal s_data_out_m : std_logic_vector(31 downto 0);
  signal s_ack_m : std_logic;
  signal s_address_count : std_logic_vector(31 downto 0);
  signal burst_length : std_logic_vector(11 downto 0);
  signal data_to_write_burst : std_logic_vector(16*32-1 downto 0);
  
  --signals for thread0:
  -- from/to memory controller
  signal s_data_in_m0 : std_logic_vector(31 downto 0);
  signal s_data_out_m0 : std_logic_vector(31 downto 0);
  signal s_address_m0 : std_logic_vector(31 downto 0);
  signal s_rd_req_m0 : std_logic;
  signal s_wr_req_m0 : std_logic;
  signal s_ack_m0 : std_logic;
  -- from/to registers
  signal s_ready_r0 : std_logic;
  signal s_address_a_r0 : std_logic_vector(31 downto 0);
  signal s_data_debug0 : std_logic_vector(31 downto 0);
  
  --signals for thread1:
  -- from/to memory controller
  signal s_data_in_m1 : std_logic_vector(31 downto 0);
  signal s_data_out_m1 : std_logic_vector(31 downto 0);
  signal s_address_m1 : std_logic_vector(31 downto 0);
  signal s_rd_req_m1 : std_logic;
  signal s_wr_req_m1 : std_logic;
  signal s_ack_m1 : std_logic;
  -- from/to registers
  signal s_ready_r1 : std_logic;
  signal s_address_a_r1 : std_logic_vector(31 downto 0);
  signal s_data_debug1 : std_logic_vector(31 downto 0);
  
  --signals for thread2:
  -- from/to memory controller
  signal s_data_in_m2 : std_logic_vector(31 downto 0);
  signal s_data_out_m2 : std_logic_vector(31 downto 0);
  signal s_address_m2 : std_logic_vector(31 downto 0);
  signal s_rd_req_m2 : std_logic;
  signal s_wr_req_m2 : std_logic;
  signal s_ack_m2 : std_logic;
  -- from/to registers
  signal s_ready_r2 : std_logic;
  signal s_address_a_r2 : std_logic_vector(31 downto 0);
  signal s_data_debug2 : std_logic_vector(31 downto 0);
  
  --signals for thread3:
  -- from/to memory controller
  signal s_data_in_m3 : std_logic_vector(31 downto 0);
  signal s_data_out_m3 : std_logic_vector(31 downto 0);
  signal s_address_m3 : std_logic_vector(31 downto 0);
  signal s_rd_req_m3 : std_logic;
  signal s_wr_req_m3 : std_logic;
  signal s_ack_m3 : std_logic;
  -- from/to registers
  signal s_ready_r3 : std_logic;
  signal s_address_a_r3 : std_logic_vector(31 downto 0);
  signal s_data_debug3 : std_logic_vector(31 downto 0);
  
  --signals for rd_req_processes
  signal s_rd_req_m0_bis : std_logic;
  signal s_rd_req_m1_bis : std_logic;
  signal s_rd_req_m2_bis : std_logic;
  signal s_rd_req_m3_bis : std_logic;
  
  --signals for ready_processes 
  type ready_proc_t is (ZERO, ONE);
    --signals for ready_process0
  signal s_ready_proc0 : ready_proc_t;
  signal ready0 : std_logic;
    --signals for ready_process1
  signal s_ready_proc1 : ready_proc_t;
  signal ready1 : std_logic;
    --signals for ready_process2
  signal s_ready_proc2 : ready_proc_t;
  signal ready2 : std_logic;
    --signals for ready_process3
  signal s_ready_proc3 : ready_proc_t;
  signal ready3 : std_logic;
  
  --signals for ack_processes
  type ack_t_proc_t is (ZERO, ONE);
  signal s_ack_t_proc : ack_t_proc_t;
  signal s_ack_t : std_logic;
  signal s_ack_m0_bis : std_logic;
  signal s_ack_m1_bis : std_logic;
  signal s_ack_m2_bis : std_logic;
  signal s_ack_m3_bis : std_logic;
  signal s_ack_m_bis : std_logic;
  signal s_data_in_m0_bis : std_logic_vector(31 downto 0);
  signal s_data_in_m1_bis : std_logic_vector(31 downto 0);
  signal s_data_in_m2_bis : std_logic_vector(31 downto 0);
  signal s_data_in_m3_bis : std_logic_vector(31 downto 0);
  
  --signals for wr_req_processes
  signal s_wr_req_m0_bis : std_logic;
  signal s_wr_req_m1_bis : std_logic;
  signal s_wr_req_m2_bis : std_logic;
  signal s_wr_req_m3_bis : std_logic;
  
  --other signals:
  signal s_burst_type : std_logic;
  signal s_data_read_burst : std_logic_vector(16*32-1 downto 0);
  signal identif : std_logic_vector(3 downto 0);
  
  signal DEBUG_bus2ip_mstrd_src_rdy_n : std_logic;
  signal DEBUG_ip2bus_mstwr_req : std_logic;
  signal DEBUG_bus2ip_mst_error : std_logic;
  signal DEBUG_ESTADO : std_logic_vector(4 downto 0);
  signal DEBUG_ip2bus_mst_length : std_logic_vector(11 downto 0);
  signal DEBUG_ip2bus_mstwr_sof_n : std_logic;
  signal DEBUG_ip2bus_mstwr_eof_n : std_logic;

  
  
  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg1                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg_write_sel              : std_logic_vector(1 downto 0);
  signal slv_reg_read_sel               : std_logic_vector(1 downto 0);
  signal slv_ip2bus_data                : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

 
begin

  --USER logic implementation added here

  ------------------------------------------
  -- Example code to read/write user logic slave model s/w accessible registers
  -- 
  -- Note:
  -- The example code presented here is to show you one way of reading/writing
  -- software accessible registers implemented in the user logic slave model.
  -- Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  -- to one software accessible register by the top level template. For example,
  -- if you have four 32 bit software accessible registers in the user logic,
  -- you are basically operating on the following memory mapped registers:
  -- 
  --    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  --                     "1000"   C_BASEADDR + 0x0
  --                     "0100"   C_BASEADDR + 0x4
  --                     "0010"   C_BASEADDR + 0x8
  --                     "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
  slv_reg_write_sel <= Bus2IP_WrCE(1 downto 0);
  slv_reg_read_sel  <= Bus2IP_RdCE(1 downto 0);
  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1);
  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Resetn = '0' then
        slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
      else
        case slv_reg_write_sel is
          when "10" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8+7 downto byte_index*8) <= Bus2IP_Data(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
          when "01" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg1(byte_index*8+7 downto byte_index*8) <= Bus2IP_Data(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0, slv_reg1 ) is
  begin

    case slv_reg_read_sel is
      when "10" => slv_ip2bus_data <= slv_reg0;
      when "01" => slv_ip2bus_data <= slv_reg1;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;



  --------------------------------------------------
  -- Threads instantiation
 
   thread0: thread PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
			 -- from/to memory controller
          data_in_m => s_data_in_m0_bis,
          data_out_m => s_data_out_m0,
          address_m => s_address_m0,
          rd_req_m => s_rd_req_m0_bis,
          wr_req_m => s_wr_req_m0_bis,
          ack_m => s_ack_t,
			 -- from/to registers
          go_r => go,
          ready_r => s_ready_r0,
          address_a_r => address_in_0,
			 DATA_DEBUG => s_data_debug0
        );
		  
  --------------------------------------------------		  
	thread1: thread PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
			 -- from/to memory controller
          data_in_m => s_data_in_m1_bis,
			 data_out_m => s_data_out_m1,
          address_m => s_address_m1,
          rd_req_m => s_rd_req_m1_bis,
			 wr_req_m => s_wr_req_m1_bis,
          ack_m => s_ack_t,
			 -- from/to registers
          go_r => go,
          ready_r => s_ready_r1,
          address_a_r => address_in_1,
			 DATA_DEBUG => s_data_debug1
        );
		  
  --------------------------------------------------
  	thread2: thread PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
			 -- from/to memory controller
          data_in_m => s_data_in_m2_bis,
			 data_out_m => s_data_out_m2,
          address_m => s_address_m2,
          rd_req_m => s_rd_req_m2_bis,
			 wr_req_m => s_wr_req_m2_bis,
          ack_m => s_ack_t,
			 -- from/to registers
          go_r => go,
          ready_r => s_ready_r2,
          address_a_r => address_in_2,
			 DATA_DEBUG => s_data_debug2
        );
		  
  --------------------------------------------------
  	thread3: thread PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
			 -- from/to memory controller
          data_in_m => s_data_in_m3_bis,
			 data_out_m => s_data_out_m3,
          address_m => s_address_m3,
          rd_req_m => s_rd_req_m3_bis,
			 wr_req_m => s_wr_req_m3_bis,
          ack_m => s_ack_t,
			 -- from/to registers
          go_r => go,
          ready_r => s_ready_r3,
          address_a_r => address_in_3,
			 DATA_DEBUG => s_data_debug3
        );
  
  --------------------------------------------------
  
  
  --------------------------------------------------
  -- Controller instantiation
 
   controller0: controller PORT MAP ( 
         -- from/to thread
         data_t2c => s_data_out_m,
         data_c2t => s_data_in_m,
         address_t2c => s_address_m,
         rd_req_t2c => s_rd_req_m,
         wr_req_t2c => s_wr_req_m,
         ack_c2t => s_ack_m,
         ----
         burst_type => s_burst_type,
			burst_length => burst_length,
			data_to_write_burst => data_to_write_burst,
			----
			address_count => s_address_count,
			----
			DEBUG_ESTADO => DEBUG_ESTADO,
         -- from/to bus
         Bus2IP_Clk                     => Bus2IP_Clk,              
         Bus2IP_Resetn                  => Bus2IP_Resetn,
--         Bus2IP_Data                    => Bus2IP_Data,
--         Bus2IP_BE                      => Bus2IP_BE,
--         Bus2IP_RdCE                    => Bus2IP_RdCE,
--         Bus2IP_WrCE                    => Bus2IP_WrCE,
--         IP2Bus_Data                    => IP2Bus_Data,
--         IP2Bus_RdAck                   => IP2Bus_RdAck,
--         IP2Bus_WrAck                   => IP2Bus_WrAck,
--         IP2Bus_Error                   => IP2Bus_Error,
         ip2bus_mstrd_req               => ip2bus_mstrd_req,
         ip2bus_mstwr_req               => DEBUG_ip2bus_mstwr_req,--------------------------------------------
         ip2bus_mst_addr                => ip2bus_mst_addr,
         ip2bus_mst_be                  => ip2bus_mst_be,
         ip2bus_mst_length              => DEBUG_ip2bus_mst_length,----------------------------------------
         ip2bus_mst_type                => ip2bus_mst_type,
         ip2bus_mst_lock                => ip2bus_mst_lock,
         ip2bus_mst_reset               => ip2bus_mst_reset,
         bus2ip_mst_cmdack              => bus2ip_mst_cmdack,
         bus2ip_mst_cmplt               => bus2ip_mst_cmplt,
         bus2ip_mst_error               => bus2ip_mst_error,
--         bus2ip_mst_rearbitrate         => bus2ip_mst_rearbitrate,
--         bus2ip_mst_cmd_timeout         => bus2ip_mst_cmd_timeout,
         bus2ip_mstrd_d                 => bus2ip_mstrd_d,
--         bus2ip_mstrd_rem               => bus2ip_mstrd_rem,
         bus2ip_mstrd_sof_n             => bus2ip_mstrd_sof_n,
         bus2ip_mstrd_eof_n             => bus2ip_mstrd_eof_n,
         bus2ip_mstrd_src_rdy_n         => bus2ip_mstrd_src_rdy_n,
--         bus2ip_mstrd_src_dsc_n         => bus2ip_mstrd_src_dsc_n,
         ip2bus_mstrd_dst_rdy_n         => ip2bus_mstrd_dst_rdy_n,
         ip2bus_mstrd_dst_dsc_n         => ip2bus_mstrd_dst_dsc_n,
         ip2bus_mstwr_d                 => ip2bus_mstwr_d,
         ip2bus_mstwr_rem               => ip2bus_mstwr_rem,
         ip2bus_mstwr_src_rdy_n         => ip2bus_mstwr_src_rdy_n,
         ip2bus_mstwr_src_dsc_n         => ip2bus_mstwr_src_dsc_n,
         ip2bus_mstwr_sof_n             => DEBUG_ip2bus_mstwr_sof_n,-----------------------------------
         ip2bus_mstwr_eof_n             => DEBUG_ip2bus_mstwr_eof_n,-----------------------------------
         bus2ip_mstwr_dst_rdy_n         => bus2ip_mstwr_dst_rdy_n
--         bus2ip_mstwr_dst_dsc_n         => bus2ip_mstwr_dst_dsc_n  
        );    
		  
  --------------------------------------------------
  
  
  --------------------------------------------------
  -- Ready processes instantiation (one per thread)
  -- pone las señales de ready a '1'
  
  ready_proc0: ready_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_ready_ri => s_ready_r0,
          readyi => ready0
        );

  --------------------------------------------------
  ready_proc1: ready_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_ready_ri => s_ready_r1,
          readyi => ready1
        );

  --------------------------------------------------
  ready_proc2: ready_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_ready_ri => s_ready_r2,
          readyi => ready2
        );

  --------------------------------------------------
  ready_proc3: ready_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_ready_ri => s_ready_r3,
          readyi => ready3
        );
  
  ----		  
  ready <= ready0 and ready1 and ready2 and ready3;
  
  --------------------------------------------------


  --------------------------------------------------
  -- Read requests processes instantiation (one per thread)
  -- controla los rd req
  
  rd_req_proc0: rd_req_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_rd_req_mi_bis => s_rd_req_m0_bis,
          s_ack_mi => s_ack_m0,
          s_ack_t => s_ack_t,
          s_rd_req_mi => s_rd_req_m0
        );

  --------------------------------------------------
  rd_req_proc1: rd_req_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_rd_req_mi_bis => s_rd_req_m1_bis,
          s_ack_mi => s_ack_m1,
          s_ack_t => s_ack_t,
          s_rd_req_mi => s_rd_req_m1
        );

  --------------------------------------------------
  rd_req_proc2: rd_req_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_rd_req_mi_bis => s_rd_req_m2_bis,
          s_ack_mi => s_ack_m2,
          s_ack_t => s_ack_t,
          s_rd_req_mi => s_rd_req_m2
        );

  --------------------------------------------------
  rd_req_proc3: rd_req_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_rd_req_mi_bis => s_rd_req_m3_bis,
          s_ack_mi => s_ack_m3,
          s_ack_t => s_ack_t,
          s_rd_req_mi => s_rd_req_m3
        );

  --------------------------------------------------
  
  
  
  --------------------------------------------------
  -- Decod. process instantiation
  -- detecta cuándo merece la pena hacer un burst
  
  decod_proc0: decod_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_rd_req_m0 => s_rd_req_m0,
          s_rd_req_m1 => s_rd_req_m1,
          s_rd_req_m2 => s_rd_req_m2,
          s_rd_req_m3 => s_rd_req_m3,
			 s_wr_req_m0 => s_wr_req_m0,
			 s_wr_req_m1 => s_wr_req_m1,
			 s_wr_req_m2 => s_wr_req_m2,
			 s_wr_req_m3 => s_wr_req_m3,
          s_address_m0 => s_address_m0,
          s_address_m1 => s_address_m1,
          s_address_m2 => s_address_m2,
          s_address_m3 => s_address_m3,
			 s_data_out_m0 => s_data_out_m0,
          s_data_out_m1 => s_data_out_m1,
          s_data_out_m2 => s_data_out_m2,
          s_data_out_m3 => s_data_out_m3,
          s_rd_req_m => s_rd_req_m,
          s_wr_req_m => s_wr_req_m,
          s_address_m => s_address_m,
          s_data_out_m => s_data_out_m,
          s_burst_type => s_burst_type,
          burst_length => burst_length,
			 data_to_write_burst => data_to_write_burst,
			 identif => identif
        );

  --------------------------------------------------

  
  --------------------------------------------------
  -- Filt. process instantiation
  -- da el dato a quien corresponda, según addr count
  
  filt_proc0: filt_proc PORT MAP (
          clk => Bus2IP_Clk,
			 resetn => Bus2IP_Resetn,
          s_burst_type => s_burst_type,
          bus2ip_mstrd_src_rdy_n => bus2ip_mstrd_src_rdy_n,
          s_address_count => s_address_count,
          s_address_m0 => s_address_m0,
          s_address_m1 => s_address_m1,
          s_address_m2 => s_address_m2,
          s_address_m3 => s_address_m3,
          s_data_in_m => s_data_in_m,
          s_ack_m => s_ack_m,
			 s_wr_req_m0 => s_wr_req_m0,
			 s_wr_req_m1 => s_wr_req_m1,
			 s_wr_req_m2 => s_wr_req_m2,
			 s_wr_req_m3 => s_wr_req_m3,
			 identif => identif,
          s_data_in_m0 => s_data_in_m0,
          s_data_in_m1 => s_data_in_m1,
          s_data_in_m2 => s_data_in_m2,
          s_data_in_m3 => s_data_in_m3,
          s_ack_m0 => s_ack_m0,
          s_ack_m1 => s_ack_m1,
          s_ack_m2 => s_ack_m2,
          s_ack_m3 => s_ack_m3
        );

  --------------------------------------------------
  
  
  --------------------------------------------------
  -- Ack. process instantiation
  -- genera los ack bis (para mantener la sincronización)
  
  ack_proc0: ack_proc PORT MAP (
          clk => Bus2IP_Clk,
			 resetn => Bus2IP_Resetn,
			 s_ack_t => s_ack_t,
			 s_ack_m => s_ack_m,
			 s_ack_m0 => s_ack_m0,
			 s_ack_m1 => s_ack_m1,
			 s_ack_m2 => s_ack_m2,
			 s_ack_m3 => s_ack_m3,
			 s_data_in_m0 => s_data_in_m0,
          s_data_in_m1 => s_data_in_m1,
          s_data_in_m2 => s_data_in_m2,
          s_data_in_m3 => s_data_in_m3,
			 s_ack_m_bis => s_ack_m_bis,
			 s_ack_m0_bis => s_ack_m0_bis,
          s_ack_m1_bis => s_ack_m1_bis,
          s_ack_m2_bis => s_ack_m2_bis,
          s_ack_m3_bis => s_ack_m3_bis,
          s_data_in_m0_bis => s_data_in_m0_bis,
          s_data_in_m1_bis => s_data_in_m1_bis,
          s_data_in_m2_bis => s_data_in_m2_bis,
          s_data_in_m3_bis => s_data_in_m3_bis
        );
  
  ----
  s_ack_t <= s_ack_m0_bis and s_ack_m1_bis and s_ack_m2_bis and s_ack_m3_bis and s_ack_m_bis;

  --------------------------------------------------
  
  
  --------------------------------------------------
  -- Write requests processes instantiation (one per thread)
  -- controla los wr req
  
  wr_req_proc0: wr_req_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_wr_req_mi_bis => s_wr_req_m0_bis,
          s_ack_mi => s_ack_m0,
          s_ack_t => s_ack_t,
          s_wr_req_mi => s_wr_req_m0
        );

  --------------------------------------------------
  wr_req_proc1: wr_req_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_wr_req_mi_bis => s_wr_req_m1_bis,
          s_ack_mi => s_ack_m1,
          s_ack_t => s_ack_t,
          s_wr_req_mi => s_wr_req_m1
        );

  --------------------------------------------------
  wr_req_proc2: wr_req_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_wr_req_mi_bis => s_wr_req_m2_bis,
          s_ack_mi => s_ack_m2,
          s_ack_t => s_ack_t,
          s_wr_req_mi => s_wr_req_m2
        );

  --------------------------------------------------
  wr_req_proc3: wr_req_proc PORT MAP (
          clk => Bus2IP_Clk,
          resetn => Bus2IP_Resetn,
          s_wr_req_mi_bis => s_wr_req_m3_bis,
          s_ack_mi => s_ack_m3,
          s_ack_t => s_ack_t,
          s_wr_req_mi => s_wr_req_m3
        );

  --------------------------------------------------
  
  
  --------------------------------------------------
  -- debugging issues

  DEBUG_bus2ip_mstrd_src_rdy_n <= bus2ip_mstrd_src_rdy_n;
  ip2bus_mstwr_req <= DEBUG_ip2bus_mstwr_req;
  ip2bus_mst_length <= DEBUG_ip2bus_mst_length;
  ip2bus_mstwr_sof_n <= DEBUG_ip2bus_mstwr_sof_n;
  ip2bus_mstwr_eof_n <= DEBUG_ip2bus_mstwr_eof_n;
  DEBUG_bus2ip_mst_error <= bus2ip_mst_error;
  DEBUG_signal <= ready3& --1
						ready2& --1
						ready1& --1
						ready0& --1
						s_ack_t& --1
						s_ack_m_bis& --1
						s_ack_m& --1
						s_ack_m3_bis& --1
						s_ack_m3& --1
						s_ack_m2_bis& --1
						s_ack_m2& --1
						s_ack_m1_bis& --1
						s_ack_m1& --1
						s_ack_m0_bis& --1
						s_ack_m0& --1
						s_data_debug3& --32
						s_data_debug2& --32
						s_data_debug1& --32 s_data_in_m1& / s_data_debug1& / s_data_in_m1_bis
						s_data_debug0& --32
						s_data_in_m& --32
						--s_address_count& --32
						s_address_m& --32
						s_burst_type& --1
						s_wr_req_m& --1
						s_wr_req_m3& --1
						s_wr_req_m2& --1
						s_wr_req_m1& --1
						s_wr_req_m0& --1
						s_rd_req_m& --1
						s_rd_req_m3& --1
						s_rd_req_m2& --1
						s_rd_req_m1& --1
						s_rd_req_m0& --1
						go& --1
						identif& --4
						DEBUG_ip2bus_mstwr_req& --1
						DEBUG_bus2ip_mstrd_src_rdy_n& --1
						DEBUG_ip2bus_mstwr_sof_n& --1
						DEBUG_ip2bus_mstwr_eof_n& --1
						bus2ip_mstrd_src_dsc_n& --1
						bus2ip_mstwr_dst_rdy_n& --1
						bus2ip_mstwr_dst_dsc_n& --1
						bus2ip_mst_cmplt& --1
						bus2ip_mst_cmdack& --1
						DEBUG_bus2ip_mst_error& --1
						DEBUG_ip2bus_mst_length& --12
						DEBUG_ESTADO&'1'; --5+1
									------------
											--251
                      

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  --~ mst_ip2bus_data when mst_read_ack = '1' else
                  (others => '0');

  --~ IP2Bus_WrAck <= slv_write_ack or mst_write_ack;
  --~ IP2Bus_RdAck <= slv_read_ack or mst_read_ack;
  IP2Bus_WrAck <= slv_write_ack;
  IP2Bus_RdAck <= slv_read_ack;
  IP2Bus_Error <= '0';

end IMP;
