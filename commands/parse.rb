require 'json'

Pokemon = Struct.new(:name, :nickname, :kills, :status, :team, :indirect) do
  kills = 0;
end

# removes the positional marker from hash keys to not see double in double battles
def uniformize_key(input)
  # TODO: regex to check format
  output = input
  output[2] = ":"
  return output
end

def setup_parse_commands(bot)
  bot.application_command(:parselog) do |event|
    replay_link = event.target.content
    unless /^https:\/\/replay\.pokemonshowdown\.com\/[a-z0-9]+-\d+-?[a-z0-9]*$/ =~ replay_link
      event.respond(content: "Incorrect usage! Please use me on a message containing only a showdown replay link.", ephemeral: true)
    else
      event.respond(content: "Spoink is thinking and bouncing...")
      output = ""
      poke_hash = Hash.new
      response = `curl -s #{replay_link}.log`
      if(response.nil? || response.split("\n").size == 0)
        event.edit_response(content: "Showdown's servers appear to be down! Or they changed the replay format. Please Arceus let it be the former.")
        return 0
      end
      last_damager = nil
      weather_setter = nil
      rock_setter =   [nil, nil]
      spike_setter =  [nil, nil]
      tspike_setter = [nil, nil]
      team_user = ["", ""]

      response.split("\n").each do |line|
        # puts line
        fields = line.split("|")
        if fields.size > 0
          linetype = fields[1]
          key = uniformize_key(fields[2]) unless fields.size < 3 || fields[2].size < 3
          case linetype

          when "player"
            team_user[fields[2][1].to_i - 1] = fields[3]

          when "switch", "drag"
            # clear last damager (used to detect tspike status)
            last_damager = nil
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

          when "-damage"
            # non-move sources of damage
            if(fields.size >= 5)
              if(fields.size >= 6 && fields[5].split(" ")[0] == "[of]")
                last_damager = poke_hash[uniformize_key(fields[5].split(" ")[1..-1].join(" "))]
              else
                from = fields[4].split(" ")[1..-1].join(" ")
                case from
                when "item: Life Orb"
                  last_damager = poke_hash[key]
                when "Stealth Rock"
                  last_damager = rock_setter[poke_hash[key].team%2]
                when "Spikes"
                  last_damager = spike_setter[poke_hash[key].team%2]
                when "psn", "brn", "tox"
                  last_damager = poke_hash[key].status
                when "Sandstorm", "Hail"
                  last_damager = weather_setter
                when "Salt Cure"
                  last_damager = poke_hash[key].indirect
                else
                end
              end             
            end
            
          when "-status"
            if(fields.size >= 5 && fields[4].split(" ")[1] == "item")
              poke_hash[key].status = poke_hash[key]
            elsif(last_damager.nil?)
              poke_hash[key].status = tspike_setter[poke_hash[key].team%2]
            else
              poke_hash[key].status = last_damager
            end

          when "-start"
            if(fields.size >= 4 && fields[3] == "Salt Cure")
              poke_hash[key].indirect = last_damager
            end

          when "-activate"
            # handle special activations
            activation = fields[3].split(" ")[1..-1].join(" ")
            if(["Destiny Bond", "Aftermath", "Toxic Debris"].include?(activation))
              last_damager = poke_hash[key]
            end

          when "-weather"
            if(fields.size == 3)
              weather_setter = last_damager
            elsif(fields.size == 5)
              weather_setter = poke_hash[uniformize_key(fields[4].split(" ")[1..-1].join(" "))]
            end

          when "-sidestart"
            team = fields[2][1].to_i
            move = fields[3].split(" ")[1..-1].join(" ")
            if(move == "Toxic Spikes")
              tspike_setter[team%2] = last_damager
            elsif(fields[3] == "Spikes")
              spike_setter[team%2] = last_damager
            elsif(move == "Stealth Rock")
              rock_setter[team%2] = last_damager
            end

          when "faint"
            victim = poke_hash[key].name
            puts "#{victim} faint event"
            if(poke_hash[key] == last_damager)
              # puts "#{last_damager.name} self-KO'd"
            else
              last_damager.kills += 1
              # puts "#{last_damager.name} knocked out #{victim}"
            end
          else
          end
        end # if fields.size > 0
      end # response.split("\n").each do |line|
      poke_hash.each_pair do |k,v|
        output += "Team #{team_user[v.team-1]}: #{v.name} (#{v.nickname}) got #{v.kills} KO#{v.kills > 1 ? "s" : ""}\n" if v.kills > 0
      end
      event.edit_response(content: output)
    end
  end
end
# parse_log("https://replay.pokemonshowdown.com/gen8doublescustomgame-1650614891");
# parse_log("https://replay.pokemonshowdown.com/gen8nationaldex-1476000200");
# parse_log("https://replay.pokemonshowdown.com/gen8nationaldex-1476004100");
# parse_log("https://replay.pokemonshowdown.com/gen8doublescustomgame-1711114645");
# parse_log("https://replay.pokemonshowdown.com/gen9customgame-1858660514-gg007w3p4zsftrrl0m0qp4citylqowcpw");
