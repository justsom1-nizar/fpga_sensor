library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RCA_4bit is
    Port ( A : in STD_LOGIC_VECTOR(3 downto 0);
           B : in STD_LOGIC_VECTOR(3 downto 0);
           Cin : in STD_LOGIC;
           Sum : out STD_LOGIC_VECTOR(3 downto 0);
           Cout : out STD_LOGIC);
end RCA_4bit;

architecture Behavioral of RCA_4bit is
    component full_adder is
        Port ( A : in STD_LOGIC;
               B : in STD_LOGIC;
               Cin : in STD_LOGIC;
               Sum : out STD_LOGIC;
               Cout : out STD_LOGIC);
    end component;
    
    signal carry : STD_LOGIC_VECTOR(3 downto 0);
begin
    -- First full adder (LSB)
    FA0: full_adder port map (
        A => A(0),
        B => B(0),
        Cin => Cin,
        Sum => Sum(0),
        Cout => carry(0)
    );
    
    -- Second full adder
    FA1: full_adder port map (
        A => A(1),
        B => B(1),
        Cin => carry(0),
        Sum => Sum(1),
        Cout => carry(1)
    );
    
    -- Third full adder
    FA2: full_adder port map (
        A => A(2),
        B => B(2),
        Cin => carry(1),
        Sum => Sum(2),
        Cout => carry(2)
    );
    
    -- Fourth full adder (MSB)
    FA3: full_adder port map (
        A => A(3),
        B => B(3),
        Cin => carry(2),
        Sum => Sum(3),
        Cout => Cout
    );
end Behavioral;