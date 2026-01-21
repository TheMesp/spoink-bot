require_relative "../data/banlist.rb"

# recursively returns valid evos
def trace_evo_tree(chain, base_form, passed_base_form)
  # stupid edge cases
  return ['you decide'] if base_form == 'eevee'
  return ['porygon-z'] if base_form == 'porygon'
  output = []
  if passed_base_form && !POKEDEX_BANLIST.include?(chain['species']['name'])
   output += [chain['species']['name']]
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

def setup_mod_commands(bot)
  
  bot.application_command(:mod100) do |event|
    
    if event.options['num'] && (event.options['num'].to_i < 1 || event.options['num'] > 100)
      event.respond(content:"Invalid number. Only 1-100, please.", ephemeral: true)
    else
      event.respond(content:"Generating, please wait...")
      num = event.options['num'].to_i
      output_names = []
      output_ids = []
      for i in 0..10 do
        next_id = num + (i * 100)
        if next_id <= MAX_POKEDEX_NUM
          response = `curl -s https://pokeapi.co/api/v2/pokemon-species/#{next_id}`
          response = JSON.parse(response)
          poke_name = response['name']
          formatted_poke_name = poke_name
          if(POKEDEX_BANLIST.include? poke_name)
            formatted_poke_name = "~~#{poke_name}~~"
          elsif(TERA_BANLIST.include? poke_name)
            formatted_poke_name = "*#{poke_name}* (NO TERA)"
          end
          output_ids << next_id
          if response['evolution_chain']
            evos = get_evos(response['evolution_chain']['url'].split('evolution-chain/')[1].to_i, poke_name)
            formatted_poke_name << " (#{evos.join(", ")})" unless evos.empty?
          end
          formatted_poke_name << " (Kanto only)" if poke_name == "moltres"
          output_names << formatted_poke_name
        end
      end
      extra_format = num < 10 || num == 100 ? "0" : ""
      embed_title = "Team X#{extra_format}#{num%100}:"
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