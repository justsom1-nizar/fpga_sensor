package work_package  is

    constant CLK_PERIOD : time := 20 ns;
    constant I2C_Adress_size : integer := 7;
    constant I2C_Data_size : integer := 8;
    constant timeout_limit : integer := 1000; -- in clock cycles
end work_package;
