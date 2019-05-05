module Azurite
  module Query
    alias SearchType = Hash(String, SearchSubtype)
    alias SearchSubtype = String | Int32

    class Procedure
      @query = Hash(String, SearchType).new

      def initialize(@query, @key : String)
      end

      def eq(val : Int32 | String) : Procedure
        @query[@key] ||= SearchType.new
        @query[@key]["$eq"] = val

        self
      end

      def gt(val : Int32) : Procedure
        @query[@key] ||= SearchType.new
        @query[@key]["$gt"] = val

        self
      end

      def lt(val : Int32) : Procedure
        @query[@key] ||= SearchType.new
        @query[@key]["$lt"] = val

        self
      end

      def &(procedure : Procedure)
        @query.merge(procedure.query)

        self
      end

      def |(procedure : Procedure)
        # Need implementation here.
        # The problem is the Query type.
        # Maybe AST will solve it.
        self
      end

      def query
        @query
      end
    end
  end
end
