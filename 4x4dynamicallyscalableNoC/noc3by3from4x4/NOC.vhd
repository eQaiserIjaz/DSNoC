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

	signal rxN0000, rxN0100, rxN0200, rxN0300 : regNport;
	signal data_inN0000, data_inN0100, data_inN0200, data_inN0300 : arrayNport_regflit;
	signal ack_rxN0000, ack_rxN0100, ack_rxN0200, ack_rxN0300 : regNport;
	signal txN0000, txN0100, txN0200, txN0300 : regNport;
	signal data_outN0000, data_outN0100, data_outN0200, data_outN0300 : arrayNport_regflit;
	signal ack_txN0000, ack_txN0100, ack_txN0200, ack_txN0300 : regNport;
	signal rxN0001, rxN0101, rxN0201, rxN0301 : regNport;
	signal data_inN0001, data_inN0101, data_inN0201, data_inN0301 : arrayNport_regflit;
	signal ack_rxN0001, ack_rxN0101, ack_rxN0201, ack_rxN0301 : regNport;
	signal txN0001, txN0101, txN0201, txN0301 : regNport;
	signal data_outN0001, data_outN0101, data_outN0201, data_outN0301 : arrayNport_regflit;
	signal ack_txN0001, ack_txN0101, ack_txN0201, ack_txN0301 : regNport;
	signal rxN0002, rxN0102, rxN0202, rxN0302 : regNport;
	signal data_inN0002, data_inN0102, data_inN0202, data_inN0302 : arrayNport_regflit;
	signal ack_rxN0002, ack_rxN0102, ack_rxN0202, ack_rxN0302 : regNport;
	signal txN0002, txN0102, txN0202, txN0302 : regNport;
	signal data_outN0002, data_outN0102, data_outN0202, data_outN0302 : arrayNport_regflit;
	signal ack_txN0002, ack_txN0102, ack_txN0202, ack_txN0302 : regNport;
	signal rxN0003, rxN0103, rxN0203, rxN0303 : regNport;
	signal data_inN0003, data_inN0103, data_inN0203, data_inN0303 : arrayNport_regflit;
	signal ack_rxN0003, ack_rxN0103, ack_rxN0203, ack_rxN0303 : regNport;
	signal txN0003, txN0103, txN0203, txN0303 : regNport;
	signal data_outN0003, data_outN0103, data_outN0203, data_outN0303 : arrayNport_regflit;
	signal ack_txN0003, ack_txN0103, ack_txN0203, ack_txN0303 : regNport;
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

	Router0100 : Entity work.RouterBC(RouterBC)
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

	Router0200 : Entity work.RouterBC(RouterBC)
	generic map( address => ADDRESSN0200 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0200,
		data_in  => data_inN0200,
		ack_rx   => ack_rxN0200,
		tx       => txN0200,
		data_out => data_outN0200,
		ack_tx   => ack_txN0200);

	Router0300 : Entity work.RouterBR(RouterBR)
	generic map( address => ADDRESSN0300 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0300,
		data_in  => data_inN0300,
		ack_rx   => ack_rxN0300,
		tx       => txN0300,
		data_out => data_outN0300,
		ack_tx   => ack_txN0300);

	Router0001 : Entity work.RouterCL(RouterCL)
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

	Router0101 : Entity work.RouterCC(RouterCC)
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

	Router0201 : Entity work.RouterCC(RouterCC)
	generic map( address => ADDRESSN0201 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0201,
		data_in  => data_inN0201,
		ack_rx   => ack_rxN0201,
		tx       => txN0201,
		data_out => data_outN0201,
		ack_tx   => ack_txN0201);

	Router0301 : Entity work.RouterCR(RouterCR)
	generic map( address => ADDRESSN0301 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0301,
		data_in  => data_inN0301,
		ack_rx   => ack_rxN0301,
		tx       => txN0301,
		data_out => data_outN0301,
		ack_tx   => ack_txN0301);

	Router0002 : Entity work.RouterCL(RouterCL)
	generic map( address => ADDRESSN0002 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0002,
		data_in  => data_inN0002,
		ack_rx   => ack_rxN0002,
		tx       => txN0002,
		data_out => data_outN0002,
		ack_tx   => ack_txN0002);

	Router0102 : Entity work.RouterCC(RouterCC)
	generic map( address => ADDRESSN0102 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0102,
		data_in  => data_inN0102,
		ack_rx   => ack_rxN0102,
		tx       => txN0102,
		data_out => data_outN0102,
		ack_tx   => ack_txN0102);

	Router0202 : Entity work.RouterCC(RouterCC)
	generic map( address => ADDRESSN0202 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0202,
		data_in  => data_inN0202,
		ack_rx   => ack_rxN0202,
		tx       => txN0202,
		data_out => data_outN0202,
		ack_tx   => ack_txN0202);

	Router0302 : Entity work.RouterCR(RouterCR)
	generic map( address => ADDRESSN0302 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0302,
		data_in  => data_inN0302,
		ack_rx   => ack_rxN0302,
		tx       => txN0302,
		data_out => data_outN0302,
		ack_tx   => ack_txN0302);

	Router0003 : Entity work.RouterTL(RouterTL)
	generic map( address => ADDRESSN0003 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0003,
		data_in  => data_inN0003,
		ack_rx   => ack_rxN0003,
		tx       => txN0003,
		data_out => data_outN0003,
		ack_tx   => ack_txN0003);

	Router0103 : Entity work.RouterTC(RouterTC)
	generic map( address => ADDRESSN0103 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0103,
		data_in  => data_inN0103,
		ack_rx   => ack_rxN0103,
		tx       => txN0103,
		data_out => data_outN0103,
		ack_tx   => ack_txN0103);

	Router0203 : Entity work.RouterTC(RouterTC)
	generic map( address => ADDRESSN0203 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0203,
		data_in  => data_inN0203,
		ack_rx   => ack_rxN0203,
		tx       => txN0203,
		data_out => data_outN0203,
		ack_tx   => ack_txN0203);

	Router0303 : Entity work.RouterTR(RouterTR)
	generic map( address => ADDRESSN0303 )
	port map(
		clock    => clock,
		reset    => reset,
		rx       => rxN0303,
		data_in  => data_inN0303,
		ack_rx   => ack_rxN0303,
		tx       => txN0303,
		data_out => data_outN0303,
		ack_tx   => ack_txN0303);

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
	data_inN0100(0)<=data_outN0300(1);
	rxN0100(0)<=txN0300(1);
	ack_txN0100(0)<=ack_rxN0300(1);
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

