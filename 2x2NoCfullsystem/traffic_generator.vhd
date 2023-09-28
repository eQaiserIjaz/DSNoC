----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:01:31 12/29/2009 
-- Design Name:     TAN JUNYAN
-- Module Name:    traffic_generator - Behavioral 
-- Project Name:   	NoC Hermes simulation
-- Target Devices:      XILINX V5 ML506
-- Tool versions:       Xilinx 10.1
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
Library IEEE;
Use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;
Use IEEE.std_logic_arith.all;
use work.HermesPackage.all;

Entity traffic_generator IS
generic ( address: regmetadeflit;  IP_address_x: integer ;  IP_address_y: integer ; 
  total_flit_in_packet:INTEGER;   nber_packet:INTEGER;  idle_paket:INTEGER ) ;
port ( 
clock, reset			: IN std_logic;  
router_rx				: OUT std_logic; -- signals face to the Local ports of the NoC
router_ack_rx			: IN std_logic;  -- signals face to the Local ports of the NoC
router_data_in			: OUT regflit    -- signals face to the Local ports of the NoC   
);
end traffic_generator;


Architecture traffic_generator of traffic_generator IS
SIGNAL data_enter: regflit;
signal routerrx   : std_logic :='0';
signal stat :integer :=0;  --count the number of cycles between 2 packets 
signal IP_address : regmetadeflit;

Begin
  P: process (clock, reset)
    variable packet_received : integer :=0 ;  --count the nber of packets ("measure" of the nber of packets)
    VARIABLE flit_state_pointer:INTEGER:=0; --use to send the data in the table.
    VARIABLE sum_of_idle_cycle:INTEGER:=0; --count the nber of cycles between 2 packets ("measure" of idle time)
    variable compteur, mesure_initial: integer:=0;
	variable mesure_initial_logic: std_logic_vector( TAM_FLIT*2-1 downto 0);
	
	begin
	-- convert into logic vector size of one flit by concatenating x and y
	IP_address<=conv_std_logic_vector(IP_address_x,QUARTOFLIT)&conv_std_logic_vector(IP_address_y,QUARTOFLIT);
     
	--if reset is active nothing is given to the router
	if reset ='1' THEN
       routerrx <= '0';
       router_data_in <= (others=>'0');
       flit_state_pointer:=0;
	   
	--else if reset is 0
    else
	  
	    -- clock is 1 and triggering
        if clock='1' and clock'event then
	  
					--compteur:=compteur+1;
					
            if sum_of_idle_cycle=0 or idle_paket=0 then
		      
			    -- if the source address is not equal with IP_address and received packet 
			    -- is less than expected packets and routerrx is 
                if (address /= IP_address and packet_received< nber_packet and routerrx ='0') then
			  
			             --if flit_state_pointer 0, assign 0 in a logic vector of size double flit
						 -- for first and second flit
                         -- if flit_state_pointer =0 then
					        -- mesure_initial := compteur;
							-- mesure_initial_logic:= conv_std_logic_vector (mesure_initial,TAM_FLIT*2);
						 -- end if;
						 
						 -- -- in third flit_state_pointer, router_data_in will be given the first flit in mesure_initial_logic
						 -- if flit_state_pointer =3 then	
						     -- router_data_in <= mesure_initial_logic(TAM_FLIT-1 downto 0);
						     
							 -- -- in fourth flit_state_pointer, router_data_in will be given the second flit in mesure_initial_logic
						     -- elsif flit_state_pointer =4 then
							     -- router_data_in <= mesure_initial_logic(TAM_FLIT*2-1 downto TAM_FLIT);
							     
								 -- -- starting from the 5th flit_state_pointer, router_data_in will be given flits from data_table						 
								 -- else
							     -- router_data_in <= data_enter;
						-- end if;	
						
						--receive data (flit) and update the ack signal
						router_data_in <= data_enter;
						routerrx <='1'; 
						
						--update the pointer of flit
						flit_state_pointer:=flit_state_pointer+1;
						
				     --if the flit pointer equates with total flit in packet, then  the packet is received.
					If (flit_state_pointer = total_flit_in_packet) then -- packet finished
						--reset the flit state pointer and add 1 to the received packets
						flit_state_pointer := 0 ; 
						packet_received := packet_received + 1;
						
						-- consider on idle cycle in this step
						sum_of_idle_cycle :=1;
                    end if;
					
                end if;
				
				-- if router ackdged, then reset the transmitter request routerrx
                if router_ack_rx='1' then
                  routerrx<='0';
                 end if;
			
			
            else
			    --increment idle cycle by 1
                sum_of_idle_cycle:=sum_of_idle_cycle+1;
			    
				--if sum of idle cycle equal to idle packet plus two, then reset it
				IF sum_of_idle_cycle = idle_paket+2 THEN
					sum_of_idle_cycle:=0;
				END IF;
				
				-- if router ackdged, then reset the transmitter request routerrx
				IF router_ack_rx='1' THEN
					routerrx<='0';
				END IF;
            
            END IF;
        
          
        
           stat<=flit_state_pointer;

        end if;
          
      
	end if;
  
     --process(clk, reset) again
	 
  end process P;
         
  router_rx<=routerrx;
  
    


    
 --data flit table. flit_1 source address, flit_2 number of flits of data, flit_3 destination IP_address
 -- from flit_4 until last, data flits
    data_enter<="00000000" & address WHEN stat=0 ELSE  
                  CONV_STD_LOGIC_VECTOR(total_flit_in_packet-2,TAM_FLIT) WHEN stat=1 ELSE
				  "00000000" & IP_address WHEN stat=2 ELSE
                  "0000000000000000" WHEN stat=3 ELSE
                  "0000000000000000" WHEN stat=4 ELSE
                  "1111111111111110" WHEN stat=5 ELSE
                  "1111111111111100" WHEN stat=6 ELSE
                  "1111111111111000" WHEN stat=7 ELSE
                  "1111111111110000" WHEN stat=8 ELSE
				  "1111111111100000" WHEN stat>9;




end traffic_generator;


