def setup_sheets_commands(bot)
  bot.application_command(:sheets).subcommand(:banlist) do |event|
    event.respond(content: "https://docs.google.com/document/d/1UYaocb3WJmfSu-oKx9XcvjurgmXnPKtgYumRTM1mpV0/edit?usp=sharing", ephemeral: event.options['hide'])
  end
  bot.application_command(:sheets).subcommand(:draft) do |event|
    event.respond(content: "https://docs.google.com/spreadsheets/d/108PwlIrNHNb0TgfR7ByPrd42DY2ojEFr_aN_7rlw3Ag", ephemeral: event.options['hide'])
  end
  bot.application_command(:sheets).subcommand(:schedule) do |event|
    event.respond(content: "https://docs.google.com/spreadsheets/d/1ogPhQmyCUYFnQ1x2QsykNJVvDRedfww0ihVv9QGAsLY/edit?usp=sharing", ephemeral: event.options['hide'])
  end
end