--	-- ROUTER 0200
--	-- EAST port
--	data_inN0200(0)<=data_outN0300(1);
--	rxN0200(0)<=txN0300(1);
--	ack_txN0200(0)<=ack_rxN0300(1);
--	-- WEST port
--	data_inN0200(1)<=data_outN0100(0);
--	rxN0200(1)<=txN0100(0);
--	ack_txN0200(1)<=ack_rxN0100(0);
--	-- NORTH port
--	data_inN0200(2)<=data_outN0201(3);
--	rxN0200(2)<=txN0201(3);
--	ack_txN0200(2)<=ack_rxN0201(3);
--	-- SOUTH port
--	data_inN0200(3)<=(others=>'0');
--	rxN0200(3)<='0';
--	ack_txN0200(3)<='0';
--	-- LOCAL port
--	rxN0200(4)<=rxLocal(N0200);
--	ack_txN0200(4)<=ack_txLocal(N0200);
--	data_inN0200(4)<=data_inLocal(N0200);
--	txLocal(N0200)<=txN0200(4);
--	ack_rxLocal(N0200)<=ack_rxN0200(4);
--	data_outLocal(N0200)<=data_outN0200(4);

	-- ROUTER 0300
	-- EAST port
	data_inN0300(0)<=(others=>'0');
	rxN0300(0)<='0';
	ack_txN0300(0)<='0';
	-- WEST port
	data_inN0300(1)<=data_outN0100(0);
	rxN0300(1)<=txN0100(0);
	ack_txN0300(1)<=ack_rxN0100(0);
	-- NORTH port
	data_inN0300(2)<=data_outN0301(3);
	rxN0300(2)<=txN0301(3);
	ack_txN0300(2)<=ack_rxN0301(3);
	-- SOUTH port
	data_inN0300(3)<=(others=>'0');
	rxN0300(3)<='0';
	ack_txN0300(3)<='0';
	-- LOCAL port
	rxN0300(4)<=rxLocal(N0300);
	ack_txN0300(4)<=ack_txLocal(N0300);
	data_inN0300(4)<=data_inLocal(N0300);
	txLocal(N0300)<=txN0300(4);
	ack_rxLocal(N0300)<=ack_rxN0300(4);
	data_outLocal(N0300)<=data_outN0300(4);

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
	data_inN0001(2)<=data_outN0003(3);
	rxN0001(2)<=txN0003(3);
	ack_txN0001(2)<=ack_rxN0003(3);
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
	data_inN0101(0)<=data_outN0301(1);
	rxN0101(0)<=txN0301(1);
	ack_txN0101(0)<=ack_rxN0301(1);
	-- WEST port
	data_inN0101(1)<=data_outN0001(0);
	rxN0101(1)<=txN0001(0);
	ack_txN0101(1)<=ack_rxN0001(0);
	-- NORTH port
	data_inN0101(2)<=data_outN0103(3);
	rxN0101(2)<=txN0103(3);
	ack_txN0101(2)<=ack_rxN0103(3);
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

