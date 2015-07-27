----------------------------------------------------------------------------------
-- Company:          Univerity of Massachusetts 
-- Engineer:         Kevin Andryc
-- 
-- Create Date:      17:50:27 09/19/2010  
-- Module Name:      pipeline_write - arch 
-- Project Name:     GPGPU
-- Target Devices: 
-- Tool versions:    ISE 10.1
-- Description: 
--
----------------------------------------------------------------------------
-- Revisions:       
--  REV:        Date:           Description:
--  0.1.a       9/13/2010       Created Top level file 
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all ;  
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.gpgpu_package.all;

    entity pipeline_write is
        generic (
            CORE_ID                     : std_logic_vector(7 downto 0) := x"00";
            SHMEM_ADDR_SIZE             : integer := 14;
            CMEM_ADDR_SIZE              : integer := 18;
            LMEM_ADDR_SIZE              : integer := 16;
            GMEM_ADDR_SIZE              : integer := 18
        );
        port (
            reset                       : in  std_logic;
            clk_in                      : in  std_logic;
         
            en                          : in  std_logic;
            pipeline_stall_in           : in  std_logic;
            
            num_warps_in                : in  std_logic_vector(4 downto 0); 
            
            warp_id_in                  : in  std_logic_vector(4 downto 0);
            warp_lane_id_in             : in  std_logic_vector(1 downto 0);
            cta_id_in                   : in  std_logic_vector(3 downto 0);
            initial_mask_in             : in  std_logic_vector(31 downto 0);
            current_mask_in             : in  std_logic_vector(31 downto 0);
            shmem_base_addr_in          : in  std_logic_vector(SHMEM_ADDR_SIZE-1 downto 0);
            gprs_size_in                : in  std_logic_vector(8 downto 0);                   
            gprs_base_addr_in           : in  std_logic_vector(8 downto 0);
            next_pc_in                  : in  std_logic_vector(31 downto 0);
            warp_state_in               : in  warp_state_type;
                        
            instr_opcode_type_in        : in  instr_opcode_type;
            
            temp_vector_register_in     : in  temp_vector_register;
            dest_in                     : in  std_logic_vector(31 downto 0);
            instruction_mask_in         : in  std_logic_vector(31 downto 0);
            instruction_flags_in        : in  vector_flag_register;
            dest_data_type_in           : in  data_type;
            dest_mem_type_in            : in  mem_type;
            dest_mem_opcode_type_in     : in  mem_opcode_type;
            
            addr_hi_in                  : in  std_logic;
            addr_lo_in                  : in  std_logic_vector(1 downto 0);
            addr_imm_in                 : in  std_logic;
            addr_inc_in                 : in  std_logic;
            mov_size_in                 : in  std_logic_vector(2 downto 0);
            write_pred_in               : in  std_logic;
            set_pred_in                 : in  std_logic;
            set_pred_reg_in             : in  std_logic_vector(1 downto 0);
            sm_type_in						 : in  std_logic_vector(1 downto 0);
            
            src1_in                     : in  std_logic_vector(31 downto 0);
            
            gprs_base_addr_out          : out gprs_addr_array; 
            gprs_reg_num_out            : out gprs_reg_array;
            gprs_lane_id_out            : out warp_lane_id_array; 
            gprs_wr_en_out              : out wr_en_array;
            gprs_wr_data_out            : out vector_register;
            gprs_rd_data_in             : in  vector_register;
            
            pred_regs_warp_id_out       : out warp_id_array; 
            pred_regs_warp_lane_id_out  : out warp_lane_id_array;
            pred_regs_reg_num_out       : out reg_num_array;
            pred_regs_wr_en_out         : out wr_en_array;
            pred_regs_wr_data_out       : out vector_flag_register;
            pred_regs_rd_data_in        : in  vector_flag_register;
            
            addr_regs_warp_id_out       : out warp_id_array; 
            addr_regs_warp_lane_id_out  : out warp_lane_id_array;
            addr_regs_reg_num_out       : out reg_num_array;
            addr_regs_wr_en_out         : out wr_en_array;
            addr_regs_wr_data_out       : out vector_register;
            addr_regs_rd_data_in        : in  vector_register;
            
            shmem_addr_out              : out std_logic_vector(SHMEM_ADDR_SIZE-1 downto 0);
            shmem_wr_en_out             : out std_logic_vector(0 downto 0);
            shmem_wr_data_out           : out std_logic_vector(7 downto 0);
            shmem_rd_data_in            : in  std_logic_vector(7 downto 0);
            
            cmem_addr_out               : out std_logic_vector(CMEM_ADDR_SIZE-1 downto 0);
            cmem_wr_en_out              : out std_logic_vector(0 downto 0);
            cmem_wr_data_out            : out std_logic_vector(7 downto 0);
            cmem_rd_data_in             : in  std_logic_vector(7 downto 0);
            
            gmem_addr_out               : out std_logic_vector(GMEM_ADDR_SIZE-1 downto 0);
            gmem_wr_en_out              : out std_logic_vector(0 downto 0);
            gmem_wr_data_out            : out std_logic_vector(7 downto 0);
            gmem_rd_data_in             : in  std_logic_vector(7 downto 0);
            
            lmem_addr_out               : out std_logic_vector(LMEM_ADDR_SIZE-1 downto 0);
            lmem_wr_en_out              : out std_logic_vector(0 downto 0);
            lmem_wr_data_out            : out std_logic_vector(7 downto 0);
            lmem_rd_data_in             : in  std_logic_vector(7 downto 0);
            
            warp_id_out                 : out std_logic_vector(4 downto 0);
            warp_lane_id_out            : out std_logic_vector(1 downto 0);
            cta_id_out                  : out std_logic_vector(3 downto 0);
            initial_mask_out            : out std_logic_vector(31 downto 0);
            current_mask_out            : out std_logic_vector(31 downto 0);
            shmem_base_addr_out         : out std_logic_vector(SHMEM_ADDR_SIZE-1 downto 0);
            gprs_addr_out               : out std_logic_vector(8 downto 0);
            next_pc_out                 : out std_logic_vector(31 downto 0);
            warp_state_out              : out warp_state_type;
            
            -- stats
            stats_reset                 : in  std_logic;
            stats_out                   : out stat_record;
            
            pipeline_stall_out          : out std_logic;
            pipeline_reg_ld             : out std_logic;
				check_dest_reg					 : out std_logic_vector(8 downto 0);
				
				rd_en_fifo_in :  in STD_LOGIC;
				valid_fifo_out : out STD_LOGIC;
				dout_fifo_out : out std_logic_vector(31 downto 0);
				not_empty_out : out std_logic
        );   
    end pipeline_write;

architecture arch of pipeline_write is
    
	 COMPONENT fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    wr_ack : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC
  );
