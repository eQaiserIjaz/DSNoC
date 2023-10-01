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
generic (  
  address: regmetadeflit;	-- address of initiator
  IP_address_x: integer ;  -- address of destination X axis
  IP_address_y: integer ;  -- address of destination Y axis
  size_packet_int:INTEGER; --address and number of flits is included.
  nber_packet:INTEGER;		-- number of the packets.
  idle_time:INTEGER       -- idle time.
)  ;
port ( 
clock, reset			: IN std_logic;  
router_rx				: OUT std_logic; -- signals face to the Local ports of the NoC
router_ack_rx			: IN std_logic;  -- signals face to the Local ports of the NoC
router_data_in			: OUT regflit    -- signals face to the Local ports of the NoC   
);
end traffic_generator;


Architecture archi_traffic_generator of traffic_generator IS
SIGNAL data_enter: regflit;
signal routerrx   : std_logic :='0';
signal stat :integer :=0;  --count the number of cycles between 2 packets (measure of idle)
signal IP_address : regmetadeflit;

Begin
  P: process (clock, reset)
    variable nber : integer :=0 ;  --count the nber of packets ("measure" of the nber of packets)
    VARIABLE state:INTEGER:=0; --use to send ths data in the table.
    VARIABLE sum:INTEGER:=0; --count the nber of cycles between 2 packets ("measure" of idle time)
    variable compteur, mesure_initial: integer:=0;
	 variable mesure_initial_logic: std_logic_vector( TAM_FLIT*2-1 downto 0);
	begin
	IP_address<=conv_std_logic_vector(IP_address_x,QUARTOFLIT)&conv_std_logic_vector(IP_address_y,QUARTOFLIT);
     if reset ='1' THEN
       routerrx <= '0';
       router_data_in <= (others=>'0');
       state:=0;
    else
      if clock='1' and clock'event then
					compteur:=compteur+1;
           if sum=0 or idle_time=0 then
              if (address /= IP_address and nber< nber_packet and routerrx ='0') then
                 if state =0 then
					      mesure_initial := compteur;
							mesure_initial_logic:= conv_std_logic_vector (mesure_initial,TAM_FLIT*2);
						 end if;
						 if state =3 then	
						     router_data_in <= mesure_initial_logic(TAM_FLIT-1 downto 0);
						  elsif state =4 then
							  router_data_in <= mesure_initial_logic(TAM_FLIT*2-1 downto TAM_FLIT);
							else
							router_data_in <= data_enter;
						end if;	
                     routerrx <='1'; 
                     state:=state+1;
                  If (state=size_packet_int) then -- packet finished
                    state := 0 ; 
                    nber := nber+1;
                     sum :=1;
                   end if;
                end if;
                if router_ack_rx='1' then
                  routerrx<='0';
                 end if;
            else
             sum:=sum+1;
            IF sum=idle_time+2 THEN
                sum:=0;
             END IF;
             IF router_ack_rx='1' THEN
                routerrx<='0';
              END IF;
            
          END IF;
        
          
        
        stat<=state;

          end if;
          
      end if;
  end process P;
         
  router_rx<=routerrx;
  
    


    
 --given by the routers
    data_enter<="00000000" & address WHEN stat=0 ELSE
                  CONV_STD_LOGIC_VECTOR(size_packet_int-2,TAM_FLIT) WHEN stat=1 ELSE
						"00000000" & IP_address WHEN stat=2 ELSE
                  "0000000000000000" WHEN stat=3 ELSE
                  "0000000000000000" WHEN stat=4 ELSE
                  "1111111111111110" WHEN stat=5 ELSE
                  "1111111111111100" WHEN stat=6 ELSE
                  "1111111111111000" WHEN stat=7 ELSE
                  "1111111111110000" WHEN stat=8 ELSE
						"1111111111100000" WHEN stat>8;




end archi_traffic_generator;


