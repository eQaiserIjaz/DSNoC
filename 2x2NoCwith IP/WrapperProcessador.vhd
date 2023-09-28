-----------------------------------------------------------------------------------
-- O processor receives network packets in the following format:
--
-- ability  <target> <size> <source> <command - 02>
-- return scanf <target> <size> <source> <command - 04> <dataH> <dataL>
-- return read <target> <size> <source> <command - 09> <dataH> <dataL>
-- notify  <target> <size> <source> <command - 08>
--
-- The local memory receives network packets in the following format:
--
-- read  <target> <size> <source> <command - 00> <addH> <addL>
-- write <target> <size> <source> <command - 01> <addH> <addL> <dataH> <dataL>
--
-- The processor sends packet to network in the following format:
--
-- read  <target> <size> <source> <command - 00> <addH> <addL>
-- write <target> <size> <source> <command - 01> <addH> <addL> <dataH> <dataL>
-- printf <target> <size> <source> <command - 03> <dataH> <dataL>
-- scanf  <target> <size> <source> <command - 04>
-- notify  <target> <size> <source> <command - 08>
--
-- The Local memory for packet network sends in the following format:
--
-- return read <target> <size> <source> <command - 09> <dataH> <dataL>
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.HermesPackage.all;
use work.R8Package.all;

-- interface do WrapperProcessador
entity WrapperProcessador is
	port(
	clock:          in  std_logic;
	reset:          in  std_logic;
	address:        in  reg8;
	rx:             in  std_logic;
	ack_rx:         out std_logic;
	data_in:        in  reg8;
	tx:             out std_logic;
	ack_tx:         in  std_logic;
	data_out:       out reg8);
end WrapperProcessador;

-- implementação do WrapperProcessador
architecture WrapperProcessador of WrapperProcessador is
		 
-- maquina de estados da recepção de dados da NoC
type stateReceive is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12);
signal ER: stateReceive;

-- maquina de estados do envio de dados para a NoC
type stateSend is (S0,S1,S2,S3,S4,S5,S6,S7,S9,S10,S11,S12,S13,S14,S15);
signal ES: stateSend;

-- NoC
signal size,sizePayload,source,command,nWord,counterWord: regflit;
signal doutNoC:	reg16;
signal txR8,ack_rxR8: std_logic;
signal data_outR8: regflit;
-- Processador
signal ce,rw,ack,waitR8,haltR8,busyNoCR8: std_logic;
signal abilityR8,returnRead,receiveNotify: std_logic;
signal target,targetSerial: regflit;
signal addrRemoto,addrR8,dinR8,doutR8:	reg16;
signal notify: std_logic_vector((NROT-1) downto 0);
-- memoria
signal ceR8,rwR8,busyNoCMem: std_logic;
signal txMem, ack_rxMem: std_logic;
signal data_outMem: regflit;
signal doutMem: reg16;

begin
	targetSerial <= ADDRESSN00;
-------------------------------------------------------------------------------------------------------	
---- SIGNALS NETWORK
-------------------------------------------------------------------------------------------------------	
	ack_rx <= ack_rxR8 or ack_rxMem;
	tx <= txMem when busyNoCMem='1' else txR8;
	data_out <= data_outMem when busyNoCMem='1' else data_outR8;
	
	PROC : entity work.Processador(Processador)
	port map(
		ck => clock,
		rst => reset,
		dataIN => doutR8,
		dataOUT => dinR8,
		address => addrR8,
		ce => ce,
		rw => rw,
		waitR8 => waitR8,
		haltR8 => haltR8);

	CACHE : entity work.MemoriaLocal(MemoriaLocal)
	port map(
		clock => clock,
		reset => reset,
		address => address,
		-- Interface com o processador
		ceR8 => ceR8,
		rwR8 => rwR8,
		addrR8 => addrR8,
		dinR8 => dinR8,
		doutR8 => doutMem,
		busyNoCR8 => busyNoCR8,
		busyNoCMem => busyNoCMem,
		-- Interface com a NoC
		tx => txMem,
		data_out => data_outMem,
		ack_tx => ack_tx,
		rx => rx,
		data_in => data_in,
		ack_rx => ack_rxMem);

