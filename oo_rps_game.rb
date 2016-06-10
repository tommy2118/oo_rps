# frozen_string_literal: true
class Logger
  attr_accessor :move_log

  def initialize
    @move_log = {}
  end

  def log_moves(score, human, computer)
    move_log[score.total_rounds] = [human.move.value, computer.move.value]
  end

  def display_log(human, computer)
    system('clear') || system('cls')
    puts "Move Log".center(65, '*')
    move_log.each do |round, moves|
      puts "Round: #{round} #{human.name}'s move: #{moves[0]} -- \
#{computer.name}'s move: #{moves[1]}"
    puts ""
    end
    puts "*".center(65, '*')
    puts ""
  end
end

class Statistics
  attr_accessor :log_file

  def initialize(log_file)
    @log_file = log_file
  end

  def human_rock_count
    rocks = []
    log_file.each do |_, moves|
      rocks << moves[0] if moves[0] == "rock"
    end
    rocks.count
  end

  def human_paper_count
    papers = []
    log_file.each do |_, moves|
      papers << moves[0] if moves[0] == "paper"
    end
    papers.count
  end

  def human_scissors_count
    scissors = []
    log_file.each do |_, moves|
      scissors << moves[0] if moves[0] == "scissors"
    end
    scissors.count
  end

  def human_rock_average
    human_rock_count / log_file.count.to_f
  end

  def human_paper_average
    human_paper_count / log_file.count.to_f
  end

  def human_scissors_average
    human_paper_count / log_file.count.to_f
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors'].freeze

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def scissors?
    @value == 'scissors'
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (scissors? && other_move.rock?)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end

  def increase_score
    self.score += 1
  end
end

class Human < Player
  def set_name
    player_name = ''
    system('clear') || system('clr')
    loop do
      puts "what's your name?"
      player_name = gets.chomp
      break unless player_name.empty?
      puts "sorry, you must enter a name."
    end
    self.name = player_name
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors:"
      choice = gets.chomp.downcase
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose(stats)
    if stats.human_rock_average > 0.33 &&
       stats.human_paper_average < 0.50 &&
       stats.human_scissors_average < 0.50 &&
      self.move = Move.new('paper')
    elsif stats.human_paper_average > 0.33 &&
       stats.human_rock_average < 0.50 &&
       stats.human_scissors_average < 0.50 &&
      self.move = Move.new('scissors')
    elsif stats.human_scissors_average > 0.33 &&
       stats.human_paper_average < 0.50 &&
       stats.human_rock_average < 0.50 &&
      self.move = Move.new('rock')
    else
      self.move = Move.new(Move::VALUES.sample)
    end
  end
end

class ScoreKeeper
  ROUNDS_TO_WIN = 3

  attr_accessor :rounds_this_game, :tied_rounds_this_game, :total_rounds

  def initialize
    @rounds_this_game = 0
    @tied_rounds_this_game = 0
    @total_rounds = 0
  end

  def tally_score(human, computer)
    if human.move > computer.move
      human.increase_score
    elsif human.move < computer.move
      computer.increase_score
    else
      self.tied_rounds_this_game += 1
    end
    self.rounds_this_game += 1
    self.total_rounds += 1
  end

  def display_score(human, computer)
    puts "After #{rounds_this_game} \
#{rounds_this_game == 1 ? 'round' : 'rounds'},\
#{human.name} has won #{human.score} and #{computer.name} has won \
#{computer.score} .  #{tied_rounds_this_game} \
#{tied_rounds_this_game == 1 ? 'round has' : 'rounds have'} \
ended in a tie."
  end

  def reset_scores(human, computer)
    human.score = 0
    computer.score = 0
    self.tied_rounds_this_game = 0
    self.rounds_this_game = 0
  end
end

class RpsGame
  attr_accessor :human, :computer, :score, :logger, :stats

  def initialize
    @human = Human.new
    @computer = Computer.new
    @score = ScoreKeeper.new
    @logger = Logger.new
    @stats = Statistics.new(logger.move_log)
  end

  def display_welcome_message
    system('clear') || system('clr')
    puts "Welcome to Rock, Paper, Scissors!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Goodbye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_round_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_game_winner
    if human.score >= ScoreKeeper::ROUNDS_TO_WIN
      puts "#{human.name} wins the game!"
    else
      puts "#{computer.name} wins the game!"
    end
  end

  def play_round
    loop do
      make_moves
      declare_round
      break if human.score >= ScoreKeeper::ROUNDS_TO_WIN ||
               computer.score >= ScoreKeeper::ROUNDS_TO_WIN
    end
  end

  def make_moves
    human.choose
    computer.choose(stats)
  end

  def declare_round
    display_moves
    display_round_winner
    score.tally_score(human, computer)
    score.display_score(human, computer)
    logger.log_moves(score, human, computer)
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include? answer
      puts "Sorry, must be y or n."
    end

    return false if answer == 'n'
    return true if answer == 'y'
  end

  def start
    display_welcome_message
    loop do
      play_round
      score.reset_scores(human, computer)
      break unless play_again?
    end
    logger.display_log(human, computer)
    display_goodbye_message
  end
end

RpsGame.new.start