--	-- ROUTER 0201
--	-- EAST port
--	data_inN0201(0)<=data_outN0301(1);
--	rxN0201(0)<=txN0301(1);
--	ack_txN0201(0)<=ack_rxN0301(1);
--	-- WEST port
--	data_inN0201(1)<=data_outN0101(0);
--	rxN0201(1)<=txN0101(0);
--	ack_txN0201(1)<=ack_rxN0101(0);
--	-- NORTH port
--	data_inN0201(2)<=data_outN0202(3);
--	rxN0201(2)<=txN0202(3);
--	ack_txN0201(2)<=ack_rxN0202(3);
--	-- SOUTH port
--	data_inN0201(3)<=data_outN0200(2);
--	rxN0201(3)<=txN0200(2);
--	ack_txN0201(3)<=ack_rxN0200(2);
--	-- LOCAL port
--	rxN0201(4)<=rxLocal(N0201);
--	ack_txN0201(4)<=ack_txLocal(N0201);
--	data_inN0201(4)<=data_inLocal(N0201);
--	txLocal(N0201)<=txN0201(4);
--	ack_rxLocal(N0201)<=ack_rxN0201(4);
--	data_outLocal(N0201)<=data_outN0201(4);

	-- ROUTER 0301
	-- EAST port
	data_inN0301(0)<=(others=>'0');
	rxN0301(0)<='0';
	ack_txN0301(0)<='0';
	-- WEST port
	data_inN0301(1)<=data_outN0101(0);
	rxN0301(1)<=txN0101(0);
	ack_txN0301(1)<=ack_rxN0101(0);
	-- NORTH port
	data_inN0301(2)<=data_outN0303(3);
	rxN0301(2)<=txN0303(3);
	ack_txN0301(2)<=ack_rxN0303(3);
	-- SOUTH port
	data_inN0301(3)<=data_outN0300(2);
	rxN0301(3)<=txN0300(2);
	ack_txN0301(3)<=ack_rxN0300(2);
	-- LOCAL port
	rxN0301(4)<=rxLocal(N0301);
	ack_txN0301(4)<=ack_txLocal(N0301);
	data_inN0301(4)<=data_inLocal(N0301);
	txLocal(N0301)<=txN0301(4);
	ack_rxLocal(N0301)<=ack_rxN0301(4);
	data_outLocal(N0301)<=data_outN0301(4);

--	-- ROUTER 0002
--	-- EAST port
--	data_inN0002(0)<=data_outN0102(1);
--	rxN0002(0)<=txN0102(1);
--	ack_txN0002(0)<=ack_rxN0102(1);
--	-- WEST port
--	data_inN0002(1)<=(others=>'0');
--	rxN0002(1)<='0';
--	ack_txN0002(1)<='0';
--	-- NORTH port
--	data_inN0002(2)<=data_outN0003(3);
--	rxN0002(2)<=txN0003(3);
--	ack_txN0002(2)<=ack_rxN0003(3);
--	-- SOUTH port
--	data_inN0002(3)<=data_outN0001(2);
--	rxN0002(3)<=txN0001(2);
--	ack_txN0002(3)<=ack_rxN0001(2);
--	-- LOCAL port
--	rxN0002(4)<=rxLocal(N0002);
--	ack_txN0002(4)<=ack_txLocal(N0002);
--	data_inN0002(4)<=data_inLocal(N0002);
--	txLocal(N0002)<=txN0002(4);
--	ack_rxLocal(N0002)<=ack_rxN0002(4);
--	data_outLocal(N0002)<=data_outN0002(4);

