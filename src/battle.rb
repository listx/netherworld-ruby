require_relative 'monster.rb'
require_relative 'random.rb'

def spawn_monsters(gs)
	gs.monsters << Monster.new(gs.rng)
end

def battle_trigger(gs)
	r = gs.rng.roll(100)
	if r < 7
		puts "You enter a battle!!!"
		spawn_monsters(gs)
		battle_loop(gs)
	end
end

def battle_loop(gs)
	battle_player_option(gs)
	#battle_monster_option(gs)
	if gs.monsters.empty?
		puts "You defeat all monsters!"
		gs.last_battle_command = ""
	else
		battle_loop(gs)
	end
end

def battle_player_option(gs)
	str = get_user_input(gs)
	if str.split(' ').length > 0
		run_option(gs, str)
	else
		run_option(gs, gs.last_battle_command)
	end
end

def run_option(gs, str)
	case str
	when "f"
		gs.last_battle_command = str
		r = gs.rng.roll(100)
		puts "You do #{r} damage!"
		ms = []
		gs.monsters.each do |m|
			m.stats.sub!(:health, r)
			if m.stats.hash[:health] > 0
				ms << m
			end
		end
		gs.monsters = ms
	else
		puts "What?"
		gs.last_battle_command = str
		battle_player_option(gs)
	end
end
