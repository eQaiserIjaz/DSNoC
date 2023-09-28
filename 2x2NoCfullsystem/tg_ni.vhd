--Traffic Generator NI

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all ;
use work.HermesPackage.all;
use work.ParameterPackage.all;

library top_level_peripheral_v1_00_a;



entity tg_ni is
	port(tg_clock       	    :  in std_logic;
		 tg_reset        	    :  in std_logic;

		 --tg_select          :  in Std_Logic_Vector((NROT-1) downto 1);
		 --receive
		 rx_2_tg_ni     	:  in regNrot;
		 ack_rx_2_router	:  out regNrot;
		 data_2_tg_ni   	:  in arrayNrot_regflit;
		 --send
		 tx_2_router       	:  out regNrot;
		 ack_tx_2_tg_ni     :  in regNrot;
		 data_2_router     	:  out arrayNrot_regflit;
		 
		 mux_latency        :  out integNORT;
		 mux_time           :  out integNORT
		 );	 
		 
end tg_ni;



architecture arch_tg_ni of tg_ni is

--   component traffic_generator is
--	 generic ( address: regmetadeflit;  IP_address_x: integer ;  IP_address_y: integer ; 
--   size_packet_int:INTEGER;   nber_packet:INTEGER;  idle_percent:INTEGER ) ;
--	 port(clock       	:  in std_logic;
--		 reset        	:  in std_logic;
--		 router_rx      :  out std_logic;
--		 router_ack_rx	:  in  std_logic;
--		 router_data_in    :  out regflit);
--   end component;

  -- component traffic_recepter is
	-- generic(pkt_number: integer);
    -- port(clock       	:  in std_logic;
		-- reset        	:  in std_logic;
		-- rx    	:  in std_logic;
		-- ack_rx   :  out std_logic;
		-- data_in      :  in regflit		
		-- );
  -- end component;
    signal clk_signal: std_logic;
	signal reset_signal: std_logic;
	signal rxRX0100, rxRX0001, rxRX0101: std_logic;
	signal txTX0100, txTX0001, txTX0101: std_logic;
	
	signal data_inRX0100, data_inRX0001,data_inRX0101:regflit;
	signal data_outTX0100, data_outTX0001,data_outTX0101:regflit;
	
	signal ack_txRX0100, ack_txRX0001, ack_txRX0101: std_logic;
	signal ack_rxTX0100, ack_rxTX0001, ack_rxTX0101: std_logic;
	
	signal total_latency_signal: integer;
   signal total_time_signal: integer;

 
begin


  TX0100: Entity work.traffic_generator(traffic_generator)
	generic map( address =>ADDRESSN0100,IP_address_x=> 1, IP_address_y=> 0, total_flit_in_packet => 6 , nber_packet	=> 4 , idle_paket => 1)
	port map(clock      => clk_signal,
		reset       => reset_signal,
		router_rx   => txTX0100,
		router_ack_rx=> ack_txRX0100,
		router_data_in => data_outTX0100);
  

  RX0100: Entity work.traffic_receptor(traffic_receptor)
	generic map(pkt_number=> 4)
    port map(clock => clk_signal,
		reset        => reset_signal,
		rx     => rxRX0100,
		ack_rx=> ack_rxTX0100,
		data_in   => data_inRX0100,
		latency_total=> mux_latency(1),
      total_time => mux_time(1)
		);
		
  TX0001: Entity work.traffic_generator(traffic_generator)
	generic map( address =>ADDRESSN0100,IP_address_x=> 0, IP_address_y=> 1, total_flit_in_packet => 6 , nber_packet	=> 4 , idle_paket => 1)
	port map(clock      => clk_signal,
		reset       => reset_signal,
		router_rx   => txTX0001,
		router_ack_rx=> ack_txRX0001,
		router_data_in => data_outTX0001);
  

  RX0001: Entity work.traffic_receptor(traffic_receptor)
	generic map(pkt_number=> 4)
    port map(clock       => clk_signal,
		    reset        => reset_signal,
			 data_in   => data_inRX0001,
			 	ack_rx=> ack_rxTX0001,
				rx     => rxRX0001,		
			latency_total=> mux_latency(2),
        total_time => mux_time(2));
		
	TX0101: Entity work.traffic_generator(traffic_generator)
	generic map( address =>ADDRESSN0100,IP_address_x=> 1, IP_address_y=> 1, total_flit_in_packet => 6 , nber_packet	=> 4 , idle_paket => 1)
	port map(clock      => clk_signal,
		reset       => reset_signal,
		router_rx   => txTX0101,
		router_ack_rx=> ack_txRX0101,
		router_data_in => data_outTX0101);
  

  RX0101: Entity work.traffic_receptor(traffic_receptor)
	generic map(pkt_number=> 4)
    port map(clock       => clk_signal,
				reset        => reset_signal,
						rx     => rxRX0101,
						ack_rx => ack_rxTX0101,
					data_in   => data_inRX0101,
				 latency_total=> mux_latency(3),
					total_time => mux_time(3));
  
  
