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

	signal rxN00, rxN10 : regNport;
	signal data_inN00, data_inN10 : arrayNport_regflit;
	signal ack_rxN00, ack_rxN10 : regNport;
	signal txN00, txN10 : regNport;
	signal data_outN00, data_outN10 : arrayNport_regflit;
	signal ack_txN00, ack_txN10 : regNport;
	signal rxN01, rxN11 : regNport;
	signal data_inN01, data_inN11 : arrayNport_regflit;
	signal ack_rxN01, ack_rxN11 : regNport;
	signal txN01, txN11 : regNport;
	signal data_outN01, data_outN11 : arrayNport_regflit;
	signal ack_txN01, ack_txN11 : regNport;
begin

	Router00 : Entity work.RouterBL(RouterBL)
	generic map( address => ADDRESSN00 )
	port map(
		clock => clock,
		reset => reset,
		rx => rxN00,
		data_in => data_inN00,
		ack_rx => ack_rxN00,
		tx => txN00,
		data_out => data_outN00,
		ack_tx => ack_txN00
	);

	Router10 : Entity work.RouterBR(RouterBR)
	generic map( address => ADDRESSN10 )
	port map(
		clock => clock,
		reset => reset,
		rx => rxN10,
		data_in => data_inN10,
		ack_rx => ack_rxN10,
		tx => txN10,
		data_out => data_outN10,
		ack_tx => ack_txN10
	);

	Router01 : Entity work.RouterTL(RouterTL)
	generic map( address => ADDRESSN01 )
	port map(
		clock => clock,
		reset => reset,
		rx => rxN01,
		data_in => data_inN01,
		ack_rx => ack_rxN01,
		tx => txN01,
		data_out => data_outN01,
		ack_tx => ack_txN01
	);

	Router11 : Entity work.RouterTR(RouterTR)
	generic map( address => ADDRESSN11 )
	port map(
		clock => clock,
		reset => reset,
		rx => rxN11,
		data_in => data_inN11,
		ack_rx => ack_rxN11,
		tx => txN11,
		data_out => data_outN11,
		ack_tx => ack_txN11
	);

	-- entradas do roteador00
	data_inN00(0)<=data_outN10(1);
	rxN00(0)<=txN10(1);
	ack_txN00(0)<=ack_rxN10(1);
	data_inN00(1)<=(others=>'0');
	rxN00(1)<='0';
	ack_txN00(1)<='0';
	data_inN00(3)<=(others=>'0');
	rxN00(3)<='0';
	ack_txN00(3)<='0';
	data_inN00(2)<=data_outN01(3);
	rxN00(2)<=txN01(3);
	ack_txN00(2)<=ack_rxN01(3);
	data_inN00(4)<=data_inLocal(N00);
	rxN00(4)<=rxLocal(N00);
	ack_txN00(4)<=ack_txLocal(N00);
	ack_rxLocal(N00)<=ack_rxN00(4);
	data_outLocal(N00)<=data_outN00(4);
	txLocal(N00)<=txN00(4);

	-- entradas do roteador10
	data_inN10(0)<=(others=>'0');
	rxN10(0)<='0';
	ack_txN10(0)<='0';
	data_inN10(1)<=data_outN00(0);
	rxN10(1)<=txN00(0);
	ack_txN10(1)<=ack_rxN00(0);
	data_inN10(3)<=(others=>'0');
	rxN10(3)<='0';
	ack_txN10(3)<='0';
	data_inN10(2)<=data_outN11(3);
	rxN10(2)<=txN11(3);
	ack_txN10(2)<=ack_rxN11(3);
	data_inN10(4)<=data_inLocal(N10);
	rxN10(4)<=rxLocal(N10);
	ack_txN10(4)<=ack_txLocal(N10);
	ack_rxLocal(N10)<=ack_rxN10(4);
	data_outLocal(N10)<=data_outN10(4);
	txLocal(N10)<=txN10(4);

	-- entradas do roteador01
	data_inN01(0)<=data_outN11(1);
	rxN01(0)<=txN11(1);
	ack_txN01(0)<=ack_rxN11(1);
	data_inN01(1)<=(others=>'0');
	rxN01(1)<='0';
	ack_txN01(1)<='0';
	data_inN01(3)<=data_outN00(2);
	rxN01(3)<=txN00(2);
	ack_txN01(3)<=ack_rxN00(2);
	data_inN01(2)<=(others=>'0');
	rxN01(2)<='0';
	ack_txN01(2)<='0';
	data_inN01(4)<=data_inLocal(N01);
	rxN01(4)<=rxLocal(N01);
	ack_txN01(4)<=ack_txLocal(N01);
	ack_rxLocal(N01)<=ack_rxN01(4);
	data_outLocal(N01)<=data_outN01(4);
	txLocal(N01)<=txN01(4);

	-- entradas do roteador11
	data_inN11(0)<=(others=>'0');
	rxN11(0)<='0';
	ack_txN11(0)<='0';
	data_inN11(1)<=data_outN01(0);
	rxN11(1)<=txN01(0);
	ack_txN11(1)<=ack_rxN01(0);
	data_inN11(3)<=data_outN10(2);
	rxN11(3)<=txN10(2);
	ack_txN11(3)<=ack_rxN10(2);
	data_inN11(2)<=(others=>'0');
	rxN11(2)<='0';
	ack_txN11(2)<='0';
	data_inN11(4)<=data_inLocal(N11);
	rxN11(4)<=rxLocal(N11);
	ack_txN11(4)<=ack_txLocal(N11);
	ack_rxLocal(N11)<=ack_rxN11(4);
	data_outLocal(N11)<=data_outN11(4);
	txLocal(N11)<=txN11(4);

end NOC;