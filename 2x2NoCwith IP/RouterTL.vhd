---------------------------------------------------------------------------------------	
--                          ROTEADOR   
--
--                            NORTH        LOCAL
--               -------------------------------
--               |           ******     ****** |
--               |           *FILA*     *FILA* |
--               |           ******     ****** |
--               |        *************        |
--               |        *  ARBITRO  *        |
--               | ****** ************* ****** |
--          WEST | *FILA* ************* *FILA* | EAST
--               | ****** *CHAVEAMENTO* ****** |
--               |        *************        |
--               |           ******            |
--               |           *FILA*            |
--               |           ******            |
--               -------------------------------
--                           SOUTH
--
--  Os roteadores realizam a transfer�ncia de mensagens entre n�cleos. 
--  O roteador possui uma l�gica de controle e 5 portas bidirecionais: East, West, 
--  North, South e Local. Cada porta possui uma fila para o armazenamento tempor�rio
--  de flits. A porta Local estabelece a comunica��o entre o roteador e seu n�cleo.
--  As demais portas ligam o roteador aos roteadores vizinhos.
--  Os endere�os dos roteadores s�o compostos pelas coordenadas XY da rede de interconex�o, 
--  onde X � a posi��o horizontal e Y a posi��o vertical. A atribui��o de endere�os aos 
--  roteadores � necess�ria para a execu��o do algoritmo de roteamento.
--  Os m�dulos principais que comp�em o roteador s�o: fila, �rbitro e l�gica de 
--  chaveamento. Cada uma das filas do roteador, ao receber um novo pacote requisita 
--  roteamento ao �rbitro. O �rbitro seleciona a requisi��o de maior prioridade, quando
--  existem requisi��es simult�neas, e encaminha o pedido de roteamento � l�gica de 
--  chaveamento. A l�gica de chaveamento verifica se � poss�vel atender � solicita��o. 
--  Sendo poss�vel, a conex�o � estabelecida e o �rbitro � informado. Por sua vez, o �rbitro
--  informa a fila que come�a a enviar os flits armazenados. Quando todos os flits do pacote
--  foram enviados, a conex�o � conclu�da pela sinaliza��o, por parte da fila, atrav�s do 
--  sinal sender.
---------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HermesPackage.all;

entity RouterTL is
generic( address: regflit);
port(
    clock    : in  std_logic;
    reset    : in  std_logic;
    data_in  : in  arrayNport_regflit;
    rx       : in  regNport;
    ack_rx   : out regNport;
    data_out : out arrayNport_regflit;
    tx       : out regNport;
    ack_tx   : in  regNport);
end RouterTL;

architecture RouterTL of RouterTL is

signal h, ack_h, data_av, sender, data_ack: regNport;
signal data: arrayNport_regflit;
signal mux_in,mux_out: arrayNport_reg3;
signal free: regNport;

begin

	FEast : Entity work.Fila(Fila)
	port map(
		clock => clock,
		reset => reset,
		data_in => data_in(0),
		rx => rx(0),
		ack_rx => ack_rx(0),
		h => h(0),
		ack_h => ack_h(0),
		data_av => data_av(0),
		data => data(0),
		data_ack => data_ack(0),
		sender=>sender(0));

	FSouth : Entity work.Fila(Fila)
	port map(
		clock => clock,
		reset => reset,
		data_in => data_in(3),
		rx => rx(3),
		ack_rx => ack_rx(3),
		h => h(3),
		ack_h => ack_h(3),
		data_av => data_av(3),
		data => data(3),
		data_ack => data_ack(3),
		sender=>sender(3));

	FLocal : Entity work.Fila(Fila)
	port map(
		clock => clock,
		reset => reset,
		data_in => data_in(4),
		rx => rx(4),
		ack_rx => ack_rx(4),
		h => h(4),
		ack_h => ack_h(4),
		data_av => data_av(4),
		data => data(4),
		data_ack => data_ack(4),
		sender=>sender(4));

    SwitchControl : Entity work.SwitchControl(AlgorithmXY)
    port map(
        clock => clock,
        reset => reset,
        h => h,
        ack_h => ack_h,
        address => address,
        data => data,
        sender => sender,
        free => free,
        mux_in => mux_in,
        mux_out => mux_out);

    ----------------------------------------------------------------------------------
    -- OBSERVACAO:
    -- quando eh sinal de saida quem determina eh o sinal mux_out
    -- quando eh sinal de entrada quem determina eh mux_in
    ----------------------------------------------------------------------------------	
    MUXS : for i in 0 to (NPORT-1) generate   
        data_out(i) <= data(CONV_INTEGER(mux_out(i))) when free(i)='0' else (others=>'0');
        data_ack(i) <= 	ack_tx(CONV_INTEGER(mux_in(i))) when sender(i)='1' else '0'; 			
        tx(i) <= data_av(CONV_INTEGER(mux_out(i))) when free(i)='0' else '0';
    end generate MUXS;       
    	
	h(1)<='0';
	data_av(1)<='0';
	data(1)<=(others=>'0');
	sender(1)<='0';
	h(2)<='0';
	data_av(2)<='0';
	data(2)<=(others=>'0');
	sender(2)<='0';

	
end RouterTL;
