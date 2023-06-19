def register_commands(bot)
  bot.register_application_command(:pokemon, 'Prints basic information about a pokemon, including type and weaknesses') do |cmd|
    cmd.string('pokemon', 'The pokemon to look up')
  end
  bot.register_application_command(:roll, 'Roll a pokemon team') do |cmd|
    cmd.integer('num', 'The number of pokemon to roll')
    cmd.boolean('rig', 'Rig the roll?')
  end

  bot.register_application_command(:parselog, nil, type: :message) do |cmd|
  end

  bot.register_application_command(:draft, 'draft-related commands') do |group|
    group.subcommand(:submit, 'submit a draft pick') do |sub|
      sub.user('user', 'user drafting', required: true)
      sub.string('pokemon', 'pokemon drafted', required: true)
    end
    group.subcommand(:view, 'View the draft status') do |sub|
      sub.user('user', 'user to view', required: false)
    end
    group.subcommand(:verify, 'verify that a user\'s letters could make a word') do |sub|
      sub.user('user', 'user to verify', required: true)
      sub.string('next', 'next planned pick (optional)', required: false)
    end
    group.subcommand(:check_pick, 'check that a pick is available') do |sub|
      sub.string('pokemon', 'pokemon to check', required: true)
    end
    group.subcommand(:check_letter, 'check the pokemon already taken for a letter') do |sub|
      sub.string('letter', 'letter to check', required: true)
    end
  end
end