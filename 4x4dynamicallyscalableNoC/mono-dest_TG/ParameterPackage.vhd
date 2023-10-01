--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--	  constants, and functions 
--   Version 1 for multisources to one destination
--   TAN Junyan, FRESSE Virginie, ROUSSEAU Frédéric.
 

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use work.HermesPackage.all;
package ParameterPackage is
type integNORT is array(0 to (NROT-1)) of integer;
-- Generally, this configuration is used to the node(22) :
-- 10 packets of 8 flits from node(00) with the idletime 0(data injection rate of 100%)
-- node(22) receives 10 packets.
constant address_destination			:			regmetadeflit:= "00100010";        -- address of the destinationY=0011,X=0011 
constant size_of_packet					: 			integNORT := (8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);  -- size of packet(number of flits)
constant	nbre_packet_send   			: 			integNORT := (4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);   -- Number of packets sent
constant	idle_time						: 			integNORT := (50,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);  -- idle time(on the cycles of clock) 
constant	nbre_packet_received  		: 			integNORT := (0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0);   -- Number of packets received
 -- Generally, this configuration is used to the node(22) :
-- 10 packets of 8 flits from node(00) with the idletime 0(data injection rate of 100%)
--  50 packets of 20 flits from node (01) with the idletime 93 (data injection rate of 30%)
-- node(22) receives 60 packets.
--constant address_destination			:			regmetadeflit:= "00100010";        -- address of the destinationY=0010,X=0001 
--constant size_of_packet					: 			integNORT := (8,0,0,20,0,0,0,0,0);  -- size of packet(number of flits)
--constant	nbre_packet_send   			: 			integNORT := (10,0,0,50,0,0,0,0,0);   -- Number of packets sent
--constant	idle_time						: 			integNORT := (0,0,0,93,0,0,0,0,0);  -- idle time(on the cycles of clock) 
--constant	nbre_packet_received  		: 			integNORT := (0,0,0,0,0,0,0,0,60);   -- Number of packets received
 
end ParameterPackage;
