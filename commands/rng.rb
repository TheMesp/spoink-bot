MAX_POKEDEX_NUM = 898
# POKEDEX_BANLIST = [
#   # 493,898,815,491,555,386,483,882,887,890,649,487,383,250,382,646,645,249,792,
#   # 802,801,150,804,800,484,795,384,643,492,791,897,641,892,716,717,888,889,644,718
  
# ]
POKEDEX_BANLIST = %w(
  arceus
  calyrex-ice
  calyrex-shadow
  cinderace
  darkrai
  darmanitan-galar
  deoxys-normal
  deoxys-attack
  deoxys-speed
  dialga 
  dracovish
  dragapult
  eternatus
  eternatus-eternamax
  genesect
  giratina-altered
  giratina-origin
  groudon
  ho-oh
  kyogre
  kyurem-black
  kyurem-white
  landorus-incarnate
  lugia
  lunala
  marshadow
  magearna
  mewtwo
  naganadel
  necrozma-dawn-wings
  necrozma-dusk-mane
  palkia
  pheromosa
  rayquaza
  reshiram
  shaymin-sky
  solgaleo
  spectrier
  tornadus-therian
  urshifu-single-strike
  xerneas
  yveltal
  zacian
  zacian-crowned
  zamazenta
  zamazenta-crowned
  zekrom
  zygarde
)


# recursively returns valid evos
def trace_evo_tree(chain, base_form, passed_base_form)
  # stupid edge cases
  return ['urshifu-rapid-strike'] if base_form == 'kubfu'
  return ['you decide'] if chain['species']['name'] == 'eevee'
  return ['lol, lmao'] if chain['species']['name'] == 'cosmog'
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
    if !event.options['num'] || event.options['num'].to_i < 1 || event.options['num'] > 6
      event.respond(content:"Invalid number. Only 1-6, please.", ephemeral: true)
    else
      event.respond(content:"Generating, please wait...")
      num = event.options['num'].to_i
      output_names = []
      output_ids = []
      for i in 1..num do
        poke_name = ''
        loop do
          next_id = rand(1..MAX_POKEDEX_NUM)
          response = `curl -s https://pokeapi.co/api/v2/pokemon-species/#{next_id}`
          response = JSON.parse(response)
          temp_name = ""
          loop do
            temp_name = response['varieties'].sample['pokemon']['name']
            unless temp_name.include?('mega') || temp_name.include?('gmax') || temp_name.include?('totem')
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
        end
        
      end
      response_embed = Discordrb::Webhooks::Embed.new(
        title: "Team of #{num}:"
      )
      output_names.each_with_index do |output, i|
        response_embed.add_field(name: "##{output_ids[i]}", value: output)
      end
      event.edit_response(embeds:[response_embed.to_hash])
    end
  end
end