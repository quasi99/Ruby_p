# frozen_string_literal: true

require_relative '../lib/board'

describe Board do
  let(:board_table) { described_class.new }
  describe '#position' do
    before do
      board_table.instance_variable_set(:@board, [
                                          ['.', '.', '.', '.', '.', '.', '.'],
                                          ['.', '.', '.', '.', '.', '.', '.'],
                                          ['.', '.', '.', '.', '.', '.', '.'],
                                          ['.', '.', '.', '.', '.', '.', '.'],
                                          ['.', '.', '.', '.', '.', '.', '.'],
                                          ['.', '.', '.', '.', '.', '.', 'x']
                                        ])
    end
    it 'should return the given position' do
      board = board_table.instance_variable_get(:@board)
      board_position = board[board.length - 1][6]
      expect(board_position).to eq('x')
      board_table.position(7, 'x')
    end
  end

  describe '#full?' do
    let(:board_table) { described_class.new }

    context 'when board is full' do
      before do
        board_table.instance_variable_set(:@board, [
                                            [1, 2, 3, 4, 5, 6, 7],
                                            [8, 9, 10, 11, 12, 13, 14],
                                            [15, 16, 17, 18, 19, 20, 21],
                                            [22, 23, 24, 25, 26, 27, 28],
                                            [29, 30, 31, 32, 34, 35, 36],
                                            [37, 38, 39, 40, 41, 42, 43]
                                          ])
      end
      it 'should return true' do
        expect(board_table).to be_full
      end
    end

    context 'when board is not full' do
      before do
        board_table.instance_variable_set(:@board, [
                                            [1, 2, 3, 4, 5, 6, 7],
                                            [8, 9, 10, 11, 12, 13, 14],
                                            [15, 16, 17, 18, 19, 20, 21],
                                            [22, 23, 24, 25, 26, 27, 28],
                                            [29, 30, 31, 32, 34, 35, 36],
                                            [37, 38, 39, 40, 41, 42, '.']
                                          ])
      end
      it 'should return false' do
        expect(board_table).not_to be_full
      end
    end
  end

  describe '#game_over?' do
    let(:board) { described_class.new }
    context 'when horizontal match is found' do
      before do
        board.instance_variable_set(:@board, [
                                      ['.', '.', '.', 'x', 'x', 'x', 'x'],
                                      ['.', '.', '.', '.', '.', '.', '.'],
                                      ['.', '.', '.', '.', '.', '.', '.'],
                                      ['.', '.', '.', '.', '.', '.', '.'],
                                      ['o', 'o', 'o', '.', '.', '.', '.'],
                                      ['.', 'x', '.', 'x', '.', 'x', 'x']
                                    ])
      end
      it 'returns true' do
        expect(board).to be_game_over
      end
    end

    context 'when vertical match is found' do
      before do
        board.instance_variable_set(:@board, [
                                      ['.', '.', '.', '.', '.', '.', '.'],
                                      ['o', '.', '.', '.', '.', '.', '.'],
                                      ['o', '.', '.', '.', '.', '.', 'o'],
                                      ['o', '.', '.', '.', '.', '.', 'o'],
                                      ['x', 'o', 'o', '.', '.', '.', 'o'],
                                      ['x', '.', '.', '.', '.', '.', 'o']
                                    ])
        allow(board).to receive(:four_in_a_row?).and_return(false)
      end
      it 'returns true' do
        expect(board).to be_game_over
      end
    end

    context 'when diagonal matches from left' do
      before do
        board.instance_variable_set(:@board, [
                                      ['.', '.', '.', '.', '.', '.', '.'],
                                      ['.', 'x', '.', '.', '.', '.', '.'],
                                      ['x', '.', 'x', '.', '.', '.', '.'],
                                      ['.', 'x', '.', 'x', '.', '.', '.'],
                                      ['.', '.', 'x', '.', '.', '.', '.'],
                                      ['.', '.', '.', 'x', '.', '.', '.']
                                    ])
        allow(board).to receive(:four_in_a_row?).and_return(false)
        allow(board).to receive(:four_in_a_column?).and_return(false)
      end

      it 'returns true' do
        expect(board).to be_game_over
      end
    end

    context 'when diagonal matches from right' do
      before do
        board.instance_variable_set(:@board, [
                                      ['.', '.', '.', '.', '.', '.', '.'],
                                      ['.', '.', '.', '.', '.', 'x', '.'],
                                      ['.', '.', '.', '.', 'x', '.', 'x'],
                                      ['.', '.', '.', 'x', '.', 'x', '.'],
                                      ['.', '.', '.', '.', 'x', '.', '.'],
                                      ['.', '.', '.', 'x', '.', '.', '.']
                                    ])
        allow(board).to receive(:four_in_a_row?).and_return(false)
        allow(board).to receive(:four_in_a_column?).and_return(false)
      end
      it 'returns true' do
        expect(board).to be_game_over
      end
    end
  end
end
