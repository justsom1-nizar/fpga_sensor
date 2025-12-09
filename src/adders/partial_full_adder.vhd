library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity partial_full_adder is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Cin : in STD_LOGIC;
           Sum : out STD_LOGIC;
           P : out STD_LOGIC;   -- Propagate
           G : out STD_LOGIC);  -- Generate
end partial_full_adder;

architecture Behavioral of partial_full_adder is
    signal prop : STD_LOGIC;
    signal gen : STD_LOGIC;
begin
    -- Generate: produces carry when both inputs are 1
    gen <= A and B;
    
    -- Propagate: passes carry when at least one input is 1
    prop <= A xor B;
    
    -- Sum output
    Sum <= prop xor Cin;
    
    -- Output propagate and generate for CLA logic
    P <= prop;
    G <= gen;
end Behavioral;