-------------------------------------------------------------------------------------------------------	
---- RECEIVE FROM NETWORK
-------------------------------------------------------------------------------------------------------	
-- o estado S12 deve ser testado pq este estado estará ativo qnd a memoria 
-- estiver respondendo a um pedido de leitura e uma recepção de dados destinados
-- a memoria pode acarretar em perda de dados
	ack_rxR8 <= rx when busyNoCMem='0' and ER/=S12 else '0'; 

	process (reset,clock)
	begin
		if reset='1' then
				ER <= S0;
				size <= (others=>'0');
				sizePayload <= (others=>'0');
				source <= (others=>'0');
				command <= (others=>'0');
				nWord <= (others=>'0');
				counterWord <= (others=>'0');
				doutNoC <= (others=>'0');
				abilityR8 <= '0';
				returnRead <= '0';
				receiveNotify <= '0';
	elsif clock'event and clock='1' then
			case ER is
				when S0 =>
					size <= (others=>'0');
					sizePayload <= (others=>'0');
					source <= (others=>'0');
					command <= (others=>'0');
					nWord <= (others=>'0');
					counterWord <= (others=>'0');
					doutNoC <= (others=>'0');
					abilityR8 <= '0';
					returnRead <= '0';
					receiveNotify <= '0';
					if rx='1' and busyNoCMem='0' then 
						ER <= S1;
					elsif busyNoCMem='1' then
						ER <= S12;
					end if;
				when S1 =>
					if rx='1' then 
						size <= data_in;
						ER <= S2;
					end if;
				when S2 =>
					if rx='1' then 
						source <= data_in;
						sizePayload <= sizePayload + '1';
						ER <= S3;
					end if;
				when S3 =>
					if rx='1' then 
						command <= data_in;
						sizePayload <= sizePayload + '1';
						if data_in=x"2" then
							ER <= S9;
						elsif data_in=x"8" then	
							ER <= S11;
						elsif data_in=x"4" or data_in=x"9" then	
							ER <= S6;
						else
							ER <= S5;
						end if;
					end if;
				when S4 =>
					if rx='1' then 
						nWord <= data_in;
						sizePayload <= sizePayload + '1';
						ER <= S6;
					end if;
				when S5 => 
					if sizePayload=size then	
						ER <= S0;
					elsif rx='1' then 
						sizePayload <= sizePayload + '1';
						ER <= S5;
					end if;						
				when S6 =>
					if rx='1' then
						doutNoC(15 downto 8) <= data_in;
						counterWord <= counterWord + '1';
						ER <= S7;
					end if;
				when S7 =>
					if rx='1' then 
						doutNoC(7 downto 0) <= data_in;
						ER <= S8;
					end if;
				when S8 =>
					returnRead <= '1';
					if command=x"4" then
						ER <= S10;
					else
						ER <= S0;
					end if;
				when S9 => -- habilita processador
					abilityR8 <= '1';
					ER <= S0;
				when S10 => -- retorno scanf
					ER <= S0;
				when S11 => -- notify
					receiveNotify <= '1';
					ER <= S0;
				when S12 => -- read
					if busyNoCMem ='0' then
						ER <= S0;
					end if;
			end case;
		end if;
	end process;

