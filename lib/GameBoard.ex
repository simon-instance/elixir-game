defmodule GameBoard do
  require Logger
  import Enum, only: [flat_map: 2, random: 1, each: 2]

  defmodule GameState do
    defstruct board: Map, bombs: Map, player_vision_radius: 2, game_over: false
  end

  defmodule Point do
    defstruct x: 0, y: 0

    def difference(%Point{x: x1, y: y1}, %Point{x: x2, y: y2}) do
      %Point{x: x1 + x2, y: y1 + y2}
    end
  end

  defmodule Target do
    defstruct []
  end

  defmodule PowerUp do
    defstruct []
  end

  def get_random_target do
    {:rand.uniform(19), :rand.uniform(19)}
  end

  def create_board(%Point{x: player_x, y: player_y}, rows, columns) do
    target = get_random_target()

    flat_map(0..(rows - 1), fn y ->
      flat_map(0..(columns - 1), fn x ->
        num = random(0..10)

        cond do
          player_x == x and player_y == y ->
            [{%Point{x: x, y: y}, %Player{}}]
          elem(target, 0) == x and elem(target, 1) == y ->
            [{%Point{x: x, y: y}, %Target{}}]
          num == 0 or rem(10, num) == 0 ->
            [{%Point{x: x, y: y}, %Bomb{}}]
          num == 0 or rem(15, num) == 0 ->
            [{%Point{x: x, y: y}, %PowerUp{}}]
          true ->
            [{%Point{x: x, y: y}, %Clear{}}]
        end
      end)
    end)
  end

  defp refresh_board(previous_board, old_player_position, new_player_position) do
    for {point, cell} <- previous_board do
      cond do
        point.x == old_player_position.x and point.y == old_player_position.y ->
          {point, %Clear{}}
        point.x == new_player_position.x and point.y == new_player_position.y ->
          {point, %Player{}}
        true ->
          {point, cell}
      end
    end
  end

  def update_board(previous_game_state, new_player_position) when is_struct(previous_game_state, GameBoard.GameState) do
    previous_board = previous_game_state.board
    previous_vision = previous_game_state.player_vision_radius

    new_state = Enum.reduce(previous_board, %GameState{
      board: previous_board,
      bombs: previous_game_state.bombs,
      game_over: false
    }, fn {point, cell}, acc ->
      case cell do
        %Player{} ->
          {_, cell} = Enum.find(previous_board, fn {k, _v} -> k == new_player_position end)

          new_board = refresh_board(acc.board, point, new_player_position)
          player_vision_radius = if cell === %PowerUp{} and previous_vision < 6 do
            previous_vision + 1
          else
            previous_vision
          end
          %GameState{
            board: new_board,
            player_vision_radius: player_vision_radius,
            game_over: (cell === %Bomb{} or cell === %Target{})
          }
        _ ->
          acc
      end
    end)

    new_state
  end

  def print_board(board, player_vision_radius) do
    player_data = Enum.find(board, fn {_, cell} -> is_struct(cell, Player) end)
    visible_area = Player.get_visible_area(elem(player_data, 0), player_vision_radius)

    each(board, fn {point, cell} ->
      if point in visible_area do
        case cell do
          %Bomb{} -> IO.write(" ó ")
          %Player{} -> IO.write(" p ")
          %Target{} -> IO.write(" T ")
          %PowerUp{} -> IO.write(" u ")
          _ -> IO.write(" x ")
        end
      else
        IO.write(" . ")
      end

      if point.x == 19 do IO.write("\n") end
    end)
  end

  def get_bomb_data(initial_board) do
    directions = [
      {:topleft, %Point{x: -1, y: -1}},
      {:top, %Point{x: 0, y: -1}},
      {:topright, %Point{x: 1, y: -1}},
      {:left, %Point{x: -1, y: 0}},
      {:right, %Point{x: 1, y: 0}},
      {:bottomleft, %Point{x: -1, y: 1}},
      {:bottom, %Point{x: 0, y: 1}},
      {:bottomright, %Point{x: 1, y: 1}}
    ]

    for {board_point, _cell} <- initial_board do
      counted_bombs = Enum.reduce(directions, 0, fn {_direction, direction_point}, acc ->
        scannable = Point.difference(board_point, direction_point)
        if scannable.y >= 0 and scannable.y < 20 and scannable.x >= 0 or scannable.x < 20 do
          tile_content = Enum.find(initial_board, fn {point, _} -> point == scannable end)

          if tile_content != nil do
            tile_content = elem(tile_content, 1)

            if tile_content == %Bomb{} do
              acc + 1
            else
              acc
            end
          else
            acc
          end
        else
          acc
        end
      end)

      [{board_point, counted_bombs}]
    end
  end
end
