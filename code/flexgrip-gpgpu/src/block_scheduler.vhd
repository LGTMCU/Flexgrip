----------------------------------------------------------------------------------
-- Company:          Univerity of Massachusetts 
-- Engineer:         Kevin Andryc
-- 
-- Create Date:      17:50:27 09/19/2010  
-- Module Name:      block_scheduler - arch 
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
use IEEE.std_logic_unsigned.all;  
use IEEE.std_logic_arith.all;

library unisim;
use unisim.vcomponents.all;

use work.gpgpu_package.all;

    entity block_scheduler is
        port (
            clk_in                      : in  std_logic;
			host_reset                  : in  std_logic;
            
            en                          : in  std_logic;
            
            kernel_blocks_per_core_in   : in  std_logic_vector(3 downto 0);
            kernel_num_gprs_in          : in  std_logic_vector(8 downto 0);
            kernel_shmem_size_in        : in  std_logic_vector(31 downto 0);
            kernel_parameter_size_in    : in  std_logic_vector(15 downto 0);
            kernel_dyn_shmem_size_in    : in  std_logic_vector(31 downto 0);
            kernel_block_x_in           : in  std_logic_vector(15 downto 0);
            kernel_block_y_in           : in  std_logic_vector(15 downto 0);
            kernel_block_z_in           : in  std_logic_vector(15 downto 0);
            kernel_grid_x_in            : in  std_logic_vector(15 downto 0);
            kernel_grid_y_in            : in  std_logic_vector(15 downto 0);
            
            smp_done_in                 : in  std_logic;
            
            threads_per_block_out       : out std_logic_vector(11 downto 0);
            num_blocks_out              : out std_logic_vector(3 downto 0);
            shmem_base_addr_out         : out std_logic_vector(31 downto 0);
            shmem_size_out              : out std_logic_vector(31 downto 0);
            parameter_size_out          : out std_logic_vector(15 downto 0);
            gprs_size_out               : out std_logic_vector(8 downto 0);
            block_x_out                 : out std_logic_vector(15 downto 0);
            block_y_out                 : out std_logic_vector(15 downto 0);
            block_z_out                 : out std_logic_vector(15 downto 0);
            grid_x_out                  : out std_logic_vector(15 downto 0);
            grid_y_out                  : out std_logic_vector(15 downto 0);
            block_idx_out               : out std_logic_vector(15 downto 0);
            shmem_params_out            : out std_logic_vector(15 downto 0);
            cmem_params_out             : out std_logic_vector(15 downto 0);
            
            threads_per_block_ld        : out std_logic;
            num_blocks_ld               : out std_logic;
            shmem_base_addr_ld          : out std_logic;
            shmem_size_ld               : out std_logic;
            parameter_size_ld           : out std_logic;
            gprs_size_ld                : out std_logic;
            block_x_ld                  : out std_logic;
            block_y_ld                  : out std_logic;
            block_z_ld                  : out std_logic;
            grid_x_ld                   : out std_logic;
            grid_y_ld                   : out std_logic;
            block_idx_ld                : out std_logic;
            
			smp_reset_out			    : out std_logic;
            smp_en_out                  : out std_logic;
            
            rdy                         : out std_logic;
			kernel_done					: out std_logic
        );  
    end block_scheduler;

architecture arch of block_scheduler is

    type block_scheduler_state_type is (IDLE, CALC_BLOCKS, CHECK_BLOCKS, SCHEDULE_BLOCKS, SCHEDULE_WAIT);
    signal block_scheduler_state_machine        : block_scheduler_state_type;
    
    signal en_reg                       : std_logic;
    signal smp_done_in_reg              : std_logic;
    signal grid_dimension               : std_logic_vector(31 downto 0);
    signal num_blocks                   : std_logic_vector(31 downto 0);
    signal blocks_per_gpgpu             : std_logic_vector(11 downto 0);
    signal blocks_scheduled_cnt         : std_logic_vector(15 downto 0);
    signal threads_per_block_i          : std_logic_vector(47 downto 0);
    signal kernel_blocks_per_core_i     : std_logic_vector(3 downto 0);
    signal kernel_num_gprs_i            : std_logic_vector(8 downto 0);
    signal kernel_shmem_size_i          : std_logic_vector(31 downto 0);
    signal kernel_parameter_size_i      : std_logic_vector(15 downto 0);
    signal kernel_dyn_shmem_size_i      : std_logic_vector(31 downto 0);
    signal kernel_block_x_i             : std_logic_vector(15 downto 0);
    signal kernel_block_y_i             : std_logic_vector(15 downto 0);
    signal kernel_block_z_i             : std_logic_vector(15 downto 0);
    signal kernel_grid_x_i              : std_logic_vector(15 downto 0);
    signal kernel_grid_y_i              : std_logic_vector(15 downto 0);
    signal blocks_remaining             : std_logic_vector(31 downto 0);
    
    function minimum (
        left, right : std_logic_vector
    )
    return std_logic_vector is
    begin  -- function minimum
        if unsigned(LEFT) < unsigned(RIGHT) 
            then return LEFT;
        else 
            return RIGHT;
        end if;
    end function minimum;
    
