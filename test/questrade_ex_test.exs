defmodule QuestradeExTest do
  use ExUnit.Case, async: true

  doctest QuestradeEx
  doctest QuestradeEx.Api
  doctest QuestradeEx.Content
  doctest QuestradeEx.Opts
  doctest QuestradeEx.Request
  doctest QuestradeEx.Response
  doctest QuestradeEx.Url
end
