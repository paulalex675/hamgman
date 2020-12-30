require "erb"
require "csv"

class Game
  attr_accessor :guesses, :name, :letters_guessed, :word, :hidden_word, :incorrect_guesses, :save
    
  def initialize(name, guesses, letters_guessed, word, hidden_word, incorrect_guesses)
    @name = name
    @guesses = guesses
    @word = word
    @guesses = 12
    @save = save
    @letters_guessed = letters_guessed
    @letters_guessed = Array.new
    @hidden_word = hidden_word
    @hidden_word = Array.new
    @incorrect_guesses = incorrect_guesses
    @incorrect_guesses = Array.new
  end

  def pick_word()
    dictionary = File.readlines "5desk.txt"
    dictionary.each { |line| line.split(" ") }
    dictionary.keep_if { |a| a.length > 3 && a.length < 12 }
    @word = dictionary.sample.chomp.downcase
    @word = @word.split('')
  end

  def hide_word()
    @hidden_word.clear
    x = @word.length
    x.times { @hidden_word << '_' }
    p @hidden_word
  end

  def guess()
    if @guesses > 0
      puts "guess a letter"
      @guess = gets.chomp.downcase
      if @guess == 'save'
        save_game()
      elsif @guess == @word.join('')
        puts @guess
        puts "Congratulations, you win!"
        exit
      elsif @letters_guessed.include?(@guess)
        puts "You've already guessed that letter, try again"
        guess()
      else @letters_guessed << @guess
      end
      if @word.include?(@guess)
        @word.each_index do |i| if @word[i] == @guess 
                                      @hidden_word[i] = @guess
                                end
                          end
      else @incorrect_guesses << @guess
      end
      if @word.join('') == @hidden_word.join('')
        puts @word.join('')
        puts 'Congratulations! You Win'
        exit
      else
        @guesses -= 1
        p @hidden_word
        p "incorrect guesses #{@incorrect_guesses}"
        puts "you have #{@guesses} guesses left"
        guess()
      end
    else puts "You're out of guesses! bad luck"
      puts @word.join('')
    exit
    end
  end
end

def new_game_or_load
  puts "What's your name friend?"
  @name = gets.chomp
  puts 'Do you want to load a game or start a new game? type "L" or "N"'
  l_or_s = gets.chomp.upcase
  if l_or_s == 'L'
    load_game
  elsif l_or_s == 'N'
    new_game
  else new_game_or_load
  end
end

def new_game
  $game = Game.new(@name, 12, @letters_guessed, @word, @hidden_word, @incorrect_guesses)
  $game.pick_word()
  $game.hide_word()
end

def load_game
  puts @name
  load = CSV.open "save_template.csv", headers: true, header_converters: :symbol
  load.each do |row| 
    if @name == row[:name] 
      @guesses = row[:guesses]
      @letters_guessed = row[:letters_guessed]
      @word = row[:word]
      @hidden_word = row[:hidden_word]
      @incorrect_guesses = row[:incorrect_guesses]
      $game = Game.new(@name, @guesses, @letters_guessed, @word, @hidden_word, @incorrect_guesses)
    else puts 'No save data found for your name'
      puts 'Starting new game'
      new_game
    end
  end
  
end

def save_game()
  @guesses += 1
  CSV.open("save_template.csv", "a") do |row| 
  row << ["#{Time.new},#{@name},#{@guesses},#{@letters_guessed.join('')},#{@word.join('')},#{@hidden_word.join('')},#{@incorrect_guesses.join('')}"]
  end
end

puts 'Hi! Welcome to Hangman!'
new_game_or_load
puts "If at anytime you need to save you're progress, type 'save' as your guess"
$game.guess