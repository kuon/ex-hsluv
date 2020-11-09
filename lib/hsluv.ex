defmodule HSLuv do
  @moduledoc """
  Convert colors between HSLuv and RGB color spaces
  """

  import :math

  @min_f 0.00000001
  @max_f 99.9999999

  @m {
    {3.240969941904521, -1.537383177570093, -0.498610760293},
    {-0.96924363628087, 1.87596750150772, 0.041555057407175},
    {0.055630079696993, -0.20397695888897, 1.056971514242878}
  }

  @m_inv {
    {0.41239079926595, 0.35758433938387, 0.18048078840183},
    {0.21263900587151, 0.71516867876775, 0.072192315360733},
    {0.019330818715591, 0.11919477979462, 0.95053215224966}
  }

  @ref_y 1.0
  @ref_u 0.19783000664283
  @ref_v 0.46831999493879
  @kappa 903.2962962
  @epsilon 0.0088564516

  @enforce_keys [:h, :s, :l]
  defstruct @enforce_keys

  @doc """
  Create an HSLuv color from values

  Both integer and floats are supported.

  - `h` must be between 0 and 360 included
  - `s` must be between 0 and 100 included
  - `l` must be between 0 and 100 included
  """
  def new(h, s, l) do
    %HSLuv{h: h, s: s, l: l}
  end

  @doc """
  Create an HSLuv color from RGB values

  Both integer and floats are supported.

  - `r` must be between 0 and 255 included
  - `g` must be between 0 and 255 included
  - `b` must be between 0 and 255 included

  ## Examples

      iex> HSLuv.rgb(200, 150, 20)
      %HSLuv{h: 57.26077539223336, l: 65.07659371178795, s: 97.61326139925325}
  """
  def rgb(r, g, b) do
    {h, s, l} = rgb_to_hsluv({r / 255.0, g / 255.0, b / 255.0})
    %HSLuv{h: h, s: s, l: l}
  end

  @doc """
  Convert HSLuv to RGB.

  Returned components are between 0 and 255 included

  ## Examples

      iex> HSLuv.to_rgb(20, 50, 20)
      {75, 38, 31}
  """
  def to_rgb(h, s, l) do
    new(h, s, l)
    |> to_rgb()
  end

  def to_rgb(%HSLuv{h: h, s: s, l: l}) do
    {r, g, b} = hsluv_to_rgb({h, s, l})
    {round(r * 255.0), round(g * 255.0), round(b * 255.0)}
  end

  @doc """
  Convert RGB to HSLuv.

  ## Examples

      iex> HSLuv.to_hsluv(20, 50, 20)
      {127.71501294923954, 67.94319276530133, 17.829530512200364}
  """
  def to_hsluv(r, g, b) do
    c = rgb(r, g, b)
    {c.h, c.s, c.l}
  end

  def hsluv_to_rgb([h, s, l]), do: hsluv_to_rgb({h, s, l})

  def hsluv_to_rgb({_h, _s, _l} = hsl) do
    hsl
    |> hsluv_to_lch()
    |> lch_to_luv()
    |> luv_to_xyz()
    |> xyz_to_rgb()
  end

  def hpluv_to_rgb([h, s, l]), do: hpluv_to_rgb({h, s, l})

  def hpluv_to_rgb({_h, _s, _l} = hsl) do
    hsl
    |> hpluv_to_lch()
    |> lch_to_luv()
    |> luv_to_xyz()
    |> xyz_to_rgb()
  end

  def rgb_to_hsluv([r, g, b]), do: rgb_to_hsluv({r, g, b})

  def rgb_to_hsluv({_r, _g, _b} = rgb) do
    rgb
    |> rgb_to_xyz()
    |> xyz_to_luv()
    |> luv_to_lch()
    |> lch_to_hsluv()
  end

  def rgb_to_hpluv([r, g, b]), do: rgb_to_hpluv({r, g, b})

  def rgb_to_hpluv({_r, _g, _b} = rgb) do
    rgb
    |> rgb_to_xyz()
    |> xyz_to_luv()
    |> luv_to_lch()
    |> lch_to_hpluv()
  end

  def lch_to_luv({l, c, h}) do
    h_rad = h / 360.0 * 2.0 * pi()

    {l, cos(h_rad) * c, sin(h_rad) * c}
  end

  def lch_to_luv([l, c, h]), do: lch_to_luv({l, c, h})

  def luv_to_lch({l, u, v}) do
    c = sqrt(u * u + v * v)

    h =
      if c < @min_f do
        0.0
      else
        atan2(v, u) * 180.0 / pi()
      end

    h =
      if h < 0.0 do
        360.0 + h
      else
        h
      end

    {l, c, h}
  end

  def luv_to_lch([l, u, v]), do: luv_to_lch({l, u, v})

  def xyz_to_rgb({_x, _y, _z} = xyz) do
    {m1, m2, m3} = @m
    {a, b, c} = {dot(m1, xyz), dot(m2, xyz), dot(m3, xyz)}
    {from_linear(a), from_linear(b), from_linear(c)}
  end

  def xyz_to_rgb([x, y, z]), do: xyz_to_rgb({x, y, z})

  def rgb_to_xyz({r, g, b}) do
    {m1, m2, m3} = @m_inv
    rgb = {to_linear(r), to_linear(g), to_linear(b)}
    {dot(m1, rgb), dot(m2, rgb), dot(m3, rgb)}
  end

  def rgb_to_xyz([r, g, b]), do: rgb_to_xyz({r, g, b})

  def xyz_to_luv({x, y, z}) do
    l = f(y)

    if l == 0.0 || (x == 0.0 && y == 0.0 && z == 0.0) do
      {0.0, 0.0, 0.0}
    else
      var_u = 4.0 * x / (x + 15.0 * y + 3.0 * z)

      var_v = 9.0 * y / (x + 15.0 * y + 3.0 * z)

      u = 13.0 * l * (var_u - @ref_u)

      v = 13.0 * l * (var_v - @ref_v)
      {l, u, v}
    end
  end

  def xyz_to_luv([x, y, z]), do: xyz_to_luv({x, y, z})

  def luv_to_xyz({l, u, v}) do
    if l == 0.0 do
      {0.0, 0.0, 0.0}
    else
      var_y = f_inv(l)
      var_u = u / (13.0 * l) + @ref_u
      var_v = v / (13.0 * l) + @ref_v
      y = var_y * @ref_y

      x = 0.0 - 9.0 * y * var_u / ((var_u - 4.0) * var_v - var_u * var_v)

      z = (9.0 * y - 15.0 * var_v * y - var_v * x) / (3.0 * var_v)
      {x, y, z}
    end
  end

  def luv_to_xyz([l, u, v]), do: luv_to_xyz({l, u, v})

  def hsluv_to_lch({h, s, l}) do
    cond do
      l > @max_f ->
        {100.0, 0, h}

      l < @min_f ->
        {0.0, 0.0, h}

      true ->
        {l, max_safe_chroma_for_lh(l, h) / 100.0 * s, h}
    end
  end

  def hsluv_to_lch([h, s, l]), do: hsluv_to_lch({h, s, l})

  def lch_to_hsluv({l, c, h}) do
    cond do
      l > @max_f ->
        {h, 0, 100.0}

      l < @min_f ->
        {h, 0.0, 0.0}

      true ->
        max_chroma = max_safe_chroma_for_lh(l, h)
        {h, c / max_chroma * 100.0, l}
    end
  end

  def lch_to_hsluv([l, c, h]), do: lch_to_hsluv({l, c, h})

  def hpluv_to_lch({h, s, l}) do
    cond do
      l > @max_f ->
        {100.0, 0, h}

      l < @min_f ->
        {0.0, 0.0, h}

      true ->
        {l, max_safe_chroma_for_l(l) / 100.0 * s, h}
    end
  end

  def hpluv_to_lch([h, s, l]), do: hpluv_to_lch({h, s, l})

  def lch_to_hpluv({l, c, h}) do
    cond do
      l > @max_f ->
        {h, 0.0, 100.0}

      l < @min_f ->
        {h, 0.0, 0.0}

      true ->
        {h, c / max_safe_chroma_for_l(l) * 100.0, l}
    end
  end

  def lch_to_hpluv([l, c, h]), do: lch_to_hpluv({l, c, h})

  def get_bounds(l) do
    sub = pow(l + 16.0, 3.0) / 1_560_896.0

    sub =
      if sub > @epsilon do
        sub
      else
        l / @kappa
      end

    compute = fn {m1, m2, m3}, t ->
      top1 = (284_517.0 * m1 - 94839.0 * m3) * sub

      top2 =
        (838_422.0 * m3 + 769_860.0 * m2 + 731_718.0 * m1) * l * sub -
          769_860.0 * t * l

      bottom = (632_260.0 * m3 - 126_452.0 * m2) * sub + 126_452.0 * t

      {top1 / bottom, top2 / bottom}
    end

    {m1, m2, m3} = @m

    [
      compute.(m1, 0.0),
      compute.(m1, 1.0),
      compute.(m2, 0.0),
      compute.(m2, 1.0),
      compute.(m3, 0.0),
      compute.(m3, 1.0)
    ]
  end

  def max_safe_chroma_for_l(l) do
    val = 1.7976931348623157e308

    l
    |> get_bounds()
    |> Enum.reduce(val, fn bound, val ->
      length = distance_line_from_origin(bound)

      if length >= 0.0 do
        min(val, length)
      else
        val
      end
    end)
  end

  def max_safe_chroma_for_lh(l, h) do
    h_rad = h / 360.0 * pi() * 2.0
    val = 1.7976931348623157e308

    l
    |> get_bounds()
    |> Enum.reduce(val, fn bound, val ->
      length = length_of_ray_until_intersect(h_rad, bound)

      if length >= 0.0 do
        min(val, length)
      else
        val
      end
    end)
  end

  def distance_line_from_origin({slope, intercept}) do
    abs(intercept) / sqrt(pow(slope, 2.0) + 1.0)
  end

  def length_of_ray_until_intersect(theta, {slope, intercept}) do
    intercept / (sin(theta) - slope * cos(theta))
  end

  def dot({a0, a1, a2}, {b0, b1, b2}) do
    a0 * b0 + a1 * b1 + a2 * b2
  end

  defp f(t) do
    if t > @epsilon do
      116.0 * pow(t / @ref_y, 1.0 / 3.0) - 16.0
    else
      t / @ref_y * @kappa
    end
  end

  defp f_inv(t) do
    if t > 8 do
      @ref_y * pow((t + 16.0) / 116.0, 3.0)
    else
      @ref_y * t / @kappa
    end
  end

  defp to_linear(c) do
    if c > 0.04045 do
      pow((c + 0.055) / 1.055, 2.4)
    else
      c / 12.92
    end
  end

  defp from_linear(c) do
    if c <= 0.0031308 do
      12.92 * c
    else
      1.055 * pow(c, 1.0 / 2.4) - 0.055
    end
  end
end
