--------------------------------------------------------------------------
-- package com tipos basicos
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.std_logic_unsigned.all;

package R8Package is  

---------------------------------------------------------
-- SUBTIPOS, TIPOS E FUNCOES
---------------------------------------------------------
	subtype reg4 is std_logic_vector(3 downto 0);
	subtype reg16 is std_logic_vector(15 downto 0);

----------------------------------------------------------------------------------
-- TIPOS E FUNCOES DO PROCESSADOR R8
----------------------------------------------------------------------------------
  -- indica o tipo de instrucao decodificada pela unidade de controle  -- 28 INSTRUÇÕES
  -- os 15 umps com flags resumem-se a três instruções: saltoR,salto, saltoD
 type instrucao is  
    ( add,  sub,  e,   ou,   oux,  addi,  subi,  ldl,   ldh,   ld,      st,    sl0,  sl1, sr0,  sr1,
      notA, nop, halt, ldsp, rts,  pop,   push,  saltoR, salto, saltoD, jsrr,  jsr, jsrd); 
  
  type microinstrucao is record
     mpc:   std_logic_vector(1 downto 0);  -- controle do mux de entrada do registrador PC
     msp:   std_logic;                     -- mux do sp (stack-pointer)
     mad:   std_logic_vector(1 downto 0);  -- mux para origem do endereco (AD) da memoria
     mreg:  std_logic;                     -- controle do dado que entra no banco de registradores
     ms2:   std_logic;                     -- origem do segundo registrador fonte (source2 - s2)
     ma:    std_logic;                     -- mux para a selecao do operando A na entrada da ULA
     mb:    std_logic_vector(1 downto 0);  -- mux para a selecao do operando B na entrada da ULA
     wpc:   std_logic;                     -- ENABLE para escrita em PC
     wsp:   std_logic;
     wir:   std_logic;
     wab:   std_logic;
     wula:  std_logic;
     wreg:  std_logic;  
     wnz:   std_logic;
     wcv:   std_logic;
     ce,rw: std_logic;                     -- Chip enable e R_Wnegado
     ula:   instrucao;
  end record;
         
  -- registrador de 16 bits, com reset e habilitacao de escrita
  component registrador
       port( ck,rst,ce:in std_logic;
             D:in  reg16;
             Q:out reg16 );
  end component;
  
  procedure somaAB  (  signal A,B: in  reg16;   signal Cin: in STD_LOGIC;
                       signal S:   out reg16;   signal Cout, Ov:out STD_LOGIC);
                       
  function is_zero  (  signal A:  in  reg16  ) return std_logic ;
  
end R8Package;

package body R8Package is
---------------------------------------------------------
-- FUNCAO E PROCESDURES DO PROCESSADOR R8
---------------------------------------------------------
  procedure somaAB  (  signal A,B: in  reg16;   signal Cin: in STD_LOGIC;
                       signal S:   out reg16;   signal Cout, Ov:out STD_LOGIC) is             
     variable cant, carry : STD_LOGIC;
  begin    
             for w in 0 to 15 loop
                  if w=0 then carry:=Cin;  end if;
                  S(w) <= A(w) xor B(w) xor carry;
                  cant  := carry;
                  carry := (A(w) and B(w)) or (A(w) and carry) or (B(w) and carry);
             end loop;
             Cout <= carry;
             Ov <= cant xor carry;
  end somaAB;
 
  function is_zero  (  signal A:  in  reg16  ) return std_logic is           
      begin     
             if A="0000000000000000" then return '1'; else return '0';  end if;
  end is_zero;

end R8Package;