-------------------------------------------------------------------------------------------------------	
---- SEND TO NETWORK
-------------------------------------------------------------------------------------------------------	
	process (reset,clock)
	begin
		if reset='1' then
			txR8 <= '0';					
			busyNoCR8 <= '0';
			data_outR8 <= (others=>'0');					
			ES <= S0;
		elsif clock'event and clock='1' then
			case ES is
				-- habilitacao do processador
				when S0 =>
					txR8 <= '0';					
					busyNoCR8 <= '0';
					if abilityR8='1' then
						ES <= S1;
					end if;
				when S1 => ES <= S2;
				-- processando
				when S2 => 
					if haltR8='1' then ES <= S13;
					elsif ce = '1' and addrR8 = x"FFFF" and busyNoCMem='0' then ES <= S4; -- printf e scanf
					elsif ce = '1' and addrR8 = x"FFFF" then ES <= S3; -- printf e scanf
					elsif ce = '1' and addrR8 = x"FFFE" then ES <= S15; -- wait
					elsif ce = '1' and addrR8 = x"FFFD" and busyNoCMem='0' then ES <= S4; -- notify
					elsif ce = '1' and addrR8 = x"FFFD" then ES <= S3; -- notify
					elsif ce = '1' and addrR8 > x"03FF" and busyNoCMem='0' then ES <= S4; -- leitura ou escrita remota
					elsif ce = '1' and addrR8 > x"03FF" then ES <= S3; -- leitura ou escrita remota
					end if;
				when S3 =>
					if busyNoCMem = '0' then 
						ES <= S4;
					end if;
				when S4 =>
					busyNoCR8 <= '1';
					--envia target
					txR8 <= '1';
					if addrR8=x"FFFD" then
						data_outR8 <= dinR8(7 downto 0); -- notify
					elsif addrR8=x"FFFF" then
						data_outR8 <= targetSerial; -- printf ou scanf
					else						
						data_outR8 <= target;
					end if;

					if ack_tx = '1' then
						txR8 <= '0';
						ES <= S5;
					end if;
				when S5 =>
					-- envia nword
					txR8 <= '1';
					if addrR8=x"FFFF" and rw = '0' then
						data_outR8 <= x"04"; -- printf
					elsif addrR8=x"FFFF" and rw = '1' then
						data_outR8 <= x"02"; -- scanf
					elsif addrR8=x"FFFD" then
						data_outR8 <= x"02"; -- notify
					elsif rw = '0' then
						data_outR8 <= x"06"; -- escrita remota
					else
						data_outR8 <= x"04"; -- leitura remota
					end if;
					if ack_tx = '1' then
						txR8 <= '0';
						ES <= S6;
					end if;
				when S6 =>
					-- envia endereço do núcleo origem
					txR8 <= '1';
					data_outR8 <= address;
					if ack_tx = '1' then
						txR8 <= '0';
						ES <= S7;
					end if;
				when S7 =>
					-- envia comando
					txR8 <= '1';
					if addrR8=x"FFFF" and rw = '0' then
						data_outR8 <= x"03"; -- printf
					elsif addrR8=x"FFFF" and rw = '1' then
						data_outR8 <= x"04"; -- scanf
					elsif addrR8=x"FFFD" then
						data_outR8 <= x"08"; -- notify
					elsif rw = '0' then
						data_outR8 <= x"01"; -- escrita remota
					else
						data_outR8 <= x"00"; -- leitura remota
					end if;
					if ack_tx = '1' and addrR8=x"FFFF" and rw = '0' then -- printf
						txR8 <= '0';
						ES <= S11;
					elsif ack_tx = '1' and addrR8=x"FFFF" and rw = '1' then -- scanf
						txR8 <= '0';
						ES <= S14;
					elsif ack_tx = '1' and addrR8=x"FFFD" then -- notify
						txR8 <= '0';
						ES <= S1;
					elsif ack_tx = '1' then -- leitura e escrita remota
						txR8 <= '0';
						ES <= S9;
					end if;
				when S9 =>
					-- envia endereço parte alta
					txR8 <= '1';
					data_outR8 <= addrRemoto(15 downto 8);
					if ack_tx = '1' then
						txR8 <= '0';
						ES <= S10;
					end if;
				when S10 =>
					-- envia endereço parte baixa
					txR8 <= '1';
					data_outR8 <= addrRemoto(7 downto 0);
					if ack_tx = '1' and rw='1' then -- leitura remota
						txR8 <= '0';
						ES <= S14;
					elsif ack_tx = '1' then -- escrita remota
						txR8 <= '0';
						ES <= S11;
					end if;
				when S11 =>
					-- envia dado parte alta
					txR8 <= '1';
					data_outR8 <= dinR8(15 downto 8);
					if ack_tx = '1' then
						txR8 <= '0';
						ES <= S12;
					end if;
				when S12 =>
					-- envia dado parte baixa
					txR8 <= '1';
					data_outR8 <= dinR8(7 downto 0);
					if ack_tx = '1' then
						txR8 <= '0';
						ES <= S1;
					end if;
				when S13 =>
					ES <= S0;
				when S14 =>
					busyNoCR8 <= '0';
					if returnRead='1' then
						ES <= S1;
					end if;
				when S15 =>
					if notify(CONV_INDEXNOTIFY(dinR8(7 downto 0)))='1' then
						ES <= S1;
					end if;
			end case;
		end if;
	end process;

