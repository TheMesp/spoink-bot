require 'discordrb'
require 'json'
require 'pry'
require_relative 'secrets.rb'
bot = Discordrb::Commands::CommandBot.new token: DISCORD_TOKEN, client_id: DISCORD_CLIENT, prefix: 's/'

bot.register_application_command(:pokemon, 'Prints basic information about a pokemon, including type and weaknesses', server_id: 662470757716197428) do |cmd|
	cmd.string('pokemon', 'The pokemon to look up')
end

bot.application_command(:pokemon) do |event|
	pokemon = event.options['pokemon'].gsub(/[^a-zA-Z0-9\-]/,'').downcase # Clean that so i don't get injected plzty
	response = `curl -s https://pokeapi.co/api/v2/pokemon/#{pokemon}`
	if response == 'Not Found'
		event.respond(content:"#{pokemon} is not a recognized pokemon!", ephemeral: true)
	else
		res = JSON.parse(response)
		typestring = res['types'][0]['type']['name'].capitalize
		typestring << "/#{res['types'][1]['type']['name'].capitalize}" if res['types'].length() == 2
		# find strengths and weaknesses
		strengths = []
		weaknesses = []
		immunities = []
		ability_immunities = {
			'dry-skin' => 'water',
			'flash-fire' => 'fire',
			'levitate' => 'ground',
			'lightning-rod' => 'electric',
			'bulletproof' => 'bullet/bomb based moves',
			'soundproof' => 'sound-based moves',
			'storm-drain' => 'water',
			'volt-absorb' => 'electric',
			'water-absorb' => 'water'
		}
		abilities = []
		res['abilities'].each do |ability|
			abilities << ability['ability']['name'].capitalize.gsub('-',' ')
			immunities << ability_immunities[ability['ability']['name']] if ability_immunities[ability['ability']['name']]
		end
		res['types'].each do |type|
			damage_relations = JSON.parse(`curl -s #{type['type']['url']}`)['damage_relations']
			damage_relations['double_damage_from'].each do |weakness|
				name = weakness['name']
				if weaknesses.include? name
					weaknesses.delete(name)
					weaknesses << "**#{name}**"
				elsif strengths.include? name
					strengths.delete(name)
				elsif !immunities.include? name
					weaknesses << name
				end
			end
			damage_relations['half_damage_from'].each do |strength|
				name = strength['name']
				if strengths.include? name
					strengths.delete(name)
					strengths << "**#{name}**"
				elsif weaknesses.include? name
					weaknesses.delete(name)
				elsif !immunities.include? name
					strengths << name
				end
			end
			damage_relations['no_damage_from'].each do |immunity|
				name = immunity['name']
				weaknesses.delete(name) if weaknesses.include? name
				immunities << name unless immunities.include? name
				strengths.delete(name) if strengths.include? name
			end
		end
		if pokemon == 'shedinja'
			strengths = []
			immunities = ['Literally everything not in weaknesses']
		end

		description = "Type: **#{typestring}**"
		description << "\nPossible Abilities: #{abilities.join(', ')}"
		description << "\nType matchups (**Bold** indicates a 4x weakness/resistance):\n"
		description << "*Resists:* #{strengths.join(", ")}\n" if strengths.length() > 0
		description << "*Weak to:* #{weaknesses.join(", ")}\n" if weaknesses.length() > 0
		description << "*Immune to:* #{immunities.join(", ")}\n" if immunities.length() > 0

		response_embed = Discordrb::Webhooks::Embed.new(
			title: "#{res['name'].capitalize}",
			description: description,
			image: Discordrb::Webhooks::EmbedImage.new(url:"#{res['sprites']['front_default']}")
		)
		res['stats'].each do |stat|
			response_embed.add_field(name: stat['stat']['name'], value: stat['base_stat'])
		end
		event.respond(embeds:[response_embed.to_hash])
	end
end

bot.run(true)
puts 'bot active'
bot.join
