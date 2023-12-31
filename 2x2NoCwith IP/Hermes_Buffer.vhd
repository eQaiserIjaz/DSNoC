---------------------------------------------------------------------------------------	
--                             FILA
--                        --------------
--                   RX ->|            |-> H 		   
--              DATA_IN ->|            |<- ACK_H
--               ACK_RX <-|            |
--                        |            |-> DATA_AV
--                        |            |-> DATA
--                        |            |<- DATA_ACK
--                        |            |
--                        |            |   SENDER
--                        |            |=> de todas
--                        |            |   as portas
--                        --------------
--
--  Quando a porta escolhida pelo algoritmo de roteamento est� ocupada, o header flit
--  tamb�m como os flits subseq�entes do pacote ser�o bloqueados. Este bloqueio afeta
--  o desempenho de toda rede, porque os flits s�o bloqueados n�o somente no roteador
--  atual, mas em todos os intermedi�rios. 
--  Para diminuir a perda de desempenho foi adicionada uma fila em cada porta de 
--  entrada do roteador, reduzindo os roteadores afetados com o bloqueio dos flits de
--  um pacote. � importante observar que quanto maior for o tamanho da fila menor ser�
--  o n�mero de roteadores intermedi�rias afetados. 
--  Na HERMES, as filas cont�m dimens�o e largura de flit parametriz�veis. Para 
--  alter�-las modifique as constantes TAM_BUFFER e TAM_FLIT no arquivo "packet.vhd".
--  As filas inseridas funcionam como FIFOs circulares. Cada fila possui dois ponteiros:
--  first e last. First aponta para a posi��o da fila onde se encontra o flit a ser 
--  consumido. Last aponta para a posi��o onde deve ser inserido o pr�ximo flit.
---------------------------------------------------------------------------------------	
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HermesPackage.all;

-- interface da Fila
entity Fila is
port(
    clock:          in  std_logic;
    reset:          in  std_logic;
    data_in:        in  regflit;
    rx:             in  std_logic;
    ack_rx:         out std_logic;
    h:              out std_logic;
    ack_h:          in  std_logic;
    data_av:        out std_logic;
    data:           out regflit;
    data_ack:       in  std_logic;
    sender:         out std_logic);
end Fila;

architecture Fila of Fila is

type fila_out is (S_INIT, S_PAYLOAD, S_SENDHEADER, S_HEADER, S_END);
signal EA : fila_out;

signal buf                : buff;
signal first,last         : pointer;
signal tem_espaco_na_fila : std_logic;
signal counter_flit       : regflit;
signal auxAck_rx          : std_logic;

