require_relative "../data/banlist.rb"

def setup_mod_commands(bot)
  
  bot.application_command(:mod100) do |event|
    
    if event.options['num'] && (event.options['num'].to_i < 1 || event.options['num'] > 100)
      event.respond(content:"Invalid number. Only 1-100, please.", ephemeral: true)
    else
      event.respond(content:"Generating, please wait...")
      num = event.options['num'].to_i
      output_names = []
      output_ids = []
      for i in 0..9 do
        next_id = num + (i * 100)
        if next_id <= MAX_POKEDEX_NUM
          response = `curl -s https://pokeapi.co/api/v2/pokemon-species/#{next_id}`
          response = JSON.parse(response)
          output_names << response['name']
          output_ids << next_id
        end
      end
      if(num <= 25)
        output_ids << num + 1000
        response = `curl -s https://pokeapi.co/api/v2/pokemon-species/#{num + 1000}`
          response = JSON.parse(response)
          output_names << response['name']
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