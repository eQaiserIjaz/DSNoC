------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
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
-- Date:              Wed Apr 15 10:35:37 2015 (by Create and Import Peripheral Wizard)
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

library top_level_peripheral_v1_00_a;
use top_level_peripheral_v1_00_a.HermesPackage.all;
use top_level_peripheral_v1_00_a.ParameterPackage.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
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
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_NUM_REG                      : integer              := 2;
    C_SLV_DWIDTH                   : integer              := 32
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    --USER ports added here
    -- ADD USER PORTS ABOVE THIS LINE ------------------
    --latency_total : out integNORT;
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
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Resetn : signal is "RST";
  
  

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic
  
  ------------------------------------------
  -- component Noc
  ------------------------------------------
  component NOC is
  port (
	clock         : in  std_logic;
	reset         : in  std_logic;
	rxLocal       : in  regNrot;
	data_inLocal  : in  arrayNrot_regflit;
	ack_rxLocal   : out regNrot;
	txLocal       : out regNrot;
	data_outLocal : out arrayNrot_regflit;
	ack_txLocal   : in  regNrot
	);
  end component;
  --attribute box_type : string;
  --attribute box_type of NOC : component is "user_black_box";
   ------------------------------------------
  -- component Wrapper
  ------------------------------------------
  component NI_Wrapper is
  port (
	Bus2NI_Clk                     : in  std_logic;
    Bus2NI_Resetn                  : in  std_logic;
	
	--from NI to router 
	rxLocNI       : in  std_logic;
	data_inLocNI  : in  regflit;
	ack_rxLocNI   : out std_logic;
	txLocNI       : out std_logic;
	data_outLocNI : out regflit;
	ack_txLocNI   : in  std_logic;
	
	-- --from NI to AXI bus 	
    Bus2NI_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0); 
    Bus2NI_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);	
    Bus2NI_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    Bus2NI_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    NI2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    NI2Bus_RdAck                   : out std_logic;
    NI2Bus_WrAck                   : out std_logic;
    NI2Bus_Error                   : out std_logic
	);
  end component;
  
  ------------------------------------------
  -- component Trafic generator
  ------------------------------------------
--  component traffic_generator 
--	generic (
--	address: regmetadeflit;	-- address of initiator
--	IP_address_x: integer ;  -- address of destination X axis
--	IP_address_y: integer ;  -- address of destination Y axis
--	size_packet_int:INTEGER; --address and number of flits is included.
--	nber_packet:INTEGER;		-- number of the packets.
--	idle_percent: integidle--;     -- idle percent.	     
--	);	
--	port (
--	clock, reset			: IN std_logic;
--	router_rx				: OUT std_logic;
--	router_ack_rx			: IN std_logic;
--	router_data_in			: OUT regflit 
--	);
--  end component;
  
  
 COMPONENT traffic_generator
GENERIC(adresse:std_logic_vector(7 DOWNTO 0);
        TRx:INTEGER;
        dest_addres_integer,total_flit_in_packet:INTEGER;
        num_pakets:INTEGER;
        idle_paket:INTEGER);
PORT(clock,reset,router_tx,router_ack_rx:  IN std_logic;
     router_data_out:          IN regflit;
     router_rx,router_ack_tx:  OUT std_logic;
     router_data_in:           OUT regflit);
END COMPONENT;


 COMPONENT traffic_generator1
GENERIC(adresse1:std_logic_vector(7 DOWNTO 0);
        TRx1:INTEGER;
        dest_addres_integer1,total_flit_in_packet1:INTEGER;
        num_pakets1:INTEGER;
        idle_paket1:INTEGER);
PORT(clock,reset,router_tx1,router_ack_rx1:  IN std_logic;
     router_data_out1:          IN regflit;
     router_rx1,router_ack_tx1:  OUT std_logic;
     router_data_in1:           OUT regflit);
END COMPONENT;

 COMPONENT traffic_generator2
GENERIC(adresse2:std_logic_vector(7 DOWNTO 0);
        TRx2:INTEGER;
        dest_addres_integer2,total_flit_in_packet2:INTEGER;
        num_pakets2:INTEGER;
        idle_paket2:INTEGER);
PORT(clock,reset,router_tx2,router_ack_rx2:  IN std_logic;
     router_data_out2:          IN regflit;
     router_rx2,router_ack_tx2:  OUT std_logic;
     router_data_in2:           OUT regflit);
END COMPONENT;

