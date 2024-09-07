require_relative '../commands/parse.rb'

def expect_equal(expected, link)
  actual = parse_log(link)
  if(actual == expected)
    puts "PASS - #{link}"
  else
    puts "FAIL - #{link} - \n#{expected}\nDOES NOT EQUAL\n#{actual}"
  end
end

# coming soon(tm)
expect_equal(
"Link: https://replay.pokemonshowdown.com/gen9doublescustomgame-2175480309
Toxicroak was KO'd by themselves via ability: Dry Skin
Lilligant-Hisui was KO'd by Zapdos via Drill Peck
Donphan was KO'd by Heatran via Earth Power
Zapdos was KO'd by Walking Wake via Hydro Steam
Cofagrigus was KO'd by Heatran via Heat Wave
Turtonator was KO'd by Walking Wake via Draco Meteor
Hatterene was KO'd by Heatran via Heat Wave

Winner: zvero

Team zvero: Heatran (Seatran) got 3 KOs
Team delicousfalcon: Zapdos (Chris Buscher) got 1 KO
Team zvero: Walking Wake (Viking Volt) got 2 KOs",
"https://replay.pokemonshowdown.com/gen9doublescustomgame-2175480309")