END COMPONENT;

    component convert_data_types
        port (
            mov_size_in                 : in  std_logic_vector(2 downto 0);
            conv_type_in                : in  conv_type;
            reg_type_in                 : in  reg_type;
			data_type_in                : in  data_type;
            sm_type_in                  : in  std_logic_vector(1 downto 0);
            mem_type_in                 : in  std_logic_vector(2 downto 0);
            
            mv_size_to_sm_type_out      : out sm_type;
			data_type_to_sm_type_out    : out sm_type;
            sm_type_to_sm_type_out      : out sm_type;
            mem_type_to_sm_type_out     : out sm_type;
            conv_type_to_reg_type_out   : out reg_type;
            reg_type_to_data_type_out   : out data_type;
            mv_size_to_data_type_out    : out data_type;
            conv_type_to_data_type_out  : out data_type;
            sm_type_to_data_type_out    : out data_type;
            mem_type_to_data_type_out   : out data_type;
            sm_type_to_cvt_type_out     : out conv_type;
            mem_type_to_cvt_type_out    : out conv_type
        );
    end component;
    
    component increment_address
        port (
			reset                               : in  std_logic;
			clk_in                              : in  std_logic;
			en						            : in  std_logic;
            
            addr_reg_in                         : in  std_logic_vector(1 downto 0);
            data_type_in                        : in  data_type;
            mask_in                             : in  std_logic_vector(CORES-1 downto 0);
            imm_in                              : in  std_logic_vector(31 downto 0);
            
            addr_regs_en_out                    : out std_logic;
            addr_regs_reg_num_out               : out std_logic_vector(1 downto 0);
            addr_regs_wr_data_out               : out vector_register;
            addr_regs_mask_out                  : out std_logic_vector(CORES-1 downto 0);
            addr_regs_rd_wr_en_out              : out std_logic;
            addr_regs_rd_data_in                : in  vector_register;
            addr_regs_rdy_in                    : in  std_logic;
            
            rdy_out                             : out std_logic
            
        );
    end component;
    
    component compute_pred_flags
        port (
			reset                               : in  std_logic;
			clk_in                              : in  std_logic;
			en						            : in  std_logic;
            
			data_in                             : in  vector_register;
            flags_in                            : in  vector_flag_register;
            data_type_in                        : in  data_type;
            
            flags_out                           : out vector_flag_register;
            
            rdy_out                             : out std_logic
        );
    end component;
    
    component vector_register_controller
        port (
            reset                   : in  std_logic;
            clk_in                  : in  std_logic;
            en                      : in  std_logic;
            
            lane_id_in              : in  std_logic_vector(1 downto 0); 
            base_addr_in            : in  std_logic_vector(8 downto 0);
            reg_num_in              : in  std_logic_vector(8 downto 0);
            data_in                 : in  vector_word_register_array;
            data_type_in            : in  data_type;
            mask_in                 : in  std_logic_vector(CORES-1 downto 0);
            rd_wr_en_in             : in  std_logic;
            
            gprs_base_addr_out      : out gprs_addr_array; 
            gprs_reg_num_out        : out gprs_reg_array;
            gprs_lane_id_out        : out warp_lane_id_array; 
            gprs_wr_en_out          : out wr_en_array;
            gprs_wr_data_out        : out vector_register;
            gprs_rd_data_in         : in  vector_register;
            
            data_out                : out vector_word_register_array;
            
            rdy_out                 : out std_logic
        );
    end component;
    
    component predicate_register_controller
        port (
            reset                       : in  std_logic;
            clk_in                      : in  std_logic;
            en                          : in  std_logic;
            
            warp_id_in                  : in  std_logic_vector(4 downto 0); 
            lane_id_in                  : in  std_logic_vector(1 downto 0); 
            reg_num_in                  : in  std_logic_vector(1 downto 0);
            data_in                     : in  vector_flag_register;
            mask_in                     : in  std_logic_vector(CORES-1 downto 0);
            rd_wr_en_in                 : in  std_logic;
            
            pred_regs_warp_id_out       : out warp_id_array; 
            pred_regs_warp_lane_id_out  : out warp_lane_id_array;
            pred_regs_reg_num_out       : out reg_num_array;
            pred_regs_wr_en_out         : out wr_en_array;
            pred_regs_wr_data_out       : out vector_flag_register;
            pred_regs_rd_data_in        : in  vector_flag_register;
            
            data_out                    : out vector_flag_register;
            
            rdy_out                     : out std_logic
        );
    end component;
    
    component address_register_controller
        port (
            reset                       : in  std_logic;
            clk_in                      : in  std_logic;
            en                          : in  std_logic;
            
            warp_id_in                  : in  std_logic_vector(4 downto 0); 
            lane_id_in                  : in  std_logic_vector(1 downto 0); 
            reg_num_in                  : in  std_logic_vector(1 downto 0);
            data_in                     : in  vector_register;
            mask_in                     : in  std_logic_vector(CORES-1 downto 0);
            rd_wr_en_in                 : in  std_logic;
            
            addr_regs_warp_id_out       : out warp_id_array; 
            addr_regs_warp_lane_id_out  : out warp_lane_id_array;
            addr_regs_reg_num_out       : out reg_num_array;
            addr_regs_wr_en_out         : out wr_en_array;
            addr_regs_wr_data_out       : out vector_register;
            addr_regs_rd_data_in        : in  vector_register;
            
            data_out                    : out vector_register;
            
            rdy_out                     : out std_logic
        );
    end component;
    
    component shared_memory_controller
		generic (
            ADDRESS_SIZE                : integer := 32;
            ARB_GPRS_EN                 : std_logic := '0';
            ARB_ADDR_REGS_EN            : std_logic := '0'
        );
		port (
			reset                       : in  std_logic;
			clk_in                      : in  std_logic;
			en						   	: in  std_logic;
            
            data_in                     : in  vector_word_register_array;
            base_addr_in                : in  std_logic_vector(ADDRESS_SIZE-1 downto 0);
			addr_in						: in  std_logic_vector(31 downto 0);
			mask_in                     : in  std_logic_vector(CORES-1 downto 0);
            rd_wr_type_in               : in  mem_opcode_type;
            sm_type_in					: in  sm_type;
            
			addr_lo_in					: in  std_logic_vector(1 downto 0);
			addr_hi_in					: in  std_logic;
			addr_imm_in					: in  std_logic;
			
            gprs_req_out                : out std_logic;
            gprs_ack_out                : out std_logic;
            gprs_grant_in               : in  std_logic;
            
            gprs_en_out                 : out std_logic;
            gprs_reg_num_out            : out std_logic_vector(8 downto 0);
            gprs_data_type_out          : out data_type;
            gprs_mask_out               : out std_logic_vector(CORES-1 downto 0);
            gprs_rd_wr_en_out           : out std_logic;
            gprs_rd_data_in             : in  vector_word_register_array;
            gprs_rdy_in                 : in  std_logic;
            
            addr_regs_req_out           : out std_logic;
            addr_regs_ack_out           : out std_logic;
            addr_regs_grant_in          : in  std_logic;
            
            addr_regs_en_out            : out std_logic;
            addr_regs_reg_out           : out std_logic_vector(1 downto 0);
            addr_regs_mask_out          : out std_logic_vector(CORES-1 downto 0);
            addr_regs_rd_wr_en_out      : out std_logic;
            addr_regs_rd_data_in        : in  vector_register;
            addr_regs_rdy_in            : in  std_logic;
            
            shmem_addr_out              : out std_logic_vector(ADDRESS_SIZE-1 downto 0);
            shmem_wr_en_out             : out std_logic_vector(0 downto 0);
            shmem_wr_data_out           : out std_logic_vector(7 downto 0);
            shmem_rd_data_in            : in  std_logic_vector(7 downto 0);
            
			data_out			        : out vector_word_register_array;
			rdy_out		                : out std_logic
		);
	end component;
    
    component global_memory_controller
		generic (
            ADDRESS_SIZE                : integer := 32;
            ARB_GPRS_EN                 : std_logic := '0';
            ARB_ADDR_REGS_EN            : std_logic := '0'
        );
		port (
			reset                       : in  std_logic;
			clk_in                      : in  std_logic;
			en						    : in  std_logic;
			
            data_in                     : in  vector_word_register_array;
			addr_in						: in  std_logic_vector(31 downto 0);
			mask_in                     : in  std_logic_vector(CORES-1 downto 0);
            rd_wr_type_in               : in  mem_opcode_type;
            data_type_in			    : in  data_type;
            
			addr_lo_in					: in  std_logic_vector(1 downto 0);
			addr_hi_in					: in  std_logic;
			addr_imm_in					: in  std_logic;
			
            gprs_req_out                : out std_logic;
            gprs_ack_out                : out std_logic;
            gprs_grant_in               : in  std_logic;
            
            gprs_en_out                 : out std_logic;
            gprs_reg_num_out            : out std_logic_vector(8 downto 0);
            gprs_data_type_out          : out data_type;
            gprs_mask_out               : out std_logic_vector(CORES-1 downto 0);
            gprs_rd_wr_en_out           : out std_logic;
            gprs_rd_data_in             : in  vector_word_register_array;
            gprs_rdy_in                 : in  std_logic;
            
            addr_regs_req_out           : out std_logic;
            addr_regs_ack_out           : out std_logic;
            addr_regs_grant_in          : in  std_logic;
            
            addr_regs_en_out            : out std_logic;
            addr_regs_reg_out           : out std_logic_vector(1 downto 0);
            addr_regs_mask_out          : out std_logic_vector(CORES-1 downto 0);
            addr_regs_rd_wr_en_out      : out std_logic;
            addr_regs_rd_data_in        : in  vector_register;
            addr_regs_rdy_in            : in  std_logic;
            
            gmem_addr_out               : out std_logic_vector(ADDRESS_SIZE-1 downto 0);
            gmem_wr_en_out              : out std_logic_vector(0 downto 0);
            gmem_wr_data_out            : out std_logic_vector(7 downto 0);
            gmem_rd_data_in             : in  std_logic_vector(7 downto 0);
            
			data_out			        : out vector_word_register_array;
			rdy_out		                : out std_logic
		);
	end component;
    
    component local_memory_controller
		generic (
            ADDRESS_SIZE                : integer := 32;
            ARB_GPRS_EN                 : std_logic := '0';
            ARB_ADDR_REGS_EN            : std_logic := '0'
        );
		port (
			reset                       : in  std_logic;
			clk_in                      : in  std_logic;
			en						    : in  std_logic;
			
            core_id_in                  : in  std_logic_vector(7 downto 0); 
            num_warps_in                : in  std_logic_vector(4 downto 0); 
            warp_id_in                  : in  std_logic_vector(4 downto 0);
            warp_lane_id_in             : in  std_logic_vector(1 downto 0);
            
            data_in                     : in  vector_word_register_array;
            addr_in						: in  std_logic_vector(31 downto 0);
			mask_in                     : in  std_logic_vector(7 downto 0);
            rd_wr_type_in               : in  mem_opcode_type;
            data_type_in			    : in  data_type;
            
			addr_lo_in					: in  std_logic_vector(1 downto 0);
			addr_hi_in					: in  std_logic;
			addr_imm_in					: in  std_logic;
			
            gprs_req_out                : out std_logic;
            gprs_ack_out                : out std_logic;
            gprs_grant_in               : in  std_logic;
            
            gprs_en_out                 : out std_logic;
            gprs_reg_num_out            : out std_logic_vector(8 downto 0);
            gprs_data_type_out          : out data_type;
            gprs_mask_out               : out std_logic_vector(CORES-1 downto 0);
            gprs_rd_wr_en_out           : out std_logic;
            gprs_rd_data_in             : in  vector_word_register_array;
            gprs_rdy_in                 : in  std_logic;
            
            addr_regs_req_out           : out std_logic;
            addr_regs_ack_out           : out std_logic;
            addr_regs_grant_in          : in  std_logic;
            
            addr_regs_en_out            : out std_logic;
            addr_regs_reg_out           : out std_logic_vector(1 downto 0);
            addr_regs_mask_out          : out std_logic_vector(CORES-1 downto 0);
            addr_regs_rd_wr_en_out      : out std_logic;
            addr_regs_rd_data_in        : in  vector_register;
            addr_regs_rdy_in            : in  std_logic;
            
            lmem_addr_out               : out std_logic_vector(ADDRESS_SIZE-1 downto 0);
            lmem_wr_en_out              : out std_logic_vector(0 downto 0);
            lmem_wr_data_out            : out std_logic_vector(7 downto 0);
            lmem_rd_data_in             : in  std_logic_vector(7 downto 0);
            
			data_out			        : out vector_word_register_array;
			rdy_out		                : out std_logic
		);
	end component;
    
    type write_state_type is (IDLE, WRITE_GPRS, WRITE_SHMEM, WRITE_GMEM, WRITE_LMEM, WRITE_ADDR, CHECK_PRED_REGS, COMPUTE_PRED_REGS, WRITE_PRED_REGS, CHECK_INCREMENT_ADDR, INCREMENT_ADDR, DONE);
	 type mailbox_state_type is (IDLE, DATA_INIT, WRITE_EN, WRITE_DIS, READ_EN, DONE);
    signal write_state_machine              	: write_state_type;
	 signal mailbox_state_machine					: mailbox_state_type;
    signal write_state_machine_cs               : std_logic_vector(3 downto 0);
    
    signal num_warps_i                          : std_logic_vector(4 downto 0); 
    signal warp_id_i                            : std_logic_vector(4 downto 0); 
    signal warp_lane_id_i                       : std_logic_vector(1 downto 0);
    signal cta_id_i                             : std_logic_vector(3 downto 0);
    signal initial_mask_i                       : std_logic_vector(31 downto 0);
    signal current_mask_i                       : std_logic_vector(31 downto 0);
    signal shmem_base_addr_i                    : std_logic_vector(SHMEM_ADDR_SIZE-1 downto 0);
    signal gprs_size_i                          : std_logic_vector(8 downto 0);                   
    signal base_addr_i                          : std_logic_vector(8 downto 0); 
    signal next_pc_i                            : std_logic_vector(31 downto 0);
    signal warp_state_i                         : warp_state_type;
    
