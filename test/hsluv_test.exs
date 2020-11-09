defmodule HSLuvTest do
  use ExUnit.Case
  doctest HSLuv

  import HSLuv

  test "snapshot v4" do
    "test/snapshot-rev4.json"
    |> File.read!()
    |> Jason.decode!()
    |> Enum.each(fn {hex, v} ->
      [r, g, b] =
        hex
        |> String.slice(1, 6)
        |> String.codepoints()
        |> Enum.chunk_every(2)
        |> Enum.map(fn v ->
          v
          |> Enum.join()
          |> String.to_integer(16)
          |> Kernel./(255.0)
        end)

      %{
        "hpluv" => hpluv,
        "hsluv" => hsluv,
        "lch" => lch,
        "luv" => luv,
        "rgb" => rgb,
        "xyz" => xyz
      } = v

      assert_color({r, g, b}, rgb)
      assert_color(lch_to_luv(lch), luv)
      assert_color(luv_to_lch(luv), lch)
      assert_color(xyz_to_rgb(xyz), rgb)
      assert_color(rgb_to_xyz(rgb), xyz)
      assert_color(xyz_to_luv(xyz), luv)
      assert_color(luv_to_xyz(luv), xyz)
      assert_color(hsluv_to_lch(hsluv), lch)
      assert_color(lch_to_hsluv(lch), hsluv)
      assert_color(hpluv_to_lch(hpluv), lch)
      assert_color(lch_to_hpluv(lch), hpluv)
      assert_color(hsluv_to_rgb(hsluv), rgb)
      assert_color(hpluv_to_rgb(hpluv), rgb)
      assert_color(rgb_to_hsluv(rgb), hsluv)
      assert_color(rgb_to_hpluv(rgb), hpluv)
    end)
  end

  defp assert_color({a0, b0, c0}, {a1, b1, c1}) do
    assert_in_delta(a0, a1, 0.000000001)
    assert_in_delta(b0, b1, 0.000000001)
    assert_in_delta(c0, c1, 0.000000001)
  end

  defp assert_color({a0, b0, c0}, [a1, b1, c1]) do
    assert_color({a0, b0, c0}, {a1, b1, c1})
  end

  defp assert_color([a0, b0, c0], [a1, b1, c1]) do
    assert_color({a0, b0, c0}, {a1, b1, c1})
  end

  defp assert_color([a0, b0, c0], {a1, b1, c1}) do
    assert_color({a0, b0, c0}, {a1, b1, c1})
  end
end
