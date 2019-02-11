module Azurite
  module Query
    # A `Query::Builder` is generated from an `Entity`
    class Builder
      getter query : Hash(String, Hash(String, String | Int32))

      def initialize
        @query = Hash(String, Hash(String, String | Int32)).new
      end

      def initialize(@query)
      end

      def &(other)
        @query = @query.merge(other.query)
        self
      end

      def |(other)
        # Need implementation here.
        # The problem is the Query type.
        # Maybe AST will solve it.
        self
      end
    end
  end
end
