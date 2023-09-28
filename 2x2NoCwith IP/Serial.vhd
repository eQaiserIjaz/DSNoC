-----------------------------------------------------------------------------------
-- A serial recebe pacotes do software serial nos seguintes formato:
--
-- read   <command - 00> <target> <nword> <addH1> <addL1> ... <addHn> <addLn>
-- write  <command - 01> <target> <nword> <addH1> <addL1> <dataH1> <dataL1> ... <addHn> <addLn> <dataHn> <dataLn>
-- reset  <command - 02> <target>
-- return scanf  <command - 04> <target> <dataH> <dataL>
-----------------------------------------------------------------------------------
-- A serial envia pacotes para o software serial nos seguintes formato:
--
-- printf <source> <command - 03> <dataH> <dataL>
-- scanf  <source> <command - 04>
-- return read <dataH1> <dataL1> ... <dataHn> <dataLn>
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.HermesPackage.all;

-- interface do Serial
entity Serial is
port(
	clock:          in  std_logic;
	reset:          in  std_logic;
	state:          out reg8;  
---- habilitar os sinais txd e rxd  para prototipar ----
 	txd:            in  std_logic;
	rxd:            out std_logic;
---- desabilitar para prototipar daqui -----------------
--	rx_data:	   out std_logic_vector(7 downto 0);  
--	rx_start:	   out std_logic;                     
--	rx_busy:	   in  std_logic;                     	
--	tx_data:	   in  std_logic_vector(7 downto 0); 
--	tx_av:		   in  std_logic;                        	
---- desabilitar até aqui para prototipar --------------
---- Interface NoC -------------------------------------
	address:       in  regflit;
	tx:            out std_logic;
	data_out:      out regflit;
	ack_tx:        in  std_logic;
	rx:            in  std_logic;
	data_in:       in  regflit;
	ack_rx:        out std_logic);
end;

-- implementação do módulo serial
architecture Serial of Serial is    

type send_network is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15);
signal ES: send_network;

type receive_network is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16);
signal ER: receive_network;

---- habilitar para prototipar daqui ------
signal tx_av, rx_busy, rx_start: std_logic;
signal tx_data, rx_data: reg8;
---- habilitar até aqui para prototipar ---

-- serial interface
signal reset_n: std_logic;
signal busySerial: std_logic;
-- send network
signal command : regflit;
signal target: regflit;
signal nWord,counterWord: regflit;
signal add: std_logic_vector(15 downto 0);
signal dataH,dataL: regflit;
-- receive network
signal commandReceive : regflit;
signal sourceReceive : regflit;
signal nWordReceive,counterWordReceive : regflit;
signal data1,data2: regflit;
signal ntimes: reg8;

-- implementação da Serial
begin

	reset_n <= not reset;

---- habilitar para prototipar daqui ------
	SI : Entity work.SerialInterface(SerialInterface)
	port map(
		clock=> clock,
		reset=> reset_n,
		rx_data=> rx_data,
		rx_start=> rx_start,
		rx_busy=> rx_busy,
		rxd=> rxd,
		txd=> txd,
		tx_data=> tx_data,
		tx_av=> tx_av);
---- habilitar até aqui para prototipar ---
	
