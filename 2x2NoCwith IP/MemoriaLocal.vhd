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
use work.R8Package.all;

---- desabilitar para prototipar daqui ----
--library UNISIM;
--use UNISIM.vcomponents.all;
---- desabilitar até aqui para prototipar ---

-- Interface da Memoria Local
entity MemoriaLocal is
	port(
	clock:          in  std_logic;
	reset:          in  std_logic;
	address:        in  regflit;
	-- Interface com o processador
	ceR8:           in  std_logic;
	rwR8:           in  std_logic;
	addrR8:         in  reg16;
	dinR8:          in  reg16;
	doutR8:         out reg16;
	busyNoCR8:      in  std_logic;
	busyNoCMem:     out std_logic;
	-- Interface com a NoC
	tx:             out std_logic;
	data_out:       out regflit;
	ack_tx:         in  std_logic;
	rx:             in  std_logic;
	data_in:        in  regflit;
	ack_rx:         out std_logic);
end MemoriaLocal;

-- implementação da Memoria Local
architecture MemoriaLocal of MemoriaLocal is

-- interface do bloco de RAM Virtex 800
--component RAMB4_S4
--port(
--	WE, EN, RST, CLK:	in std_logic;
--	ADDR:			in std_logic_vector(9 downto 0);
--	DI:			in std_logic_vector(3 downto 0);
--	DO:			out std_logic_vector(3 downto 0));
--end component;

---- interface do bloco de RAM Virtex II
--component RAMB16_S9 
--port (DI     : in STD_LOGIC_VECTOR (7 downto 0);
--        DIP    : in STD_LOGIC_VECTOR (0 downto 0);
--        EN     : in STD_ULOGIC;
--        WE     : in STD_ULOGIC;
--        SSR    : in STD_ULOGIC;
--        CLK    : in STD_ULOGIC;
--        ADDR   : in STD_LOGIC_VECTOR (10 downto 0);
--        DO     : out STD_LOGIC_VECTOR (7 downto 0);
--        DOP    : out STD_LOGIC_VECTOR (0 downto 0)); 
--end component;

-- interface do bloco de RAM Virtex VI
component RAM32X1S
generic(
INIT : std_logic_vector(31 downto 0)
port (  O      : out std_logic_vector(31 downto 0);
        A0     : in STD_ULOGIC;
		  A1     : in STD_ULOGIC;
		  A2     : in STD_ULOGIC;
		  A3     : in STD_ULOGIC;
		  A4     : in STD_ULOGIC;
		  D      : in std_logic_vector(31 downto 0);
		  WCLK   : in STD_ULOGIC;
        WE     : in STD_ULOGIC); 
end component;

-- maquina de estados do acesso da memória
type state is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17);
signal ER: state;

-- sinais da interface com a rede
signal size,sizePayload,target,command,dataH,dataL: regflit;
signal weNoC,busy: std_logic;
signal addrNoC,dinNoC: reg16;

-- sinais da memoria
signal Nclock: std_logic;
signal accessMem: std_logic_vector(1 downto 0);
signal en,we: std_logic;
signal din,dout: std_logic_vector(31 downto 0);
-- Sinais da RAM Virtex 800
signal addr: std_logic_vector(9 downto 0);
-- Sinais da RAM Virtex II
--signal addr: std_logic_vector(10 downto 0);
--signal paridade: std_logic_vector(0 downto 0);

begin

	Nclock <= not clock;
	
-------------------------------------------------------------------------------------------------------	
---- MEMORIA VIRTEX 800
-------------------------------------------------------------------------------------------------------	
	--instanciando o bloco de RAM
	RAM0: RAM32X1S generic map ( INIT => X"00000000")
     port map(WE=>we, WCLK=>Nclock, D=>din, A4=>'1', A3=>'1', A2=>'1', A1=>'1', A0=>'1', O=>dout);
	--instanciando o bloco de RAM
	RAM1: RAM32X1S generic map ( INIT => X"00000000")
     port map(WE=>we, WCLK=>Nclock, D=>din, A4=>'1', A3=>'1', A2=>'1', A1=>'1', A0=>'1', O=>dout);
	--instanciando o bloco de RAM
	RAM2: RAM32X1S generic map ( INIT => X"00000000")
     port map(WE=>we, WCLK=>Nclock, D=>din, A4=>'1', A3=>'1', A2=>'1', A1=>'1', A0=>'1', O=>dout);
	--instanciando o bloco de RAM
	RAM3: RAM32X1S generic map ( INIT => X"00000000")
     port map(WE=>we, WCLK=>Nclock, D=>din, A4=>'1', A3=>'1', A2=>'1', A1=>'1', A0=>'1', O=>dout);
	 
	 port map(WE=>we, EN=>en, RST=>reset, CLK=>Nclock, ADDR=>addr, DI=>din(15 downto 12), DO=>dout(15 downto 12));