--    signal addr_reg_i                           : std_logic_vector(1 downto 0); 
    signal mov_size_i                           : std_logic_vector(2 downto 0); 
    
    signal addr_imm_i                           : std_logic;
    signal addr_regs_sel                        : std_logic;
    
    signal inc_addr_en_i                        : std_logic;
    signal inc_addr_reg_i                       : std_logic_vector(1 downto 0);
    signal inc_addr_data_type_i                 : data_type;
    signal inc_addr_mask_i                      : std_logic_vector(CORES-1 downto 0); 
    signal inc_addr_imm_i                       : std_logic_vector(31 downto 0); 
    signal inc_addr_rdy_o                       : std_logic;
    
    signal compute_pred_en_i                    : std_logic;
    signal compute_pred_data_i                  : vector_register;
    signal compute_pred_flags_i                 : vector_flag_register;
    signal compute_pred_data_type_i             : data_type;
    signal compute_pred_flags_o                 : vector_flag_register;
    signal compute_pred_rdy_o                   : std_logic;
    
    signal gprs_en_i                            : std_logic;
    signal gprs_reg_num_i                       : std_logic_vector(8 downto 0); 
    signal gprs_wr_data_i                       : vector_word_register_array;
    signal gprs_data_type_i                     : data_type;
    signal gprs_mask_i                          : std_logic_vector(CORES-1 downto 0); 
    signal gprs_rd_wr_en_i                      : std_logic;
    signal gprs_rd_data_o                       : vector_word_register_array;
    signal gprs_rdy_o                           : std_logic;
    
    signal write_gprs_en                        : std_logic;
    signal write_gprs_reg_num                   : std_logic_vector(8 downto 0);
    signal write_gprs_wr_data                   : vector_word_register_array;
	 signal mailbox_gprs_wr_data						: vector_word_register_array;
    signal write_gprs_data_type                 : data_type;
    signal write_gprs_mask                      : std_logic_vector(CORES-1 downto 0);
    signal write_gprs_rd_wr_en                  : std_logic;
    signal write_gprs_rd_data                   : vector_word_register_array;
    signal write_gprs_rdy                       : std_logic;
    
    signal shmem_gprs_en                        : std_logic;
    signal shmem_gprs_en_reg                    : std_logic;
    signal shmem_gprs_reg_num                   : std_logic_vector(8 downto 0);
    signal shmem_gprs_wr_data                   : vector_word_register_array;
    signal shmem_gprs_data_type                 : data_type;
    signal shmem_gprs_mask                      : std_logic_vector(CORES-1 downto 0);
    signal shmem_gprs_rd_wr_en                  : std_logic;
    signal shmem_gprs_rd_data                   : vector_word_register_array;
    signal shmem_gprs_rdy                       : std_logic;
    
    signal gmem_gprs_en                         : std_logic;
    signal gmem_gprs_en_reg                    : std_logic;
    signal gmem_gprs_reg_num                    : std_logic_vector(8 downto 0);
    signal gmem_gprs_wr_data                    : vector_word_register_array;
    signal gmem_gprs_data_type                  : data_type;
    signal gmem_gprs_mask                       : std_logic_vector(CORES-1 downto 0);
    signal gmem_gprs_rd_wr_en                   : std_logic;
    signal gmem_gprs_rd_data                    : vector_word_register_array;
    signal gmem_gprs_rdy                        : std_logic;
    
    signal lmem_gprs_en                         : std_logic;
    signal lmem_gprs_en_reg                     : std_logic;
    signal lmem_gprs_reg_num                    : std_logic_vector(8 downto 0);
    signal lmem_gprs_wr_data                    : vector_word_register_array;
    signal lmem_gprs_data_type                  : data_type;
    signal lmem_gprs_mask                       : std_logic_vector(CORES-1 downto 0);
    signal lmem_gprs_rd_wr_en                   : std_logic;
    signal lmem_gprs_rd_data                    : vector_word_register_array;
    signal lmem_gprs_rdy                        : std_logic;
    
    signal addr_regs_en_i                       : std_logic;
    signal addr_regs_reg_num_i                  : std_logic_vector(1 downto 0);
    signal addr_regs_wr_data_i                  : vector_register;
    signal addr_regs_mask_i                     : std_logic_vector(CORES-1 downto 0); 
    signal addr_regs_rd_wr_en_i                 : std_logic;
    signal addr_regs_rd_data_o                  : vector_register;
    signal addr_regs_rdy_o                      : std_logic;
    
    signal write_addr_regs_en                   : std_logic;
    signal write_addr_regs_reg_num              : std_logic_vector(1 downto 0); 
    signal write_addr_regs_wr_data              : vector_register;
    signal write_addr_regs_mask                 : std_logic_vector(CORES-1 downto 0); 
    signal write_addr_regs_rd_wr_en             : std_logic;
    signal write_addr_regs_rd_data              : vector_register;
    signal write_addr_regs_rdy                  : std_logic;
    
    signal inc_addr_regs_en                     : std_logic;
    signal inc_addr_regs_reg_num                : std_logic_vector(1 downto 0);
    signal inc_addr_regs_wr_data                : vector_register;
    signal inc_addr_regs_mask                   : std_logic_vector(CORES-1 downto 0);
    signal inc_addr_regs_rd_wr_en               : std_logic;
    signal inc_addr_regs_rd_data                : vector_register;
    signal inc_addr_regs_rdy                    : std_logic;
    
    signal shmem_addr_regs_en                   : std_logic;
    signal shmem_addr_regs_reg_num              : std_logic_vector(1 downto 0);
    signal shmem_addr_regs_wr_data              : vector_register;
    signal shmem_addr_regs_mask                 : std_logic_vector(CORES-1 downto 0);
    signal shmem_addr_regs_rd_wr_en             : std_logic;
    signal shmem_addr_regs_rd_data              : vector_register;
    signal shmem_addr_regs_rdy                  : std_logic;
    
    signal gmem_addr_regs_en                    : std_logic;
    signal gmem_addr_regs_reg_num               : std_logic_vector(1 downto 0);
    signal gmem_addr_regs_wr_data               : vector_register;
    signal gmem_addr_regs_mask                  : std_logic_vector(CORES-1 downto 0);
    signal gmem_addr_regs_rd_wr_en              : std_logic;
    signal gmem_addr_regs_rd_data               : vector_register;
    signal gmem_addr_regs_rdy                   : std_logic;
    
    signal lmem_addr_regs_en                    : std_logic;
    signal lmem_addr_regs_reg_num               : std_logic_vector(1 downto 0);
    signal lmem_addr_regs_wr_data               : vector_register;
    signal lmem_addr_regs_mask                  : std_logic_vector(CORES-1 downto 0);
    signal lmem_addr_regs_rd_wr_en              : std_logic;
    signal lmem_addr_regs_rd_data               : vector_register;
    signal lmem_addr_regs_rdy                   : std_logic;
    
    signal pred_regs_en_i                       : std_logic;
    signal pred_regs_num_i                      : std_logic_vector(1 downto 0); 
    signal pred_regs_wr_data_i                  : vector_flag_register;
    signal pred_regs_mask_i                     : std_logic_vector(CORES-1 downto 0); 
    signal pred_regs_rd_wr_en_i                 : std_logic;
    signal pred_regs_rd_data_o                  : vector_flag_register;
    signal pred_regs_rdy_o                      : std_logic;
    
    signal shmem_en_i                           : std_logic;
    signal shmem_wr_data_i                      : vector_word_register_array;
    signal shmem_addr_i                         : std_logic_vector(31 downto 0); 
    signal shmem_rd_wr_type_i                   : mem_opcode_type;
    signal shmem_sm_type_i                      : sm_type;
    signal shmem_mask_i                         : std_logic_vector(CORES-1 downto 0); 
    signal shmem_rd_data_o                      : vector_word_register_array;
    signal shmem_rdy_o                          : std_logic;
            
    signal gmem_en_i                            : std_logic;
    signal gmem_wr_data_i                       : vector_word_register_array;
    signal gmem_addr_i                          : std_logic_vector(31 downto 0); 
    signal gmem_rd_wr_type_i                    : mem_opcode_type;
    signal gmem_data_type_i                     : data_type;
    signal gmem_mask_i                          : std_logic_vector(CORES-1 downto 0); 
    signal gmem_rd_data_o                       : vector_word_register_array;
    signal gmem_rdy_o                           : std_logic;
            
    signal lmem_en_i                            : std_logic;
    signal lmem_wr_data_i                       : vector_word_register_array;
    signal lmem_addr_i                          : std_logic_vector(31 downto 0); 
    signal lmem_rd_wr_type_i                    : mem_opcode_type;
    signal lmem_data_type_i                     : data_type;
    signal lmem_mask_i                          : std_logic_vector(CORES-1 downto 0); 
    signal lmem_rd_data_o                       : vector_word_register_array;
    signal lmem_rdy_o                           : std_logic;
    
    signal addr_hi_2_i                          : std_logic_vector(1 downto 0);
    signal addr_reg                             : std_logic_vector(1 downto 0);
    signal mask_i                               : std_logic_vector(CORES-1 downto 0); 
    signal write_pred_i                         : std_logic;
    signal instruction_flags_i                  : vector_flag_register;
    signal set_pred_i                           : std_logic;
    signal set_pred_reg_i                       : std_logic_vector(1 downto 0);
    signal addr_lo_i                            : std_logic_vector(1 downto 0);
	 signal addr_hi_i                            : std_logic;
            
    signal mv_size_to_sm_type_o                 : sm_type;
    signal mv_size_to_data_type_o               : data_type;
    signal sm_type_to_data_type_o               : data_type;
    
    signal write_select                         : std_logic_vector(2 downto 0);
    
    signal en_reg                               : std_logic;
	 
	signal data_type_in							: data_type;
    
    --
    -- Stats
    --
    signal stat_idle_cnt                            : integer range 0 to 2147483647;
    signal stat_idle_total_cnt                      : integer range 0 to 2147483647;
    signal stat_proc_cnt                            : integer range 0 to 2147483647;
    signal stat_proc_total_cnt                      : integer range 0 to 2147483647;
    signal stat_stall_cnt                           : integer range 0 to 2147483647;
    signal stat_stall_total_cnt                     : integer range 0 to 2147483647;
	 signal check_dest_reg_i									 : std_logic_vector(8 downto 0);
    
	 --*****************************************************
	 signal rst : std_logic := '0';
   signal wr_clk : std_logic := '0';
   signal rd_clk : std_logic := '0';
   signal din : std_logic_vector(31 downto 0) := (others => '0');
   signal wr_en : std_logic := '0';
   signal rd_en : std_logic := '0';

 	--Outputs
   signal dout : std_logic_vector(31 downto 0);
   signal full : std_logic;
	signal wr_ack : std_logic;
	signal valid : std_logic;
   signal empty_i : std_logic;
	--signal fifo_done : std_logic := '0';
	
    signal    rd_en_fifo_i :  STD_LOGIC;
