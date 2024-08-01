require 'csv'
STALE_MATCH_CUTOFF = 25
def reset_elo
    @elo_dict = Hash.new(1000)
    @diff_dict = Hash.new(0)
    @maxelo_dict = Hash.new(0)
    @matchage_dict = Hash.new(0)
    @matchup_dict = Hash.new(0)
    @currmatch = 0
end

def add_matchup(player1, player2)
    key = [player1, player2].sort().join("-")
    @matchup_dict[key] = @matchup_dict[key] + 1 
end

def calc_match_probability(winner, loser)
    return 1.0 * 1.0 / (1 + 1.0 * (10 ** (1.0 * (loser - winner) / 400)))
end

def process_match(player1, player2, constant, outcome)
    add_matchup(player1,player2)
    @currmatch += 1;
    @matchage_dict[player1] = @currmatch;
    @matchage_dict[player2] = @currmatch;
    prob1 = calc_match_probability(@elo_dict[player1], @elo_dict[player2])
    prob2 = calc_match_probability(@elo_dict[player2], @elo_dict[player1])
    @maxelo_dict[player1] = @elo_dict[player1] if @elo_dict[player1] > @maxelo_dict[player1]
    @maxelo_dict[player2] = @elo_dict[player2] if @elo_dict[player2] > @maxelo_dict[player2]
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
    @maxelo_dict[player1] = @elo_dict[player1] if @elo_dict[player1] > @maxelo_dict[player1]
    @maxelo_dict[player2] = @elo_dict[player2] if @elo_dict[player2] > @maxelo_dict[player2]

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
        print("Active players:\n\n")
        sorted.each do |key,value|
            symbol = @diff_dict[key] < 0 ? '-' : '+';
            print("#{symbol}#{key}: #{value.to_i}#{key.length==9?"":"\t"}(+#{@diff_dict[key].round(1)})\n".sub("+-","-")) if @matchage_dict[key] + STALE_MATCH_CUTOFF >= @currmatch
        end
        print("\nInactive players:\n\n")
        sorted.each do |key,value|
            symbol = @diff_dict[key] < 0 ? '-' : '+';
            print("#{symbol}#{key}: #{value.to_i}#{key.length==9?"":"\t"}(+#{@diff_dict[key].round(1)})\n".sub("+-","-")) if @matchage_dict[key] + STALE_MATCH_CUTOFF < @currmatch
        end

        # print("\nMatchup stats:\n\n")
        # matchups = @matchup_dict.sort_by {|k, v| -v}
        # matchups.each do |key,value|
        #     print("#{key}: #{value} faceoffs\n") if(key.include?("emily"))
        # end
        
    end
end

reset_elo()
calc_elo_dict()