-------------------------------------------------------------------------------------------------------	
---- MEMORIA VIRTEX II
-------------------------------------------------------------------------------------------------------	
--	paridade <= "1";
--
--	--instanciando o bloco de RAM
--	RAM0: RAMB16_S9
--	port map(WE=>we, EN=>en, DIP=>paridade, SSR=>reset, CLK=>Nclock, ADDR=>addr, DI=>din(7 downto 0), DO=>dout(7 downto 0));
--	--instanciando o bloco de RAM
--	RAM1: RAMB16_S9
--	port map(WE=>we, EN=>en, DIP=>paridade, SSR=>reset, CLK=>Nclock, ADDR=>addr, DI=>din(15 downto 8), DO=>dout(15 downto 8));
	
-------------------------------------------------------------------------------------------------------	
---- RECEIVE FROM NETWORK  - SEND TO NETWORK 
-------------------------------------------------------------------------------------------------------	
	busyNoCMem <= busy;

-- o sinal busyNoCMem deve ser testado pq este estará ativo qnd a memoria 
-- estiver respondendo a um pedido de leitura e uma recepção de dados pode
-- acarretar em perda de dados
	ack_rx <= rx when busy='0' and ER/=S17 else '0'; 

	process (reset,clock)
	begin
		if reset='1' then
				ER <= S0;
				tx <= '0';
				data_out <= (others=>'0');
				target <= (others=>'0');
				size <= (others=>'0');
				sizePayload <= (others=>'0');
				command <= (others=>'0');
				dataH <= (others=>'0');
				dataL <= (others=>'0');
				-- sinais da memoria
				weNoC <= '0';
				addrNoC <= (others=>'0');
				dinNoC <= (others=>'0');
				busy <= '0';
		elsif clock'event and clock='1' then
			case ER is
				when S0 =>
					tx <= '0';
					sizePayload <= (others=>'0');
					-- sinais da memoria
					weNoC <= '0';
					busy <= '0';
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
						addrNoC(15 downto 8) <= data_in;
						sizePayload <= sizePayload + '1';
						ER <= S5;
					end if;
				when S5 =>
					if rx='1' then 
						-- recebendo parte baixa do endereço
						addrNoC(7 downto 0) <= data_in;
						sizePayload <= sizePayload + '1';
						ER <= S6;
					end if;
				when S6 =>
					if command=x"0" and busyNoCR8='0' then 
						busy <= '1';
						ER <= S10;
					elsif rx='1' then
						-- recebendo parte alta do dado
						dinNoC(15 downto 8) <= data_in;
						sizePayload <= sizePayload + '1';
						ER <= S7;
					end if;
				when S7 =>
					if rx='1' then 
						-- recebendo parte baixa do dado
						dinNoC(7 downto 0) <= data_in;
						sizePayload <= sizePayload + '1';
						-- sinais da memoria
						weNoC <= '1';
						ER <= S8;
					end if;
				when S8 =>
					-- escrita na memoria
					weNoC <= '0';
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
					tx <= '1';
					data_out <= target;
					if ack_tx = '1' then
						tx <= '0';
						ER <= S11;
					end if;
				when S11 =>
					tx <= '1';
					data_out <= x"04";
					if ack_tx = '1' then
						tx <= '0';
						ER <= S12;
					end if;
				when S12 =>
					tx <= '1';
					data_out <= address;
					if ack_tx = '1' then
						tx <= '0';
						ER <= S13;
					end if;
				when S13 =>
					tx <= '1';
					data_out <= x"09";
					if ack_tx = '1' then
						tx <= '0';
						ER <= S14;
					end if;
				when S14 =>
					weNoC <= '0';
					if accessMem = "10" then
						ER <= S15;
						dataL <= dout(7 downto 0);
						dataH <= dout(15 downto 8);
					end if;
				when S15 =>
					tx <= '1';
					data_out <= dataH;
					if ack_tx = '1' then
						tx <= '0';
						ER <= S16;
					end if;
				when S16 =>
					tx <= '1';
					data_out <= dataL;
					if ack_tx = '1' then
						weNoC <= '0';
						tx <= '0';
						busy <= '0';
						ER <= S17;
					end if;
				when S17 =>
					ER <= S0;
			end case;
		end if;
	end process;
	
	accessMem <= "01" when ceR8='1' else
	             "10" when (ER=S8 or ER=S14) else --  ER=S14 lendo da blockram e ER=S8 escrevendo na blockram.
	             "00"; 
	
	en <= '1' when accessMem/="00" else '0';

	we <= rwR8 when accessMem="01" else
	      weNoC when accessMem="10" else
	      '0';

-------------------------------------------------------------------------------------------------------	
---- MEMORIA VIRTEX I
-------------------------------------------------------------------------------------------------------	
	addr <= addrR8(9 downto 0) when accessMem="01" else
    	    addrNoC(9 downto 0) when accessMem="10" else
        	(others=>'0');

-------------------------------------------------------------------------------------------------------	
---- MEMORIA VIRTEX II
-------------------------------------------------------------------------------------------------------	
--	addr <= addrR8(10 downto 0) when accessMem="01" else
--    	        addrNoC(10 downto 0) when accessMem="10" else
--        	(others=>'0');

	din <= dinR8 when accessMem="01" else
    	       dinNoC when accessMem="10" else
	       (others=>'0');

	doutR8 <= dout when accessMem="01" else (others=>'0');

end MemoriaLocal;