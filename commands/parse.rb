require 'json'

Pokemon = Struct.new(:name, :nickname, :kills, :status, :team, :indirect, :retaliation_storage, :perish_setter) do
  kills = 0;
end

# removes the positional marker from hash keys to not see double in double battles
def uniformize_key(input)
  if((input =~ /p\d[abcd]/) != nil)
    output = "#{input}"
    output[2] = ":"
    return output
  else
    return "BAD KEY"
  end
end

def parse_log(replay_link)
  output = "Link: #{replay_link}\n"
  poke_hash = Hash.new
  response = `curl -s #{replay_link}.log`
  if(response.nil? || response.split("\n").size == 0)
    event.edit_response(content: "Showdown's servers appear to be down! Or they changed the replay format. Please Arceus let it be the former.")
    return 0
  end
  toxic_debris_source = nil
  future_sight_setter = nil
  last_damager = nil
  weather_setter = nil
  rock_setter =   [nil, nil]
  spike_setter =  [nil, nil]
  tspike_setter = [nil, nil]
  team_user = ["", ""]
  winner = ""
  cause = ""
  stored_cause = ""

  response.split("\n").each do |line|
    # puts line
    fields = line.split("|")
    if fields.size > 0
      linetype = fields[1]
      key = uniformize_key(fields[2]) unless fields.size < 3 || fields[2].size < 3
      case linetype

      when "poke"
        if fields[3].include? "Zoroark"
          output += "\n**WARNING: ZOROARK DETECTED. MANUAL VERIFICATION OF KILLS RECOMMENDED.**\n\n"
        end

      when "player"
        team_user[fields[2][1].to_i - 1] = fields[3] if fields.size >= 5

      when "switch", "drag", "replace"
        # clear last damager (used to detect tspike status)
        last_damager = nil unless linetype == "replace"
        # add new poke to the hash
        unless poke_hash.key?(key)
          name = fields[3].split(",")[0]
          nickname = fields[2].split(" ")[1..-1].join(" ")
          team = fields[2][1].to_i
          poke_hash[key] = Pokemon.new(name, nickname, 0, "", team, nil, nil, nil)
        end

      when "move"
        # grab pokemon name
        last_damager = poke_hash[key]            
        cause = fields[3]
        last_damager.retaliation_storage = nil
        poke_hash[uniformize_key(fields[4])].retaliation_storage = nil if fields.size >= 5 && uniformize_key(fields[4]) != "BAD KEY"

      when "-damage"
        # non-move sources of damage
        if(fields.size >= 5)
          if(fields.size >= 6 && fields[5].split(" ")[0] == "[of]" && poke_hash[uniformize_key(fields[5].split(" ")[1..-1].join(" "))].retaliation_storage.nil?)
            attacker = uniformize_key(fields[5].split(" ")[1..-1].join(" "))
            if(attacker != key)
              poke_hash[attacker].retaliation_storage = last_damager                  
              stored_cause = cause
            end
            last_damager = poke_hash[uniformize_key(fields[5].split(" ")[1..-1].join(" "))]
            cause = fields[4].split(" ")[1..-1].join(" ")                
          else
            from = fields[4].split(" ")[1..-1].join(" ")
            case from
            when "item: Life Orb"
              last_damager = poke_hash[key]
              cause = "Life Orb chip"
            when "Recoil"
              last_damager = poke_hash[key]
              cause = "#{cause} recoil"
            when "Stealth Rock"
              last_damager = rock_setter[poke_hash[key].team%2]
              cause = "Stealth Rock chip"
            when "Spikes"
              last_damager = spike_setter[poke_hash[key].team%2]
              cause = "Spikes chip"
            when "psn", "brn", "tox"
              last_damager = poke_hash[key].status
              cause = "status damage"
            when "Sandstorm", "Hail"
              last_damager = weather_setter
              cause = "weather chip"
            when "Salt Cure"
              last_damager = poke_hash[key].indirect
              cause = "Salt Cure chip"
            when "confusion"
              last_damager = poke_hash[key]
              cause = "hitting itself"
            else
            end
          end             
        end
        
      when "-status"
        if(fields.size >= 5 && fields[4].split(" ")[1] == "item")
          poke_hash[key].status = poke_hash[key]
        elsif(fields.size >= 6 && fields[5].split(" ")[0] == "[of]")
          poke_hash[key].status = poke_hash[uniformize_key(fields[5].split(" ")[1..-1].join(" "))]
        elsif(last_damager.nil?)
          poke_hash[key].status = tspike_setter[poke_hash[key].team%2]
        else
          poke_hash[key].status = last_damager
        end

      when "-start"
        move = fields[3].gsub("move: ","")
        if(move == "Salt Cure")
          poke_hash[key].indirect = last_damager
        elsif(move == "Future Sight")
          future_sight_setter = poke_hash[key]
        elsif(fields.size >= 5 && move == "perish3" )
          poke_hash[key].perish_setter = last_damager
        elsif(move == "perish0")
          last_damager = poke_hash[key].perish_setter
          poke_hash[key].retaliation_storage = nil
          cause = "Perish Song"
        end

      when "-end" 
        move = fields[3].split(" ")[1..-1].join(" ")
        if(move == "Future Sight")
          last_damager = future_sight_setter
          future_sight_setter = nil
          cause = "Future Sight"
        end

      when "-activate"
        # handle special activations
        activation = fields[3].split(" ")[1..-1].join(" ")
        if(["Destiny Bond", "Aftermath", "Toxic Debris"].include?(activation))
          toxic_debris_source = last_damager if activation == "Toxic Debris" && poke_hash[key] != last_damager
          last_damager = poke_hash[key]
          cause = activation unless activation == "Toxic Debris"
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
          if(!toxic_debris_source.nil?)
            last_damager = toxic_debris_source
            toxic_debris_source = nil
          end
        elsif(fields[3] == "Spikes")
          spike_setter[team%2] = last_damager
        elsif(move == "Stealth Rock")
          rock_setter[team%2] = last_damager
        end

      when "faint"
        victim = poke_hash[key].name
        if(!(poke_hash[key].retaliation_storage.nil?) && !(stored_cause.empty?)) # Literally only for when you kill a guy but then die to the retaliation of like, rough skin or something
          output += "#{victim} was KO'd by #{poke_hash[key].retaliation_storage.name} via #{stored_cause}\n"
          poke_hash[key].retaliation_storage.kills += 1
          stored_cause = ""
        else
          output += "#{victim} was KO'd by #{poke_hash[key] == last_damager ? "themselves": last_damager.name} via #{cause}\n"
          unless(poke_hash[key] == last_damager)
            last_damager.kills += 1
          end
        end
      
      when "win"
        winner = fields[2]

      else
      end
    end # if fields.size > 0
  end # response.split("\n").each do |line|
  output += "\nWinner: #{winner}\n\n"
  poke_hash.each_pair do |k,v|
    output += "Team #{team_user[v.team-1]}: #{v.name}#{v.name == v.nickname ? "" : " (#{v.nickname})"} got #{v.kills} KO#{v.kills > 1 ? "s" : ""}\n" if v.kills > 0
  end
  return output[0..1999]
end

def setup_parse_commands(bot)
  bot.application_command(:parselog) do |event|
    replay_link = event.target.content.gsub("battle-","")
    unless /^https:\/\/replay\.pokemonshowdown\.com\/[a-z0-9]+-\d+-?[a-z0-9]*$/ =~ replay_link
      event.respond(content: "Incorrect usage! Please use me on a message containing only a showdown replay link.", ephemeral: true)
    else
      event.respond(content: "Spoink is thinking and bouncing...", ephemeral: true)
      begin
        output = parse_log(replay_link)
      rescue => exception
        event.edit_response(content: "Oh no! I fell over. Show Mesp this message: #{exception.to_s}")
      else
        event.edit_response(content: output)
      end     
    end
  end
end
