require 'discordrb'
require 'json'
require 'pry'
require_relative 'secrets.rb'
require_relative 'command_registry.rb'
require_relative 'commands/pokemon.rb'
require_relative 'commands/rng.rb'
require_relative 'commands/parse.rb'
require_relative 'commands/draft.rb'
bot = Discordrb::Commands::CommandBot.new token: DISCORD_TOKEN, client_id: DISCORD_CLIENT, prefix: 's/'

register_commands(bot)
setup_pokemon_commands(bot)
setup_rng_commands(bot)
setup_parse_commands(bot)
setup_draft_commands(bot)

bot.command(:mock) do |event, id, hide|
bot.send_message(id.to_i, event.message.content.sub(/^[^\s]*\s[^\s]*\s(hide\s)?/, ""))
event.message.delete if hide.eql?("hide")
end

bot.run(true)
puts 'bot active'
bot.join
