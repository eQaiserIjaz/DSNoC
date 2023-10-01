-------------------------------------------------------------------------------
-- system_sysace_compactflash_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library axi_sysace_v1_01_a;
use axi_sysace_v1_01_a.all;

entity system_sysace_compactflash_wrapper is
  port (
    S_AXI_ACLK : in std_logic;
    S_AXI_ARESETN : in std_logic;
    S_AXI_AWADDR : in std_logic_vector(31 downto 0);
    S_AXI_AWVALID : in std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA : in std_logic_vector(31 downto 0);
    S_AXI_WSTRB : in std_logic_vector(3 downto 0);
    S_AXI_WVALID : in std_logic;
    S_AXI_WREADY : out std_logic;
    S_AXI_BRESP : out std_logic_vector(1 downto 0);
    S_AXI_BVALID : out std_logic;
    S_AXI_BREADY : in std_logic;
    S_AXI_ARADDR : in std_logic_vector(31 downto 0);
    S_AXI_ARVALID : in std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA : out std_logic_vector(31 downto 0);
    S_AXI_RRESP : out std_logic_vector(1 downto 0);
    S_AXI_RVALID : out std_logic;
    S_AXI_RREADY : in std_logic;
    SysACE_CLK : in std_logic;
    SysACE_MPIRQ : in std_logic;
    SysACE_MPD_I : in std_logic_vector(7 downto 0);
    SysACE_MPD_O : out std_logic_vector(7 downto 0);
    SysACE_MPD_T : out std_logic_vector(7 downto 0);
    SysACE_MPA : out std_logic_vector(6 downto 0);
    SysACE_CEN : out std_logic;
    SysACE_OEN : out std_logic;
    SysACE_WEN : out std_logic;
    SysACE_IRQ : out std_logic
  );

  attribute x_core_info : STRING;
  attribute x_core_info of system_sysace_compactflash_wrapper : entity is "axi_sysace_v1_01_a";

end system_sysace_compactflash_wrapper;

architecture STRUCTURE of system_sysace_compactflash_wrapper is

  component axi_sysace is
    generic (
      C_FAMILY : STRING;
      C_INSTANCE : STRING;
      C_BASEADDR : std_logic_vector;
      C_HIGHADDR : std_logic_vector;
      C_S_AXI_ADDR_WIDTH : INTEGER;
      C_S_AXI_DATA_WIDTH : INTEGER;
      C_MEM_WIDTH : INTEGER
    );
    port (
      S_AXI_ACLK : in std_logic;
      S_AXI_ARESETN : in std_logic;
      S_AXI_AWADDR : in std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
      S_AXI_AWVALID : in std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA : in std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      S_AXI_WSTRB : in std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1) downto 0);
      S_AXI_WVALID : in std_logic;
      S_AXI_WREADY : out std_logic;
      S_AXI_BRESP : out std_logic_vector(1 downto 0);
      S_AXI_BVALID : out std_logic;
      S_AXI_BREADY : in std_logic;
      S_AXI_ARADDR : in std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
      S_AXI_ARVALID : in std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA : out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      S_AXI_RRESP : out std_logic_vector(1 downto 0);
      S_AXI_RVALID : out std_logic;
      S_AXI_RREADY : in std_logic;
      SysACE_CLK : in std_logic;
      SysACE_MPIRQ : in std_logic;
      SysACE_MPD_I : in std_logic_vector((C_MEM_WIDTH-1) downto 0);
      SysACE_MPD_O : out std_logic_vector((C_MEM_WIDTH-1) downto 0);
      SysACE_MPD_T : out std_logic_vector((C_MEM_WIDTH-1) downto 0);
      SysACE_MPA : out std_logic_vector(6 downto 0);
      SysACE_CEN : out std_logic;
      SysACE_OEN : out std_logic;
      SysACE_WEN : out std_logic;
      SysACE_IRQ : out std_logic
    );
  end component;

begin

  SysACE_CompactFlash : axi_sysace
    generic map (
      C_FAMILY => "virtex6",
      C_INSTANCE => "SysACE_CompactFlash",
      C_BASEADDR => X"41800000",
      C_HIGHADDR => X"4180ffff",
      C_S_AXI_ADDR_WIDTH => 32,
      C_S_AXI_DATA_WIDTH => 32,
      C_MEM_WIDTH => 8
    )
    port map (
      S_AXI_ACLK => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_AWADDR => S_AXI_AWADDR,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WDATA => S_AXI_WDATA,
      S_AXI_WSTRB => S_AXI_WSTRB,
      S_AXI_WVALID => S_AXI_WVALID,
      S_AXI_WREADY => S_AXI_WREADY,
      S_AXI_BRESP => S_AXI_BRESP,
      S_AXI_BVALID => S_AXI_BVALID,
      S_AXI_BREADY => S_AXI_BREADY,
      S_AXI_ARADDR => S_AXI_ARADDR,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA => S_AXI_RDATA,
      S_AXI_RRESP => S_AXI_RRESP,
      S_AXI_RVALID => S_AXI_RVALID,
      S_AXI_RREADY => S_AXI_RREADY,
      SysACE_CLK => SysACE_CLK,
      SysACE_MPIRQ => SysACE_MPIRQ,
      SysACE_MPD_I => SysACE_MPD_I,
      SysACE_MPD_O => SysACE_MPD_O,
      SysACE_MPD_T => SysACE_MPD_T,
      SysACE_MPA => SysACE_MPA,
      SysACE_CEN => SysACE_CEN,
      SysACE_OEN => SysACE_OEN,
      SysACE_WEN => SysACE_WEN,
      SysACE_IRQ => SysACE_IRQ
    );

end architecture STRUCTURE;