--  Component traffic_receptor
--	generic (  pkt_number: integer
--		);
--	port (
--	reset				: in std_logic;
--	clock				: IN std_logic;
--	data_in     	: IN regflit;
--	ack_rx         : OUT std_logic;
--	rx             : IN std_logic	
--	);
--  end component;
--  attribute box_type2: string;
--  attribute box_type2 of traffic_receptor: component is "black_box";
  ------------------------------------------
  -- Signals for NoC and TG
  ------------------------------------------
  SIGNAL signal_clock, signal_reset	    : std_logic;
  SIGNAL signal_rxlocal					: regNrot;
  signal signal_data_inlocal			: arrayNrot_regflit;
  signal signal_txlocal					: regNrot;
  signal signal_data_outlocal			: arrayNrot_regflit;
  signal signal_ack_rxlocal				: regNrot;
  signal signal_ack_txlocal				: regNrot;
   
   ------------------------------------------
  -- Signals for noc_wrapper
  ------------------------------------------
  -- signal rxLocNI_signal       : std_logic;
  -- signal data_inLocNI_signal  : regflit;
  -- signal ack_rxLocNI_signal   : std_logic;
  -- signal txLocNI_signal       : std_logic;
  -- signal data_outLocNI_signal : regflit;
  -- signal ack_txLocNI_signal   : std_logic;
  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg1                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal bus2slv_be                     : std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);
  signal slv_reg_write_sel              : std_logic_vector(1 downto 0);
  signal slv_reg_read_sel               : std_logic_vector(1 downto 0);
  signal slv_ip2bus_data                : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;
  signal slv_ip2bus_error               : std_logic;

begin

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
--  slv_reg_write_sel <= Bus2IP_WrCE(1 downto 0);
--  slv_reg_read_sel  <= Bus2IP_RdCE(1 downto 0);
--  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1);
--  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1);

  -- implement slave model software accessible register(s)
  --SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  --begin

    -- if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      -- if Bus2IP_Resetn = '0' then
        -- slv_reg0 <= (others => '0');
        -- slv_reg1 <= (others => '0');
      -- else
        -- case slv_reg_write_sel is
          -- when "10" =>
            -- for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              -- if ( Bus2IP_BE(byte_index) = '1' ) then
                -- slv_reg0(byte_index*8+7 downto byte_index*8) <= Bus2IP_Data(byte_index*8+7 downto byte_index*8);
              -- end if;
            -- end loop;
          -- when "01" =>
            -- for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              -- if ( Bus2IP_BE(byte_index) = '1' ) then
                -- slv_reg1(byte_index*8+7 downto byte_index*8) <= Bus2IP_Data(byte_index*8+7 downto byte_index*8);
              -- end if;
            -- end loop;
          -- when others => null;
        -- end case;
      -- end if;
    -- end if;

  -- end process SLAVE_REG_WRITE_PROC;

  -- -- implement slave model software accessible register(s) read mux
  -- SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0, slv_reg1 ) is
  -- begin

    -- case slv_reg_read_sel is
      -- when "10" => slv_ip2bus_data <= slv_reg0;
      -- when "01" => slv_ip2bus_data <= slv_reg1;
      -- when others => slv_ip2bus_data <= (others => '0');
    -- end case;

  -- end process SLAVE_REG_READ_PROC;

  -- ------------------------------------------
  -- -- Example code to drive IP to Bus signals
  -- ------------------------------------------
  -- IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  -- (others => '0');

  -- IP2Bus_WrAck <= slv_write_ack;
  -- IP2Bus_RdAck <= slv_read_ack;
  -- IP2Bus_Error <= '0';
 
  
  --USER logic implementation added here
  
    --USER logic implementation added here
   reNoC: NoC port map(
	clock				=> signal_clock,      
	reset				=> signal_reset,
	rxLocal			=> signal_rxlocal,       
	data_inLocal   => signal_data_inlocal,
	ack_rxLocal    => signal_ack_rxlocal,	
	txLocal        => signal_txlocal,
	data_outLocal  => signal_data_outlocal,
	ack_txLocal 	=> signal_ack_txlocal
    );
	 
	 			 			Wrapper_NI: NI_Wrapper  port map		(
							
											Bus2NI_Clk 		  => signal_clock, 
											Bus2NI_Resetn	  => signal_reset,
	
											--from NI to router 
											rxLocNI       => signal_txlocal(0),
											data_inLocNI  => signal_data_outlocal(0),
											ack_rxLocNI   => signal_ack_txlocal(0),											
											txLocNI       => signal_rxlocal(0),
											data_outLocNI => signal_data_inlocal(0),
											ack_txLocNI   => signal_ack_rxlocal(0),
	
											    --from NI to AXI bus 	
											Bus2NI_Data         => slv_reg0,
                                 Bus2NI_BE         	=> bus2slv_be,										
											Bus2NI_RdCE         => slv_reg_read_sel, 
											Bus2NI_WrCE         => slv_reg_write_sel,
											NI2Bus_Data         => slv_ip2bus_data,
											NI2Bus_RdAck        => slv_read_ack,
											NI2Bus_WrAck        => slv_write_ack,
											NI2Bus_Error        => slv_ip2bus_error
																				
										);
	
					  			TRxs0: traffic_generator GENERIC MAP(adresse=>"00010001",TRx=>1, dest_addres_integer=>0,total_flit_in_packet=>9,num_pakets=>10,idle_paket=>5)
                          PORT MAP(clock=>signal_clock,
                                  reset=>signal_reset,
                                  router_data_in=>signal_data_inlocal(1),
                                  router_rx=>signal_rxlocal(1),
                                  router_ack_tx=>signal_ack_txlocal(1),
                                  router_tx=>signal_txlocal(1),
                                  router_ack_rx=>signal_rxlocal(1),
                                  router_data_out=>signal_data_outlocal(1));
											 
								TRxs1: traffic_generator GENERIC MAP(adresse=>"00010001",TRx=>1, dest_addres_integer=>0,total_flit_in_packet=>9,num_pakets=>10,idle_paket=>5)
                         PORT MAP(clock=>signal_clock,
                                  reset=>signal_reset,
                                  router_data_in=>signal_data_inlocal(2),
                                  router_rx=>signal_rxlocal(2),
                                  router_ack_tx=>signal_ack_txlocal(2),
                                  router_tx=>signal_txlocal(2),
                                  router_ack_rx=>signal_rxlocal(2),
                                  router_data_out=>signal_data_outlocal(2));
											 
					  			TRxs2: traffic_generator GENERIC MAP(adresse=>"00010001",TRx=>1, dest_addres_integer=>0,total_flit_in_packet=>9,num_pakets=>10,idle_paket=>5)
                         PORT MAP(clock=>signal_clock,
                                  reset=>signal_reset,
                                  router_data_in=>signal_data_inlocal(3),
                                  router_rx=>signal_rxlocal(3),
                                  router_ack_tx=>signal_ack_txlocal(3),
                                  router_tx=>signal_txlocal(3),
                                  router_ack_rx=>signal_rxlocal(3),
                                  router_data_out=>signal_data_outlocal(3));
											 
