# frozen_string_literal: true

require_relative '../lib/game'
require_relative '../lib/player'
describe Game do
  describe '#combatents' do
    context 'when initialized' do
      let(:game) { described_class.new }

      before do
        player_name = 'john'
        choice = 'x'
        allow(game).to receive(:puts)
        allow(game).to receive(:create_player).with(1)
        allow(game).to receive(:gets).and_return(player_name)
        allow(game).to receive(:choice_input).and_return(choice)
        allow(Player).to receive(:new).and_return(player_name, choice)
      end

      it 'creates first player' do
        game.create_player(1)
      end
    end
  end

  describe '#play_turns' do
    let(:game) { described_class.new }
    first_player =  Player.new('john', 'x')
    second_player = Player.new('dave', 'o')
    context 'when game is playing' do
      before do
        allow(game).to receive(:current_player).and_return(first_player)
        allow(game.board).to receive(:full?).and_return(false)
        allow(game).to receive(:puts)
        allow(game).to receive(:gets).and_return('1')
        allow(game).to receive(:turn).and_return(1)
      end
      it 'returns the first player' do
        current_player_name = game.current_player.name
        allow(game.board).to receive(:game_over?).and_return(true)
        expect(current_player_name).to eq(first_player.name)
        game.play_turns
      end

      it 'returns the second player' do
        allow(game.board).to receive(:game_over?).and_return(false)
        allow(game).to receive(:current_player).and_return(second_player)
        allow(game.board).to receive(:game_over?).and_return(true)
        current_player_name = game.current_player.name
        expect(current_player_name).to eq(second_player.name)
        game.play_turns
      end
    end
  end
end
