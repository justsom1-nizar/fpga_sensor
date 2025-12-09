library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CLA_4bit_tb is
end CLA_4bit_tb;

architecture Behavioral of CLA_4bit_tb is
    component CLA_4bit is
        Port ( A : in STD_LOGIC_VECTOR(3 downto 0);
               B : in STD_LOGIC_VECTOR(3 downto 0);
               Cin : in STD_LOGIC;
               Sum : out STD_LOGIC_VECTOR(3 downto 0);
               Cout : out STD_LOGIC);
    end component;
    
    signal A : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal B : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal Cin : STD_LOGIC := '0';
    signal Sum : STD_LOGIC_VECTOR(3 downto 0);
    signal Cout : STD_LOGIC;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: CLA_4bit port map (
        A => A,
        B => B,
        Cin => Cin,
        Sum => Sum,
        Cout => Cout
    );
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Test case 1: 0 + 0 + 0 = 0
        A <= "0000"; B <= "0000"; Cin <= '0';
        wait for 10 ns;
        
        -- Test case 2: 5 + 3 + 0 = 8
        A <= "0101"; B <= "0011"; Cin <= '0';
        wait for 10 ns;
        
        -- Test case 3: 7 + 8 + 0 = 15
        A <= "0111"; B <= "1000"; Cin <= '0';
        wait for 10 ns;
        
        -- Test case 4: 15 + 1 + 0 = 16 (overflow, Cout = 1)
        A <= "1111"; B <= "0001"; Cin <= '0';
        wait for 10 ns;
        
        -- Test case 5: 15 + 15 + 0 = 30 (overflow, Cout = 1)
        A <= "1111"; B <= "1111"; Cin <= '0';
        wait for 10 ns;
        
        -- Test case 6: 5 + 3 + 1 = 9 (with carry in)
        A <= "0101"; B <= "0011"; Cin <= '1';
        wait for 10 ns;
        
        -- Test case 7: 15 + 15 + 1 = 31 (max value with carry)
        A <= "1111"; B <= "1111"; Cin <= '1';
        wait for 10 ns;
        
        -- Test case 8: 0 + 0 + 1 = 1
        A <= "0000"; B <= "0000"; Cin <= '1';
        wait for 10 ns;
        
        -- Test case 9: 10 + 5 + 0 = 15
        A <= "1010"; B <= "0101"; Cin <= '0';
        wait for 10 ns;
        
        -- Test case 10: 8 + 8 + 0 = 16 (overflow, Cout = 1)
        A <= "1000"; B <= "1000"; Cin <= '0';
        wait for 10 ns;
        
        -- End simulation
        report "CLA 4-bit Testbench completed successfully!";
        wait;
    end process;
end Behavioral;