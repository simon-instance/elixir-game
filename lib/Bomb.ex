defmodule Bomb do
  defstruct []

  def player_on_bomb(bomb_point, player_point) do
    bomb_point.x == player_point.x and bomb_point.y == player_point.y
  end
end
