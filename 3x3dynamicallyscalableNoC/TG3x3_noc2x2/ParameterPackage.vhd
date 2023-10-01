--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--	  constants, and functions 
--   Version 1 for multisources to one destination with data injection rate automatic
--   TAN Junyan, FRESSE Virginie, ROUSSEAU Frédéric.
 

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use work.HermesPackage.all;
package ParameterPackage is
type integNORT is array(0 to (NROT-1)) of integer;
type integidle is array(0 to 9) of integer;
-- Generally, this configuration is used to the node(21) :
-- 10 packets of 8 flits from node(00) with the idletime 0(data injection rate of 100%)
-- node(21) receives 10 packets.
constant address_destination			:			regmetadeflit:= "00100001";        -- address of the destinationY=0010,X=0001 
constant size_of_packet					: 			integNORT := (6,0,0,0,0,0,0,0,0);  -- size of packet(number of flits)
constant	nbre_packet_send   			: 			integNORT := (4,0,0,0,0,0,0,0,0);   -- Number of packets sent
constant	idle_percent 					: 			integidle := (1,1,1,1,1,1,1,1,1,1);  -- idle percent(10%;20%;30%;40%;50%;60%;70%;80%;90%;100%)
function idle_clk		(nb: integer )	return  integidle;
constant	nbre_packet_received  		: 			integNORT := (0,0,0,0,0,4,0,0,0);   -- Number of packets received
constant nb_data_injection_rate     :      integer := 10;
 
--constant address_destination			:			regmetadeflit:= "00100001";        -- address of the destinationY=0010,X=0001 
--constant size_of_packet					: 			integNORT := (6,0,0,0,0,0,0,0,0);  -- size of packet(number of flits)
--constant	nbre_packet_send   			: 			integNORT := (4,0,0,0,0,0,0,0,0);   -- Number of packets sent
--constant	idle_percent 					: 			integidle := (1,0,0,1,1,0,1,1,1,1);  -- idle percent(10%;20%;30%;40%;50%;60%;70%;80%;90%;100%)
--function idle_clk		(nb: integer )	return  integidle;
--constant	nbre_packet_received  		: 			integNORT := (0,0,0,0,0,4,0,0,0);   -- Number of packets received
--constant nb_data_injection_rate     :      integer := 7; 
 
end ParameterPackage;

Package BODY ParameterPackage IS
FUNCTION idle_clk (nb: integer )	return  integidle is
variable clk : integidle;
begin
for i in 0 to 9 loop
 clk(i) :=  ((9-i)*2*nb -(9-i)*2*nb mod (i+1))/ (1+i);  --Calculate the idle clock according to the data injection rate 
end loop;
return clk;
end function;
end  Package BODY;