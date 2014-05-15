require 'debugger'

class Sudoku
  def initialize(filename)
    @grid = make_puzzle(filename)
    @possibs = Array.new(9) { Array.new(9) { Array.new(9, true) } }
  end

  def make_puzzle(filename)
    rows = File.readlines(filename)
    rows.map { |row| row.strip.split(" ").map(&:to_i) }
  end

  def solve_square(i, j, val)
    @grid[i][j] = val

    @possibs[i].each { |row_square| row_square[val-1] = false }

    @possibs.each { |row| row[j][val-1] = false }

    row_quad = ((i/3)*3..(i/3)*3+2).to_a
    col_quad = ((j/3)*3..(j/3)*3+2).to_a

    row_quad.each do |row|
      col_quad.each do |col|
        @possibs[row][col][val-1] = false
      end
    end

    @possibs[i][j].each { |possib| possib = false }
    @possibs[i][j][val-1] = true
  end

  def solve_puzzle
    initialize_possibilities

    count = 0
    updated = true

    while updated
      updated = false
      updated ||= solve_square_with_one_possibility
      updated ||= solve_row_with_one_possibility
      updated ||= solve_column_with_one_possibility
      updated ||= solve_quad_with_one_possibility

      if updated
        count += 1
        puts "Number of new squares solved: #{count}"
      end
    end

    print_board
    report_result
  end

  def print_board
    @grid.each { |row| puts row.join(" ") }
  end

  def report_result
    unsolved_squares = 0
    @grid.each { |row| row.each { |square| unsolved_squares += 1 if square == 0 } }

    puts
    if unsolved_squares == 0
      puts "Puzzle solved!"
    else
      puts "Unsolved squares remaining: #{unsolved_squares}"
    end
  end

  def initialize_possibilities
    (0...@grid.length).to_a.each_with_index do |i|
      (0...@grid.length).to_a.each_with_index do |j|
        if @grid[i][j] != 0
          solve_square(i, j, @grid[i][j])
        end
      end
    end
  end

  def solve_square_with_one_possibility
    @possibs.each_with_index do |row, i|
      row.each_with_index do |square, j|
        true_count = 0
        true_num = 0

        square.each_with_index do |possib, index|
          if possib == true
            true_count += 1
            true_num = index + 1
          end
        end

        if true_count == 1
          if @grid[i][j] == 0
            solve_square(i, j, true_num)
            return true
          end
        end
      end
    end
    false
  end

  def solve_row_with_one_possibility
    @possibs.each_with_index do |row, i|
      row_possib_aggregator = Array.new(9, 0)

      row.each do |row_square|
        row_square.each_with_index do |possib, k|
          row_possib_aggregator[k] += 1 if possib
        end
      end

      row_possib_aggregator.each_with_index do |possib, k|
        if possib == 1
          row.each_with_index do |row_square, j|
            if row_square[k] and @grid[i][j] == 0
              solve_square(i, j, k+1)
              return true
            end
          end
        end
      end
    end
    false
  end

  def solve_column_with_one_possibility
    (0...@possibs.length).to_a.each do |j|
      col_possib_aggregator = Array.new(9, 0)

      @possibs.each do |row|
        row[j].each_with_index do |possib, k|
          col_possib_aggregator[k] += 1 if possib
        end
      end

      col_possib_aggregator.each_with_index do |possib, k|
        if possib == 1
          @possibs.each_with_index do |row, i|
            if row[j][k] and @grid[i][j] == 0
              solve_square(i, j, k+1)
              return true
            end
          end
        end
      end
    end
    false
  end

  def solve_quad_with_one_possibility
    3.times do |time|
      (0...@possibs.length/3).to_a.each do |row_quad|
        quad_possib_aggregator = Array.new(9, 0)
        (row_quad*3..row_quad*3+2).to_a.each do |i|
          (time*3..time*3+2).to_a.each do |j|
            # puts "i: #{i}, j: #{j}"
            @possibs[i][j].each_with_index do |possib, k|
              quad_possib_aggregator[k] += 1 if possib
            end
          end
        end

        quad_possib_aggregator.each_with_index do |possib, k|
          if possib == 1
            (row_quad*3..row_quad*3+2).to_a.each do |i|
              (time*3..time*3+2).to_a.each do |j|
                if @possibs[i][j][k] and @grid[i][j] == 0
                  solve_square(i, j, k+1)
                  return true
                end
              end
            end
          end
        end
      end
    end
    false
  end
end


game = Sudoku.new(ARGV[0])
game.solve_puzzle
