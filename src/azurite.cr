require "./azurite/database"
require "./azurite/entity"
require "./azurite/repository"

module Azurite
  TYPES = [Nil, String, Bool, Int32, Int64, Float32, Float64, Time, Bytes]
  {% begin %}
    alias Any = Union({{*TYPES}})
  {% end %}
  alias SupportedArrayTypes = Array(String) | Array(Int16) | Array(Int32) | Array(Int64) | Array(Float32) | Array(Float64) | Array(Bool)
  alias Type = Any | SupportedArrayTypes

  VERSION = "0.1.0"
end
