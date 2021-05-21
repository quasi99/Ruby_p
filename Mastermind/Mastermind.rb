# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module TextInstructions
  def instructions
    <<~HEREDOC


      #{formatting('underline', 'How to play Mastermind:')}

      This is a 1-player game against the computer.
      You can choose to be the code #{formatting('underline', 'maker')} or the code #{formatting('underline', 'breaker')}.

      There are six different number/color combinations:

      #{code_colors('1')}#{code_colors('2')}#{code_colors('3')}#{code_colors('4')}#{code_colors('5')}#{code_colors('6')}


      The code maker will choose four to create a 'master code'. For example,

      #{code_colors('1')}#{code_colors('3')}#{code_colors('4')}#{code_colors('1')}

      As you can see, there can be #{formatting('red', 'more then one')} of the same number/color.
      In order to win, the code breaker needs to guess the 'master code' in 12 or less turns.


      #{formatting('underline', 'Clues:')}
      After each guess, there will be up to four clues to help crack the code.

       #{clue_colors('*')}This clue means you have 1 correct number in the correct location.

       #{clue_colors('?')}This clue means you have 1 correct number, but in the wrong location.


      #{formatting('underline', 'Clue Example:')}
      To continue the example, using the above 'master code' a guess of "1463" would produce 3 clues:

      #{code_colors('1')}#{code_colors('4')}#{code_colors('6')}#{code_colors('3')}  Clues: #{clue_colors('*')}#{clue_colors('?')}#{clue_colors('?')}


      The guess had 1 correct number in the correct location and 2 correct numbers in a wrong location.

      #{formatting('underline', "It's time to play!")}
      Would you like to be the code MAKER or code BREAKER?

      Press '1' to be the code MAKER
      Press '2' to be the code BREAKER
    HEREDOC
  end
end

# rubocop:enable Metrics/AbcSize

# rubocop:disable Layout/LineLength

module TextContent
  def formatting(description, string)
    {
      'underline' => "\e[4;1m#{string}\e[0m",
      'red' => "\e[31;1m#{string}\e[0m"
    }[description]
  end

  def game_message(message)
    {
      'human_won' => "  You broke the code! Congratulations, you win! \n\n",
      'display_code' => "Here is the 'master code' that you were trying to break:",
      'computer_lost' => "\nYou out-smarted the computer & won the game!",
      'repeat_prompt' => "\n\nDo you want to play again? Press 'y' for yes (or any other key for no).",
      'thanks' => 'Thank you for playing Mastermind!'
    }[message]
  end

  def computer_won_message(message)
    {
      'inconceivable' => "\nInconceivable! Either your code only had 1-2 different numbers or the computer's randomized numbers just happened to be in a perfect order.",
      'won' => "\nGame over. The computer broke your code.",
      'close' => "\nThat was close, but the computer finally broke your code."
    }[message]
  end

  def turn_message(message, number = nil)
    {
      'guess_prompt' => "Turn ##{number}: Type in four numbers (1-6) to guess code, or 'q' to quit game.",
      'computer' => "\nComputer Turn ##{number}:",
      'breaker_start' => "The computer has set the 'master code' and now it's time for you to break the code.\n\n",
      'code_prompt' => "Please enter a 4-digit 'master code' for the computer to break.",
      'code_displayed' => "is your 'master code'.\n"
    }[message]
  end

  def warning_message(message)
    {
      'answer_error' => formatting('red', "Enter '1' to be the code MAKER or '2' to be the code BREAKER.").to_s,
      'turn_error' => formatting('red', 'Your guess should only be 4 digits between 1-6.').to_s,
      'last_turn' => formatting('red', 'Choose carefully. This is your last chance to win!').to_s,
      'code_error' => formatting('red', "Your 'master code' must be 4 digits long, using numbers between 1-6.").to_s,
      'game_over' => "#{formatting('red', 'Game over. That was a hard code to break! ¯\\_(ツ)_/¯ ')} \n\n"
    }[message]
  end
end

# rubocop:enable Layout/LineLength

module Display
  def code_colors(number)
    {
      '1' => "\e[101m  1  \e[0m ",
      '2' => "\e[43m  2  \e[0m ",
      '3' => "\e[44m  3  \e[0m ",
      '4' => "\e[45m  4  \e[0m ",
      '5' => "\e[46m  5  \e[0m ",
      '6' => "\e[41m  6  \e[0m ",
    }[number]
  end

  def clue_colors(clue)
    {
      '*' => "\e[91m\u25CF\e[0m ",
      '?' => "\e[37m\u25CB\e[0m "
    }[clue]
  end

  def show_code(array)
    array.each do |num|
      print code_colors num
    end
  end

  def show_clues(exact, same)
    print '  Clues: '
    exact.times { print clue_colors('*') }
    same.times { print clue_colors('?') }
    puts ''
  end
end

class Game
  include TextInstructions
  include TextContent
  include Display

  def play
    puts instructions
    game_mode = mode_selection
    code_maker if game_mode == '1'
    code_breaker if game_mode == '2'
  end

  def mode_selection
    input = gets.chomp
    return input if input.match(/^[1-2]$/)

    puts warning_message('answer_error')
    mode_selection
  end

  def code_maker
    maker = ComputerSolver.new
    maker.computer_start
  end

  def code_breaker
    breaker = HumanSolver.new
    breaker.player_turns
  end
