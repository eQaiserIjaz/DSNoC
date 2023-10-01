----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:15:10 12/09/2009 
-- Design Name: 
-- Module Name:    traffic_receptor - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.std_logic_textio.all;
USE STD.TEXTIO.all;
use work.HermesPackage.all;
use work.ParameterPackage.all;


Entity traffic_receptor is
generic (  pkt_number: integer  -- number of packets received in this routor.
    );
port (
clock  		 : IN std_logic;
reset				 : IN std_logic;
data_in      	 : IN regflit;
ack_rx          : OUT std_logic;
rx              : IN std_logic
--latency_total   : out integer;   -- Total latency for all the data transmission.
--total_time      : out integer    -- Total time used for all the data transmission. 
);
END traffic_receptor;

Architecture archi_traffic_receptor OF traffic_receptor IS
BEGIN
p1:process(clock, reset)
variable mesure_time: integer:=0;
variable latency_int: integer:=0;
variable mesure_time_logic : std_logic_vector(TAM_FLIT*2-1  downto 0);
variable count_flit : integer:=0;
variable  nbre_flit : integer:=0;
variable nber_packet : integer:=0;
variable compteur: integer;
begin 
if reset='1' then
 compteur:=0; 
--latency_total<= 0;
	  --total_time<= 0 ; 
 else
    if clock='1' and clock'event  then 
	  compteur:= compteur + 1;
	  
      if rx ='1' then 
          
			    if count_flit=1 then
			      nbre_flit:= conv_integer(data_in);  -- receive the information for the number of the packets. 
			     end if;
				  -- receive the information for the latency
				  if count_flit=3 then
			      mesure_time_logic(TAM_FLIT-1 downto 0) := data_in;
					elsif count_flit=4 then
			      mesure_time_logic(TAM_FLIT*2-1 downto TAM_FLIT) := data_in;	
			     end if;
	-- count the flit received
			count_flit:= count_flit +1; 
			
			  if count_flit= nbre_flit+2 then
			     mesure_time := conv_integer(mesure_time_logic);
			     latency_int:=latency_int + (compteur- mesure_time); 
			 --latency_total <= latency_int;
			 count_flit:=0;
			nber_packet:=nber_packet+1;
			   if nber_packet = pkt_number then
				--- total_time<= compteur;
         	 end if;
          end if;
     end if;	
  end if;

  end if;     
end process p1;
ack_rx <= rx;
end archi_traffic_receptor;

