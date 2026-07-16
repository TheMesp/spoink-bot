def register_commands(bot)
  bot.register_application_command(:pokemon, 'Prints basic information about a pokemon, including type and weaknesses') do |cmd|
    cmd.string('pokemon', 'The pokemon to look up')
  end
  bot.register_application_command(:roll, 'Roll a pokemon team') do |cmd|
    cmd.integer('num', 'The number of pokemon to roll')
    cmd.integer('forceid', 'Force a particular id FOR TESTING PURPOSES ONLY')
    cmd.boolean('rig', 'Rig the roll?')
  end

  bot.register_application_command(:mod100, 'See what a 100 slice gets you') do |cmd|
    cmd.integer('num', 'The number (XX) to use (YXX)', required: true)
  end

  bot.register_application_command(:hammertime, 'Print hammertime link') do |cmd|
    cmd.boolean('hide', 'Hide the output?')
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

  bot.register_application_command(:squirdle, 'squirdle-related commands') do |group|
    group.subcommand(:submit, 'submit your daily squirdle') do |sub|
      sub.string('result', 'the result emoji matrix, to be copied from the site',  required: true)
    end

    group.subcommand(:display, 'show your entry for a given day (defaults to current)') do |sub|
      sub.integer('day', 'the day you want to see your result for')
    end

    group.subcommand(:stats, 'show your personal squirdle stats') do |sub|
    end
  end

  bot.register_application_command(:sheets, 'season sheet links') do |group|
    group.subcommand(:banlist, 'current banlist') do |sub|
      sub.boolean('hide', 'Hide the output?')
    end
    group.subcommand(:draft, 'draft tracker') do |sub|
      sub.boolean('hide', 'Hide the output?')
    end
    group.subcommand(:schedule, 'season schedule & team sheets') do |sub|
      sub.boolean('hide', 'Hide the output?')
    end
  end

  bot.register_application_command(:player, 'season sheet links') do |group|
    group.subcommand(:signup, 'Sign yourself up') do |sub|
    end
    group.subcommand(:show, 'Show signup record') do |sub|
      sub.user('user', 'user to display', required: true)
    end
    group.subcommand(:edit, 'Edit your signup record') do |sub|
    end
  end
end