begin

    grid_dimension          <= kernel_grid_x_in * kernel_grid_y_in;
    blocks_per_gpgpu        <= CORE_COUNT * kernel_blocks_per_core_in;
    threads_per_block_i     <= kernel_block_x_in * kernel_block_y_in * kernel_block_z_in;
    
    pBlockSchedulerStateMachine: process(clk_in)
	begin
		if(rising_edge(clk_in)) then 
            if (host_reset = '1') then
                en_reg                                      <= '0';
                rdy                                         <= '0';
                num_blocks                                  <= (others => '0');
                kernel_blocks_per_core_i                    <= (others => '0');
                kernel_num_gprs_i                           <= (others => '0');
                kernel_shmem_size_i                         <= (others => '0');
                kernel_parameter_size_i                     <= (others => '0');
                kernel_dyn_shmem_size_i                     <= (others => '0');
                kernel_block_x_i                            <= (others => '0');
                kernel_block_y_i                            <= (others => '0');
                kernel_block_z_i                            <= (others => '0');
                kernel_grid_x_i                             <= (others => '0');
                kernel_grid_y_i                             <= (others => '0');
                blocks_scheduled_cnt                        <= (others => '0');
                threads_per_block_out                       <= (others => '0');
                num_blocks_out                              <= (others => '0');
                shmem_base_addr_out                         <= (others => '0');
                shmem_size_out                              <= (others => '0');
                gprs_size_out                               <= (others => '0');
                block_x_out                                 <= (others => '0');
                block_y_out                                 <= (others => '0');
                block_z_out                                 <= (others => '0');
                grid_x_out                                  <= (others => '0');
                grid_y_out                                  <= (others => '0');
                block_idx_out                               <= (others => '0');
                shmem_params_out                            <= (others => '0');
                cmem_params_out                             <= (others => '0');
                threads_per_block_ld                        <= '0';
                num_blocks_ld                               <= '0';
                shmem_base_addr_ld                          <= '0';
                shmem_size_ld                               <= '0';
                parameter_size_ld                           <= '0';
                gprs_size_ld                                <= '0';
                block_x_ld                                  <= '0';
                block_y_ld                                  <= '0';
                block_z_ld                                  <= '0';
                grid_x_ld                                   <= '0';
                grid_y_ld                                   <= '0';
                block_idx_ld                                <= '0';
                smp_en_out                                  <= '0';
                smp_reset_out						  		<= '1';
                kernel_done							  		<= '0';
                block_scheduler_state_machine	            <= IDLE;
            else  
                case block_scheduler_state_machine is 
                    when IDLE =>
                        en_reg                              <= en;
                        blocks_scheduled_cnt                <= (others => '0');
                        num_blocks_out                      <= (others => '0');
                        shmem_base_addr_out                 <= (others => '0');
                        shmem_size_out                      <= (others => '0');
                        gprs_size_out                       <= (others => '0');
                        block_x_out                         <= (others => '0');
                        block_y_out                         <= (others => '0');
                        block_z_out                         <= (others => '0');
                        grid_x_out                          <= (others => '0');
                        grid_y_out                          <= (others => '0');
                        block_idx_out                       <= (others => '0');
                        threads_per_block_ld                <= '0';
                        num_blocks_ld                       <= '0';
                        shmem_base_addr_ld                  <= '0';
                        shmem_size_ld                       <= '0';
                        gprs_size_ld                        <= '0';
                        block_x_ld                          <= '0';
                        block_y_ld                          <= '0';
                        block_z_ld                          <= '0';
                        grid_x_ld                           <= '0';
                        grid_y_ld                           <= '0';
                        block_idx_ld                        <= '0';
                        smp_reset_out						<= '0';
                        kernel_done							<= '0';
                        if (en_reg = '0' and en = '1') then
                            kernel_blocks_per_core_i        <= kernel_blocks_per_core_in;
                            kernel_num_gprs_i               <= kernel_num_gprs_in;
                            kernel_shmem_size_i             <= kernel_shmem_size_in;
                            kernel_parameter_size_i         <= kernel_parameter_size_in;
                            kernel_dyn_shmem_size_i         <= kernel_dyn_shmem_size_in;
                            kernel_block_x_i                <= kernel_block_x_in;
                            kernel_block_y_i                <= kernel_block_y_in;
                            kernel_block_z_i                <= kernel_block_z_in;
                            kernel_grid_x_i                 <= kernel_grid_x_in;
                            kernel_grid_y_i                 <= kernel_grid_y_in;
                            rdy                             <= '0';
                            block_scheduler_state_machine   <= CALC_BLOCKS;
                        else
                            kernel_blocks_per_core_i        <= (others => '0');
                            kernel_num_gprs_i               <= (others => '0');
                            kernel_shmem_size_i             <= (others => '0');
                            kernel_parameter_size_i         <= (others => '0');
                            kernel_dyn_shmem_size_i         <= (others => '0');
                            kernel_block_x_i                <= (others => '0');
                            kernel_block_y_i                <= (others => '0');
                            kernel_block_z_i                <= (others => '0');
                            kernel_grid_x_i                 <= (others => '0');
                            kernel_grid_y_i                 <= (others => '0');
                            rdy                             <= '1';
                        end if;
                    when CALC_BLOCKS =>
                        if (blocks_scheduled_cnt < grid_dimension) then
                            num_blocks                      <= minimum(x"0000000" & kernel_blocks_per_core_i, blocks_remaining);
                            smp_reset_out		    		<= '0';
                            block_scheduler_state_machine   <= CHECK_BLOCKS;
                         else
                            rdy                             <= '1';
                            kernel_done					    <= '1';
                            block_scheduler_state_machine   <= IDLE;
                        end if;
                    when CHECK_BLOCKS =>
                        if (num_blocks > 0) then
                            threads_per_block_out           <= threads_per_block_i(11 downto 0);
                            num_blocks_out                  <= num_blocks(3 downto 0);
                            shmem_base_addr_out             <= (others => '0');
                            shmem_size_out                  <= (x"10" + kernel_parameter_size_i + kernel_shmem_size_i + kernel_dyn_shmem_size_i + x"FF") and (not x"000000FF");
                            parameter_size_out              <= kernel_parameter_size_i;
                            gprs_size_out                   <= kernel_num_gprs_i;
                            block_x_out                     <= kernel_block_x_i;
                            block_y_out                     <= kernel_block_y_i;
                            block_z_out                     <= kernel_block_z_i;
                            grid_x_out                      <= kernel_grid_x_i;
                            grid_y_out                      <= kernel_grid_y_i;
                            block_idx_out                   <= blocks_scheduled_cnt;
                            threads_per_block_ld            <= '1';
                            num_blocks_ld                   <= '1';
                            shmem_base_addr_ld              <= '1';
                            shmem_size_ld                   <= '1';
                            parameter_size_ld               <= '1';
                            gprs_size_ld                    <= '1';
                            block_x_ld                      <= '1';
                            block_y_ld                      <= '1';
                            block_z_ld                      <= '1';
                            grid_x_ld                       <= '1';
                            grid_y_ld                       <= '1';
                            block_idx_ld                    <= '1';
                            block_scheduler_state_machine   <= SCHEDULE_BLOCKS;
                        else
                            block_scheduler_state_machine   <= IDLE;
                        end if;
                    when SCHEDULE_BLOCKS =>
                        threads_per_block_ld                <= '0';
                        num_blocks_ld                       <= '0';
                        shmem_base_addr_ld                  <= '0';
                        shmem_size_ld                       <= '0';
                        parameter_size_ld                   <= '0';
                        gprs_size_ld                        <= '0';
                        block_x_ld                          <= '0';
                        block_y_ld                          <= '0';
                        block_z_ld                          <= '0';
                        grid_x_ld                           <= '0';
                        grid_y_ld                           <= '0';
                        block_idx_ld                        <= '0';
                        blocks_scheduled_cnt                <= blocks_scheduled_cnt + num_blocks(15 downto 0);
                        smp_en_out                          <= '1';
                        block_scheduler_state_machine       <= SCHEDULE_WAIT;
                    when SCHEDULE_WAIT =>
                        smp_en_out                          <= '0';
                        smp_done_in_reg                     <= smp_done_in;
                        if (smp_done_in_reg = '0' and smp_done_in = '1') then
                            smp_reset_out					<= '1';
                            block_scheduler_state_machine   <= CALC_BLOCKS;
                        end if;
                    when others =>
                        block_scheduler_state_machine       <= IDLE;
                end case;
            end if;
        end if;
    end process;
    
    pCalcBlocksRemaining : process(clk_in)
    begin
        if (rising_edge(clk_in)) then 
            if (host_reset = '1') then
                blocks_remaining        <= (others => '0');
            else
                blocks_remaining        <= grid_dimension - blocks_scheduled_cnt;
            end if;
        end if;
    end process;
    
end arch;

