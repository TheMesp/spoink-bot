# David "Mesp" Loewen
# DB accessor file

require 'sqlite3'
require 'csv'

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
			favourite_pokemon int
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
	# Turn off foreign keys for dummy data since we don't control the order that tables are fed in
	db.execute "PRAGMA foreign_keys = OFF;"
	Dir.glob("/root/discordbots/spoink-project/spoink-backend/db/dummy_data/*.csv").each do |filename|
		# fetch the table name from the csv name
		tablename = filename.match(/(\w+)\.csv/).to_a[1]
		headers = []
			
		CSV.foreach(filename) do |row|
			if headers.empty?
				headers = row
			else
				# print "INSERT INTO #{tablename}(#{headers.join(', ')}) VALUES (#{row.join(', ')})\n"
				db.execute("INSERT INTO #{tablename}(#{headers.join(', ')}) VALUES (#{Array.new(headers.size, '?').join(', ')})", row)
			end
		end
	end
	db.execute "PRAGMA foreign_keys = ON;"

	# db.execute("SELECT * FROM players") do |row|
	# 	print("#{row}\n")
	# end
	# db.execute("SELECT * FROM seasons") do |row|
	# 	print("#{row}\n")
	# end

	print "Done\n"
end
setup