defmodule Minesweeper do
  require Logger
  use Application

  def start(_type, _args) do
    player_position = Player.get_initial_position()
    initial_board = player_position |> GameBoard.create_board(20, 20)

    GameBoard.print_board(initial_board, 2)
    bombs = GameBoard.get_bomb_data(initial_board)

    run(player_position, %GameBoard.GameState{board: initial_board, bombs: bombs, player_vision_radius: 2, game_over: false})
  end

  defp run(player_position, previous_board_state) do
    next_player_position = Player.get_next_position(player_position)

    next_player_position |> IO.inspect()
    next_game_state = GameBoard.update_board(previous_board_state, next_player_position)
    if next_game_state.game_over do
      Logger.info("game over!")
    else
      GameBoard.print_board(next_game_state.board, next_game_state.player_vision_radius)
    end

    run(next_player_position, next_game_state)
  end
end
