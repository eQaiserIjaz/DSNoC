----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:46:57 01/26/2010 
-- Design Name:  TAN Junyan, FRESSE Virginie, ROUSSEAU Frédéric.
-- Module Name:    traffic_generator - Behavioral 
-- Project Name:   HERMES NoC emulation Platform
-- Target Devices: Xilinx V5 ML506
-- Tool versions: Xilinx 10.1
-- Description:  This version provides the HERMES NoC emulation with load automatic. 
--
-- Dependencies: 
--
-- Revision: Multi-sources, Mono-destination Version 1
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
Library IEEE;
Use IEEE.std_logic_1164.all;
Use IEEE.std_logic_unsigned.all;
Use IEEE.std_logic_arith.all;
use work.HermesPackage.all;
use work.ParameterPackage.all;  

Entity traffic_generator IS
generic (  
  address: regmetadeflit;	-- address of destination
  IP_address_x: integer ;  -- address of iniator X axis
  IP_address_y: integer ;  -- address of iniator Y axis
  size_packet_int:INTEGER; --address and number of flits is included.
  nber_packet:INTEGER;		-- number of the packets.
  idle_percent: integidle     -- idle percent.
 
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
signal etat :integer :=0;  --count the number of cycles between 2 packets (measure of idle)
signal IP_address : regmetadeflit;
signal idle_time : integer;
signal idle_s : integidle;
--------------
signal idle_clock: integidle;

Begin
idle_clock <= idle_clk (size_packet_int);


  P: process (clock, reset)
    variable nber : integer :=0 ;  --count the nber of packets ("measure" of the nber of packets)
    VARIABLE state:INTEGER:=0; --use to send ths data in the table.
    VARIABLE sum:INTEGER:=0; --count the nber of cycles between 2 packets ("measure" of idle time)
	 VARIABLE S1,S2:integer:=0;  
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
     --- loop for data injection rate      
			  for j in 0 to 9 loop
			     if (idle_percent(j)=1) then 
				    if (j< S2) then
					 next;
					 end if;
				    if (nber< nber_packet ) then
				        
						  idle_time <= idle_clock(j) ;
					     
						  S2:=j;
					exit;
					
					elsif (S1= nb_data_injection_rate -1) then
					 exit;
					 end if;
					 
					routerrx<= '0';
				nber:=0;
				state:=0;
				S1:=S1+1;
					next;
              end if;
				 
				
				
           end loop;				 
			  
			  
			  
			  
			  
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
                  If (state=size_packet_int) then -- fin du paquet
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
        
          
        
        etat<=state;

          end if;
          
      end if;
  end process P;
         
  router_rx<=routerrx;
  
    

g1: for i in 0 to 9 generate
  g2 : if (idle_percent(i)=1) generate
    
 --donnes d'entre selon les routeurs
    data_enter<="00000000" & address WHEN etat=0 ELSE
                  CONV_STD_LOGIC_VECTOR(size_packet_int-3,TAM_FLIT) WHEN etat=1 ELSE
						"00000000" & IP_address WHEN etat=2 ELSE
                  "0000000000000000" WHEN etat=3 ELSE
                  "0000000000000000" WHEN etat=4 ELSE
                  "1111111111111110" WHEN etat=5 ELSE
                  "1111111111111100" WHEN etat=6 ELSE
                  "1111111111111000" WHEN etat=7 ELSE
                  "1111111111110000" WHEN etat=8 ELSE
						"1111111111100000" WHEN etat>8;

 end generate g2;
 end generate g1;


end archi_traffic_generator;