--	-- ROUTER 0102
--	-- EAST port
--	data_inN0102(0)<=data_outN0202(1);
--	rxN0102(0)<=txN0202(1);
--	ack_txN0102(0)<=ack_rxN0202(1);
--	-- WEST port
--	data_inN0102(1)<=data_outN0002(0);
--	rxN0102(1)<=txN0002(0);
--	ack_txN0102(1)<=ack_rxN0002(0);
--	-- NORTH port
--	data_inN0102(2)<=data_outN0103(3);
--	rxN0102(2)<=txN0103(3);
--	ack_txN0102(2)<=ack_rxN0103(3);
--	-- SOUTH port
--	data_inN0102(3)<=data_outN0101(2);
--	rxN0102(3)<=txN0101(2);
--	ack_txN0102(3)<=ack_rxN0101(2);
--	-- LOCAL port
--	rxN0102(4)<=rxLocal(N0102);
--	ack_txN0102(4)<=ack_txLocal(N0102);
--	data_inN0102(4)<=data_inLocal(N0102);
--	txLocal(N0102)<=txN0102(4);
--	ack_rxLocal(N0102)<=ack_rxN0102(4);
--	data_outLocal(N0102)<=data_outN0102(4);
--
--	-- ROUTER 0202
--	-- EAST port
--	data_inN0202(0)<=data_outN0302(1);
--	rxN0202(0)<=txN0302(1);
--	ack_txN0202(0)<=ack_rxN0302(1);
--	-- WEST port
--	data_inN0202(1)<=data_outN0102(0);
--	rxN0202(1)<=txN0102(0);
--	ack_txN0202(1)<=ack_rxN0102(0);
--	-- NORTH port
--	data_inN0202(2)<=data_outN0203(3);
--	rxN0202(2)<=txN0203(3);
--	ack_txN0202(2)<=ack_rxN0203(3);
--	-- SOUTH port
--	data_inN0202(3)<=data_outN0201(2);
--	rxN0202(3)<=txN0201(2);
--	ack_txN0202(3)<=ack_rxN0201(2);
--	-- LOCAL port
--	rxN0202(4)<=rxLocal(N0202);
--	ack_txN0202(4)<=ack_txLocal(N0202);
--	data_inN0202(4)<=data_inLocal(N0202);
--	txLocal(N0202)<=txN0202(4);
--	ack_rxLocal(N0202)<=ack_rxN0202(4);
--	data_outLocal(N0202)<=data_outN0202(4);
--
--	-- ROUTER 0302
--	-- EAST port
--	data_inN0302(0)<=(others=>'0');
--	rxN0302(0)<='0';
--	ack_txN0302(0)<='0';
--	-- WEST port
--	data_inN0302(1)<=data_outN0202(0);
--	rxN0302(1)<=txN0202(0);
--	ack_txN0302(1)<=ack_rxN0202(0);
--	-- NORTH port
--	data_inN0302(2)<=data_outN0303(3);
--	rxN0302(2)<=txN0303(3);
--	ack_txN0302(2)<=ack_rxN0303(3);
--	-- SOUTH port
--	data_inN0302(3)<=data_outN0301(2);
--	rxN0302(3)<=txN0301(2);
--	ack_txN0302(3)<=ack_rxN0301(2);
--	-- LOCAL port
--	rxN0302(4)<=rxLocal(N0302);
--	ack_txN0302(4)<=ack_txLocal(N0302);
--	data_inN0302(4)<=data_inLocal(N0302);
--	txLocal(N0302)<=txN0302(4);
--	ack_rxLocal(N0302)<=ack_rxN0302(4);
--	data_outLocal(N0302)<=data_outN0302(4);

	-- ROUTER 0003
	-- EAST port
	data_inN0003(0)<=data_outN0103(1);
	rxN0003(0)<=txN0103(1);
	ack_txN0003(0)<=ack_rxN0103(1);
	-- WEST port
	data_inN0003(1)<=(others=>'0');
	rxN0003(1)<='0';
	ack_txN0003(1)<='0';
	-- NORTH port
	data_inN0003(2)<=(others=>'0');
	rxN0003(2)<='0';
	ack_txN0003(2)<='0';
	-- SOUTH port
	data_inN0003(3)<=data_outN0001(2);
	rxN0003(3)<=txN0001(2);
	ack_txN0003(3)<=ack_rxN0001(2);
	-- LOCAL port
	rxN0003(4)<=rxLocal(N0003);
	ack_txN0003(4)<=ack_txLocal(N0003);
	data_inN0003(4)<=data_inLocal(N0003);
	txLocal(N0003)<=txN0003(4);
	ack_rxLocal(N0003)<=ack_rxN0003(4);
	data_outLocal(N0003)<=data_outN0003(4);

	-- ROUTER 0103
	-- EAST port
	data_inN0103(0)<=data_outN0303(1);
	rxN0103(0)<=txN0303(1);
	ack_txN0103(0)<=ack_rxN0303(1);
	-- WEST port
	data_inN0103(1)<=data_outN0003(0);
	rxN0103(1)<=txN0003(0);
	ack_txN0103(1)<=ack_rxN0003(0);
	-- NORTH port
	data_inN0103(2)<=(others=>'0');
	rxN0103(2)<='0';
	ack_txN0103(2)<='0';
	-- SOUTH port
	data_inN0103(3)<=data_outN0101(2);
	rxN0103(3)<=txN0101(2);
	ack_txN0103(3)<=ack_rxN0101(2);
	-- LOCAL port
	rxN0103(4)<=rxLocal(N0103);
	ack_txN0103(4)<=ack_txLocal(N0103);
	data_inN0103(4)<=data_inLocal(N0103);
	txLocal(N0103)<=txN0103(4);
	ack_rxLocal(N0103)<=ack_rxN0103(4);
	data_outLocal(N0103)<=data_outN0103(4);