-------------------------------------------------------------------------------------------------------	
---- RECEIVE FROM SOFTWARE SERIAL  - SEND TO NETWORK 
-------------------------------------------------------------------------------------------------------	
	process (reset,clock)
	begin
		if reset='1' then
			tx <= '0';
			data_out <= (others => '0');
			command <= (others=>'0');
			target <= (others=>'0');
			nWord <= (others=>'0');
			counterWord <= (others=>'0');
			add <= (others=>'0');
			dataH <= (others=>'0');
			dataL <= (others=>'0');
			state <= x"00";					
			ES <= S0;
		elsif clock'event and clock='1' then
			case ES is
				when S0 =>
					state <= x"00";					
					tx <= '0';
					data_out <= (others => '0');
					command <= (others=>'0');
					target <= (others=>'0');
					nWord <= (others=>'0');
					counterWord <= (others=>'0');
					add <= (others=>'0');
					dataH <= (others=>'0');
					dataL <= (others=>'0');
	
					if tx_av='1' then
						command <= tx_data;
						ES <= S1;
					end if;
				when S1 =>
					state <= x"01";
					if (command/=x"00" and command/=x"01" and command/=x"02" and command/=x"04") then
						ES <= S0;
					elsif tx_av='1' and command=x"02" then -- ability
						-- captura o endereco do núcleo destino do pacote
						target <= tx_data;
						ES <= S7;
					elsif tx_av='1' and command=x"04" then -- return scanf
						-- captura o endereco do núcleo destino do pacote
						target <= tx_data;
						ES <= S5;
					elsif tx_av='1' then -- leitura ou escrita
						-- captura o endereco do núcleo destino do pacote
						target <= tx_data;
						ES <= S2;
					end if;
				when S2 =>
					state <= x"02";
					if tx_av='1' then
						-- captura numero de palavras a ser escrito ou lido
						nWord <= tx_data;
						ES <= S3;
					end if;
				when S3 =>
					state <= x"03";
					if tx_av='1' then
						-- captura a parte alta do endereço da palavra a ser escrita ou lida
						add(15 downto 8) <= tx_data;
						ES <= S4;
					end if;
				when S4 =>
					state <= x"04";
					if tx_av='1' and command=x"00" then --leitura
						-- captura a parte baixa do endereço da palavra a ser escrita ou lida
						add(7 downto 0) <= tx_data;
						ES <= S7;
					elsif tx_av='1' then
						-- captura a parte baixa do endereço da palavra a ser escrita ou lida
						add(7 downto 0) <= tx_data;
						ES <= S5;
					end if;
				when S5 =>
					state <= x"05";
					tx <= '0';
					if tx_av='1' then
						-- captura a parte alta do dado da palavra a ser escrita ou lida
						dataH <= tx_data;
						ES <= S6;
					end if;
				when S6 =>
					state <= x"06";
					if tx_av='1' then
						-- captura a parte baixa do dado da palavra a ser escrita ou lida
						dataL <= tx_data;
						ES <= S7;
					end if;
				when S7 =>
					state <= x"07";
					-- envia para rede o flit contendo o endereço do núcleo destino do pacote (target)
					tx <= '1';
					data_out <= target;
					if ack_tx='1' then
						tx <= '0';
						ES <= S8;
					end if;
				when S8 =>
					state <= x"08";
					tx <= '1';
					if command=x"00" then data_out <= x"04";    -- comando de leitura
					elsif command=x"01" then data_out <= x"06"; -- comando de escrita
					elsif command=x"02" then data_out <= x"02"; -- comando de habilitação do processador						
					elsif command=x"04" then data_out <= x"04"; -- comando scanf
					end if;
					if ack_tx='1' then 
						tx <= '0';
						ES <= S9;
					end if;
				when S9 => 
					state <= x"09";
					-- envia para rede o flit contendo o endereço do núcleo origem do pacote (source)
					tx <= '1';
					data_out <= address;
					if ack_tx='1' then
						tx <= '0';
						ES <= S10;
					end if;
				when S10 =>
					state <= x"10";
					-- envia para rede o flit contendo o comando do pacote
					tx <= '1';
					data_out <= command;
					if ack_tx='1' and command=x"02" then
						tx <= '0';
						ES <= S0;
					elsif ack_tx='1' and command=x"04" then
						tx <= '0';
						ES <= S14;
					elsif ack_tx='1' then
						tx <= '0';
						ES <= S12;
					end if;
				when S11 =>
					state <= x"11";
					-- envia para rede o flit contendo o número de palavras que serão lidas ou escritas
					tx <= '1';
					data_out <= nWord;
					if ack_tx='1' then
						tx <= '0';
						ES <= S12;
					end if;
				when S12 =>
					state <= x"12";
					-- envia para rede o flit contendo a parte alta do endereço
					tx <= '1';
					data_out <= add(15 downto 8);
					if ack_tx='1' then
						tx <= '0';
						counterWord <= counterWord + '1';
						ES <= S13;
					end if;
				when S13 =>
					state <= x"13";
					-- envia para rede o flit contendo a parte baixa do endereço
					tx <= '1';
					data_out <= add(7 downto 0) ;
					if ack_tx='1' and command=x"00" and counterWord=nWord then
						tx <= '0';
						ES <= S0;
					elsif ack_tx='1' and command=x"00" and counterWord/=nWord then
						tx <= '0';
						add <= add + '1';
						ES <= S7;
					elsif ack_tx='1' then
						tx <= '0';
						ES <= S14;
					end if;
				when S14 => 
					state <= x"14";
					-- envia para rede o flit contendo a parte alta da palavra
					tx <= '1';
					data_out <= dataH;
					if ack_tx='1' then
						tx <= '0';
						ES <= S15;
					end if;
				when S15 =>
					state <= x"15";
					-- envia para rede o flit contendo a parte baixa da palavra
					tx <= '1';
					data_out <= dataL;
					if ack_tx='1' and (command=x"04" or counterWord=nWord) then
						tx <= '0';
						ES <= S0;
					elsif ack_tx='1' and counterWord/=nWord then
						tx <= '0';
						add <= add + '1';
						ES <= S5;
					end if;
			end case;
		end if;
	end process;


