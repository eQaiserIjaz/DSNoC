library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HermesPackage.all;

entity NOC is
port(
	clock         : in  std_logic;
	reset         : in  std_logic;
	rxLocal       : in  regNrot;
	data_inLocal  : in  arrayNrot_regflit;
	ack_rxLocal   : out regNrot;
	txLocal       : out regNrot;
	data_outLocal : out arrayNrot_regflit;
	ack_txLocal   : in  regNrot);
end NOC;

architecture NOC of NOC is

	signal rxN0000, rxN0100 : regNport;
	signal data_inN0000, data_inN0100 : arrayNport_regflit;
	signal ack_rxN0000, ack_rxN0100 : regNport;
	signal txN0000, txN0100 : regNport;
	signal data_outN0000, data_outN0100 : arrayNport_regflit;
	signal ack_txN0000, ack_txN0100 : regNport;
	signal rxN0001, rxN0101 : regNport;
	signal data_inN0001, data_inN0101 : arrayNport_regflit;
	signal ack_rxN0001, ack_rxN0101 : regNport;
	signal txN0001, txN0101 : regNport;
	signal data_outN0001, data_outN0101 : arrayNport_regflit;
	signal ack_txN0001, ack_txN0101 : regNport;
begin

	Router0000 : Entity work.RouterBL(RouterBL)
	generic map( address => ADDRESSN0000 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0000,
		data_in  => data_inN0000,
		ack_rx   => ack_rxN0000,
		tx       => txN0000,
		data_out => data_outN0000,
		ack_tx   => ack_txN0000);

	Router0100 : Entity work.RouterBR(RouterBR)
	generic map( address => ADDRESSN0100 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0100,
		data_in  => data_inN0100,
		ack_rx   => ack_rxN0100,
		tx       => txN0100,
		data_out => data_outN0100,
		ack_tx   => ack_txN0100);

	Router0001 : Entity work.RouterTL(RouterTL)
	generic map( address => ADDRESSN0001 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0001,
		data_in  => data_inN0001,
		ack_rx   => ack_rxN0001,
		tx       => txN0001,
		data_out => data_outN0001,
		ack_tx   => ack_txN0001);

	Router0101 : Entity work.RouterTR(RouterTR)
	generic map( address => ADDRESSN0101 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0101,
		data_in  => data_inN0101,
		ack_rx   => ack_rxN0101,
		tx       => txN0101,
		data_out => data_outN0101,
		ack_tx   => ack_txN0101);

	-- ROUTER 0000
	-- EAST port
	data_inN0000(0)<=data_outN0100(1);
	rxN0000(0)<=txN0100(1);
	ack_txN0000(0)<=ack_rxN0100(1);
	-- WEST port
	data_inN0000(1)<=(others=>'0');
	rxN0000(1)<='0';
	ack_txN0000(1)<='0';
	-- NORTH port
	data_inN0000(2)<=data_outN0001(3);
	rxN0000(2)<=txN0001(3);
	ack_txN0000(2)<=ack_rxN0001(3);
	-- SOUTH port
	data_inN0000(3)<=(others=>'0');
	rxN0000(3)<='0';
	ack_txN0000(3)<='0';
	-- LOCAL port
	rxN0000(4)<=rxLocal(N0000);
	ack_txN0000(4)<=ack_txLocal(N0000);
	data_inN0000(4)<=data_inLocal(N0000);
	txLocal(N0000)<=txN0000(4);
	ack_rxLocal(N0000)<=ack_rxN0000(4);
	data_outLocal(N0000)<=data_outN0000(4);

	-- ROUTER 0100
	-- EAST port
	data_inN0100(0)<=(others=>'0');
	rxN0100(0)<='0';
	ack_txN0100(0)<='0';
	-- WEST port
	data_inN0100(1)<=data_outN0000(0);
	rxN0100(1)<=txN0000(0);
	ack_txN0100(1)<=ack_rxN0000(0);
	-- NORTH port
	data_inN0100(2)<=data_outN0101(3);
	rxN0100(2)<=txN0101(3);
	ack_txN0100(2)<=ack_rxN0101(3);
	-- SOUTH port
	data_inN0100(3)<=(others=>'0');
	rxN0100(3)<='0';
	ack_txN0100(3)<='0';
	-- LOCAL port
	rxN0100(4)<=rxLocal(N0100);
	ack_txN0100(4)<=ack_txLocal(N0100);
	data_inN0100(4)<=data_inLocal(N0100);
	txLocal(N0100)<=txN0100(4);
	ack_rxLocal(N0100)<=ack_rxN0100(4);
	data_outLocal(N0100)<=data_outN0100(4);

	-- ROUTER 0001
	-- EAST port
	data_inN0001(0)<=data_outN0101(1);
	rxN0001(0)<=txN0101(1);
	ack_txN0001(0)<=ack_rxN0101(1);
	-- WEST port
	data_inN0001(1)<=(others=>'0');
	rxN0001(1)<='0';
	ack_txN0001(1)<='0';
	-- NORTH port
	data_inN0001(2)<=(others=>'0');
	rxN0001(2)<='0';
	ack_txN0001(2)<='0';
	-- SOUTH port
	data_inN0001(3)<=data_outN0000(2);
	rxN0001(3)<=txN0000(2);
	ack_txN0001(3)<=ack_rxN0000(2);
	-- LOCAL port
	rxN0001(4)<=rxLocal(N0001);
	ack_txN0001(4)<=ack_txLocal(N0001);
	data_inN0001(4)<=data_inLocal(N0001);
	txLocal(N0001)<=txN0001(4);
	ack_rxLocal(N0001)<=ack_rxN0001(4);
	data_outLocal(N0001)<=data_outN0001(4);

	-- ROUTER 0101
	-- EAST port
	data_inN0101(0)<=(others=>'0');
	rxN0101(0)<='0';
	ack_txN0101(0)<='0';
	-- WEST port
	data_inN0101(1)<=data_outN0001(0);
	rxN0101(1)<=txN0001(0);
	ack_txN0101(1)<=ack_rxN0001(0);
	-- NORTH port
	data_inN0101(2)<=(others=>'0');
	rxN0101(2)<='0';
	ack_txN0101(2)<='0';
	-- SOUTH port
	data_inN0101(3)<=data_outN0100(2);
	rxN0101(3)<=txN0100(2);
	ack_txN0101(3)<=ack_rxN0100(2);
	-- LOCAL port
	rxN0101(4)<=rxLocal(N0101);
	ack_txN0101(4)<=ack_txLocal(N0101);
	data_inN0101(4)<=data_inLocal(N0101);
	txLocal(N0101)<=txN0101(4);
	ack_rxLocal(N0101)<=ack_rxN0101(4);
	data_outLocal(N0101)<=data_outN0101(4);

	
end NOC;