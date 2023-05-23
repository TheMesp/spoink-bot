require_relative "../data/banlist.rb"

def check_unique(pokemon)
  Dir.glob("/root/discordbots/spoink-project/spoink-bot/data/*.draft") do |filename|
    name = filename.split("/")[-1].split(".")[0]
    rows = []
    File.foreach("#{filename}") do |row|
      return name if row.strip == pokemon.strip
    end
  end
  return nil
end

def setup_draft_commands(bot)
  bot.application_command(:draft).subcommand(:submit) do |event|
    event.respond(content: "Spoink is thinking and bouncing...", ephemeral: true)
    pokemon = event.options['pokemon'].gsub(/[^a-zA-Z0-9\-]/,'').gsub(" ","-").downcase # Clean that so i don't get injected plzty
    response = `curl -s https://pokeapi.co/api/v2/pokemon/#{pokemon}`
    if response == 'Not Found'
      event.edit_response(content:"#{pokemon} is not a recognized pokemon! Remember to watch format!\ne.g. Mr. Mime and Alolan Raticate exist as `mr-mime` and `raticate-alola`.")
    elsif POKEDEX_BANLIST.include? pokemon
      event.edit_response(content:"#{pokemon} is banned!")
    else
      other = check_unique(pokemon)
      if !other.nil?
        event.edit_response(content: "#{pokemon} is already drafted by <@#{other}>")
      else
        File.open("/root/discordbots/spoink-project/spoink-bot/data/#{event.options['user']}.draft", "a") do |f|
          f.write("#{pokemon}\n")
        end
        event.edit_response(content: "Draft pick ok, all clear")
        event.send_message(content: "<@#{event.options['user']}> has drafted #{pokemon}", ephemeral: false)
      end
    end
  end
  bot.application_command(:draft).subcommand(:view) do |event|
    event.respond(content: "Spoink is thinking and bouncing...", ephemeral: true)
    output = ""
    title = ""
    if !event.options['user']
      Dir.glob("/root/discordbots/spoink-project/spoink-bot/data/*.draft") do |filename|
        name = filename.split("/")[-1].split(".")[0]
        output << "<@#{name}>: "
        rows = []
        File.foreach("#{filename}") do |row|
          rows << row.strip
        end
        output << "#{rows.join(", ")}\n"
      end
      title = "Draft Tracker"
    elsif File.exists? "/root/discordbots/spoink-project/spoink-bot/data/#{event.options['user']}.draft"
      rows = []
      
      File.foreach("/root/discordbots/spoink-project/spoink-bot/data/#{event.options['user']}.draft") do |row|
        rows << row.strip
      end
      output << "<@#{event.options['user']}>: #{rows.join(", ")}\n"
      title = "Team Preview"
    else
      event.edit_response(content: "<@#{event.options['user']}> doesn't have a draft record!")
    end
    unless output.empty?
      response_embed = Discordrb::Webhooks::Embed.new(
        title: title,
        description: output
      )
      event.edit_response(embeds:[response_embed.to_hash])
    end
  end

  bot.application_command(:draft).subcommand(:verify) do |event|
    event.respond(content: "Spoink is thinking and bouncing...", ephemeral: true)
    if File.exists? "/root/discordbots/spoink-project/spoink-bot/data/#{event.options['user']}.draft"
      word = ""
      File.foreach("/root/discordbots/spoink-project/spoink-bot/data/#{event.options['user']}.draft") do |row|
        row.each do |field|
          word << field[0]
        end
      end
      word << event.options['next'] if event.options['next']
      event.edit_response(content: "https://wordfinderx.com/words-for/_/words-start-with/#{word}/length/6/?dictionary=all_en&extended_fields=true")

    else
      event.edit_response(content: "<@#{event.options['user']}> doesn't have a draft record!")
    end
  end

  bot.application_command(:draft).subcommand(:check_pick) do |event|
    event.respond(content: "Spoink is thinking and bouncing...", ephemeral: true)
    pokemon = event.options['pokemon'].gsub(/[^a-zA-Z0-9\-]/,'').gsub(" ","-").downcase # Clean that so i don't get injected plzty
    response = `curl -s https://pokeapi.co/api/v2/pokemon/#{pokemon}`
    if response == 'Not Found'
      event.edit_response(content:"#{pokemon} is not a recognized pokemon! Remember to watch format!\ne.g. Mr. Mime and Alolan Raticate exist as `mr-mime` and `raticate-alola`.")
    elsif POKEDEX_BANLIST.include? pokemon
      event.edit_response(content:"#{pokemon} is banned!")
    else
      other = check_unique(pokemon)
      if !other.nil?
        event.edit_response(content: "#{pokemon} is already drafted by <@#{other}>")
      else
        event.edit_response(content: "#{pokemon} is available!")
      end
    end
  end
end