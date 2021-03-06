defmodule Identicon do

  def main(input) do
    hash_input(input)
    |> pick_color
    |> build_grid
    |> filter_odd
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _remain]} = image) do
    %Identicon.Image{image | colors: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid = Enum.chunk_every(hex_list, 3, 3, :discard)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([a, b |_tail] = row) do
    row ++ [b, a]
  end

  def filter_odd(%Identicon.Image{grid: grid} = image) do
    new_grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: new_grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{colors: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({top_left, bottom_right}) ->
      :egd.filledRectangle(image, top_left, bottom_right, fill)
    end

    :egd.render(image)
  end

  def save_image(binary_image, filename) do
    File.write("#{filename}.png", binary_image)
  end
end
