module Azurite
  module Procedures
    module Equality(T)
      METHODS = {
        eq: "eq",
        ne: "not_eq"
      }

      {% for mongo, method in METHODS %}
        def {{method.id}}(value : T)
          @query[@key] ||= SearchType.new
          @query[@key]["${{mongo}}"] = value

          self
        end
      {% end %}
    end
  end
end
