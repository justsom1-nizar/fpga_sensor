library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Cin : in STD_LOGIC;
           Sum : out STD_LOGIC;
           Cout : out STD_LOGIC);
end full_adder;

architecture Behavioral of full_adder is
    component half_adder is
        Port ( A : in STD_LOGIC;
               B : in STD_LOGIC;
               Sum : out STD_LOGIC;
               Carry : out STD_LOGIC);
    end component;
    
    signal sum1 : STD_LOGIC;
    signal carry1 : STD_LOGIC;
    signal carry2 : STD_LOGIC;
begin
    -- First half adder: A + B
    HA1: half_adder port map (
        A => A,
        B => B,
        Sum => sum1,
        Carry => carry1
    );
    
    -- Second half adder: sum1 + Cin
    HA2: half_adder port map (
        A => sum1,
        B => Cin,
        Sum => Sum,
        Carry => carry2
    );
    
    -- Final carry out
    Cout <= carry1 or carry2;
end Behavioral;