signal     valid_fifo_i : STD_LOGIC;
signal     dout_fifo_i :  STD_LOGIC_VECTOR(31 DOWNTO 0);
	
begin
	not_empty_out <= not empty_i;
		rd_en_fifo_i <= rd_en_fifo_in;
	 valid_fifo_out <= valid_fifo_i;
    dout_fifo_out <=dout_fifo_i;
	 check_dest_reg_i <= dout_fifo_i(8 downto 0);
    addr_hi_2_i         <= '0' & addr_hi_in;
    addr_reg            <= (to_stdlogicvector(to_bitvector(addr_hi_2_i) sll 2)) or addr_lo_in;
     --check_dest_reg_i     <= src1_in(8 downto 0);
		 check_dest_reg	<=  check_dest_reg_i; --********************************
    pPipelineWrite :  process(clk_in)
    begin
        if (rising_edge(clk_in)) then
            if (reset = '1') then
                num_warps_i                                         <= (others => '0');
                warp_id_i                                           <= (others => '0');
                warp_lane_id_i                                      <= (others => '0');            
                cta_id_i                                            <= (others => '0');
                initial_mask_i                                      <= (others => '0');
                current_mask_i                                      <= (others => '0');
                shmem_base_addr_i                                   <= (others => '0');
                gprs_size_i                                         <= (others => '0');              
                base_addr_i                                         <= (others => '0');
                next_pc_i                                           <= (others => '0');
                warp_state_i                                        <= ACTIVE;
    --            addr_reg_i                                          <= (others => '0');
                mov_size_i                                          <= (others => '0');
                addr_imm_i                                          <= '0';
                addr_regs_sel                                       <= '0';
                inc_addr_en_i                                       <= '0';
                inc_addr_reg_i                                      <= (others => '0');
                inc_addr_mask_i                                     <= (others => '0');
                inc_addr_imm_i                                      <= (others => '0');
                compute_pred_data_i                                 <= (others => (others => '0'));
                compute_pred_flags_i                                <= (others => (others => '0')); 
                pred_regs_en_i                                      <= '0';
                pred_regs_num_i                                     <= (others => '0');
                pred_regs_wr_data_i                                 <= (others => (others => '0'));
                pred_regs_mask_i                                    <= (others => '0');
                pred_regs_rd_wr_en_i                                <= '0';
                instruction_flags_i                                 <= (others => (others => '0'));
                set_pred_i                                          <= '0';
                set_pred_reg_i                                      <= (others => '0');
                addr_lo_i                                           <= (others => '0');
                addr_hi_i                                           <= '0';
                write_select                                        <= (others => '0');
                pipeline_reg_ld                                     <= '0';
                en_reg                                              <= '0';
                pipeline_stall_out                                  <= '0';
                write_state_machine                                 <= IDLE;
            else
                case write_state_machine is 
                    when IDLE =>
                        pipeline_reg_ld                             <= '0';
                        en_reg                                      <= en;
                        compute_pred_en_i                       	<= '0';
                        write_addr_regs_en							<= '0';
                        write_gprs_en								<= '0';
                        shmem_en_i                         			<= '0';
                        gmem_en_i									<= '0';	
								--fifo_done <= '0';								
                        if (en_reg = '0' and en = '1') then
                            pipeline_stall_out                      <= '1';
                            num_warps_i                             <= num_warps_in;
                            warp_id_i                               <= warp_id_in;
                            warp_lane_id_i                          <= warp_lane_id_in;
                            cta_id_i                                <= cta_id_in;
                            initial_mask_i                          <= initial_mask_in;
                            current_mask_i                          <= current_mask_in;
                            shmem_base_addr_i                       <= shmem_base_addr_in;
                            gprs_size_i                             <= gprs_size_in;              
                            base_addr_i                             <= gprs_base_addr_in;
                            next_pc_i                               <= next_pc_in;
                            warp_state_i                            <= warp_state_in;
    --                        addr_reg_i                              <= addr_reg;
                            mov_size_i                              <= mov_size_in;
                            write_pred_i                            <= write_pred_in;
                            instruction_flags_i                     <= instruction_flags_in;
                            set_pred_i                              <= set_pred_in;
                            set_pred_reg_i                          <= set_pred_reg_in;
                            addr_lo_i                               <= addr_lo_in;
                            addr_hi_i                               <= addr_hi_in;
                            addr_imm_i                              <= addr_imm_in;
                            if ((instr_opcode_type_in = NOP) or (dest_data_type_in = DT_NONE) or (dest_mem_type_in = UNKNOWN)) then
                                write_state_machine                 <= CHECK_PRED_REGS;
                            elsif (dest_mem_type_in = REG) then
                                write_gprs_en                       <= '1';
                                write_gprs_reg_num                  <= dest_in(8 downto 0);
                                write_gprs_rd_wr_en                 <= '1';
                                for i in 0 to CORES-1 loop
                                    write_gprs_wr_data(i)           <= temp_vector_register_in(i)(TEMP_REG_DEST);
                                end loop;
                                write_gprs_data_type                <= dest_data_type_in;
                                write_gprs_mask                     <= mask_i;
                                write_select                        <= "000";
                                write_state_machine                 <= WRITE_GPRS;
                            elsif (dest_mem_type_in = MEM_SHARED) then
                                shmem_en_i                          <= '1';
                                for i in 0 to CORES-1 loop
                                    shmem_wr_data_i(i)              <= temp_vector_register_in(i)(TEMP_REG_SRC3);
                                end loop;
                                shmem_rd_wr_type_i                  <= dest_mem_opcode_type_in;
                                shmem_sm_type_i                     <= mv_size_to_sm_type_o;
                                shmem_mask_i                        <= mask_i;
                                addr_imm_i                          <= addr_imm_in;
                                if (addr_inc_in = '1') then
                                    shmem_addr_i                    <= (others => '0');
                                else
                                    shmem_addr_i                    <= dest_in;
                                end if;
                                write_select                        <= "001";
                                write_state_machine                 <= WRITE_SHMEM;
                            elsif (dest_mem_type_in = MEM_GLOBAL) then
                                gmem_en_i                           <= '1';
                                for i in 0 to CORES-1 loop
                                    gmem_wr_data_i(i)               <= temp_vector_register_in(i)(TEMP_REG_DEST);
                                end loop;
                                gmem_addr_i                         <= dest_in;
                                gmem_rd_wr_type_i                   <= dest_mem_opcode_type_in;
                                gmem_data_type_i                    <= mv_size_to_data_type_o;
                                gmem_mask_i                         <= mask_i;
                                addr_imm_i                          <= addr_imm_in;
                                write_select                        <= "010";
                                write_state_machine                 <= WRITE_GMEM;
                            elsif (dest_mem_type_in = MEM_LOCAL) then
                                lmem_en_i                           <= '1';
                                for i in 0 to CORES-1 loop
                                    lmem_wr_data_i(i)               <= temp_vector_register_in(i)(TEMP_REG_DEST);
                                end loop;
                                lmem_addr_i                         <= dest_in;
                                lmem_rd_wr_type_i                   <= dest_mem_opcode_type_in;
                                lmem_data_type_i                    <= mv_size_to_data_type_o;
                                lmem_mask_i                         <= mask_i;
                                addr_imm_i                          <= '1';
                                write_select                        <= "011";
                                write_state_machine                 <= WRITE_LMEM;
                            elsif (dest_mem_type_in = ADDRESS) then
                                write_addr_regs_en                  <= '1';
                                write_addr_regs_reg_num             <= dest_in(1 downto 0);
                                write_addr_regs_rd_wr_en            <= '1';
                                for i in 0 to CORES-1 loop
                                    write_addr_regs_wr_data(i)      <= temp_vector_register_in(i)(TEMP_REG_DEST)(0);
                                end loop;
                                write_addr_regs_mask                <= mask_i;
                                addr_imm_i                          <= '1';
                                write_select                        <= "000";
                                write_state_machine                 <= WRITE_ADDR;
									 elsif (dest_mem_type_in = MAILBOX_BUF) then
											if(mailbox_state_machine = DONE) then
												write_state_machine <= DONE;
											end if;
                            end if;
									 
                        else
                            pipeline_stall_out                      <= '0';
                        end if;
                        
                    when WRITE_GPRS =>
                        write_gprs_en                               <= '0';
                        if (write_gprs_rdy = '1') then
                                    --write_gprs_en                           <= '1';      -- USED FOR TESTING REGISTER WRITE/READ OPERATION
                            write_gprs_rd_wr_en                     <= '0';  
                            write_state_machine                     <= CHECK_PRED_REGS;
                        end if;
                        
                    when WRITE_SHMEM =>
                        shmem_en_i                                  <= '0';
                        if (shmem_rdy_o = '1') then
                                    --shmem_en_i                              <= '1';				-- USED FOR TESTING SHARED MEMORY WRITE/READ OPERATION
                            shmem_rd_wr_type_i                      <= READ_GATHER;
                            write_state_machine                     <= CHECK_PRED_REGS;
                        end if;
                        
                    when WRITE_GMEM =>
                        gmem_en_i                                   <= '0';
                        if (gmem_rdy_o = '1') then
                                    --gmem_en_i                               <= '1';			-- USED FOR TESTING GLOBAL MEMORY WRITE/READ OPERATION
                            gmem_rd_wr_type_i                       <= READ_GATHER;
                            write_state_machine                     <= CHECK_PRED_REGS;
                        end if;
                        
                    when WRITE_LMEM =>
                        lmem_en_i                                   <= '0';
                        if (lmem_rdy_o = '1') then
                            lmem_rd_wr_type_i                       <= READ;
                            write_state_machine                     <= CHECK_PRED_REGS;
                        end if;
                        
                    when WRITE_ADDR =>
                        write_addr_regs_en                          <= '0';
                        if (write_addr_regs_rdy = '1') then
                                    --write_addr_regs_en                      <= '1';  		-- USED FOR TESTING ADDRESS REGISTER WRITE/READ OPERATION	
                            write_addr_regs_rd_wr_en                <= '0';
                            write_state_machine                     <= CHECK_PRED_REGS;
                        end if;
                        
                    when CHECK_PRED_REGS =>
                                    --write_gprs_en                           <= '1';
                        if (write_pred_i = '1') then
                            compute_pred_en_i                       <= '1';
                            for i in 0 to CORES-1 loop
                                compute_pred_data_i(i)              <= temp_vector_register_in(i)(TEMP_REG_DEST)(0);
                            end loop;
                            compute_pred_flags_i                    <= instruction_flags_i;   
                            compute_pred_data_type_i                <= dest_data_type_in;
                            write_state_machine                     <= COMPUTE_PRED_REGS;
                        else
                            write_state_machine                     <= CHECK_INCREMENT_ADDR;
                        end if;
                        
                    when COMPUTE_PRED_REGS =>
                        compute_pred_en_i                           <= '0';
                        if (compute_pred_rdy_o = '1') then
                            if (set_pred_i = '1') then
                                pred_regs_en_i                      <= '1';
                                pred_regs_num_i                     <= set_pred_reg_i;
                                pred_regs_wr_data_i                 <= compute_pred_flags_o;
                                pred_regs_mask_i                    <= mask_i;
                                pred_regs_rd_wr_en_i                <= '1';
                                write_state_machine                 <= WRITE_PRED_REGS;
                            else
                                write_state_machine                 <= DONE;
                            end if;
                        end if;
                        
                    when WRITE_PRED_REGS =>
                        pred_regs_en_i                              <= '0';
                        if (pred_regs_rdy_o = '1') then
                                    --pred_regs_en_i                          <= '1';		-- USED FOR TESTING PREDICATE REGISTER WRITE/READ OPERATION
                            pred_regs_rd_wr_en_i                    <= '0';
                            write_state_machine                     <= CHECK_INCREMENT_ADDR;
                        end if;
                        
                    when CHECK_INCREMENT_ADDR =>
                        if (addr_inc_in = '1') then
                            inc_addr_en_i                           <= '1';
                            inc_addr_reg_i                          <= addr_reg;
                            if (dest_mem_type_in = MEM_SHARED) then
                                inc_addr_data_type_i                <= mv_size_to_data_type_o;
                                inc_addr_imm_i                      <= dest_in;
                            else
                                inc_addr_data_type_i                <= sm_type_to_data_type_o;
                                inc_addr_imm_i                      <= dest_in;
                            end if;
                            inc_addr_mask_i                          <= mask_i;
                            write_select                            <= "101";
                            write_state_machine                     <= INCREMENT_ADDR;
                        else
                            write_state_machine                     <= DONE;
                        end if;
                        
                    when INCREMENT_ADDR =>
                        inc_addr_en_i                               <= '0';
                        if (inc_addr_rdy_o = '1') then
                            write_state_machine                     <= DONE;
                        end if;
                        
                    when DONE =>
                        if (pipeline_stall_in = '0') then
                            warp_id_out                             <= warp_id_i;
                            warp_lane_id_out                        <= warp_lane_id_i;
                            cta_id_out                              <= cta_id_i;
                            initial_mask_out                        <= initial_mask_i;
                            current_mask_out                        <= current_mask_i;
                            shmem_base_addr_out                     <= shmem_base_addr_i;
                            gprs_addr_out                           <= base_addr_i;
                            next_pc_out                             <= next_pc_i;
                            warp_state_out                          <= warp_state_i;
                            pipeline_reg_ld                         <= '1';
                            write_state_machine                     <= IDLE;
                        end if;
                    when OTHERS =>
                        write_state_machine                         <= IDLE;
                end case;
            end if;
        end if;
    end process;
   
    gMask8: if (CORES = 8) generate 
        pMask8 : process(warp_lane_id_in)
        begin
            case warp_lane_id_in is
                when "00" =>
                    mask_i(7 downto 0)  <= instruction_mask_in(7 downto 0);
                when "01" =>
                    mask_i(7 downto 0)  <= instruction_mask_in(15 downto 8);
                when "10" =>
                    mask_i(7 downto 0)  <= instruction_mask_in(23 downto 16);
                when "11" =>
                    mask_i(7 downto 0)  <= instruction_mask_in(31 downto 24);
                when others =>
                    mask_i(7 downto 0)  <= instruction_mask_in(7 downto 0);
            end case;
        end process;
    end generate;
    
    gMask16: if (CORES = 16) generate 
        pMask16 : process(warp_lane_id_in)
        begin
            case warp_lane_id_in is
                when "00" =>
                    for i in 0 to CORES-1 loop
                        mask_i(i)       <= instruction_mask_in(i);
                    end loop;
                    --mask_i(CORES-1 downto 0)   <= instruction_mask_i(15 downto 0);
                when "01" =>
                    for i in 0 to CORES-1 loop
                        mask_i(i)       <= instruction_mask_in(i+16);
                    end loop;
                    --mask_i(CORES-1 downto 0)   <= instruction_mask_i(31 downto 16);
                when others =>
                    for i in 0 to CORES-1 loop
                        mask_i(i)       <= instruction_mask_in(i);
                    end loop;
                    --mask_i(CORES-1 downto 0)   <= instruction_mask_i(15 downto 0);
            end case;
        end process;
    end generate;
    
    gMask32: if (CORES = 32) generate
        mask_i          <= instruction_mask_in;
    end generate;
    
    MemoryGPRS_reg:process(clk_in)
    begin
        if (rising_edge(clk_in)) then
            shmem_gprs_en_reg           <= shmem_gprs_en;
            gmem_gprs_en_reg            <= gmem_gprs_en;
            lmem_gprs_en_reg            <= lmem_gprs_en;
        end if;
    end process;
	 
    uConvertDataTypes : convert_data_types
        port map (
            mov_size_in                         => mov_size_in,
            conv_type_in                        => CT_NONE,
            reg_type_in                         => RT_NONE,
			data_type_in                        => data_type_in,
            sm_type_in                          => sm_type_in,
            mem_type_in                         => "000",
            
            mv_size_to_sm_type_out              => mv_size_to_sm_type_o,
			data_type_to_sm_type_out    			=> open,
            sm_type_to_sm_type_out              => open,
            mem_type_to_sm_type_out             => open,
            conv_type_to_reg_type_out           => open,
            reg_type_to_data_type_out           => open,
            mv_size_to_data_type_out            => mv_size_to_data_type_o,
            conv_type_to_data_type_out          => open,
            sm_type_to_data_type_out            => sm_type_to_data_type_o,
            mem_type_to_data_type_out           => open,
            sm_type_to_cvt_type_out             => open,
            mem_type_to_cvt_type_out            => open
        );
    
    uIncrementAddress : increment_address
        port map (
            reset                               => reset,
            clk_in                              => clk_in,
            en						            => inc_addr_en_i,
            
            addr_reg_in                         => inc_addr_reg_i,
            data_type_in                        => inc_addr_data_type_i,
            mask_in                             => inc_addr_mask_i,
            imm_in                              => inc_addr_imm_i,
            
            addr_regs_en_out                    => inc_addr_regs_en,
            addr_regs_reg_num_out               => inc_addr_regs_reg_num,
            addr_regs_wr_data_out               => inc_addr_regs_wr_data,
            addr_regs_mask_out                  => inc_addr_regs_mask,
            addr_regs_rd_wr_en_out              => inc_addr_regs_rd_wr_en,
            addr_regs_rd_data_in                => inc_addr_regs_rd_data,
            addr_regs_rdy_in                    => inc_addr_regs_rdy,
            
            rdy_out                             => inc_addr_rdy_o
        );
   
    uComputePredFlags : compute_pred_flags
        port map (
            reset                               => reset,
			clk_in                              => clk_in,
			en						            => compute_pred_en_i,
					
			data_in                             => compute_pred_data_i,
            flags_in                            => compute_pred_flags_i,
            data_type_in                        => compute_pred_data_type_i,
            
            flags_out                           => compute_pred_flags_o,
            
            rdy_out                             => compute_pred_rdy_o
        );

    uVectorRegisterFileController : vector_register_controller
        port map (
            reset                       => reset,
            clk_in                      => clk_in,
            en                          => gprs_en_i,
            
            lane_id_in                  => warp_lane_id_i,
            base_addr_in                => base_addr_i,
            reg_num_in                  => gprs_reg_num_i,
            data_in                     => gprs_wr_data_i,
            data_type_in                => gprs_data_type_i,
            mask_in                     => gprs_mask_i,
            rd_wr_en_in                 => gprs_rd_wr_en_i,
            
            gprs_base_addr_out          => gprs_base_addr_out,
            gprs_reg_num_out            => gprs_reg_num_out,
            gprs_lane_id_out            => gprs_lane_id_out,
            gprs_wr_en_out              => gprs_wr_en_out,
            gprs_wr_data_out            => gprs_wr_data_out,
            gprs_rd_data_in             => gprs_rd_data_in,
            
            data_out                    => gprs_rd_data_o,
            
            rdy_out                     => gprs_rdy_o
        );

    gprs_en_i         <=
        write_gprs_en           when (write_select = "000") else
        shmem_gprs_en_reg       when (write_select = "001") else
        gmem_gprs_en_reg        when (write_select = "010") else
        lmem_gprs_en_reg        when (write_select = "011") else
        '0';
    
    gprs_reg_num_i    <=
        write_gprs_reg_num      when (write_select = "000") else
        shmem_gprs_reg_num      when (write_select = "001") else
        gmem_gprs_reg_num       when (write_select = "010") else
        lmem_gprs_reg_num       when (write_select = "011") else
        (others => '0');
    
    gprs_wr_data_i    <=
        write_gprs_wr_data      when (write_select = "000") else
        shmem_gprs_wr_data      when (write_select = "001") else
        gmem_gprs_wr_data       when (write_select = "010") else
        lmem_gprs_wr_data       when (write_select = "011") else
        (others => (others => (others => '0')));
    
    gprs_data_type_i  <=
        write_gprs_data_type    when (write_select = "000") else
        shmem_gprs_data_type    when (write_select = "001") else
        gmem_gprs_data_type     when (write_select = "010") else
        lmem_gprs_data_type     when (write_select = "011") else
        DT_NONE;
    
    gprs_mask_i       <=
        write_gprs_mask         when (write_select = "000") else
        shmem_gprs_mask         when (write_select = "001") else
        gmem_gprs_mask          when (write_select = "010") else
        lmem_gprs_mask          when (write_select = "011") else
        (others => '0');
    
    gprs_rd_wr_en_i   <=
        write_gprs_rd_wr_en     when (write_select = "000") else
        shmem_gprs_rd_wr_en     when (write_select = "001") else
        gmem_gprs_rd_wr_en      when (write_select = "010") else
        lmem_gprs_rd_wr_en      when (write_select = "011") else
        '0';
   
    write_gprs_rd_data  <= gprs_rd_data_o when (write_select = "000") else (others => (others => (others => '0')));
    shmem_gprs_rd_data  <= gprs_rd_data_o when (write_select = "001") else (others => (others => (others => '0')));
    gmem_gprs_rd_data   <= gprs_rd_data_o when (write_select = "010") else (others => (others => (others => '0')));
    lmem_gprs_rd_data   <= gprs_rd_data_o when (write_select = "011") else (others => (others => (others => '0')));
    
    write_gprs_rdy      <= gprs_rdy_o when (write_select = "000") else '0';
    shmem_gprs_rdy      <= gprs_rdy_o when (write_select = "001") else '0';
    gmem_gprs_rdy       <= gprs_rdy_o when (write_select = "010") else '0';
    lmem_gprs_rdy       <= gprs_rdy_o when (write_select = "011") else '0';
	 
	 
    
    uAddressRegisterController : address_register_controller
        port map (
            reset                       => reset,
            clk_in                      => clk_in,
            en                          => addr_regs_en_i,
            
            warp_id_in                  => warp_id_i,
            lane_id_in                  => warp_lane_id_i,
            reg_num_in                  => addr_regs_reg_num_i,
            data_in                     => addr_regs_wr_data_i,
            mask_in                     => addr_regs_mask_i,
            rd_wr_en_in                 => addr_regs_rd_wr_en_i,
            
            addr_regs_warp_id_out       => addr_regs_warp_id_out,
            addr_regs_warp_lane_id_out  => addr_regs_warp_lane_id_out,
            addr_regs_reg_num_out       => addr_regs_reg_num_out,
            addr_regs_wr_en_out         => addr_regs_wr_en_out,
            addr_regs_wr_data_out       => addr_regs_wr_data_out,
            addr_regs_rd_data_in        => addr_regs_rd_data_in,
            
            data_out                    => addr_regs_rd_data_o,
            
            rdy_out                     => addr_regs_rdy_o
        );
    
    addr_regs_en_i        <= 
        write_addr_regs_en          when (write_select = "000") else
        shmem_addr_regs_en          when (write_select = "001") else
        gmem_addr_regs_en           when (write_select = "010") else
        lmem_addr_regs_en           when (write_select = "011") else
        inc_addr_regs_en            when (write_select = "101") else
        '0';
        
    addr_regs_reg_num_i       <= 
        write_addr_regs_reg_num     when (write_select = "000") else
        shmem_addr_regs_reg_num     when (write_select = "001") else
        gmem_addr_regs_reg_num      when (write_select = "010") else
        lmem_addr_regs_reg_num      when (write_select = "011") else
        inc_addr_regs_reg_num       when (write_select = "101") else
        (others => '0');
        
    addr_regs_wr_data_i   <= 
        write_addr_regs_wr_data     when (write_select = "000") else
        shmem_addr_regs_wr_data     when (write_select = "001") else
        gmem_addr_regs_wr_data      when (write_select = "010") else
        lmem_addr_regs_wr_data      when (write_select = "011") else
        inc_addr_regs_wr_data       when (write_select = "101") else
        (others => (others => '0'));
        
    addr_regs_mask_i      <= 
        write_addr_regs_mask        when (write_select = "000") else
        shmem_addr_regs_mask        when (write_select = "001") else
        gmem_addr_regs_mask         when (write_select = "010") else
        lmem_addr_regs_mask         when (write_select = "011") else
        inc_addr_regs_mask          when (write_select = "101") else
        (others => '0');
        
    addr_regs_rd_wr_en_i  <= 
        write_addr_regs_rd_wr_en    when (write_select = "000") else
        shmem_addr_regs_rd_wr_en    when (write_select = "001") else
        gmem_addr_regs_rd_wr_en     when (write_select = "010") else
        lmem_addr_regs_rd_wr_en     when (write_select = "011") else
        inc_addr_regs_rd_wr_en      when (write_select = "101") else
        '0';
    
    write_addr_regs_rd_data         <= addr_regs_rd_data_o when (write_select = "000") else (others => (others => '0'));
    shmem_addr_regs_rd_data         <= addr_regs_rd_data_o when (write_select = "001") else (others => (others => '0'));
    gmem_addr_regs_rd_data          <= addr_regs_rd_data_o when (write_select = "010") else (others => (others => '0'));
    lmem_addr_regs_rd_data          <= addr_regs_rd_data_o when (write_select = "011") else (others => (others => '0'));
    inc_addr_regs_rd_data           <= addr_regs_rd_data_o when (write_select = "101") else (others => (others => '0'));
    
    write_addr_regs_rdy             <= addr_regs_rdy_o when (write_select = "000") else '0';
    shmem_addr_regs_rdy             <= addr_regs_rdy_o when (write_select = "001") else '0';
    gmem_addr_regs_rdy              <= addr_regs_rdy_o when (write_select = "010") else '0';
    lmem_addr_regs_rdy              <= addr_regs_rdy_o when (write_select = "011") else '0';
    inc_addr_regs_rdy               <= addr_regs_rdy_o when (write_select = "101") else '0';
    
    uPredicateRegsiterController : predicate_register_controller
        port map (
            reset                       => reset,
            clk_in                      => clk_in,
            en                          => pred_regs_en_i,
            
            warp_id_in                  => warp_id_i,
            lane_id_in                  => warp_lane_id_i,
            reg_num_in                  => pred_regs_num_i,
            data_in                     => pred_regs_wr_data_i,
            mask_in                     => pred_regs_mask_i,
            rd_wr_en_in                 => pred_regs_rd_wr_en_i,
            
            pred_regs_warp_id_out       => pred_regs_warp_id_out,
            pred_regs_warp_lane_id_out  => pred_regs_warp_lane_id_out,
            pred_regs_reg_num_out       => pred_regs_reg_num_out,
            pred_regs_wr_en_out         => pred_regs_wr_en_out,
            pred_regs_wr_data_out       => pred_regs_wr_data_out,
            pred_regs_rd_data_in        => pred_regs_rd_data_in,
            
            data_out                    => pred_regs_rd_data_o,
            
            rdy_out                     => pred_regs_rdy_o
        );

    uSharedMemoryController : shared_memory_controller
		generic map (
            ADDRESS_SIZE                => SHMEM_ADDR_SIZE,
            ARB_GPRS_EN                 => '0',
            ARB_ADDR_REGS_EN            => '0'
        )
		port map (
			reset                       => reset,
			clk_in                      => clk_in,
			en						   	=> shmem_en_i,
            
            data_in						=> shmem_wr_data_i,
            base_addr_in                => shmem_base_addr_i,
            addr_in						=> shmem_addr_i,
            mask_in                     => shmem_mask_i,
			rd_wr_type_in               => shmem_rd_wr_type_i,
            sm_type_in					=> shmem_sm_type_i,
            
			addr_lo_in					=> addr_lo_i,
			addr_hi_in					=> addr_hi_i,
			addr_imm_in					=> addr_imm_i,
			
            gprs_req_out                => open,
            gprs_ack_out                => open,
            gprs_grant_in               => '0',
            
            gprs_en_out                 => shmem_gprs_en,
            gprs_reg_num_out            => shmem_gprs_reg_num,
            gprs_data_type_out          => shmem_gprs_data_type,
            gprs_mask_out               => shmem_gprs_mask,
            gprs_rd_wr_en_out           => shmem_gprs_rd_wr_en,
            gprs_rd_data_in             => shmem_gprs_rd_data,
            gprs_rdy_in                 => shmem_gprs_rdy,
            
            addr_regs_req_out           => open,
            addr_regs_ack_out           => open,
            addr_regs_grant_in          => '0',
            
            addr_regs_en_out            => shmem_addr_regs_en,
            addr_regs_reg_out           => shmem_addr_regs_reg_num,
            addr_regs_mask_out          => shmem_addr_regs_mask,
            addr_regs_rd_wr_en_out      => shmem_addr_regs_rd_wr_en,
            addr_regs_rd_data_in        => shmem_addr_regs_rd_data,
            addr_regs_rdy_in            => shmem_addr_regs_rdy,
            
            shmem_addr_out              => shmem_addr_out,
            shmem_wr_en_out             => shmem_wr_en_out,
            shmem_wr_data_out           => shmem_wr_data_out,
            shmem_rd_data_in            => shmem_rd_data_in,
            
			data_out			        => shmem_rd_data_o,
			rdy_out		                => shmem_rdy_o
		);

    uGlobalMemoryController : global_memory_controller
		generic map (
            ADDRESS_SIZE                => GMEM_ADDR_SIZE,
            ARB_GPRS_EN                 => '0',
            ARB_ADDR_REGS_EN            => '0'
        )
		port map (
			reset                       => reset,
			clk_in                      => clk_in,
			en						    => gmem_en_i,
			
            data_in						=> gmem_wr_data_i,
            addr_in						=> gmem_addr_i,
            mask_in                     => gmem_mask_i,
			rd_wr_type_in               => gmem_rd_wr_type_i,
            data_type_in			    => gmem_data_type_i,
			
			addr_lo_in					=> addr_lo_i,
		    addr_hi_in					=> addr_hi_i,
		    addr_imm_in					=> addr_imm_i,
			
            gprs_req_out                => open,
            gprs_ack_out                => open,
            gprs_grant_in               => '0',
            
            gprs_en_out                 => gmem_gprs_en,
            gprs_reg_num_out            => gmem_gprs_reg_num,
            gprs_data_type_out          => gmem_gprs_data_type,
            gprs_mask_out               => gmem_gprs_mask,
            gprs_rd_wr_en_out           => gmem_gprs_rd_wr_en,
            gprs_rd_data_in             => gmem_gprs_rd_data,
            gprs_rdy_in                 => gmem_gprs_rdy,
            
            addr_regs_req_out           => open,
            addr_regs_ack_out           => open,
            addr_regs_grant_in          => '0',
            
            addr_regs_en_out            => gmem_addr_regs_en,
            addr_regs_reg_out           => gmem_addr_regs_reg_num,
            addr_regs_mask_out          => gmem_addr_regs_mask,
            addr_regs_rd_wr_en_out      => gmem_addr_regs_rd_wr_en,
            addr_regs_rd_data_in        => gmem_addr_regs_rd_data,
            addr_regs_rdy_in            => gmem_addr_regs_rdy,
            
            gmem_addr_out               => gmem_addr_out,
            gmem_wr_en_out              => gmem_wr_en_out,
            gmem_wr_data_out            => gmem_wr_data_out,
            gmem_rd_data_in             => gmem_rd_data_in,
            
			data_out			       	=> gmem_rd_data_o,
			rdy_out		                => gmem_rdy_o
		);

   scroogie : fifo
  PORT MAP (
    rst => reset,
    wr_clk => clk_in,
    rd_clk => clk_in,
    din => din,
    wr_en => wr_en,
    rd_en => rd_en_fifo_i,
    dout => dout_fifo_i,
    full => full,
    wr_ack => wr_ack,
    empty => empty_i,
    valid => valid_fifo_i
  );
		  
	
