-- dh11.vhd
-- Template for interfacing with a DHT11 temperature and humidity sensor in VHDL

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dh11 is
    Port (
        clk         : in  std_logic;         -- System clock (lets imagine we get 100kHz clock)
        rst         : in  std_logic;         -- Asynchronous reset
        dht_data_io : inout std_logic;       -- Bidirectional data line to DHT11 sensor
        start       : in  std_logic;         -- Start signal to begin data acquisition
        ready       : out std_logic;         -- Indicates data is ready
        temperature : out std_logic_vector(7 downto 0); -- 8-bit temperature output
        humidity    : out std_logic_vector(7 downto 0)  -- 8-bit humidity output
    );
end dh11;

architecture Behavioral of dh11 is

    type state_type is (IDLE, START_CONDITION, DH11_ACK_RESPONSE, DH11_ACK_GET_READY,DATA_TRANSFER);
    signal state : state_type := IDLE;
    signal bit_cnt : integer range 0 to 40 := 0; -- DHT11 sends 40 bits of data
    signal counter : integer := 0; -- General purpose counter for timing
    signal dh11_ack_bit: std_logic := '0'; -- Acknowledge signal from DHT11
begin
process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            state <= IDLE;
            ready <= '0';
            temperature <= (others => '0');
            humidity <= (others => '0');
            dht_data_io <= 'Z'; -- High impedance when not driving
        else
            case state is
                when IDLE =>
                    if start = '1' then
                        state <= START_CONDITION;
                        ready <= '0';
                    end if;

                when START_CONDITION =>
                    if counter < 1800 then -- Hold low for at least 18ms
                        dht_data_io <= '0'; -- Drive the line low
                        counter <= counter + 1;
                    elsif counter < 1802 then -- Wait for 20-40us
                        dht_data_io <= 'Z'; -- Release the line
                        counter <= counter + 1;
                    else
                        counter <= 0;
                        dht_data_io <= 'Z'; -- Release the line
                        state <= DH11_ACK;
                    end if;

                when DH11_ACK_RESPONSE =>
                    if dht_data_io='0' then
                        dh11_ack_bit <= '1'; -- DHT11 pulls line low to acknowledge
                        counter <= counter + 1;
                    end if;
                    if counter > 8 then -- Wait for 80us
                        state <= DH11_ACK_GET_READY;
                        counter <= 0;
                    end if;
                when DH11_ACK_GET_READY =>
                    if dht_data_io='1' then
                        counter <= counter + 1;
                    end if;
                    if counter > 8 then -- Wait for 80us
                        state <= DATA_TRANSFER;
                        counter <= 0;
                    end if;
                when DATA_TRANSFER =>
                    if bit_cnt < 40 then
                        if dht_data_io = '0' then
                            counter <= counter + 1;
                        else
                            if counter > 30 then -- If high for more than 30us, it's a '1'
                                if bit_cnt < 8 then
                                    humidity(7 - bit_cnt) <= '1';
                                elsif bit_cnt < 16 then
                                    humidity(15 - bit_cnt) <= '1';
                                elsif bit_cnt < 24 then
                                    temperature(7 - (bit_cnt - 16)) <= '1';
                                elsif bit_cnt < 32 then
                                    temperature(15 - (bit_cnt - 16)) <= '1';
                                end if;
                            else -- Otherwise it's a '0'
                                if bit_cnt < 8 then
                                    humidity(7 - bit_cnt) <= '0';
                                elsif bit_cnt < 16 then
                                    humidity(15 - bit_cnt) <= '0';
                                elsif bit_cnt < 24 then
                                    temperature(7 - (bit_cnt - 16)) <= '0';
                                elsif bit_cnt < 32 then
                                    temperature(15 - (bit_cnt - 16)) <= '0';
                                end if;
                            end if;
                            bit_cnt <= bit_cnt + 1;
                            counter <= 0;
                        end if;
                    else
                        bit_cnt <= 0;
                        counter <= 0;
                    ready <= '1';
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end if;
end process;

end Behavioral;