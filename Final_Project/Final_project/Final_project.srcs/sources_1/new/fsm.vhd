library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity fsm_sc is
    Port ( clk : in STD_LOGIC;
           --rst : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           dp : out STD_LOGIC);
end fsm_sc;

architecture Behavioral of fsm_sc is

type states is(start, idle, countUpT1 ,countDwT1, countUpT2, countDwT2, reset, update_display);

signal current_state,next_state: states;
signal incrementT1, decrementT1, incrementT2, decrementT2: std_logic;
signal score : STD_LOGIC_VECTOR (15 downto 0);
signal i : integer range 0 to 15; 


component driver7seg is
    Port ( clk : in STD_LOGIC; --100MHz board clock input
           Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
           an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
           seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
           dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
           dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
           rst : in STD_LOGIC); --global reset
end component driver7seg;

signal Din : STD_LOGIC_VECTOR (15 downto 0); 
signal dp_in : STD_LOGIC_VECTOR (3 downto 0);

 component DeBouncer is
    port(   Clock : in std_logic;
            Reset : in std_logic;
            button_in : in std_logic;
            pulse_out : out std_logic
        );
    end component;

component db_5s is
    port(   Clock : in std_logic;
            Reset : in std_logic;
            button_in : in std_logic;
            pulse_out : out std_logic
        );
end component db_5s;
    
    signal btn_db: std_logic_vector(4 downto 0);
    
    
begin



db3: DeBouncer port map(Clock=>clk,
                        Reset=>btn_db(4),
                        button_in=>btn(3),
                        pulse_out=>btn_db(3));
                        
db2: DeBouncer port map(Clock=>clk,
                         Reset=>btn_db(4),
                         button_in=>btn(2),
                         pulse_out=>btn_db(2));
db1: DeBouncer port map(Clock=>clk,
                        Reset=>btn_db(4),
                        button_in=>btn(1),
                        pulse_out=>btn_db(1));
db0: DeBouncer port map(Clock=>clk,
                         Reset=>btn_db(4),
                         button_in=>btn(0),
                         pulse_out=>btn_db(0));
                         
r5: db_5s port map(Clock=>clk,
                         Reset=>btn_db(4),
                         button_in=>btn(4),
                         pulse_out=>btn_db(4));
                                                  
u : driver7seg port map (clk => clk,
                        Din => score,
                        an => an,
                        seg => seg,
                        dp_in => "0000",
                        dp_out => dp,
                        rst => btn(4));
                        
process (clk, btn_db(4))
    begin
     if btn_db(4) = '1' then
         current_state <= idle;
     elsif rising_edge(clk) then
           current_state <= next_state;
     end if;    
    end process;
    
process (current_state, btn_db)
    begin
      case current_state is
        when reset => next_state <= start;
        when start => next_state <= idle;
        when idle => if btn_db(3) = '1' then
                         next_state <= countUpT1;
                      elsif btn_db(2) = '1' then
                         next_state <= countUpT2;
                      elsif btn_db(1) = '1' then
                          next_state <= countDwT1;
                      elsif btn_db(0) = '1' then
                          next_state <= countDwT2;
                      else
                          next_state <= idle;
                      end if;
        when countUpT1 => next_state <= idle;
        when countUpT2 => next_state <= idle;
        when countDwT1 => next_state <= idle;
        when countDwT2 => next_state <= idle;
        when others => next_state <= idle;
      end case;                                            
    end process;    

generate_scor: process (clk, btn_db(4))
  variable mii, sute, zeci, unitati: integer range 0 to 9 := 0;
begin
  if btn_db(4) = '1' then
    score <= (others => '0');
        mii := 0;
        sute := 0;
        zeci := 0;
        unitati := 0;
    elsif rising_edge(clk) then
        if current_state = countUpT1 then
            if unitati = 9 then
                unitati := 0;
                    if zeci = 9 then
                        zeci := 0;
                     else
	                    zeci := zeci+1;
                    end if;
            else
               unitati := unitati+1;
        end if;

        elsif current_state = countUpT2 then    
            if sute = 9 then
                sute:=0;
                    if mii = 9 then
                        mii := 0;
                        --sute:= 0;
                    else
	                   mii:= mii+1;
                    end if;
            else
	           sute := sute+1;
            end if;
       --end if;

       elsif current_state = countDwT1 then    
            if unitati = 0 then
                unitati:= 9;
                    if zeci = 0 then
                        zeci:= 9;
                    else
	                   zeci := zeci -1;
                    end if;
            else
	            unitati := unitati-1;
            end if;

       elsif current_state = countDwT2 then    
            if sute = 0 then
                sute := 9;
                    if mii = 0 then
                        mii:= 9;
                    else
	                   mii := mii -1;
                    end if;
            else
	            sute := sute-1;
            end if;
    
    
    
end if;
score <= std_logic_vector(to_unsigned(mii,4)) &
             std_logic_vector(to_unsigned(sute,4)) &
             std_logic_vector(to_unsigned(zeci,4)) &
             std_logic_vector(to_unsigned(unitati,4));
end if;
end process; 

end Behavioral;