--    uLocalMemoryController : local_memory_controller
--		generic map (
--            ADDRESS_SIZE                => LMEM_ADDR_SIZE,
--            ARB_GPRS_EN                 => '0',
--            ARB_ADDR_REGS_EN            => '0'
--        )
--		port map (
--			reset                       => reset,
--			clk_in                      => clk_in,
--			en						    => lmem_en_i,
--			
--            core_id_in                  => CORE_ID,
--            num_warps_in                => num_warps_i,
--            warp_id_in                  => warp_id_i,
--            warp_lane_id_in             => warp_lane_id_i,
--            
--            data_in						=> lmem_wr_data_i,
--            addr_in						=> lmem_addr_i,
--            mask_in                     => lmem_mask_i,
--			rd_wr_type_in               => lmem_rd_wr_type_i,
--            data_type_in			    => lmem_data_type_i,
--            
--			addr_lo_in					=> addr_lo_i,
--			addr_hi_in					=> addr_hi_i,
--			addr_imm_in					=> addr_imm_i,
--			
--            gprs_req_out                => open,
--            gprs_ack_out                => open,
--            gprs_grant_in               => '0',
--            
--            gprs_en_out                 => lmem_gprs_en,
--            gprs_reg_num_out            => lmem_gprs_reg_num,
--            gprs_data_type_out          => lmem_gprs_data_type,
--            gprs_mask_out               => lmem_gprs_mask,
--            gprs_rd_wr_en_out           => lmem_gprs_rd_wr_en,
--            gprs_rd_data_in             => lmem_gprs_rd_data,
--            gprs_rdy_in                 => lmem_gprs_rdy,
--            
--            addr_regs_req_out           => open,
--            addr_regs_ack_out           => open,
--            addr_regs_grant_in          => '0',
--            
--            addr_regs_en_out            => lmem_addr_regs_en,
--            addr_regs_reg_out           => lmem_addr_regs_reg_num,
--            addr_regs_mask_out          => lmem_addr_regs_mask,
--            addr_regs_rd_wr_en_out      => lmem_addr_regs_rd_wr_en,
--            addr_regs_rd_data_in        => lmem_addr_regs_rd_data,
--            addr_regs_rdy_in            => lmem_addr_regs_rdy,
--            
--            lmem_addr_out               => lmem_addr_out,
--            lmem_wr_en_out              => lmem_wr_en_out,
--            lmem_wr_data_out            => lmem_wr_data_out,
--            lmem_rd_data_in             => lmem_rd_data_in,
--            
--			data_out			       	=> lmem_rd_data_o,
--			rdy_out		                => lmem_rdy_o
--		); 

    --
    -- Stats
    --
    stats_out.total_idle            <= std_logic_vector(to_unsigned(stat_idle_total_cnt, stats_out.total_idle'length));
    stats_out.total_processing      <= std_logic_vector(to_unsigned(stat_proc_total_cnt, stats_out.total_processing'length));
    stats_out.total_stall           <= std_logic_vector(to_unsigned(stat_stall_total_cnt, stats_out.total_stall'length));
    
	 
    pPipelineWriteStats: process(clk_in)
	begin
		if(rising_edge(clk_in)) then
            if (reset = '1' or stats_reset = '1') then
                stat_idle_cnt                       <= 0;
                stat_idle_total_cnt                 <= 0;
                stat_proc_cnt                       <= 0;
                stat_proc_total_cnt                 <= 0;
                stat_stall_cnt                      <= 0;
                stat_stall_total_cnt                <= 0;
            else
                if (write_state_machine = IDLE) then
                    if (en_reg = '0' and en = '1') then
                        stat_idle_cnt               <= 0;
                        stat_proc_cnt               <= stat_proc_cnt + 1;
                        stat_proc_total_cnt         <= stat_proc_total_cnt + 1;
                    else
                        stat_idle_cnt               <= stat_idle_cnt + 1;
                        stat_idle_total_cnt         <= stat_idle_total_cnt + 1;
                        stat_proc_cnt               <= 0;
                    end if;
                elsif (write_state_machine = DONE) then
                    if (pipeline_stall_in = '0') then
                        stat_stall_cnt              <= 0;
                    else
                        stat_stall_cnt              <= stat_stall_cnt + 1;
                        stat_stall_total_cnt        <= stat_stall_total_cnt + 1;
                    end if;
                else
                    stat_proc_cnt                   <= stat_proc_cnt + 1;
                    stat_proc_total_cnt             <= stat_proc_total_cnt + 1; 
                end if;
            end if;
        end if;
    end process;
	 
	 pPipelineWriteMailbox: process(clk_in)
	 variable counter : integer;
	 begin
	 if(rising_edge(clk_in)) then
			if (reset = '1') then
				wr_en <= '0';
				rst <= '1';
				mailbox_state_machine <= IDLE;
				--check_dest_reg_i <= "000000001";
			else
				case mailbox_state_machine is
						when IDLE =>
							wr_en <= '0';
							rst <= '0';
							counter := 0;
							if(dest_mem_type_in = MAILBOX_BUF ) then
								mailbox_state_machine <= DATA_INIT;
								--check_dest_reg_i <= "000000010";
							end if;
						when DATA_INIT =>
							--din <=  "00000000000000000000000000001000";
							mailbox_gprs_wr_data(0) <= temp_vector_register_in(0)(TEMP_REG_DEST);
							--mailbox_gprs_wr_data(0) <= temp_vector_register_in(0)(0);
							din <= mailbox_gprs_wr_data(0)(0);
							--check_dest_reg_i <= din (8 downto 0);
							mailbox_state_machine <= WRITE_EN;
						when WRITE_EN =>
							wr_en <= '1';
							--check_dest_reg_i <= "000000100";
							--counter := counter + 1;
							--if(counter = 5)then
							--check_dest_reg_i <= "000000101";
								mailbox_state_machine <= WRITE_DIS;
							--end if;
						when WRITE_DIS =>
						--check_dest_reg_i <= "000000110";
						wr_en <= '0';
							--if(wr_ack = '1') then
								--rd_en <= '1';
								mailbox_state_machine <= READ_EN;
								--check_dest_reg_i <= "000000111";
							--end if;	
						when READ_EN =>
							
							--check_dest_reg_i <= "000001000";
							
							--if(valid = '1') then
								--check_dest_reg_i <= dout (8 downto 0);
								--check_dest_reg_i <= "000001001";
								mailbox_state_machine <= DONE;
								
							--end if;
						when DONE =>
						--check_dest_reg_i <= "000001011";
							--rd_en <= '0';
							if(write_state_machine = DONE) then
									mailbox_state_machine <= IDLE;
									--check_dest_reg_i <= "000001011";
								end if;
						when OTHERS =>
							mailbox_state_machine <= IDLE;
						end case;
			end if;
			
	 end if;
	 end process;
    
end arch;