-------------------------------------------------------------------------------------------------------	
---- SIGNALS PROCESSOR
-------------------------------------------------------------------------------------------------------	
	doutR8 <= doutNoC when ER=S10 or ER=S8 else -- S10 retorno do scanf ou S8 retorno de leitura a memoria distribuida
		      doutMem;	

	target <= ADDRESSN01 when addrR8 > x"03FF" and addrR8 < x"0800" else
			ADDRESSN10 when addrR8 > x"07FF" and addrR8 < x"0C00" else
			ADDRESSN11 when addrR8 > x"0BFF" and addrR8 < x"1000" else
			ADDRESSN00;

	addrRemoto <= addrR8 - x"0400" when addrR8 > x"03FF" and addrR8 < x"0800" else
				  addrR8 - x"0800" when addrR8 > x"07FF" and addrR8 < x"0C00" else
				  addrR8 - x"0C00" when addrR8 > x"0BFF" and addrR8 < x"1000" else
				  (others=>'0');
			   
-------------------------------------------------------------------------------------------------------	
---- LOCAL MEMORY
-------------------------------------------------------------------------------------------------------	
	ceR8 <= '1' when ce='1' and addrR8(15 downto 10)="000000" else '0';
	rwR8 <= not rw;
				
-------------------------------------------------------------------------------------------------------	
---- ACK
-------------------------------------------------------------------------------------------------------	
	process(clock,reset)
	begin
		if reset='1' then ack <='0';
		elsif clock'event and clock='0' then
			if ceR8='1' then ack <='1'; else ack<='0'; end if;
		end if;
	end process;

-------------------------------------------------------------------------------------------------------	
---- WAIT
-------------------------------------------------------------------------------------------------------	
	process(reset,clock)
	begin
		if reset='1' then
			waitR8 <='1';
		elsif clock'event and clock='0' then
			if (ce ='1' and waitR8='0') or ES = S3 or ES = S13 then -- S3 acesso a memoria local ou remota e S13 halt
				waitR8<= '1';
			elsif ack='1' or ES=S1 or ER=S8 then --S8 retorno da leitura 
				waitR8<= '0';
			end if;
		end if;
	end process;
		  
-------------------------------------------------------------------------------------------------------	
---- NOTIFY
-------------------------------------------------------------------------------------------------------	
	process (reset,clock)
	begin
		if reset='1' then
			notify <= (others=> '0');
		elsif clock'event and clock='1' then
			if receiveNotify='1' then
				notify(CONV_INDEXNOTIFY(source)) <= '1';
			elsif ES=S15 then
				notify(CONV_INDEXNOTIFY(dinR8(7 downto 0))) <= '0';
			end if;
		end if;
	end process; 
		  
end WrapperProcessador;