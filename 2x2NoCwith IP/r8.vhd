-------------------------------------------------------------------------
--  PROCESSADOR R8
--
--  moraes  - 30/setembro/2001     -     inicio do projeto
--
--  moraes - 22/11 - correção de bugs na decodificação da instrução
--        
--  moraes - 19/agosto/2002 - VERIFICAÇÃO DOS SINAIS DE HALT E WAIT
--                          - PACKAGE EM UM ARQUIVO A PARTE	  
--  carara - 10/setembro/203 - correção do PUSH e saltos de subrotinas
-------------------------------------------------------------------------

--------------------------------------------------------------------------
-- Registrador de uso geral      -   SENSIVEL A BORDA DE DESCIDA
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.R8Package.all;

entity registrador is
      port( ck,rst,ce:in std_logic;
            D:in  reg16;
            Q:out reg16 );
end registrador;

architecture registrador of registrador is
   begin
      process (ck, rst)
        begin
            if rst = '1' then
                  Q <= (others => '0');
            elsif ck'event and ck = '0' then
                  if ce = '1' then  Q <= D; end if;
            end if;
      end process;
end registrador;

--------------------------------------------------------------------------
-- Banco de registradores (R0..R15) - TODOS OS 16 REGISTRADORES SAO USADOS
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;   
use work.R8Package.all;

--library UNISIM;
--use UNISIM.vcomponents.all;

entity bcregs is
      port(  ck, rst, wreg, rs2: in   std_logic;
             ir, inREG:          in   reg16;
             source1, source2:   out  reg16     );
end entity;

architecture bcregs of bcregs is   

component RAM16X1D
port (WCLK  : IN    std_logic;
      WE    : IN    std_logic;
      D     : IN    std_logic; -- dado a ser escrito
      A0    : IN    std_logic;
      A1    : IN    std_logic;
      A2    : IN    std_logic;
      A3    : IN    std_logic;
      DPRA0 : IN    std_logic;
      DPRA1 : IN    std_logic;
      DPRA2 : IN    std_logic;
      DPRA3 : IN    std_logic;
      SPO   : OUT    std_logic;   
      DPO   : OUT    std_logic -- dado a ser lido
      );																	  
end component; 

	signal destA,destB: std_logic_vector(3 downto 0);
	signal notck: std_logic;	
   
begin            
	notck <= not ck;
	
	r1: for i in 15 downto 0 generate
	UTT: RAM16X1D
	port map(
		WCLK=>notck,
		WE=>wreg,
		D=>inREG(i),
		A0=>destA(0),
		A1=>destA(1),
		A2=>destA(2),
		A3=>destA(3),
		DPRA0=>destB(0),
		DPRA1=>destB(1),
		DPRA2=>destB(2),
		DPRA3=>destB(3),
		SPO=>source1(i),
		DPO=>source2(i));
	end generate r1;
	
	destA <= ir(11 downto 8) when wreg='1' else ir(7 downto 4);
   	destB <= ir(3 downto 0) when rs2 = '0' else ir(11 downto 8);
	
end bcregs;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--  Descricao estrutural do bloco de dados
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_unsigned.all;
use work.R8Package.all;
   
entity datapath is
      port( uins: in microinstrucao;
            ck, rst, wt: in std_logic;
            instrucao, endereco : out reg16;
            dataIN:  in  reg16;
            dataOUT: out reg16;
            flag: out reg4 );
end datapath;

architecture datapath of datapath is

    component bcregs
          port( ck, rst, wreg, rs2: in std_logic;
                ir, inREG:           in reg16;
                source1, source2:    out reg16 );
    end component;

    signal dtreg, dtpc, dtsp, s1, s2, outula, pc, sp, ir, rA, rB, rula, 
           opA, opB: reg16;
    signal somaA, somaB, soma: std_logic_vector(15 downto 0); -- 17 bits
    signal cout, overflow: std_logic;
    signal cin: std_logic;