--	-- ROUTER 0203
--	-- EAST port
--	data_inN0203(0)<=data_outN0303(1);
--	rxN0203(0)<=txN0303(1);
--	ack_txN0203(0)<=ack_rxN0303(1);
--	-- WEST port
--	data_inN0203(1)<=data_outN0103(0);
--	rxN0203(1)<=txN0103(0);
--	ack_txN0203(1)<=ack_rxN0103(0);
--	-- NORTH port
--	data_inN0203(2)<=(others=>'0');
--	rxN0203(2)<='0';
--	ack_txN0203(2)<='0';
--	-- SOUTH port
--	data_inN0203(3)<=data_outN0202(2);
--	rxN0203(3)<=txN0202(2);
--	ack_txN0203(3)<=ack_rxN0202(2);
--	-- LOCAL port
--	rxN0203(4)<=rxLocal(N0203);
--	ack_txN0203(4)<=ack_txLocal(N0203);
--	data_inN0203(4)<=data_inLocal(N0203);
--	txLocal(N0203)<=txN0203(4);
--	ack_rxLocal(N0203)<=ack_rxN0203(4);
--	data_outLocal(N0203)<=data_outN0203(4);

	-- ROUTER 0303
	-- EAST port
	data_inN0303(0)<=(others=>'0');
	rxN0303(0)<='0';
	ack_txN0303(0)<='0';
	-- WEST port
	data_inN0303(1)<=data_outN0103(0);
	rxN0303(1)<=txN0103(0);
	ack_txN0303(1)<=ack_rxN0103(0);
	-- NORTH port
	data_inN0303(2)<=(others=>'0');
	rxN0303(2)<='0';
	ack_txN0303(2)<='0';
	-- SOUTH port
	data_inN0303(3)<=data_outN0301(2);
	rxN0303(3)<=txN0301(2);
	ack_txN0303(3)<=ack_rxN0301(2);
	ack_txN0303(3)<=ack_rxN0301(2);
	-- LOCAL port
	rxN0303(4)<=rxLocal(N0303);
	ack_txN0303(4)<=ack_txLocal(N0303);
	data_inN0303(4)<=data_inLocal(N0303);
	txLocal(N0303)<=txN0303(4);
	ack_rxLocal(N0303)<=ack_rxN0303(4);
	data_outLocal(N0303)<=data_outN0303(4);

	

end NOC;