clk_signal<= tg_clock;
reset_signal<= tg_reset;

tx_2_router(0)<='0';
data_2_router(0)<=(others=>'0');
ack_rx_2_router(0)<='0';

tx_2_router(1)<=txTX0100;
ack_txRX0100 <=ack_tx_2_tg_ni(1);
data_2_router(1)<=data_outTX0100;
rxRX0100 <= rx_2_tg_ni(1);
ack_rx_2_router(1)<=ack_rxTX0100;
data_inRX0100<=data_2_tg_ni(1);

tx_2_router(2)<=txTX0001;
ack_txRX0001 <=ack_tx_2_tg_ni(2);
data_2_router(2)<=data_outTX0001;
rxRX0001 <= rx_2_tg_ni(2);
ack_rx_2_router(2)<=ack_rxTX0001;
data_inRX0001<=data_2_tg_ni(2);

tx_2_router(3)<=txTX0101;
ack_txRX0101 <=ack_tx_2_tg_ni(3);
data_2_router(3)<=data_outTX0101;
rxRX0101 <= rx_2_tg_ni(3);
ack_rx_2_router(3)<=ack_rxTX0101;
data_inRX0101<=data_2_tg_ni(3);

--mux_latency <=total_latency_signal;
--mux_time <=total_time_signal;



-- rx_2_tg_ni_signal<= rx_2_tg_ni;
-- data_2_tg_ni_signal<= data_2_tg_ni;
-- ack_tx_2_tg_ni_signal<=ack_tx_2_tg_ni;

-- outdata_2_router_signal<= data_2_router_signal;
-- outtx_2_router_signal<= tx_2_router_signal;
-- outack_rx_2_router_signal<= ack_rx_2_router_signal;
-- data_2_router<=outdata_2_router_signal;
-- tx_2_router<=outtx_2_router_signal;
-- ack_rx_2_router<=outack_rx_2_router_signal;
  
-- --Connection the TG and TR to each switch on the Y direction
-- gen1: for y in 0 to  MAX_Y   generate
		-- -- Connection the TG and TR to each switch on the X direction
			-- gen2 : for x in 0 to MAX_X generate

				-- --Router_00 is connected to microblaze. so x=0 and y=0 are excluded
				-- TG_Local: if((x+y)> 0) generate

						-- TXs: traffic_generator generic map( address	=>conv_std_logic_vector((MAX_Y-y),QUARTOFLIT)&conv_std_logic_vector((MAX_X-x),QUARTOFLIT),		
												-- IP_address_x=> x,
												-- IP_address_y=> y,	
												-- size_packet_int => 6 ,	
												-- nber_packet	=> 4 ,		
												-- idle_percent => 1)
											 
											-- port map(clock      => clk_signal,
													-- reset       => reset_signal,
													-- router_rx   =>tx_2_router_signal(x+y*(MAX_X+1)),
													-- router_ack_rx=>ack_tx_2_tg_ni_signal(x+y*(MAX_X+1)),
													-- router_data_in =>data_2_router_signal(x+y*(MAX_X+1)));  

						-- RXs:traffic_recepter generic map(pkt_number=>4)
											-- port map(clock       => clk_signal,
													-- reset        => reset_signal,
													-- rx     => rx_2_tg_ni_signal(x+y*(MAX_X+1)),
													-- ack_rx=> ack_rx_2_router_signal(x+y*(MAX_X+1)),
													-- data_in   => data_2_tg_ni_signal(x+y*(MAX_X+1))
													-- );  
					-- end generate TG_Local;
			-- end generate gen2;
-- end generate gen1;

-- clk_signal<= tg_clock;
-- reset_signal <= tg_reset;

-- rx_2_tg_ni_signal<= rx_2_tg_ni;
-- data_2_tg_ni_signal<= data_2_tg_ni;
-- ack_tx_2_tg_ni_signal<=ack_tx_2_tg_ni;

-- outdata_2_router_signal<= data_2_router_signal;
-- outtx_2_router_signal<= tx_2_router_signal;
-- outack_rx_2_router_signal<= ack_rx_2_router_signal;
-- data_2_router<=outdata_2_router_signal;
-- tx_2_router<=outtx_2_router_signal;
-- ack_rx_2_router<=outack_rx_2_router_signal;
 
end arch_tg_ni;





