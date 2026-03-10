--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture behavior of thunderbird_fsm_tb is 
	
	component thunderbird_fsm
	  port (
        i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
      );
	end component;

	-- test I/O signals
	signal w_reset : std_logic := '0';
	signal w_clk : std_logic := '0';
	signal w_turn : std_logic_vector(1 downto 0) := "00"; -- for left and right signals
	
	signal w_thunderbird : std_logic_vector(5 downto 0) := "000000"; -- one-hot
	
	-- constants
	constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	uut: thunderbird_fsm port map (
	       i_clk => w_clk,
	       i_reset => w_reset,
	       i_left => w_turn(1),
	       i_right => w_turn(0),
	       o_lights_L => w_thunderbird(5 downto 3),
	       o_lights_R => w_thunderbird(2 downto 0)
	
	   );
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	
	test_proc: process
	begin
	
	   -- sequential timing		
	   w_reset <= '1';
	   wait for k_clk_period;
		 assert w_thunderbird = "000000" report "bad reset" severity failure;
		
	   w_reset <= '0';
	   wait for k_clk_period;
	   
	   -- left turn, LA on
	   w_turn <= "10"; wait for k_clk_period;
	       assert w_thunderbird = "001000" report "LA should be on" severity failure;
	   -- LA and LB on
	   wait for k_clk_period;
	       assert w_thunderbird = "011000" report "LA and LB should be on" severity failure;
	   -- LA, LB, and LC on
	   wait for k_clk_period;
	       assert w_thunderbird = "111000" report "LA, LB, and LC should be on" severity failure;
	   -- Back to OFF
       wait for k_clk_period;
           assert w_thunderbird = "000000" report "no lights should be on" severity failure;
           
       -- right turn, RA on
	   w_turn <= "01"; wait for k_clk_period;
	       assert w_thunderbird = "000001" report "RA should be on" severity failure;
	   -- RA and RB on
	   wait for k_clk_period;
	       assert w_thunderbird = "000011" report "RA and RB should be on" severity failure;
	   -- RA, RB, and RC on
	   wait for k_clk_period;
	       assert w_thunderbird = "000111" report "RA, RB, and RC should be on" severity failure;
	   --- Back to OFF
       wait for k_clk_period;
           assert w_thunderbird = "000000" report "no lights should be on" severity failure;
	
	   -- test hazards
	   w_turn <= "11"; wait for k_clk_period;
	       assert w_thunderbird = "111111" report "all lights should be on" severity failure;
	   wait for k_clk_period;
	       assert w_thunderbird = "000000" report "no lights should be on" severity failure;
	   
	   wait;
	end process;
	-----------------------------------------------------	
	
end;
