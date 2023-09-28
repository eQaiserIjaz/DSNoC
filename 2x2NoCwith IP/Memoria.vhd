-----------------------------------------------------------------------------------
-- A memoria recebe pacotes da rede nos seguintes formato:
--
-- read  <target> <size> <source> <command - 00> <addH> <addL>
-- write <target> <size> <source> <command - 01> <addH> <addL> <dataH> <dataL>
--
-- A memoria envia pacote para rede no seguinte formato:
--
-- return read <target> <size> <source> <command - 09> <dataH> <dataL>
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.HermesPackage.all;

---- desabilitar para prototipar daqui ----
--library UNISIM;
--use UNISIM.vcomponents.all;
---- desabilitar até aqui para prototipar ---

-- Interface da Memoria
entity Memoria is
	port(
	clock:          in  std_logic;
	reset:          in  std_logic;
	address:        in  regflit;
	tx:             out std_logic;
	data_out:       out regflit;
	ack_tx:         in  std_logic;
	rx:             in  std_logic;
	data_in:        in  regflit;
	ack_rx:         out std_logic);
end Memoria;

-- implementação da Memoria
architecture Memoria of Memoria is

-- interface do bloco de RAM Virtex 800
--component RAMB4_S4
--port(
--	WE, EN, RST, CLK:	in std_logic;
--	ADDR:			in std_logic_vector(9 downto 0);
--	DI:			in std_logic_vector(3 downto 0);
--	DO:			out std_logic_vector(3 downto 0));
--end component;

-- interface do bloco de RAM Virtex II
component RAMB16_S9 
port (DI     : in STD_LOGIC_VECTOR (7 downto 0);
        DIP    : in STD_LOGIC_VECTOR (0 downto 0);
        EN     : in STD_ULOGIC;
        WE     : in STD_ULOGIC;
        SSR    : in STD_ULOGIC;
        CLK    : in STD_ULOGIC;
        ADDR   : in STD_LOGIC_VECTOR (10 downto 0);
        DO     : out STD_LOGIC_VECTOR (7 downto 0);
        DOP    : out STD_LOGIC_VECTOR (0 downto 0)); 
end component;

-- maquina de estados do acesso da memória
type state is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15);
signal ER: state;

-- sinais da interface com a rede
signal target,size,sizePayload,command,dataL: regflit;
signal add: std_logic_vector(15 downto 0);
signal busy: std_logic;

-- sinais da memoria
signal en,we: std_logic;
signal din,dout: std_logic_vector(15 downto 0);
-- Sinais da RAM Virtex 800
--signal addr: std_logic_vector(9 downto 0);
-- Sinais da RAM Virtex II
signal addr: std_logic_vector(10 downto 0);
signal paridade: std_logic_vector(0 downto 0);

begin

-------------------------------------------------------------------------------------------------------	
---- MEMORIA VIRTEX 800
-------------------------------------------------------------------------------------------------------	
--	--instanciando o bloco de RAM
--	RAM0: RAMB4_S4
--	port map(WE=>we, EN=>en, RST=>reset, CLK=>clock, ADDR=>addr, DI=>din(3 downto 0), DO=>dout(3 downto 0));
--	--instanciando o bloco de RAM
--	RAM1: RAMB4_S4
--	port map(WE=>we, EN=>en, RST=>reset, CLK=>clock, ADDR=>addr, DI=>din(7 downto 4), DO=>dout(7 downto 4));
--	--instanciando o bloco de RAM
--	RAM2: RAMB4_S4
--	port map(WE=>we, EN=>en, RST=>reset, CLK=>clock, ADDR=>addr, DI=>din(11 downto 8), DO=>dout(11 downto 8));
--	--instanciando o bloco de RAM
--	RAM3: RAMB4_S4
--	port map(WE=>we, EN=>en, RST=>reset, CLK=>clock, ADDR=>addr, DI=>din(15 downto 12), DO=>dout(15 downto 12));

-------------------------------------------------------------------------------------------------------	
---- MEMORIA VIRTEX II
-------------------------------------------------------------------------------------------------------	
--	paridade <= "1";
--
	--instanciando o bloco de RAM
	RAM0: RAMB16_S9
	port map(WE=>we, EN=>en, DIP=>paridade, SSR=>reset, CLK=>clock, ADDR=>addr, DI=>din(7 downto 0), DO=>dout(7 downto 0));
	--instanciando o bloco de RAM
	RAM1: RAMB16_S9
	port map(WE=>we, EN=>en, DIP=>paridade, SSR=>reset, CLK=>clock, ADDR=>addr, DI=>din(15 downto 8), DO=>dout(15 downto 8));
	
