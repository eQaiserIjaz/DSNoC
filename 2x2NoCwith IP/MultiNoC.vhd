-----------------------------------------------------------------------------------
-- A serial recebe pacotes do software serial nos seguintes formato:
--
-- read   <command - 00> <target> <nword> <addH1> <addL1> ... <addHn> <addLn>
-- write  <command - 01> <target> <nword> <addH1> <addL1> <dataH1> <dataL1> ... <addHn> <addLn> <dataHn> <dataLn>
-- reset  <command - 02> <target>
-- return scanf  <command - 04> <target> <dataH> <dataL>
-----------------------------------------------------------------------------------
-- A serial recebe pacotes da rede nos seguintes formato:
--
-- printf <target> <size> <source> <command - 03> <dataH> <dataL>
-- scanf  <target> <size> <source> <command - 04>
-- executione <target> <size> <source> <command - 06> <data1> <data2> <data3> <data4>
-- return read <target> <size> <source> <command - 09> <nword> <dataH1> <dataL1> ... <dataHn> <dataLn>
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.HermesPackage.all;

entity MultiNoC is
port(
	clock: in std_logic;
	rst: in std_logic;
	txd: in std_logic;
	rxd: out std_logic;
	led:   out std_logic);
end MultiNoC;

architecture MultiNoC of MultiNoC is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
	-- System Library Components (this component is used to configured the reset or clock sinals)
	component IBUFG    -- buffer de entrada
	port(
		I    : in std_logic; 
		O    : out std_logic);
	end component;

	component BUFG      -- buffer interno
	port(
		I : in std_logic;
		O : out std_logic);
	end component;

	component CLKDLL      -- clock DLL
	generic (CLKDV_DIVIDE : real); 
	port (
		CLKIN : in std_logic;
		CLKFB : in std_logic;
		RST : in std_logic;
		CLK0 : out std_logic;
		CLK90 : out std_logic;
		CLK180 : out std_logic;
		CLK270 : out std_logic;
		CLKDV : out std_logic;
		CLK2X : out std_logic;
		LOCKED : out std_logic);
	end component;

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal reset:  std_logic;
-- sinais do CLKDLL
signal clk, clkdv, clk_int2, clk_int, ZERO: std_logic; 

-- estado da maquina de envio para a rede
signal state : reg8;
-- interface rede
signal rx,ack_rx: regNrot;
signal data_in: arrayNrot_regflit;
signal tx,ack_tx: regNrot;
signal data_out: arrayNrot_regflit;

begin

	U1:	IBUFG port map (I => rst, O => reset);
	U2:	IBUFG port map (I => clock, O => clk);

	-- when the reset (button BTN1) is pressed, the LED ascende
	led <= reset;

	ZERO <= '0';

	CLK_dll : CLKDLL
	generic map( 
		CLKDV_DIVIDE=>2.0) 
	port map (
		CLKIN => clk,
		CLKFB => clk_int2,
		RST => ZERO,
		CLK0 => clk_int,
		CLKDV => clkdv);

  	CLK_bufg: BUFG
	port map (	I => clk_int,	O => clk_int2); --  aqui tenho minha saida de freq dividida

	NOC : entity work.NOC(NOC)
	port map(
		clock         => clkdv,
		reset         => reset,
		rxLocal       => tx,
		data_inLocal  => data_out,
		ack_rxLocal   => ack_tx,
		txLocal       => rx,
		data_outLocal => data_in,
		ack_txLocal   => ack_rx);

	SERIAL : entity work.Serial(Serial)
	port map(
		clock => clkdv,
		reset => reset,
---- Estado da máquina de envio para a rede ------------
		state => state,
---- Interface Serial Prototipacao ---------------------
		txd => txd,
		rxd => rxd,
---- Interface Serial Simulacao ------------------------
--		rx_data => rx_data,
--		rx_start => rx_start,
--		rx_busy => rx_busy,
--		tx_data => tx_data,
--		tx_av => tx_av,
---- Interface NoC -------------------------------------
		address => addressN00,
		tx => tx(N00),
		data_out => data_out(N00),
		ack_tx => ack_tx(N00),
		rx => rx(N00),
		data_in => data_in(N00),
		ack_rx => ack_rx(N00));

	PROC10 : entity work.WrapperProcessador(WrapperProcessador)
	port map(
		clock => clkdv,
		reset => reset, 
---- Interface NoC -------------------------------------
		address => addressN10,
		tx => tx(N10),
		data_out => data_out(N10),
		ack_tx => ack_tx(N10),
		rx => rx(N10),
		data_in => data_in(N10),
		ack_rx => ack_rx(N10));

	PROC01 : entity work.WrapperProcessador(WrapperProcessador)
	port map(
		clock => clkdv,
		reset => reset, 
---- Interface NoC -------------------------------------
		address => addressN01,
		tx => tx(N01),
		data_out => data_out(N01),
		ack_tx => ack_tx(N01),
		rx => rx(N01),
		data_in => data_in(N01),
		ack_rx => ack_rx(N01));

	-- MEMORIA11 : entity work.Memoria(Memoria)
	-- port map(
		-- clock => clkdv,
		-- reset => reset, 
-- ---- Interface NoC -------------------------------------
		-- address => addressN11,
		-- tx => tx(N11),
		-- data_out => data_out(N11),
		-- ack_tx => ack_tx(N11),
		-- rx => rx(N11),
		-- data_in => data_in(N11),
		-- ack_rx => ack_rx(N11));
	
	PROC11 : entity work.WrapperProcessador(WrapperProcessador)
	port map(
		clock => clkdv,
		reset => reset, 
---- Interface NoC -------------------------------------
		address => addressN11,
		tx => tx(N11),
		data_out => data_out(N11),
		ack_tx => ack_tx(N11),
		rx => rx(N11),
		data_in => data_in(N11),
		ack_rx => ack_rx(N11));
		
end MultiNoC;