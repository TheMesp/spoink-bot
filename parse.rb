require 'json'
# https://replay.pokemonshowdown.com/gen8doublescustomgame-1650614891.log
# https://replay.pokemonshowdown.com/gen8nationaldex-1476000200.log
# https://replay.pokemonshowdown.com/gen8nationaldex-1476004100.log

Pokemon = Struct.new(:trainer, :name, :nickname, :kills) do
  kills = 0;
end

def parse_log(replay_link)
  unless /^https:\/\/replay\.pokemonshowdown\.com\/[a-z0-9]+-\d+$/ =~ replay_link
    puts "bad format"
  else
    response = `curl -s #{replay_link}.log`
    last_damager = ""
    response.split("\n").each do |line|
      fields = line.split("|")
      if fields.size > 0
        linetype = fields[1]
        case linetype
        when "move"
          # grab pokemon name
          last_damager = fields[2].split(" ")[1..-1].join(" ")
        when "-activate"
          # handle special activations
          if(fields[3].split(" ")[1..-1].join(" ") == "Destiny Bond")
            last_damager = fields[2].split(" ")[1..-1].join(" ")
          end
        when "faint"
          victim = fields[2].split(" ")[1..-1].join(" ")
          puts "#{victim} fainted by #{last_damager}"
        else
        end
      end # if fields.size > 0
    end # response.split("\n").each do |line|
    puts "good format"
  end
end
parse_log("https://replay.pokemonshowdown.com/gen8doublescustomgame-1650614891");