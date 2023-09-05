# David "Mesp" Loewen
# DB accessor file

require 'sqlite3'
require 'csv'
require 'httparty'

# def opendb
# 	db = SQLite3::Database.new "/root/discordbots/spoink-project/spoink-backend/db/draft_league.db"
# 	`chmod 666 /root/discordbots/spoink-project/spoink-backend/db/draft_league.db`
# 	return db
# end

# queries dummy data into backend
def setup

	print "Running Pokemon Draft League Simulator 2022...\n"
	# db.execute "PRAGMA foreign_keys = OFF;"
	Dir.glob("/root/discordbots/spoink-project/spoink-backend/db/dummy_data/*.csv").each do |filename|
		# fetch the table name from the csv name
		tablename = filename.match(/(\w+)\.csv/).to_a[1]
		headers = []
		CSV.foreach(filename) do |row|
			if headers.empty?
				headers = row
			else
				row_hash = {};			
				headers.each_with_index do |header, i|
					row_hash[header] = row[i]
				end
				print row_hash
				# HTTParty.post("http://localhost:3000/#{tablename}/", type: 'application/json', body: row_hash)
			end
		end
		
	end

	print "Done\n"
end
setup