require 'csv'

def reset_elo
    @elo_dict = Hash.new(1000)
    @diff_dict = Hash.new(0)
end

def calc_match_probability(winner, loser)
    return 1.0 * 1.0 / (1 + 1.0 * (10 ** (1.0 * (loser - winner) / 400)))
end

def process_match(player1, player2, constant, outcome)

    prob1 = calc_match_probability(@elo_dict[player1], @elo_dict[player2])
    prob2 = calc_match_probability(@elo_dict[player2], @elo_dict[player1])

    if(outcome == 0)
        # Player 1 wins
        @elo_dict[player1] = @elo_dict[player1] + constant * (1 - prob1)
        @elo_dict[player2] = @elo_dict[player2] + constant * (0 - prob2)
        @diff_dict[player1] = constant * (1 - prob1)
        @diff_dict[player2] = constant * (0 - prob2)
    else
        # Player 2 wins
        @elo_dict[player1] = @elo_dict[player1] + constant * (0 - prob1)
        @elo_dict[player2] = @elo_dict[player2] + constant * (1 - prob2)
        @diff_dict[player1] = constant * (0 - prob1)
        @diff_dict[player2] = constant * (1 - prob2)
    end

end

def calc_elo_dict(player = nil)
    Dir.glob("/root/discordbots/spoink-project/spoink-bot/seasons/*.csv").sort.each do |season|
        CSV.foreach(season) do |row|
            process_match(row[0], row[1], 40, row[2].to_i)        
        end
    end
    if player
        print("#{@elo_dict[player]}\n")
    else
        sorted = @elo_dict.sort_by {|k, v| -v}
        sorted.each do |key,value|
            symbol = @diff_dict[key] < 0 ? '-' : '+';
            print("#{symbol}#{key}: #{value.to_i}\t(+#{@diff_dict[key].round(1)})\n".sub("+-","-"))
        end
        
    end
end

reset_elo()
calc_elo_dict()