-------------------------------------------------------------------------------------------------------	
---- RECEIVE FROM NETWORK  - SEND TO SOFTWARE SERIAL 
-------------------------------------------------------------------------------------------------------	
	ack_rx <= rx when busySerial='0' else '0';
			

	process (reset,clock)
	begin
		if reset='1' then
			busySerial<='0';
			rx_start <= '0';
			rx_data <= (others=>'0');
			ntimes <= (others=>'0');
			sourceReceive <= (others=>'0');
			commandReceive <= (others=>'0');
			nWordReceive <= (others=>'0');
			counterWordReceive <= (others=>'0');
			data1 <= (others=>'0');
			data2 <= (others=>'0');
			ER <= S0;
		elsif clock'event and clock='0' then
			case ER is
				when S0 =>
					busySerial<='0';
					rx_start <= '0';
					rx_data <= (others=>'0');
					ntimes <= (others=>'0');
					sourceReceive <= (others=>'0');
					commandReceive <= (others=>'0');
					nWordReceive <= (others=>'0');
					counterWordReceive <= (others=>'0');
					data1 <= (others=>'0');
					data2 <= (others=>'0');
					if rx='1' then 
					    -- recebendo target
						ER <= S1;
					end if;
				when S1 =>
					if rx='1' then 
					    -- recebendo size
						ER <= S2;
					end if;
				when S2 =>
					if rx='1' then 
					    -- recebendo source
						sourceReceive <= data_in;
						ER <= S3;
					end if;
				when S3 =>
					if rx='1' then 
					    -- recebendo comando
						commandReceive <= data_in;
						ER <= S4;
					end if;
				when S4 =>
				    -- confirmacao do recebimento do comando
					if commandReceive=x"04" then
						busySerial<='1';
						ER <= S7;
					elsif rx='1' then 
						-- recebendo data1
						data1 <= data_in;
						ER <= S6;
					end if;
				when S5 =>
					if rx='1' then 
						-- recebendo data1
						data1 <= data_in;
						ER <= S6;
					end if;
				when S6 =>
					if rx='1' and commandReceive=x"03" then 
						-- recebendo data2
						data2 <= data_in;
						busySerial<='1';
						ER <= S7;
					elsif rx='1' and commandReceive=x"09" then 
						-- recebendo data2
						data2 <= data_in;
						busySerial<='1';
						ER <= S13;
					end if;
				when S7 =>
					-- envio do 55
					rx_start <= '1';
					rx_data <= x"55";
					ntimes <= ntimes + '1';
					ER <= S8;
				when S8 =>
				    -- espera o envio do 55
					rx_start <= '0';
					if rx_busy='0' and ntimes < x"4" then
						ER<=S7;
					elsif rx_busy='0' then
						ER<=S9;
					end if;
				when S9 =>
				    -- envio do source
					rx_start <= '1';
					rx_data <= sourceReceive;
					ER <= S10;
				when S10 =>
				    -- espera o envio do source
					rx_start <= '0';
					if rx_busy='0' then
						ER<=S11;
					end if;
				when S11 =>
				    -- envio do comando
					rx_start <= '1';
					rx_data <= commandReceive;
					ER <= S12;
				when S12 =>
				    -- espera o envio do comando
					rx_start <= '0';
					if rx_busy='0' and commandReceive=x"04" then
						busySerial<='0';
						ER<=S0;
					elsif rx_busy='0' then
						ER<=S13;
					end if;
				when S13 =>
				    -- envio do data1
					rx_start <= '1';
					rx_data <= data1;
					counterWordReceive <= counterWordReceive + '1';
					ER <= S14;
				when S14 =>
				    -- espera o envio do data1
					rx_start <= '0';
					if rx_busy='0' then
						ER<=S15;
					end if;
				when S15 =>
				    -- envio do data2
					rx_start <= '1';
					rx_data <= data2;
					ER <= S16;
				when S16 =>
				    -- espera o envio do data2
					rx_start <= '0';
					if rx_busy='0' then
						busySerial<='0';
						ER<=S0;
					end if;
			end case;
		end if;
	end process;
end Serial;