---- Connection the TG and TR to each switch on the Y direction
--gen1: for y in 0 to  MAX_Y   generate 
--
---- Connection the TG and TR to each switch on the X direction
--				gen2 : for x in 0 to MAX_X generate
--                  
--						
--				      rou1: if(x =0 and y/=0) or (x/=0 and y=0) or (x/=0 and y/=0) generate
----				 			generator_y_x: 	 traffic_generator  generic map( address	=>conv_std_logic_vector((MAX_Y-y),QUARTOFLIT)&conv_std_logic_vector((MAX_X-x),QUARTOFLIT),			
----												IP_address_x=> x,
----												IP_address_y=> y,	
----												size_packet_int => 6 ,	
----												nber_packet	=> 4 ,		
----												idle_percent => idle_percent
----											) 
----								port map		(
----											clock 				=> signal_clock,
----											reset				   => signal_reset,
----											router_rx			=> signal_rxlocal(x+y*(MAX_X+1)),
----											router_ack_rx		=> signal_ack_rxlocal(x+y*(MAX_X+1)),	
----											router_data_in		=> signal_data_inlocal(x+y*(MAX_X+1))			 
----												);		
--			
----				receptor_y_x: traffic_receptor  generic map(pkt_number => 4)
----								port map (
----							reset					=> signal_reset,
----							clock				   => signal_clock,
----							data_in     	   => signal_data_outlocal(x+y*(MAX_X+1)),
----							ack_rx             => signal_ack_txlocal(x+y*(MAX_X+1)),
----							rx   			   => signal_txlocal(x+y*(MAX_X+1))							   
----											);                
--					  			TRxs: traffic_generator GENERIC MAP(adresse=>"00010001",TRx=>1, dest_addres_integer=>0,total_flit_in_packet=>9,num_pakets=>10,idle_paket=>5)
--                          PORT MAP(clock=>signal_clock,
--                                  reset=>signal_reset,
--                                  router_data_in=>signal_data_inlocal(x+y*(MAX_X+1)),
--                                  router_rx=>signal_rxlocal(x+y*(MAX_X+1)),
--                                  router_ack_tx=>signal_ack_txlocal(x+y*(MAX_X+1)),
--                                  router_tx=>signal_txlocal(x+y*(MAX_X+1)),
--                                  router_ack_rx=>signal_rxlocal(x+y*(MAX_X+1)),
--                                  router_data_out=>signal_data_outlocal(x+y*(MAX_X+1)));
--					  end generate rou1;	
--				end generate gen2;
--end generate gen1;


signal_clock <= Bus2IP_Clk;
signal_reset <= Bus2IP_Resetn;

slv_reg0<= Bus2IP_Data;
bus2slv_be <= Bus2IP_BE;
slv_reg_read_sel  <= Bus2IP_RdCE(1 downto 0);
slv_reg_write_sel <= Bus2IP_WrCE(1 downto 0);
IP2Bus_Data  <= slv_ip2bus_data;
IP2Bus_RdAck <= slv_read_ack;
IP2Bus_WrAck <= slv_write_ack;
IP2Bus_Error <= slv_ip2bus_error;     

end IMP;


