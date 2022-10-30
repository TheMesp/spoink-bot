require 'discordrb'
require 'json'
require 'pry'
require_relative 'secrets.rb'
require_relative 'command_registry.rb'
require_relative 'commands/pokemon.rb'
require_relative 'commands/rng.rb'
bot = Discordrb::Commands::CommandBot.new token: DISCORD_TOKEN, client_id: DISCORD_CLIENT, prefix: 's/'

register_commands(bot)
setup_pokemon_commands(bot)
setup_rng_commands(bot)

bot.run(true)
puts 'bot active'
bot.join
