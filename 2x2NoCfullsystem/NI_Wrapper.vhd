




library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;

library top_level_peripheral_v1_00_a;
use top_level_peripheral_v1_00_a.HermesPackage.all;
use top_level_peripheral_v1_00_a.ParameterPackage.all;



entity NI_Wrapper is

 generic
  ( 
    C_NUM_REG                      : integer              := 2;
    C_SLV_DWIDTH                   : integer              := 32   
  );
  port (
	Bus2NI_Clk        : in  std_logic;
	Bus2NI_Resetn     : in  std_logic;
	
	--from NI to router 
	rxLocNI       : in  std_logic;
	data_inLocNI  : in  regflit;
	ack_rxLocNI   : out std_logic;
	txLocNI       : out std_logic;
	data_outLocNI : out regflit;
	ack_txLocNI   : in  std_logic;
--	mux_latency2MB: in  integNORT; 
  -- mux_time2MB   : in  integNORT;
	
--	-- --from NI to AXI bus 	
    Bus2NI_Data                    : in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);  
    Bus2NI_BE                      : in  std_logic_vector(C_SLV_DWIDTH/8-1 downto 0);	
    Bus2NI_RdCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    Bus2NI_WrCE                    : in  std_logic_vector(C_NUM_REG-1 downto 0);
    NI2Bus_Data                    : out std_logic_vector(C_SLV_DWIDTH-1 downto 0);
    NI2Bus_RdAck                   : out std_logic;
    NI2Bus_WrAck                   : out std_logic
    --NI2Bus_Error                   : out std_logic
   );
   end entity NI_Wrapper;
   
   
   architecture arch_NI_wrapper of NI_Wrapper is
   
  signal slv_reg0                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg1                       : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_reg2                       : std_logic_vector(C_SLV_DWIDTH/2-1 downto 0);
  signal slv_reg3                       : std_logic_vector(C_SLV_DWIDTH/2-1 downto 0);
  signal slv_reg_write_sel              : std_logic_vector(1 downto 0);
  signal slv_reg_read_sel               : std_logic_vector(1 downto 0);
  signal slv_ip2bus_data                : std_logic_vector(C_SLV_DWIDTH-1 downto 0);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;
  
 
  begin
   ------------------------------------------
  slv_reg_write_sel <= Bus2NI_WrCE(1 downto 0);
  slv_reg_read_sel  <= Bus2NI_RdCE(1 downto 0);
  slv_write_ack     <= Bus2NI_WrCE(0) or Bus2NI_WrCE(1);
  slv_read_ack      <= Bus2NI_RdCE(0) or Bus2NI_RdCE(1);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2NI_Clk ) is
  begin

    if Bus2NI_Clk'event and Bus2NI_Clk = '1' then
      if Bus2NI_Resetn = '0' then
        slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
      else
        case slv_reg_write_sel is
          when "10" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2NI_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8+7 downto byte_index*8) <= Bus2NI_Data(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
          when "01" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2NI_BE(byte_index) = '1' ) then
                slv_reg1(byte_index*8+7 downto byte_index*8) <= Bus2NI_Data(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;
  
 send_to_router_PROC: process(Bus2NI_Clk, slv_reg_write_sel, slv_reg0, slv_reg0) is
  
  VARIABLE flit_state_pointer:INTEGER:=0;  
  VARIABLE total_flit_in_packet:INTEGER:=4;
  VARIABLE dest_address:INTEGER:=0;

  begin
  
  if Bus2NI_Clk'event and Bus2NI_Clk = '1' then
      if Bus2NI_Resetn = '0' then
        txLocNI <= '0';
        data_outLocNI <= (others => '0');
		flit_state_pointer:=0;
      else
        case slv_reg_write_sel is
          when "10" =>
			txLocNI <= '1'; 
			dest_address:=1;
			if (ack_txLocNI='1') then
			  data_outLocNI <= "00000000" & CONV_STD_LOGIC_VECTOR(total_flit_in_packet-2,TAM_FLIT/2);
			  data_outLocNI <= CONV_STD_LOGIC_VECTOR(total_flit_in_packet-2,TAM_FLIT);
			  data_outLocNI <= "00000000" & CONV_STD_LOGIC_VECTOR(dest_address,TAM_FLIT/2);
			  data_outLocNI <= slv_reg0(TAM_FLIT-1 downto 0);
			  data_outLocNI <= slv_reg0((2*TAM_FLIT)-1 downto TAM_FLIT);
            		
			end if;
			
          when "01" =>
					txLocNI <= '1'; 
					dest_address:=2;
				if ack_txLocNI='1' then			  
					data_outLocNI <= "00000000" & CONV_STD_LOGIC_VECTOR(total_flit_in_packet-2,TAM_FLIT/2);
					data_outLocNI <= CONV_STD_LOGIC_VECTOR(total_flit_in_packet-2,TAM_FLIT);
					data_outLocNI <= "00000000" & CONV_STD_LOGIC_VECTOR(dest_address,TAM_FLIT/2);
					data_outLocNI <= slv_reg1(TAM_FLIT-1 downto 0);
					data_outLocNI <= slv_reg1((2*TAM_FLIT)-1 downto TAM_FLIT);			
			end if;
          when others => null;
        end case;
      end if;
    end if;  
end process send_to_router_PROC;
  
 recieve_from_router_PROC: process(Bus2NI_Clk, data_inLocNI, rxLocNI ) is
  begin  
  if Bus2NI_Clk'event and Bus2NI_Clk = '1' then
      if Bus2NI_Resetn = '0' then
        ack_rxLocNI <= '0';
        slv_reg2 <=(others => '0');
		slv_reg3 <=(others => '0');
		--filt_pos:=0;
      else
		  if rxLocNI = '1' then
				ack_rxLocNI <= '1';		
				slv_reg2 <=data_inLocNI(TAM_FLIT-1 downto 0);
				slv_reg3 <=data_inLocNI(TAM_FLIT-1 downto 0);
			end if;
      end if; 
  end if;	 
end process recieve_from_router_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg2, slv_reg3 ) is
  begin

    case slv_reg_read_sel is
      when "10" => slv_ip2bus_data <= slv_reg2&slv_reg3;
      when "01" => slv_ip2bus_data <= slv_reg2&slv_reg3;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  NI2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  (others => '0');

  NI2Bus_WrAck <= slv_write_ack;
  NI2Bus_RdAck <= slv_read_ack;
  --NI2Bus_Error <= '0';
  
 
end arch_NI_wrapper;
  