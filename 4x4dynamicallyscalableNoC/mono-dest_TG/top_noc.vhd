----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- Module Name:    top_noc - Behavioral 
-- Project Name:   HERMES NoC emulation Platform
-- Target Devices: Xilinx V5 ML506
-- Tool versions: Xilinx 10.1
-- Description:  This version provides the HERMES NoC emulation in the scenario of multi initiators to one destination. 
--
-- Dependencies: 
--
-- Revision: Multi-sources, Mono-destination Version 1
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
 


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HermesPackage.all;
use work.ParameterPackage.all;


entity top_noc is

port (
clk_top	: In std_logic; -- Global clock signal
top_reset			: In std_logic;
--latency_total : out integNORT;
--total_time				: out integNORT
--clk200     : OUT STD_LOGIC; 
clk200_P   : IN STD_LOGIC;
clk200_N   : IN STD_LOGIC
);
end top_noc;

architecture archi_top_noc of top_noc is


component NOC
port 
(
	clock         : in  std_logic;
	reset         : in  std_logic;
	rxLocal       : in  regNrot;
	data_inLocal  : in  arrayNrot_regflit;
	ack_rxLocal   : out regNrot;
	txLocal       : out regNrot;
	data_outLocal : out arrayNrot_regflit;
	ack_txLocal   : in  regNrot);
End component;

component IBUFGDS
port 
(I : IN STD_LOGIC; 
IB: In STD_LOGIC; 
O : OUT STD_LOGIC);
End component;

component traffic_generator 
generic (


  address: 		regmetadeflit; --address of the destination "mmmmnnnn", Y=mmmm,X=nnnn	
  IP_address_x: integer ;  
  IP_address_y: integer ;  
  size_packet_int:INTEGER;  
  nber_packet:INTEGER;		
  idle_time:INTEGER       
);	
port (
clock, reset			: IN std_logic;
router_rx				: OUT std_logic;
router_ack_rx			: IN std_logic;
router_data_in			: OUT regflit 
);
end component;	

Component traffic_receptor
generic (  pkt_number: integer
    );
port (
reset				: in std_logic;
clock				: IN std_logic;
data_in     	: IN regflit;
ack_rx         : OUT std_logic;
rx             : IN std_logic
--latency_total  : out integer;
--total_time     : out integer
);
end component;

SIGNAL signal_clock,clk200, signal_reset	: std_logic;
SIGNAL signal_rxlocal					: regNrot; --array(num_routers-1 downto 0)
signal signal_data_inlocal				: arrayNrot_regflit;
signal signal_txlocal					: regNrot; --array(num_routers-1 downto 0)
signal signal_data_outlocal			: arrayNrot_regflit;
signal signal_ack_rxlocal				: regNrot; --array(num_routers-1 downto 0)
signal signal_ack_txlocal				: regNrot; --array(num_routers-1 downto 0)


begin

my_clk_inst : IBUFGDS
      port map (I => clk200_P,
               IB => clk200_N,
					O => clk200);

NoC4x4: NoC port map(
	clock		  => signal_clock,      
	reset		  => signal_reset,
	rxLocal		  => signal_rxlocal,       
	data_inLocal   => signal_data_inlocal,
	ack_rxLocal    => signal_ack_rxlocal,
	txLocal        => signal_txlocal,
	data_outLocal  => signal_data_outlocal,
	ack_txLocal 	=> signal_ack_txlocal
);

-- Connection the TG and TR to each switch on the Y direction
gen1: for y in 0 to  MAX_Y   generate 

-- Connection the TG and TR to each switch on the X direction
				gen2 : for x in 0 to MAX_X generate 
				 			generator_y_x: 	 traffic_generator  generic map( address	=>address_destination,			
												IP_address_x=> x,
												IP_address_y=> y,	
												size_packet_int => size_of_packet(x+y*(MAX_X+1)) ,	
												nber_packet	=> nbre_packet_send (x+y*(MAX_X+1)) ,		
												idle_time => idle_time (x+y*(MAX_X+1)) 	 ) 
								port map		(
											clock 				=> signal_clock,
											reset				=> signal_reset,
											router_rx			=> signal_rxlocal(x+y*(MAX_X+1)),
											router_ack_rx		=> signal_ack_rxlocal(x+y*(MAX_X+1)),	
											router_data_in		=> signal_data_inlocal(x+y*(MAX_X+1))			 
												);		
			
				receptor_y_x: traffic_receptor  generic map(pkt_number => nbre_packet_received(x+y*(MAX_X+1)))
								port map (
							reset					=> signal_reset,
							clock				   => signal_clock,
							data_in     	   => signal_data_outlocal(x+y*(MAX_X+1)),
							ack_rx            => signal_ack_txlocal(x+y*(MAX_X+1)),
								rx   					=> signal_txlocal(x+y*(MAX_X+1))
							--latency_total     => latency_total(x+y*(MAX_X+1)),
								--total_time					=> total_time(x+y*(MAX_X+1))
											);
	
				end generate gen2;
end generate gen1;	 
							
												
signal_clock <= clk_top;
signal_reset <= top_reset;

end archi_top_noc;