-------------------------------------------------------------------------------------------------------	
---- RECEIVE FROM NETWORK  - SEND TO NETWORK 
-------------------------------------------------------------------------------------------------------	
-- o sinal busyNoCMem deve ser testado pq este estará ativo qnd a memoria 
-- estiver respondendo a um pedido de leitura e uma recepção de dados pode
-- acarretar em perda de dados
	ack_rx <= rx when busy='0' else '0';

	process (reset,clock)
	begin
		if reset='1' then
				ER <= S0;
				tx <= '0';
				data_out <= (others=>'0');
				target <= (others=>'0');
				command <= (others=>'0');
				add <= (others=>'0');
				dataL <= (others=>'0');
				busy <= '0';
				-- sinais da memoria
				en <= '0';
				we <= '0';
				addr <= (others=>'0');
				din <= (others=>'0');
		elsif clock'event and clock='1' then
			case ER is
				when S0 =>
					tx <= '0';
					sizePayload <= (others=>'0');
					busy <= '0';
					-- sinais da memoria
					en <= '0';
					if rx='1' then 
						-- recebendo target
						ER <= S1;
					end if;
				when S1 =>
					if rx='1' then 
						-- recebendo size
						size <= data_in;
						ER <= S2;
					end if;
				when S2 =>
					if rx='1' then 
						-- recebendo source
						target <= data_in;
						sizePayload <= sizePayload + '1';
						ER <= S3;
					end if;
				when S3 =>
					if rx='1' then 
						-- recebendo command
						command <= data_in;
						sizePayload <= sizePayload + '1';
						ER <= S4;
					end if;
				when S4 =>
					if command/=x"0" and command/=x"1" and sizePayload=size then	
						ER <= S0;
					elsif command/=x"0" and command/=x"1" then	
						ER <= S9;
					elsif rx='1' then 
						-- recebendo parte alta do endereço
						-- VIRTEX I
						addr(9 downto 8) <= data_in(1 downto 0);
						-- VIRTEX II
						--addr(10 downto 8) <= data_in(2 downto 0);
						sizePayload <= sizePayload + '1';
						ER <= S5;
					end if;
				when S5 =>
					if rx='1' and command=x"0" then 
						-- recebendo parte baixa do endereço
						addr(7 downto 0) <= data_in;
						sizePayload <= sizePayload + '1';
						busy <= '1';
						ER <= S10;
					elsif rx='1' then 
						-- recebendo parte baixa do endereço
						addr(7 downto 0) <= data_in;
						sizePayload <= sizePayload + '1';
						ER <= S6;
					end if;
				when S6 =>
					if rx='1' then
						-- recebendo parte alta do dado
						din(15 downto 8) <= data_in;
						sizePayload <= sizePayload + '1';
						ER <= S7;
					end if;
				when S7 =>
					if rx='1' then 
						-- recebendo parte baixa do dado
						din(7 downto 0) <= data_in;
						sizePayload <= sizePayload + '1';
						-- sinais da memoria
						en <= '1';
						we <= '1';
						ER <= S8;
					end if;
				when S8 =>
					-- escrita na memoria
						en <= '0';
						we <= '0';
						ER <= S0;
				when S9 =>
					if sizePayload = size then
						ER <= S0;
					elsif rx='1' then 
						-- recebendo dado invalido
						sizePayload <= sizePayload + '1';
						ER <= S9;
					end if;
				when S10 =>
					en <= '1';
					we <= '0';
					-- enviando target
					tx <= '1';
					data_out <= target;
					if ack_tx = '1' then
						tx <= '0';
						ER <= S11;
					end if;
				when S11 =>
					-- enviando size
					tx <= '1';
					data_out <= x"04";
					if ack_tx = '1' then
						tx <= '0';
						ER <= S12;
					end if;
				when S12 =>
					-- enviando source
					tx <= '1';
					data_out <= address;
					if ack_tx = '1' then
						tx <= '0';
						ER <= S13;
					end if;
				when S13 =>
					-- enviando command
					tx <= '1';
					data_out <= x"09";
					if ack_tx = '1' then
						tx <= '0';
						ER <= S14;
					end if;
				when S14 =>
					-- enviando parte alta do dado de retorno de leitura
					tx <= '1';
					dataL <= dout(7 downto 0);
					data_out <= dout(15 downto 8);
					if ack_tx = '1' then
						tx <= '0';
						addr <= addr + '1';
						ER <= S15;
					end if;
				when S15 =>
					-- enviando parte baixa do dado de retorno de leitura
					tx <= '1';
					data_out <= dataL;
					if ack_tx = '1' then
						en <= '0';
						we <= '0';
						tx <= '0';
						busy <= '0';
						ER <= S0;
					end if;
			end case;
		end if;
	end process;
end Memoria;