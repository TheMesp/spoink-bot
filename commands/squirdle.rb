require 'rufus-scheduler'
require_relative '../db.rb'

def get_squirdle_day
  return File.read("data/count").to_i
end

def get_squirdle_streak
  return File.read("data/squirdlestreak").to_i
end

def increment_squirdle_day
  day = get_squirdle_day
  day += 1
  File.open("data/count", "w") do |f|
    f.puts "#{day}"
  end
end

def increment_squirdle_streak
  streak = get_squirdle_streak
  streak += 1
  File.open("data/squirdlestreak", "w") do |f|
    f.puts "#{streak}"
  end
end

def reset_squirdle_streak
  File.open("data/squirdlestreak", "w") do |f|
    f.puts "1"
  end
end

def format_results(res)
  res = res.sub("\n", " ")
  split_res = res.split(" ")
  if(split_res.size < 6 || split_res[0] != "Squirdle" || split_res[1] != "Daily")
    return {error: "improper format for result", day:0, matrix:[]}
  end
  day = split_res[2]
  matrix = split_res[5..]
  return {error: "", day:day, matrix:matrix}
end

def get_user_stats(user_id)
  db = open_spoink_db
  scores = Array.new(10, 0)
  (1..10).each do |num|
    scores[num-1] = db.get_first_value("SELECT COUNT(*) FROM squirdle WHERE score=? AND user=?", [num, user_id]).to_i
  end
  db.close
  return scores
end

def get_server_stats(day)
  db = open_spoink_db
  user_scores = Array.new(10, nil)
  (1..10).each do |num|
    user_scores[num-1] = [] if user_scores[num-1].nil?
    db.execute("SELECT user FROM squirdle WHERE score=? AND day=?", [num, day]) do |row|
      user_scores[num-1].push "<@#{row[0]}>"
    end
  end
  db.close
  return user_scores
end

def setup_squirdle_commands(bot)
  bot.application_command(:squirdle).subcommand(:submit) do |event|
    db = open_spoink_db
    res = format_results(event.options['result'])
    unless(res[:error].empty?)
      event.respond(content:"Something went wrong: #{res[:error]}", ephemeral: true)
    else
      count = db.get_first_value("SELECT COUNT(*) FROM squirdle WHERE day=? AND user=?", [res[:day], event.user.id]).to_i
      if(count == 0)
        db.execute("INSERT INTO squirdle (user, day, score, result) VALUES (?, ?, ?, ?)", [event.user.id.to_s, res[:day], res[:matrix][-1] == "✅✅✅✅✅" ? res[:matrix].size : 10, res[:matrix].join(" ")])
        event.respond(content:"<@#{event.user.id}> was playing Squirdle: \n```\nDay #{res[:day]} - #{res[:matrix][-1] == "✅✅✅✅✅" ? res[:matrix].size : "X"}/9:\n#{res[:matrix].join("\n")}\n```", ephemeral: false)
      else
        event.respond(content:"Your squirdle results: \n```\nDay #{res[:day]} - #{res[:matrix][-1] == "✅✅✅✅✅" ? res[:matrix].size : "X"}/9:\n#{res[:matrix].join("\n")}\n```", ephemeral: true)
      end
    end
    db.close
  end

  bot.application_command(:squirdle).subcommand(:display) do |event|
    event.respond(content: "Spoink is thinking and bouncing...", ephemeral: true)
    db = open_spoink_db
    day = event.options['day'] ? event.options['day'] : get_squirdle_day
    count = db.get_first_value("SELECT COUNT(*) FROM squirdle WHERE day=? AND user=?", [day, event.user.id]).to_i
    if(count != 0)
      db.execute("SELECT * FROM squirdle WHERE day=? AND user=?", [day, event.user.id]) do |res|
        event.delete_response
        event.send_message(content: "<@#{res[0]}> shows off: \n```\nDay #{res[1]} - #{res[2] != "10" ? res[2] : "X"}/9:\n#{res[3].split(" ").join("\n")}\n```")
      end
    else
      event.edit_response(content:"No records found for day #{day}!")
    end
    db.close
  end

  bot.application_command(:squirdle).subcommand(:stats) do |event|
    output = "Stats for <@#{event.user.id}>:"
    stats = get_user_stats(event.user.id)
    (1..10).each do |num|
      output += "\n#{num == 10 ? "X" : num.to_s}/9: #{stats[num-1]}"
    end
    event.respond(content: output, ephemeral: false)
  end

  # send daily update at 11:00 UTC, giving all time zones a chance to have done the Squirdle
  scheduler = Rufus::Scheduler.new
  scheduler.cron '0 11 * * *' do
    
    day = get_squirdle_day
    streak = get_squirdle_streak
    output = "🔥Server Streak: #{streak}🔥\n[Play Squirdle Now!](https://squirdle.fireblend.com/daily.html)\nStats for day #{day}:"
    stats = get_server_stats(day)
    first = true
    (1..10).each do |num|
      unless(stats[num-1].empty?)
        output += "\n#{num == 10 ? "X" : num.to_s}/9: #{first ? "👑" : ""}#{stats[num-1].join(first ? ", 👑" : ", ")}"
        first = false
      end
    end
    if(first)
      reset_squirdle_streak
    else
      bot.send_message(762326067657703487, output)
      increment_squirdle_streak
    end
    increment_squirdle_day
  end
end