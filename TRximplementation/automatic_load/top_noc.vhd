----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:46:57 15/06/2011 
-- Design Name:  TAN Junyan, FRESSE Virginie, ROUSSEAU Frédéric.
-- Module Name:    top_noc - Behavioral 
-- Project Name:   HERMES NoC emulation Platform
-- Target Devices: Xilinx V5 ML506
-- Tool versions: Xilinx 10.1
-- Description:  This version provides the HERMES NoC emulation in the scenario of multi initiators to one destination with data injection rate automatic. 
--
-- Dependencies: 
--
-- Revision: Multi-sources, Mono-destination data injection rate automatic Version 1
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
top_clock	: In std_logic; -- Global clock signal
reset			: In std_logic; 
latency_total : out integNORT;
total_time				: out integNORT
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
	
component traffic_generator 
generic (
 address: regmetadeflit;	-- address of initiator
  IP_address_x: integer ;  -- address of destination X axis
  IP_address_y: integer ;  -- address of destination Y axis
  size_packet_int:INTEGER; --address and number of flits is included.
  nber_packet:INTEGER;		-- number of the packets.
  idle_percent: integidle--;     -- idle percent.
  --idle_clock  : integidle       
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
rx             : IN std_logic;
latency_total  : out integer;
total_time     : out integer
);
end component;

SIGNAL signal_clock, signal_reset	: std_logic;
SIGNAL signal_rxlocal					: regNrot;
signal signal_data_inlocal				: arrayNrot_regflit;
signal signal_txlocal					: regNrot;
signal signal_data_outlocal			: arrayNrot_regflit;
signal signal_ack_rxlocal				: regNrot;
signal signal_ack_txlocal				: regNrot;


begin
NoC2X2: NoC port map(
	clock				=> signal_clock,      
	reset				=> signal_reset,
	rxLocal			=> signal_rxlocal,       
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
												idle_percent => idle_percent
											--	idle_clock  => idle_clock
											) 
								port map		(
											clock 				=> signal_clock,
											reset					=> signal_reset,
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
								rx   					=> signal_txlocal(x+y*(MAX_X+1)),
							latency_total     => latency_total(x+y*(MAX_X+1)),
								total_time					=> total_time(x+y*(MAX_X+1))
											);
	
				end generate gen2;
end generate gen1;	 
							
													
signal_clock <= top_clock;
signal_reset <= reset;

end archi_top_noc;

