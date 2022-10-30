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
  giratina
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
# given a pokeAPI evolution-chain id, determine the final element of the chain.
def get_final_evo(id)
  response = `curl -s https://pokeapi.co/api/v2/evolution-chain/#{id}`
  response = JSON.parse(response)
  return ''
end
def setup_rng_commands(bot)
  
  bot.application_command(:roll) do |event|
    num = event.options['num'].to_i
    output_names = []
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
          poke_name << "~~##{next_id}: #{temp_name.capitalize}~~ "
        else
          poke_name << "##{next_id}: #{temp_name.capitalize}"
          poke_name << get_final_evo(response['evolution-chain'].split('evolution-chain/')[1].to_i) if response['evolution-chain']
          output_names << poke_name
          break
        end
      end
      
    end
    response_embed = Discordrb::Webhooks::Embed.new(
      title: "Team of #{num}:",
      description: output_names.join("\n")
    )
    event.respond(embeds:[response_embed.to_hash])
  end
end