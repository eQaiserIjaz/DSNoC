---------------------------------------------------------------------------------------	
--                                    ROUTER
--
--                                    NORTH         LOCAL
--                      -----------------------------------
--                      |             ******       ****** |
--                      |             *FILA*       *FILA* |
--                      |             ******       ****** |
--                      |          *************          |
--                      |          *  ARBITRO  *          |
--                      | ******   *************   ****** |
--                 WEST | *FILA*   *************   *FILA* | EAST
--                      | ******   *  CONTROLE *   ****** |
--                      |          *************          |
--                      |             ******              |
--                      |             *FILA*              |
--                      |             ******              |
--                      -----------------------------------
--                                    SOUTH
--
--  As chaves realizam a transferencia de mensagens entre nucleos. 
--  A chave possui uma logica de controle de chaveamento e 5 portas bidirecionais:
--  East, West, North, South e Local. Cada porta possui uma fila para o armazenamento 
--  temporario de flits. A porta Local estabelece a comunicacao entre a chave e seu 
--  nucleo. As demais portas ligam a chave as chaves vizinhas.
--  Os enderecos das chaves sao compostos pelas coordenadas XY da rede de interconexao, 
--  onde X e a posicao horizontal e Y a posicao vertical. A atribuicao de enderecos as 
--  chaves e necessaria para a execucao do algoritmo de chaveamento.
--  Os modulos principais que compoem a chave sao: fila, arbitro e logica de 
--  chaveamento implementada pelo controle_mux. Cada uma das filas da chave (E, W, N, 
--  S e L), ao receber um novo pacote requisita chaveamento ao arbitro. O arbitro 
--  seleciona a requisicao de maior prioridade, quando existem requisicoes simultaneas, 
--  e encaminha o pedido de chaveamento a lóogica de chaveamento. A logica de 
--  chaveamento verifica se e possivel atender a solicitacao. Sendo possivel, a conexao
--  e estabelecida e o arbitro e informado. Por sua vez, o arbitro informa a fila que 
--  comeca a enviar os flits armazenados. Quando todos os flits do pacote foram 
--  enviados, a conexao e concluida pela sinalizacao, por parte da fila, atraves do 
--  sinal sender.
---------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HermesPackage.all;

entity RouterCC is
generic( address: regmetadeflit);
port(
	clock:    in  std_logic;
	reset:    in  std_logic;
	data_in:  in  arrayNport_regflit;
	rx:       in  regNport;
	ack_rx:   out regNport;
	data_out: out arrayNport_regflit;
	tx:       out regNport;
	ack_tx:   in  regNport);
end RouterCC;

architecture RouterCC of RouterCC is

signal h, ack_h, data_av, sender, data_ack: regNport := (others=>'0');
signal data: arrayNport_regflit := (others=>(others=>'0'));
signal mux_in,mux_out: arrayNport_reg3 := (others=>(others=>'0'));
signal free: regNport := (others=>'0');

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

	FWest : Entity work.Fila(Fila)
	port map(
		clock => clock,
		reset => reset,
		data_in => data_in(1),
		rx => rx(1),
		ack_rx => ack_rx(1),
		h => h(1),
		ack_h => ack_h(1),
		data_av => data_av(1),
		data => data(1),
		data_ack => data_ack(1),
		sender=>sender(1));

	FNorth : Entity work.Fila(Fila)
	port map(
		clock => clock,
		reset => reset,
		data_in => data_in(2),
		rx => rx(2),
		ack_rx => ack_rx(2),
		h => h(2),
		ack_h => ack_h(2),
		data_av => data_av(2),
		data => data(2),
		data_ack => data_ack(2),
		sender=>sender(2));

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
		data_ack(i) <= ack_tx(CONV_INTEGER(mux_in(i))) when sender(i)='1' else '0';
		tx(i) <= data_av(CONV_INTEGER(mux_out(i))) when free(i)='0' else '0';
	end generate MUXS;



end RouterCC;
