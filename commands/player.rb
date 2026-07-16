def valid_hex_color?(string)
  !!(string =~ /\A#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/)
end

def create_team_role(bot, colour, name, userid, server)
  return server.create_role(
      name: name,
      colour: colour.to_i(16),
      hoist: true,
      mentionable: true,
      reason: "Team signup for #{name}"
  )
end

def send_signup_embed(bot, channel, userid, team_name, timezone, role, showdown_name, tera)
  bot.channel(channel).send_embed do |embed|
    embed.title = "New Signup"
    embed.colour = role
    embed.description = "<@#{userid}> Info"
    embed.add_field(name: 'Team Name', value: team_name)
    embed.add_field(name: 'Timezone', value: timezone)
    embed.add_field(name: 'Role Colour', value: "##{role}")
    embed.add_field(name: 'Showdown Name', value: showdown_name)
    embed.add_field(name: 'Tera Captains', value: tera)
  end
end

def setup_player_commands(bot)
  bot.application_command(:player).subcommand(:signup) do |event|
    if File.exists?("/root/discordbots/spoink-project/spoink-bot/data/#{event.user.id}.draft")
      event.respond(content: "You have already signed up! Ask <@116674993424826375> if you need to change something about it.", ephemeral:true)
    else
      event.show_modal(title: 'Team Signup Form', custom_id: 'signup_form') do |builder|
        builder.row do |row|
          row.text_input(
            custom_id: 'team_name',
            label: 'What is your team name?',
            style: :short,
            required: true
          )
        end
        builder.row do |row|
          row.text_input(
            custom_id: 'timezone',
            label: 'What is your timezone?',
            style: :short,
            required: true
          )
        end
        builder.row do |row|
          row.text_input(
            custom_id: 'role',
            label: 'Team role colour? (FORMAT: #FFFFFF)',
            style: :short,
            required: true
          )
        end
        builder.row do |row|
          row.text_input(
            custom_id: 'showdown_name',
            label: 'What is your name on Pokemon Showdown?',
            style: :short,
            required: true
          )
        end
        builder.row do |row|
          row.text_input(
            custom_id: 'tera',
            label: 'Please list your tera captains:',
            style: :paragraph,
            required: true
          )
        end
      end
    end
    # event.respond(content: "Coming soon", ephemeral:true)
    
  end

  bot.modal_submit(custom_id: 'signup_form') do |event|
    team_name = event.value('team_name')
    timezone = event.value('timezone')
    role = event.value('role').delete('#')
    showdown_name = event.value('showdown_name')
    tera = event.value('tera')

    if(valid_hex_color?(role))

      send_signup_embed(bot, 922882312780275813, event.user.id, team_name, timezone, role, showdown_name, tera)

      new_role = create_team_role(bot, role, team_name, event.user.id, event.server)
      event.user.on(event.server).add_role(new_role.id)

      File.open("/root/discordbots/spoink-project/spoink-bot/data/#{event.user.id}.draft", "w") do |f|
        f.write("Team Name|||#{team_name}\nTimezone|||#{timezone}\nRole ID|||#{new_role.id}\nShowdown Name|||#{showdown_name}\nTera Captains|||#{tera}")
      end
      event.respond(content: 'Your application has been submitted!', ephemeral: true)
    else
      event.respond(content: "##{role} is not a valid colour hex code!", ephemeral: true)
    end
  end

  bot.application_command(:player).subcommand(:show) do |event|
    event.respond(content: "Coming soon", ephemeral:true)
  end
  bot.application_command(:player).subcommand(:edit) do |event|
    event.respond(content: "Coming soon", ephemeral:true)
  end
end