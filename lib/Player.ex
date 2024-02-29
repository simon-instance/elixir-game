defmodule Player do
  require Logger

  defstruct []

  def increase_vision(previous_vision_radius) do
    Logger.info("increasing?")
    if previous_vision_radius < 5 do
      previous_vision_radius + 1
    end
  end

  def change_player_pos(character, current_player_position) do
    case character do
      :q -> %GameBoard.Point{x: current_player_position.x - 1, y: current_player_position.y - 1}
      :w -> %GameBoard.Point{x: current_player_position.x, y: current_player_position.y - 1}
      :e -> %GameBoard.Point{x: current_player_position.x + 1, y: current_player_position.y - 1}
      :a -> %GameBoard.Point{x: current_player_position.x - 1, y: current_player_position.y}
      :d -> %GameBoard.Point{x: current_player_position.x + 1, y: current_player_position.y}
      :z -> %GameBoard.Point{x: current_player_position.x - 1, y: current_player_position.y + 1}
      :x -> %GameBoard.Point{x: current_player_position.x, y: current_player_position.y + 1}
      :c -> %GameBoard.Point{x: current_player_position.x + 1, y: current_player_position.y + 1}
      _ -> current_player_position
    end
  end

  def get_next_position(current_player_position) do
    character = IO.gets("Give an input character (q,w,e,a,d,z,x,c): ")
      |> String.trim()

    if !String.match?(character, ~r/^[aqwedcxz]$/) do
      IO.puts("Character should have format: [aqwedcxz]")
      get_next_position(current_player_position)
    else
      new_player_position = String.to_atom(character) |> change_player_pos(current_player_position)
      if new_player_position.x < 0 || new_player_position.x > 19
      || new_player_position.y < 0 || new_player_position.y > 19 do
        IO.puts("Het ingevoerde coordinaat is geen valide coordinaat, probeer opnieuw")
        get_next_position(current_player_position)
      else
        new_player_position
      end
    end
  end

  def get_initial_position() do
    coordinates = IO.gets("Voer het coordinaat in waar je wilt beginnen: ") |> String.trim()

    if !String.match?(coordinates, ~r/^\d+,\d+$/) do
      Logger.error("Coordinates should have format [number],[number]")
    end

    case String.split(coordinates, ",") do
      [x_str, y_str] ->
        player_x = String.to_integer(x_str)
        player_y = String.to_integer(y_str)

        %GameBoard.Point{
          x: player_x,
          y: player_y
        }
    end
  end

  def get_visible_area(new_player_position, vision_radius) do
    %GameBoard.Point{x: player_x, y: player_y} = new_player_position

    for y <- player_y - vision_radius..player_y + vision_radius,
      x <- player_x - vision_radius..player_x + vision_radius do
        distance = :math.sqrt((x - player_x) ** 2 + (y - player_y) ** 2)

        if distance <= vision_radius do
          %GameBoard.Point{x: x, y: y}
        end
      end
  end
end
