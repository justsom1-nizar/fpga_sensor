----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/01/2025 07:44:47 PM
-- Design Name: 
-- Module Name: i2c_master_controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.work_package.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2c_master_controller is
    Port ( SCL : in STD_LOGIC;
           SDA : inout STD_LOGIC;
           Start_sending : in STD_LOGIC;
           Addr_Byte : in STD_LOGIC_VECTOR (I2C_Adress_size-1 downto 0);
           Data_to_write : in STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0);
           R_W_bit : in STD_LOGIC;
           Data_ready_bit : out STD_LOGIC;
           Data_to_read : out STD_LOGIC_VECTOR (I2C_Data_size-1 downto 0));
end i2c_master_controller;

architecture Behavioral of i2c_master_controller is

    type state_type is (IDLE, START, ADDR, RW_BIT_STATE, WAIT_FOR_ACK,WRITE, READ, STOP);
    signal state : state_type := IDLE;
    signal bit_cnt : integer range 0 to I2C_Adress_size := 0;
    signal data_reg_Signal : STD_LOGIC_VECTOR(I2C_Data_size-1 downto 0);
    signal r_w_bit_signal : STD_LOGIC;
    signal Addr_Byte_signal : STD_LOGIC_VECTOR(I2C_Adress_size-1 downto 0);
    signal timeout_cnt : integer range 0 to timeout_limit := 0;
begin

process(SCL)
begin
    if rising_edge(SCL) then
        case state is
            when IDLE =>
                if Start_sending = '1' then
                    state <= START;
                    Addr_Byte_signal <= Addr_Byte;
                    Data_ready_bit <= '0';
                end if;

            when START =>
                state <= ADDR;
                bit_cnt <= 6;
                SDA <= '0'; -- Release SDA
                Data_ready_bit <= '0';

            when ADDR =>
                -- Send address bits
                if bit_cnt >= 0 then
                    SDA <= Addr_Byte_signal(bit_cnt);
                    if bit_cnt = 0 then
                        state <= RW_BIT_STATE;
                    else
                        bit_cnt <= bit_cnt - 1;
                    end if;
                end if;

            when RW_BIT_STATE =>
                -- Store the R/W bit while waiting for ack
                r_w_bit_signal <= R_W_bit;
                state <= WAIT_FOR_ACK;
                SDA <= 'Z'; -- Release SDA for ACK
            when WAIT_FOR_ACK =>
                if SDA = '0' then
                    -- ACK received
                    bit_cnt <= I2C_Data_size - 1;
                    if r_w_bit_signal = '0' then
                        state <= WRITE;
                        data_reg_Signal <= Data_to_write;
                    else
                        state <= READ;

                    end if;
                else
                    -- NACK received
                    if timeout_cnt < timeout_limit then
                        timeout_cnt <= timeout_cnt + 1;
                        state <= WAIT_FOR_ACK;
                    else
                        state <= STOP; -- Timeout, go to STOP
                    end if;
                end if;
            when WRITE =>
                -- Write data bits
                if bit_cnt >= 0 then
                    SDA <= data_reg_Signal(bit_cnt);
                    if bit_cnt = 0 then
                        state <= STOP;
                    else
                        bit_cnt <= bit_cnt - 1;
                    end if;
                end if;

            when READ =>
                -- Read data bits
                if bit_cnt >= 0 then
                    data_reg_Signal(bit_cnt) <= SDA;
                    if bit_cnt = 0 then
                        Data_to_read <= data_reg_Signal;
                        Data_ready_bit <= '1';
                        state <= STOP;
                    else
                        bit_cnt <= bit_cnt - 1;
                    end if;
                end if;

            when STOP =>
                SDA <= 'Z'; -- Release SDA
                Data_ready_bit <= '0';
                state <= IDLE;
            when others =>
                state <= IDLE;
        end case;
    end if;
end process;

end Behavioral;