end

module GameLogic
  def compare(master, guess)
    temp_master = master.clone
    temp_guess = guess.clone
    @exact_number = exact_matches(temp_master, temp_guess)
    @same_number = right_numbers(temp_master, temp_guess)
    @total_number = exact_number + same_number
  end

  def exact_matches(master, guess)
    exact = 0
    master.each_with_index do |item, index|
      next unless item == guess[index]

      exact += 1
      master[index] = '*'
      guess[index]  = '*'
    end
    exact
  end

  def right_numbers(master, guess)
    same = 0
    guess.each_index do |index|
      next unless guess[index] != '*' && master.include?(guess[index])

      same += 1
      remove = master.find_index(guess[index])
      master[remove] = '?'
      guess[index] = '?'
    end
    same
  end

  def solved?(master, guess)
    master == guess
  end

  def repeat_game
    puts game_message('repeat_prompt')
    replay = gets.chomp
    puts game_message('thanks') if replay.downcase != 'y'
    Game.new.play if replay.downcase == 'y'
  end
end

class HumanSolver
  attr_reader :computer_code, :guess, :exact_number, :same_number

  include GameLogic
  include Display
  include TextContent

  def initialize
    random_numbers = [rand(1..6), rand(1..6), rand(1..6), rand(1..6)]
    @computer_code = random_numbers.map(&:to_s)
  end

  def player_turns
    puts turn_message('breaker_start')
    turn_order
    human_game_over(computer_code, guess)
  end

  def turn_order
    turn = 1
    while turn <= 12
      turn_messages(turn)
      @guess = player_input.split(//)
      turn += 1

      break if guess[0].downcase == 'q'

      show_code(guess)
      break if solved?(computer_code, guess)

      turn_outcome
    end
  end

  def turn_messages(turn)
    puts turn_message('guess_prompt', turn)
    puts warning_message('last_turn') if turn == 12
  end

  def player_input
    input = gets.chomp
    return input if input.match(/^[1-6]{4}$/)
    return input if input.downcase == 'q'

    puts warning_message('turn_error')
    player_input
  end

  def turn_outcome
    compare(computer_code, guess)
    show_clues(exact_number, same_number)
  end

  def human_game_over(master, guess)
    if solved?(master, guess)
      puts game_message('human_won')
    else
      puts warning_message('game_over')
      puts game_message('display_code')
      show_code(master)
    end
    repeat_game
  end
end

class ComputerSolver
  attr_reader :maker_code, :turn_count, :exact_number, :same_number,
              :total_number, :find_code_guesses, :four_numbers

  include GameLogic
  include Display
  include TextContent

  def computer_start
    puts turn_message('code_prompt')
    @maker_code = create_code.split(//)
    show_code(maker_code)
    puts turn_message('code_displayed')
    find_code_numbers
    find_code_order
    computer_game_over(@code_permutations[0])
  end

  def create_code
    input = gets.chomp
    return input if input.match(/^[1-6]{4}$/)

    puts warning_message('code_error')
    create_code
  end

  def find_code_numbers
    numbers = %w[1 2 3 4 5 6]
    options = numbers.shuffle
    @turn_count = 1
    @find_code_guesses = []
    @four_numbers = find_four_numbers(options)
  end

  def find_four_numbers(options, index = 0, guess = [])
    guess.pop(4 - total_number) unless turn_count == 1
    guess << options[index] until guess.length == 4
    computer_turn(maker_code, guess)
    @turn_count += 1
    return guess if total_number == 4

    find_four_numbers(options, index + 1, guess)
  end

  def computer_turn(master, guess)
    puts turn_message('computer', turn_count)
    sleep(1)
    show_code(guess)
    compare(master, guess)
    show_clues(exact_number, same_number)
    current_guess = guess.clone
    @find_code_guesses << [current_guess, exact_number, same_number]
  end

  def find_code_order
    @code_permutations = create_permutations(four_numbers)
    @code_permutations.uniq!
    compare_previous_guesses
    final_turns
  end

  def create_permutations(array)
    array.permutation.to_a
  end

  def compare_previous_guesses
    @find_code_guesses.each { |code| compare_permutations(code) }
  end

  def compare_permutations(code)
    run_permutations(code[0], code[1], code[2])
  end

  def run_permutations(code, exact, same)
    @code_permutations.each do |perm|
      compare(perm, code)
      reduce_perms(perm) unless exact_number == exact && same_number == same
    end
  end

  def reduce_perms(code)
    @code_permutations.reject! do |perm|
      perm == code
    end
  end

  def final_turns
    until @turn_count > 12
      computer_turn(maker_code, @code_permutations[0])
      @turn_count += 1
      break if solved?(maker_code, @code_permutations[0])

      run_permutations(@code_permutations[0], exact_number, same_number)
    end
  end

  def computer_game_over(guess)
    if solved?(maker_code, guess)
      computer_won
    else
      puts game_message('computer_lost')
    end
    repeat_game
  end

  def computer_won
    puts computer_won_message('inconceivable') if turn_count <= 6
    puts computer_won_message('won') if turn_count.between?(7, 11)
    puts computer_won_message('close') if turn_count == 12
  end
end

Game.new.play