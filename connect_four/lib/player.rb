# frozen_string_literal: true

class Player
  attr_accessor :name, :choice

  def initialize(name, choice)
    @name = name
    @choice = choice
  end
end
