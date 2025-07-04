require_relative "../data/banlist.rb"
MAX_ROLL_NUM = 1025
MAX_POKEDEX_NUM = 1025

HARDCODED_POKEDEX = %w(
)

RIGGED_POKEDEX = [203, 563, 867, 981]

# recursively returns valid evos
def trace_evo_tree(chain, base_form, passed_base_form)
  # stupid edge cases
  return ['you decide'] if base_form == 'eevee'
  return ['Melmetal, and a free phone'] if base_form == 'meltan'
  return ['Manaph...haha just kidding sylvee'] if base_form == 'phione'
  output = []
  if passed_base_form && !POKEDEX_BANLIST.include?(chain['species']['name'])
   output += [chain['species']['name'].capitalize]
  end
  chain['evolves_to'].each do |evo|
    output += trace_evo_tree(evo, base_form, passed_base_form || chain['species']['name'] == base_form)
  end
  return output
end

# given a pokeAPI evolution-chain id and pokemon name, determine all valid evolutions
def get_evos(id, name)
  response = `curl -s https://pokeapi.co/api/v2/evolution-chain/#{id}`
  response = JSON.parse(response)
  output = []
  output += trace_evo_tree(response['chain'], name, false)
  return output
end

def setup_rng_commands(bot)
  
  bot.application_command(:roll) do |event|
    if event.options['forceid'] && event.user.id != 116674993424826375
      event.respond(content:"Sorry, only Mesp can use this option, it's just for testing", ephemeral: true)
    end
    if event.options['num'] && (event.options['num'].to_i < 1 || event.options['num'] > 6)
      event.respond(content:"Invalid number. Only 1-6, please.", ephemeral: true)
    else
      event.respond(content:"Generating, please wait...")
      num = !event.options['num'] ? 6 : event.options['num'].to_i
      output_names = []
      output_ids = []
      print("rolling\n")
      for i in 1..num do
        poke_name = ''
        loop do
          next_id = event.options['rig'] ? RIGGED_POKEDEX.sample : rand(1..MAX_ROLL_NUM)
          next_id = event.options['forceid'].to_i if event.options['forceid']
          print next_id
          print("\n")
          if next_id <= MAX_POKEDEX_NUM
            response = `curl -s https://pokeapi.co/api/v2/pokemon-species/#{next_id}`
            response = JSON.parse(response)
            temp_name = ""
            loop do
              temp_name = response['varieties'].sample['pokemon']['name']
              unless temp_name.include?('-mega') || temp_name.include?('-gmax') || temp_name.include?('-totem')
                break
              end
            end     
            if POKEDEX_BANLIST.include? temp_name
              poke_name << "~~#{temp_name.capitalize}~~ "
            else
              poke_name << temp_name.capitalize
              if response['evolution_chain']
                evos = get_evos(response['evolution_chain']['url'].split('evolution-chain/')[1].to_i, temp_name)
                poke_name << " (#{evos.join(", ")})" unless evos.empty?
              end
              output_names << poke_name
              output_ids << next_id
              break
            end
          else
            output_names << HARDCODED_POKEDEX.sample
            output_ids << "???"
            break
          end
        end
        
      end
      embed_title = event.options['rig'] ? "Rigged team of #{num}:" : "Team of #{num}:"
      embed_title = "DEBUG MODE: Forced output" if event.options['forceid']
      response_embed = Discordrb::Webhooks::Embed.new(
        title: embed_title
      )
      output_names.each_with_index do |output, i|
        response_embed.add_field(name: "##{output_ids[i]}", value: output)
      end
      event.edit_response(embeds:[response_embed.to_hash])
    end
  end
end