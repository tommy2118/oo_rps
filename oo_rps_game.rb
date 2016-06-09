# frozen_string_literal: true
class Move
  VALUES = ['rock', 'paper', 'scissors'].freeze

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
      choice = gets.chomp
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

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class ScoreKeeper
  ROUNDS_TO_WIN = 3

  attr_accessor :rounds, :tied_rounds

  def initialize
    @rounds = 0
    @tied_rounds = 0
  end

  def tally_score(human, computer)
    if human.move > computer.move
      human.increase_score
    elsif human.move < computer.move
      computer.increase_score
    else
      self.tied_rounds += 1
    end
    self.rounds += 1
  end

  def display_score(human, computer)
    puts "After #{rounds} #{rounds == 1 ? 'round' : 'rounds'}, #{human.name} \
has won #{human.score} and #{computer.name} has won #{computer.score}\
.  #{tied_rounds} #{tied_rounds == 1 ? 'round has' : 'rounds have'} \
ended in a tie."
  end

  def reset_scores(human, computer)
    human.score = 0
    computer.score = 0
    self.tied_rounds = 0
    self.rounds = 0
  end
end

class RpsGame
  attr_accessor :human, :computer, :score

  def initialize
    @human = Human.new
    @computer = Computer.new
    @score = ScoreKeeper.new
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
    computer.choose
  end

  def declare_round
    display_moves
    display_round_winner
    score.tally_score(human, computer)
    score.display_score(human, computer)
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
      break unless play_again?
    end
    display_goodbye_message
  end
end

RpsGame.new.start