begin 
        
    -------------------------------------------------------------------------------------------
    -- ENTRADA DE DADOS NA FILA
    -------------------------------------------------------------------------------------------

    -- Verifica se existe espa�o na fila para armazenamento de flits.
    -- Se existe espa�o na fila o sinal tem_espaco_na_fila � igual 1.
    process(reset, clock)
    begin
        if reset='1' then
            tem_espaco_na_fila <= '1';
        elsif clock'event and clock='0' then
            if not((first=x"0" and last=TAM_BUFFER - 1) or (first=last+1)) then
                tem_espaco_na_fila <= '1'; 
            else 
                tem_espaco_na_fila <= '0';
            end if;
        end if;
    end process;
	
    -- Quando o sinal rx � ativado indicando que existe um flit na porta de entrada e 
    -- existir espa�o na fila o sinal ack_rx � ativado, indicando que o flit foi recebido.
    -- ack_rx <= '1' when (tem_espaco_na_fila='1' and rx='1') else '0';
	
    ack_rx <= auxAck_rx;

    -- auxAck_rx � usado porque quando ack_rx ja esta em 1 ele deve ser mantido mesmo que a 
    -- tem_espaco_fila baixe
    auxAck_rx <= '1' when (tem_espaco_na_fila='1' and rx='1') or (auxAck_rx='1' and rx='1') else '0';
	
    -- O ponteiro last � inicializado com o valor zero quando o reset � ativado.
    -- Quando o sinal rx � ativado indicando que existe um flit na porta de entrada � 
    -- verificado se existe espa�o na fila para armazen�-lo. Se existir espa�o na fila o 
    -- flit recebido � armazenado na posi��o apontada pelo ponteiro last e o mesmo � 
    -- incrementado. Quando last atingir o tamanho da fila, ele recebe zero. 
    process(reset, clock)
    begin
        if reset='1' then
            last <= (others=>'0');  
		  buf <= (others=>(others=>'0'));  
        elsif clock'event and clock='1' then
            if tem_espaco_na_fila='1' and rx='1' then
                buf(CONV_INTEGER(last)) <= data_in;
                --incrementa o last
                if(last = TAM_BUFFER - 1) then last <= (others=>'0');
                else last <= last + 1;
                end if;
            end if;
        end if;
    end process;
   
    -------------------------------------------------------------------------------------------
    -- SA�DA DE DADOS NA FILA
    -------------------------------------------------------------------------------------------
   
    -- disponibiliza o dado para transmiss�o.
    data <= buf(CONV_INTEGER(first));
  
    -- Quando sinal reset � ativado a m�quina de estados avan�a para o estado S_INIT.
    -- No estado S_INIT os sinais counter_flit (contador de flits do corpo do pacote), h (que 
    -- indica requisi��o de chaveamento) e data_av (que indica a exist�ncia de flit a ser 
    -- transmitido) s�o inicializados com zero. Se existir algum flit na fila, ou seja, os 
    -- ponteiros first e last apontarem para posi��es diferentes, a m�quina de estados avan�a
    -- para o estado S_HEADER.
    --
    -- No estado S_HEADER � requisitado o chaveamento (h='1'), porque o flit na posi��o 
    -- apontada pelo ponteiro first, quando a m�quina encontra-se nesse estado, � sempre o 
    -- header do pacote. A m�quina permanece neste estado at� que receba a confirma��o do 
    -- chaveamento (ack_h='1') ent�o o sinal h recebe o valor zero e a m�quina avan�a para 
    -- S_SENDHEADER.
    --
    -- Em S_SENDHEADER � indicado que existe um flit a ser transmitido (data_av='1'). A m�quina de 
    -- estados permanece em S_SENDHEADER at� receber a confirma��o da transmiss�o (data_ack='1') 
    -- ent�o o ponteiro first aponta para o segundo flit do pacote e avan�a para o estado S_PAYLOAD.
    --
    -- No estado S_PAYLOAD � indicado que existe um flit a ser transmitido (data_av='1') quando 
    -- � recebida a confirma��o da transmiss�o (data_ack='1') � verificado qual o valor do sinal
    -- counter_flit. Se counter_flit � igual a um, a m�quina avan�a para o estado S_END. Caso
    -- counter_flit seja igual a zero, o sinal counter_flit � inicializado com o valor do flit, pois
    -- este ao n�mero de flits do corpo do pacote. Caso counter_flit seja diferente de um e de zero 
    -- o mesmo � decrementado e a m�quina de estados permanece em S_PAYLOAD enviando o pr�ximo flit
    -- do pacote.
    --
    -- Em S_END � indicado que o �ltimo flit deve ser transmitido (data_av='1') quando � recebida a
    -- confirma��o da transmiss�o (data_ack='1') a m�quina retorna ao estado S_INIT.
    process(reset, clock)
    begin
        if reset='1' then
            counter_flit <= (others=>'0');
            h <= '0';
            data_av <= '0';
            first <= (others=>'0');
            EA <= S_INIT;
        elsif clock'event and clock='1' then
            case EA is                  
                when S_INIT =>  
                    counter_flit <= (others=>'0');
                    h<='0';                 
                    data_av <= '0';
                    if first /= last then           -- detectou dado na fila
                        h<='1';                     -- pede roteamento
                        EA <= S_HEADER;
                    else
                        EA<= S_INIT;
                    end if;
                when S_HEADER =>
                    if ack_h='1' then
                        EA <= S_SENDHEADER;         -- depois de rotear envia o pacote 
                        h<='0';
                        data_av <= '1';
                    else
                        EA <= S_HEADER;
                    end if;
                when S_SENDHEADER  => 
                    if data_ack='1' then            -- mant�m este dado at� a resposta
                        EA <= S_PAYLOAD;
                        data_av <= '0';   
                        if (first = TAM_BUFFER -1) then
                            first <= (others=>'0');
                        else
                            first <= first+1;       -- assim que vier a resposta tira do buffer
                        end if;
                    elsif first /= last  then
                        data_av <= '1';
                        EA <= S_SENDHEADER;
                    else
                        data_av <= '0';
                        EA <= S_SENDHEADER;
                    end if;
                when S_PAYLOAD =>
                    if data_ack='1' then            -- mant�m este dado at� a resposta
                        data_av <= '0'; 
                        EA <= S_PAYLOAD;

                        if counter_flit = x"0" then counter_flit <=  buf(CONV_INTEGER(first)); 
                        else counter_flit <= counter_flit - 1; 
                        end if;

                        if (first = TAM_BUFFER -1) then	first <= (others=>'0');
                        else first <= first+1;      -- assim que vier a resposta tira do buffer
                        end if;

                    elsif counter_flit = x"1" and first /= last  then
                        data_av <= '1';
                        EA <= S_END;
                    elsif first /= last  then
                        data_av <= '1';
                        EA <= S_PAYLOAD;
                    else
                        data_av <= '0';
                        EA <= S_PAYLOAD;
                    end if;
                when S_END =>
                    if data_ack='1' then            -- mant�m este dado at� a resposta
                        data_av <= '0'; 
                        if (first = TAM_BUFFER -1) then	first <= (others=>'0');
                        else first <= first+1;      -- assim que vier a resposta tira do buffer
                        end if;
                        EA <= S_INIT;
                    elsif first /= last  then
                        data_av <= '1';
                        EA <= S_END;
                    else
                        data_av <= '0';
                        EA <= S_END;
                    end if;
            end case;
        end if;
    end process;            

    -- O sinal sender recebe o valor UM quando a porta de entrada est� enviando algum dado.
    -- O sinal ack_h indica que a porta de entrada teve sua requisi��o de chaveamento 
    -- atendida e que pode enviar dados. Sendo assim, quando o sinal ack_h � ativado o sinal
    -- sender deve receber UM e retornar para ZERO quando todos os dados foram enviado, ou seja,
    -- quando a m�quina encontra-se no estado S_INIT.
    process(reset, clock)
    begin
        if reset='1' then
            sender <=  '0';
        elsif clock'event and clock='1' then
            if ack_h = '1' then
                sender <= '1';
            elsif EA=S_INIT then
                sender <= '0';
            end if;
        end if;
    end process;
  
end Fila;