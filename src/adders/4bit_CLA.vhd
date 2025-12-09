library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLA_4bit is
    Port ( A : in STD_LOGIC_VECTOR(3 downto 0);
           B : in STD_LOGIC_VECTOR(3 downto 0);
           Cin : in STD_LOGIC;
           Sum : out STD_LOGIC_VECTOR(3 downto 0);
           Cout : out STD_LOGIC);
end CLA_4bit;

architecture Behavioral of CLA_4bit is
    component partial_full_adder is
        Port ( A : in STD_LOGIC;
               B : in STD_LOGIC;
               Cin : in STD_LOGIC;
               Sum : out STD_LOGIC;
               P : out STD_LOGIC;
               G : out STD_LOGIC);
    end component;
    
    signal P : STD_LOGIC_VECTOR(3 downto 0);  -- Propagate signals
    signal G : STD_LOGIC_VECTOR(3 downto 0);  -- Generate signals
    signal C : STD_LOGIC_VECTOR(4 downto 0);  -- Carry signals
    
begin
    -- Initial carry
    C(0) <= Cin;
    
    -- Carry Lookahead Logic (calculated in parallel)
    -- C1 = G0 + P0·C0
    C(1) <= G(0) or (P(0) and C(0));
    
    -- C2 = G1 + P1·G0 + P1·P0·C0
    C(2) <= G(1) or (P(1) and G(0)) or (P(1) and P(0) and C(0));
    
    -- C3 = G2 + P2·G1 + P2·P1·G0 + P2·P1·P0·C0
    C(3) <= G(2) or (P(2) and G(1)) or (P(2) and P(1) and G(0)) or 
            (P(2) and P(1) and P(0) and C(0));
    
    -- C4 = G3 + P3·G2 + P3·P2·G1 + P3·P2·P1·G0 + P3·P2·P1·P0·C0
    C(4) <= G(3) or (P(3) and G(2)) or (P(3) and P(2) and G(1)) or 
            (P(3) and P(2) and P(1) and G(0)) or 
            (P(3) and P(2) and P(1) and P(0) and C(0));
    
    -- Partial Full Adders (generate P, G and Sum)
    PFA0: partial_full_adder port map (
        A => A(0),
        B => B(0),
        Cin => C(0),
        Sum => Sum(0),
        P => P(0),
        G => G(0)
    );
    
    PFA1: partial_full_adder port map (
        A => A(1),
        B => B(1),
        Cin => C(1),
        Sum => Sum(1),
        P => P(1),
        G => G(1)
    );
    
    PFA2: partial_full_adder port map (
        A => A(2),
        B => B(2),
        Cin => C(2),
        Sum => Sum(2),
        P => P(2),
        G => G(2)
    );
    
    PFA3: partial_full_adder port map (
        A => A(3),
        B => B(3),
        Cin => C(3),
        Sum => Sum(3),
        P => P(3),
        G => G(3)
    );
    
    -- Final carry out
    Cout <= C(4);
    
end Behavioral;