require "./equality"

module Azurite
  module Procedures
    module Comparison(T)
      include Equality(T)

      METHODS = {
        gt: "gt",
        gte: "gteq",
        lt: "lt",
        lte: "lteq"
      }

      {% for mongo, method in METHODS %}
        def {{method.id}}(value : T)
          @query[@key] ||= SearchType.new
          @query[@key]["${{mongo}}"] = value

          {
            @key => {
              "${{mongo}}" => value
            }
          }

          self
        end
      {% end %}
    end
  end
end