begin

  --  conexao do registrador ir ao sinal de saida 'instrucao'
  instrucao <= ir;

  --
  --  registradores do bloco de dados: banco, pc, sp, ir, rA, rB, rula
  --
  REGS: bcregs port map( ck=>ck, rst=>rst, wreg=>uins.wreg, rs2=>uins.ms2,
                         ir=>ir, inREG=> dtreg, source1=>s1, source2=>s2);

  RPC:      registrador port map(ck=>ck, rst=>rst, ce=>uins.wpc,   d=>dtpc,   q=>pc );
                                                                                           
  RSP:      registrador port map(ck=>ck, rst=>rst, ce=>uins.wsp,   d=>dtsp,   q=>sp );

  RIR:      registrador port map(ck=>ck, rst=>rst, ce=>uins.wir,   d=>dataIN, q=>ir );

  REG_A:    registrador port map(ck=>ck, rst=>rst, ce=>uins.wab,   d=>s1,     q=>rA );

  REG_B:    registrador port map(ck=>ck, rst=>rst, ce=>uins.wab,   d=>s2,     q=>rB );

  REG_ULA:  registrador port map(ck=>ck, rst=>rst, ce=>uins.wula,  d=>outula, q=>rula );
  
  -- flags de estado
  process (ck, rst)
   begin
     if rst = '1' then
           flag <= (others => '0');
     elsif ck'event and ck = '0' then
         
        if uins.wnz='1' then
           flag(0) <= outula(15);       -- flag nevativo
           flag(1) <= is_zero(outula);  
        end if;
        
        if uins.wcv='1' then
           flag(2) <= cout;      
           flag(3) <= overflow;   
        end if; 
             
     end if;
  end process;

  --
  --  multiplexadores
  --
  dtpc <= rula   when uins.mpc = "01" else       -- selecao  de operando para o registrador PC
          dataIN when uins.mpc = "00" else
          pc     when uins.mpc = "11" else       
		  pc+1 ;                                 -- por default o PC e´ incrementado;
                                        
  dtsp <= sp-1 when uins.msp = '1' else        -- selecao  de operando para o registrador SP
          rula;

  endereco  <=      rula  when uins.mad = "00" else  -- selecao de quem endereca a RAM
               pc    when uins.mad = "01" else
               sp;

  opA <= ir     when uins.ma = '1' else ra;     -- operando A para a ULA   
      
  opB <= sp     when uins.mb = "01" else    -- operando B para a ULA, ou memria
         pc     when uins.mb = "10" else 
         rb;    

  dtreg <= dataIN when uins.mreg = '1' else rula; -- selecao do conteudo que sera escrito no banco de registradores
      
  -- moraes 21/marco - mux para o dado de saida - tinha furo!    
  dataOUT <=  s2 when ir(15 downto 12)="1010" else opB;
	  
  ---
  ---  ULA - operacoes so' dependem da instrucao corrente (decodificada no bloco de controle)
  ---

  somaA <= "00000000" & opA(7 downto 0)       when uins.ula=addi else
           not ("00000000" & opA(7 downto 0)) when uins.ula=subi else           
           opA(11) & opA(11) & opA(11) & opA(11) & opA(11 downto 0)            when  uins.ula=jsrd else
           opA(9) & opA(9) & opA(9) & opA(9) & opA(9) & opA(9)& opA(9 downto 0) when uins.ula=saltoD else
           opA; -- add, sub, ld, st
           
  somaB <= not opB  when uins.ula=sub  else
           opB; 
           
  --soma <= somaA + somaB;
  --cout <= soma(16);
  --overflow <= '0';
  
  cin <= '1' when uins.ula=sub or uins.ula=subi else '0';
  somaAB( somaA, somaB, cin, soma, cout, overflow); 
  
  outula <= opA and opB                        when uins.ula = e   else  
            opA or  opB                        when uins.ula = ou  else   
            opA xor opB                        when uins.ula = oux else  
            opB(15 downto 8) & opA(7 downto 0) when uins.ula = ldl else
            opA(7 downto 0)  & opB(7 downto 0) when uins.ula = ldh else
--            opA(14 downto 0) & '0'             when uins.ula = sl0 else
--            opA(14 downto 0) & '1'             when uins.ula = sl1 else
--            '0' & opA(15 downto 1)             when uins.ula = sr0 else
--            '1' & opA(15 downto 1)             when uins.ula = sr1 else
             not opA                           when uins.ula = notA  else 
             opB + 1                           when uins.ula = rts or uins.ula=pop else  
             RA                                when uins.ula = salto or uins.ula=jsr  or uins.ula=ldsp else      
             soma;     -- por default o resultado da ULA é a soma 
