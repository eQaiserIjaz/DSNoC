-------------------------------------------------------------------------------
-- system_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_stub is
  port (
    SysACE_WEN : out std_logic;
    SysACE_OEN : out std_logic;
    SysACE_MPIRQ : in std_logic;
    SysACE_MPD : inout std_logic_vector(7 downto 0);
    SysACE_MPA : out std_logic_vector(6 downto 0);
    SysACE_CLK : in std_logic;
    SysACE_CEN : out std_logic;
    RS232_Uart_1_sout : out std_logic;
    RS232_Uart_1_sin : in std_logic;
    RESET : in std_logic;
    CLK_P : in std_logic;
    CLK_N : in std_logic
  );
end system_stub;

architecture STRUCTURE of system_stub is

  component system is
    port (
      SysACE_WEN : out std_logic;
      SysACE_OEN : out std_logic;
      SysACE_MPIRQ : in std_logic;
      SysACE_MPD : inout std_logic_vector(7 downto 0);
      SysACE_MPA : out std_logic_vector(6 downto 0);
      SysACE_CLK : in std_logic;
      SysACE_CEN : out std_logic;
      RS232_Uart_1_sout : out std_logic;
      RS232_Uart_1_sin : in std_logic;
      RESET : in std_logic;
      CLK_P : in std_logic;
      CLK_N : in std_logic
    );
  end component;

  attribute BUFFER_TYPE : STRING;
  attribute BOX_TYPE : STRING;
  attribute BUFFER_TYPE of SysACE_CLK : signal is "BUFGP";
  attribute BOX_TYPE of system : component is "user_black_box";

begin

  system_i : system
    port map (
      SysACE_WEN => SysACE_WEN,
      SysACE_OEN => SysACE_OEN,
      SysACE_MPIRQ => SysACE_MPIRQ,
      SysACE_MPD => SysACE_MPD,
      SysACE_MPA => SysACE_MPA,
      SysACE_CLK => SysACE_CLK,
      SysACE_CEN => SysACE_CEN,
      RS232_Uart_1_sout => RS232_Uart_1_sout,
      RS232_Uart_1_sin => RS232_Uart_1_sin,
      RESET => RESET,
      CLK_P => CLK_P,
      CLK_N => CLK_N
    );

end architecture STRUCTURE;

