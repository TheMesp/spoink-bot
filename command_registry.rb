def register_commands(bot)
  bot.register_application_command(:pokemon, 'Prints basic information about a pokemon, including type and weaknesses') do |cmd|
    cmd.string('pokemon', 'The pokemon to look up')
  end
  bot.register_application_command(:roll, 'Roll a pokemon team') do |cmd|
    cmd.integer('num', 'The number of pokemon to roll')
  end
end