--             soma(15 downto 0);     -- por default o resultado da ULA é a soma 
    
end datapath;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--  Descricao do bloco de controle
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_unsigned.all;
use work.R8Package.all;
entity blocoControle is
      port (uins:     out microinstrucao;
            rst,ck:   in std_logic;
            flag:     in reg4;
            ir:       in reg16;
            waitR8_c: in std_logic;
            haltR8_c: out std_logic);
end;

architecture blocoControle of blocoControle is

  type type_state  is (repouso, Sfetch, Srreg,  Shalt, Sula,  Spop,  Sldsp, 
                     Srts,    Sld,     Sst,    Swbk,   Sjmp,  Ssbrt, Spush);   -- 14 estados
                     
  signal EA, PE :  type_state;

  signal fn, fz, fc, fv, inst_la1, inst_la2:  std_logic;
  signal i : instrucao;
  
begin
   
   fn <= flag(0);           --- flags de estado
   fz <= flag(1);
   fc <= flag(2);
   fv <= flag(3);
   
  ----------------------------------------------------------------------------------------
  -- BLOCO (1/3) - DECODIFICAÇÃO DAS INSTRUÇÕES
  ----------------------------------------------------------------------------------------
  i <= add   when ir(15 downto 12)=0  else
       sub   when ir(15 downto 12)=1  else
       e     when ir(15 downto 12)=2  else
       ou    when ir(15 downto 12)=3  else
       oux   when ir(15 downto 12)=4  else
       addi  when ir(15 downto 12)=5  else
       subi  when ir(15 downto 12)=6  else
       ldl   when ir(15 downto 12)=7  else
       ldh   when ir(15 downto 12)=8  else
       ld    when ir(15 downto 12)=9  else
       st    when ir(15 downto 12)=10 else
       sl0   when ir(15 downto 12)=11 and ir(3 downto 0)=0  else
       sl1   when ir(15 downto 12)=11 and ir(3 downto 0)=1  else
       sr0   when ir(15 downto 12)=11 and ir(3 downto 0)=2  else
       sr1   when ir(15 downto 12)=11 and ir(3 downto 0)=3  else
       notA  when ir(15 downto 12)=11 and ir(3 downto 0)=4  else
       nop   when ir(15 downto 12)=11 and ir(3 downto 0)=5  else
       halt  when ir(15 downto 12)=11 and ir(3 downto 0)=6  else
       ldsp  when ir(15 downto 12)=11 and ir(3 downto 0)=7  else
       rts   when ir(15 downto 12)=11 and ir(3 downto 0)=8  else
       pop   when ir(15 downto 12)=11 and ir(3 downto 0)=9  else
       push  when ir(15 downto 12)=11 and ir(3 downto 0)=10 else 
               
       -- instrucoes de salto (jump)  ** AQUI TESTAMOS OS FLAGS DE ESTADO PARA SALTAR OU NÃO *************

       saltoR when ir(15 downto 12)=12 and  ( ir(3 downto 0)=0 or 
                   (ir(3 downto 0)=1 and fn='1') or (ir(3 downto 0)=2 and fz='1') or 
                   (ir(3 downto 0)=3 and fc='1') or (ir(3 downto 0)=4 and fv='1') )   else 
                   
       salto  when ir(15 downto 12)=12 and  ( ir(3 downto 0)=5 or 
                   (ir(3 downto 0)=6 and fn='1') or (ir(3 downto 0)=7 and fz='1') or 
                   (ir(3 downto 0)=8 and fc='1') or (ir(3 downto 0)=9 and fv='1') )   else 

                   
       saltoD  when ir(15 downto 12)=13 or ( ir(15 downto 12)=14 and  
                   ( (ir(11 downto 10)=0 and fn='1') or (ir(11 downto 10)=1 and fz='1') or 
                     (ir(11 downto 10)=2 and fc='1') or (ir(11 downto 10)=3 and fv='1') ) )  else 
                   
       jsrr  when ir(15 downto 12)=12 and ir(3 downto 0)=10 else
       jsr   when ir(15 downto 12)=12 and ir(3 downto 0)=11 else
       jsrd  when ir(15 downto 12)=15 else
       
       nop ;  ------- IMPORTANTE condição default caso os flags forem '1';
        
  uins.ula <= i;       --- ************ operacao que a ula ira' executar

  -- instrucoes logico_aritmeticas (la) do tipo 1:
  inst_la1 <= '1' when i=add or i=sub or i=e or i=ou or i=oux or i=notA or i=sl0 or i=sr0 or i=sl1 or i=sr1 else
              '0';

  -- instrucoes logico_aritmeticas (la) do tipo 2 (rt esta´ no lado direito da expressao):
  inst_la2 <= '1' when i=addi or i=subi or i=ldl or i=ldh else
              '0'; 
              
  ----------------------------------------------------------------------------------------
  -- BLOCO (2/3) -  controle dos 7 (sete) multiplexadores
  ----------------------------------------------------------------------------------------

  uins.mpc <= --"11" when waitR8_c='1' or EA=repouso
  			  "11" when (waitR8_c='1' or EA=repouso) and EA/=Srts and EA/=Ssbrt else
              "10" when EA=Srreg  else      ------------ incrrementa PC no estado Sreg
              "00" when EA=Srts   else
              "01";                     -- da ULA

  uins.msp <= '1' when  i=jsrr or i=jsr or i=jsrd or i=push else  '0';  -- pos-decremento
              

  uins.mad <= "10" when EA=Spush or  EA=Ssbrt else  -- subrotina SP endereca
              "01" when EA=Sfetch else              -- na busca o PC endereca
              "00";                                 -- por default: LD/ST

  -- escreve nos registradores o conteudo vindo da memoria
  uins.mreg <= '1' when i=ld or i=pop else '0';
       
  -- o segundo fonte (source2) recebe o endereco do reg. destino quando for 
  -- uma operacao log_arimetica do tipo 2, push ou operacao de escrita na memoria, 
  -- pois deve-se enviar o conteudo do reg. para a RAM
  uins.ms2 <= '1' when inst_la2='1' or i=push or EA=Sst else '0';
 
  -- primeiro operando da ULA e' o IR quando for operacao log_arimetica do tipo 2 ou
  -- jump/jsr com deslocamento curto
  uins.ma <= '1' when inst_la2='1' or i=saltoD or i=jsrd else '0';   

  uins.mb <= "01"  when  i=rts or i=pop   else      -- para incrementar o SP
             "10"  when  i=saltoR or i=salto or i=saltoD or i=jsrr or i=jsr or i=jsrd  else -- em jumps/jsr o PC sera´ o segundo operando da ULA
             "00" ;      

  haltR8_c <= '1' when EA =Shalt else 
              '0';
  
  ---------------------------------------------------------------------------------------------
  -- BLOCO (3/3) -  MAQUINA DE ESTADOS DE CONTROLE - gera os comandos de escrita e acesso à RAM
  --------------------------------------------------------------------------------------------- 
  --uins.wpc  <= '1' when EA=Srreg or EA=Sjmp or EA=Ssbrt or EA=Srts                else '0';
  uins.wpc  <= '1' when EA=Srreg or EA=Sjmp or(EA=Ssbrt and waitR8_c='1') or EA=Srts else '0';
  --uins.wsp  <= '1' when EA=Sldsp or EA=Srts or EA=Ssbrt or EA=Spush or EA=Spop else '0';
  uins.wsp  <= '1' when EA=Sldsp or EA=Srts or (EA=Ssbrt and waitR8_c='1') or (EA=Spush and waitR8_c='1') or EA=Spop else '0';
  uins.wir  <= '1' when EA=Sfetch                                                  else '0';
  uins.wab  <= '1' when EA=Srreg                                                   else '0';
  uins.wula <= '1' when EA=Sula                                                    else '0';
  uins.wreg <= '1' when EA=Swbk  or EA=Sld   or EA=Spop                            else '0';
  uins.wnz  <= '1' when EA=Sula and (inst_la1='1' or  i=addi or i=subi)            else '0';
  uins.wcv  <= '1' when EA=Sula and (i=add or i=addi or i=sub or i=subi)           else '0';
  
      ---  IMPORTANTE !!!!!!!!!!!!!
  uins.ce<='1' when rst='0' and (EA=Sfetch or EA=Srts or EA=Spop or EA=Sld or EA=Ssbrt or EA=Spush or EA=Sst) else '0';
  uins.rw<='1' when EA=Sfetch or EA=Srts or EA=Spop or EA=Sld else '0';
  
  process(rst, ck, waitR8_c)
   begin
      if rst='1' then
            EA <= repouso;
      elsif ck'event and ck='1' then 
			if waitR8_c='0' then
            	EA <= PE;
			end if;
      end if;
  end process;
  
  process(EA,i,waitR8_c,inst_la1, inst_la2)     -- PROXIMO estado:  depende do ESTADO ATUAL e da INSTRUCAO CORRENTE
   begin

    case EA is
                 
     when  repouso =>  if waitR8_c='0' then PE <=Sfetch; else PE<= repouso;	end if;
     
     --
     -- primeiro ciclo de clock
     --
     when Sfetch =>  if i=halt then     
                         PE <= Shalt;
                     else
                         PE <= Srreg;
                     end if;

     --
     -- segundo ciclo de clock
     --
     when Shalt  =>  PE <= Repouso;    

     when Srreg =>   PE <= Sula;

     --
     -- terceiro ciclo de clock - pode ir para 9 lugares diferentes
     --
     when Sula => if i=pop                                 then   PE <= Spop;
                    elsif i=rts                            then   PE <= Srts;
                    elsif i=ldsp                           then   PE <= Sldsp;
                    elsif i=ld                             then   PE <= Sld;
                    elsif i=st                             then   PE <= Sst;
                    elsif inst_la1='1' or inst_la2='1'     then   PE <= Swbk;
                    elsif i=saltoR or i=salto or i=saltoD  then   PE <= Sjmp;
                    elsif i=jsrr or i=jsr or i=jsrd        then   PE <= Ssbrt;
                    elsif i=push                           then   PE <= Spush;
                    else  PE <= Sfetch;   -- o nop/jumps com flag=0 executam em 3 ciclos ** ATENCAO **
                   end if;

     --
     -- quarto ciclo de clock: VOLTA PARA O FETCH
     -- 
     when Spop | Srts | Sldsp | Sld | Sst | Swbk | Sjmp | Ssbrt | Spush =>  PE <= Sfetch;
  
   end case;

  end process;

