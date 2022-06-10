# David "Mesp" Loewen
# DB accessor file

require "sqlite3"

def opendb
	return SQLite3::Database.new "/root/discordbots/spoink-project/spoink-backend/db/draft_league.db"
end

# DELETES THE DATABASE, then recreates it
def setup
	print "Deleting old database...\n"
	File.delete("/root/discordbots/spoink-project/spoink-backend/db/draft_league.db") if File.exist?("/root/discordbots/spoink-project/spoink-backend/db/draft_league.db")
	print "Creating tables..."
	db = opendb
	db.execute "PRAGMA foreign_keys = ON;"	

	db.execute <<-SQL
		CREATE TABLE IF NOT EXISTS players(
			id int NOT NULL PRIMARY KEY,
			discord_id varchar(30),
			discord_name varchar(30),
			timezone varchar(10),
			showdown_name varchar(30),
			profile_pic_url varchar(60)
		);
	SQL
	db.execute <<-SQL
		CREATE TABLE IF NOT EXISTS seasons(
			id int NOT NULL PRIMARY KEY,
			start_time date,
			end_time date
		);
	SQL
	
	db.execute <<-SQL
		CREATE TABLE IF NOT EXISTS conferences(
			season_id int NOT NULL,
			conference varchar(30),
			CONSTRAINT pk PRIMARY KEY (season_id, conference),
			FOREIGN KEY (season_id) REFERENCES seasons(id) ON DELETE CASCADE
		);
	SQL

	db.execute <<-SQL
		CREATE TABLE IF NOT EXISTS teams(
			id int PRIMARY KEY,
			player_id int NOT NULL,
			season_id int NOT NULL,
			team_name varchar(60) NOT NULL,
			wins int,
			losses int,
			placement int,
			FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
			FOREIGN KEY (season_id) REFERENCES seasons(id) ON DELETE CASCADE
		);
	SQL

	db.execute <<-SQL
		CREATE TABLE IF NOT EXISTS matches(
			id int PRIMARY KEY,
			replay_link varchar(60),
			week int,
			season_id int,
			winner_id int NOT NULL,
			loser_id int NOT NULL,
			FOREIGN KEY (season_id) REFERENCES seasons(id) ON DELETE CASCADE,
			FOREIGN KEY (winner_id) REFERENCES teams(id) ON DELETE CASCADE,
			FOREIGN KEY (loser_id) REFERENCES teams(id) ON DELETE CASCADE
		)
	SQL

	# print db.foreign_key_list("conferences")

	db.execute <<-SQL
		CREATE TABLE IF NOT EXISTS pokemon(
			team_id int NOT NULL,
			pokedex_id int,
			kills int,
			CONSTRAINT pk PRIMARY KEY (team_id, pokedex_id),
			FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
		);
	SQL
	print "Tables created.\n"
	print "Running Pokemon Draft League Simulator 2022...\n"
	db.execute("INSERT INTO players(id, discord_id, discord_name, timezone, showdown_name, profile_pic_url) VALUES (?, ?, ?, ?, ?, ?)", [1, 11, "Mesp", "UTC-6", "Mesp", "https://archives.bulbagarden.net/media/upload/2/25/MDP_E_481.png"])
	db.execute("INSERT INTO players(id, discord_id, discord_name, timezone, showdown_name, profile_pic_url) VALUES (?, ?, ?, ?, ?, ?)", [2, 22, "Risa", "UTC-7", "D1770S", "https://archives.bulbagarden.net/media/upload/d/db/MDP_E_285.png"])
	# db.execute("INSERT INTO players VALUES (?)", ["Ghostly"])
	# db.execute("INSERT INTO players VALUES (?)", ["Crobatoh"])
	# db.execute("INSERT INTO players VALUES (?)", ["Risa"])

	# db.execute("INSERT INTO seasons VALUES (?,?,?)", [1,"date(2020-05-31)","date(2020-07-15)"])
	# db.execute("INSERT INTO seasons VALUES (?,?,?)", [2,"date(2021-05-31)","date(2021-07-15)"])

	# db.execute_batch <<-SQL
	# 	INSERT INTO conferences VALUES (1,'Ruby');
	# SQL
	# db.execute_batch <<-SQL
	# 	INSERT INTO conferences VALUES (2,'Ruby');
	# SQL

	# db.execute("SELECT * FROM conferences") do |row|
	# 	print("#{row}\n")
	# end
	# db.execute("SELECT * FROM seasons") do |row|
	# 	print("#{row}\n")
	# end

	# db.execute("DELETE FROM seasons WHERE id=1")
	# print "\n"
	# db.execute("SELECT * FROM conferences") do |row|
	# 	print("#{row}\n")
	# end
	db.execute("SELECT * FROM players") do |row|
		print("#{row}\n")
	end
	# db.execute("INSERT INTO player_records VALUES (?,?,?,?,?,?,?)",
	# 	["Mesp","???","Mesped Up","Diamond",2,0,0]
	# )
	# db.execute("INSERT INTO player_records VALUES (?,?,?,?,?,?,?)",
	# 	["Ghostly",1,"Rescue Team Team Team","Diamond",1,1,0]
	# )
	# db.execute("INSERT INTO player_records VALUES (?,?,?,?,?,?,?)",
	# 	["Crobatoh",1,"Brigade Brigade","Pearl",0,1,0]
	# )
	# db.execute("INSERT INTO player_records VALUES (?,?,?,?,?,?,?)",
	# 	["Rando",1,"Bad Team","Pearl",0,2,0]
	# )
	print "Done\n"
end
setup