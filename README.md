# HSLuv

Elixir library to convert RGB to HSLuv and vice versa.

HSLuv is a color space for easy color manipulation in perceptual space.

<https://www.hsluv.org/>

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `hsluv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hsluv, "~> 0.2.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/hsluv](https://hexdocs.pm/hsluv).


## Example

```iex
# Create an HSLuv color from RGB values (0-255)
iex> HSLuv.rgb(200, 150, 20)
%HSLuv{h: 57.26077539223336, l: 65.07659371178795, s: 97.61326139925325}

# Convert HSL values to RGB (0-255)
iex> HSLuv.to_rgb(20, 50, 20)
{75, 38, 31}
```

## License

Licensed under either of

 * Apache License, Version 2.0
   ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license
   ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