end blocoControle;

--------------------------------------------------------------------------
-- Uniao dos componentes da R8
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.R8Package.all;

entity processador is
      port( ck,rst:  in std_logic;
            dataIN:  in  reg16;
            dataOUT: out reg16;
            address: out reg16;
            ce,rw:   out std_logic;
            waitR8:  in std_logic;
            haltR8:  out std_logic);
end processador;

architecture processador of processador is

      component blocoControle
            port( uins:      out microinstrucao;
                  ck,rst:    in std_logic;
                  flag:      in reg4;
                  ir:        in reg16;
                  waitR8_c:  in std_logic;
                  haltR8_c:  out std_logic);                            
      end component;

      component datapath
            port( uins: in microinstrucao;
                  ck, rst, wt: in std_logic;
                  instrucao, endereco : out reg16;
                  dataIN:  in  reg16;
                  dataOUT: out reg16;
                  flag: out reg4 );
      end component;

      signal flag: reg4;
      signal uins: microinstrucao;
      signal ir: reg16;
                        
  begin
                
    dp: datapath   
         port map(uins=>uins, 
                  ck=>ck, 
                  wt => waitR8, 
                  rst=>rst,
                  instrucao=>ir,
                  endereco=>address,
                  dataIN=>dataIN, 
                  dataOUT=>dataOUT, 
                  flag=>flag);
                  
    ctrl: blocoControle 
          port map(uins=>uins, 
                   ck=>ck, 
                   rst=>rst, 
                   flag=>flag, 
                   ir=>ir,
                   waitR8_c=>waitR8,
                   haltR8_c=>haltR8);

    ce <= uins.ce;
    rw <= uins.rw;
          
end processador;
