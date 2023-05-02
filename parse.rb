require 'json'
# https://replay.pokemonshowdown.com/gen8doublescustomgame-1650614891.log
# https://replay.pokemonshowdown.com/gen8nationaldex-1476000200.log
# https://replay.pokemonshowdown.com/gen8nationaldex-1476004100.log

Pokemon = Struct.new(:name, :nickname, :kills, :status, :team) do
  kills = 0;
end

# removes the positional marker from hash keys to not see double in double battles
def uniformize_key(input)
  # TODO: regex to check format
  output = input
  output[2] = ":"
  return output
end

def parse_log(replay_link)
  unless /^https:\/\/replay\.pokemonshowdown\.com\/[a-z0-9]+-\d+$/ =~ replay_link
    puts "bad format"
  else
    poke_hash = Hash.new
    response = `curl -s #{replay_link}.log`
    last_damager = ""
    response.split("\n").each do |line|
      fields = line.split("|")
      if fields.size > 0
        linetype = fields[1]
        key = uniformize_key(fields[2]) unless fields.size < 3 || fields[2].size < 3
        case linetype

        when "switch", "drag"
          # add new poke to the hash
          unless poke_hash.key?(key)
            name = fields[3].split(",")[0]
            nickname = fields[2].split(" ")[1..-1].join(" ")
            team = fields[2][1].to_i
            poke_hash[key] = Pokemon.new(name, nickname, 0, "", team)
          end

        when "move"
          # grab pokemon name
          last_damager = poke_hash[key]

        when "-activate"
          # handle special activations
          if(fields[3].split(" ")[1..-1].join(" ") == "Destiny Bond")
            last_damager = poke_hash[key]
          end

        when "faint"
          victim = poke_hash[key].name
          last_damager.kills += 1
        else
        end
      end # if fields.size > 0
    end # response.split("\n").each do |line|
    puts "good format"
    poke_hash.each_pair do |k,v|
      puts "Team #{v.team}: #{v.name} (#{v.nickname}) got #{v.kills} kills"
    end
  end
end
parse_log("https://replay.pokemonshowdown.com/gen8doublescustomgame-1650614891");