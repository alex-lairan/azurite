module Azurite
  alias SearchType = Hash(String, SearchSubtype)
  alias SearchSubtype = String | Int32

  class FindProcedure
    @query = Hash(String, SearchType).new

    def initialize(@query, @key : String)
    end

    def eq(val : Int32) : FindProcedure
      @query[@key] ||= SearchType.new
      @query[@key]["$eq"] = val

      self
    end

    def gt(val : Int32) : FindProcedure
      @query[@key] ||= SearchType.new
      @query[@key]["$gt"] = val

      self
    end

    def lt(val : Int32) : FindProcedure
      @query[@key] ||= SearchType.new
      @query[@key]["$lt"] = val

      self
    end

    def &(procedure : FindProcedure)
      @query.merge(procedure.query)

      self
    end

    def |(procedure : FindProcedure)
      self
    end

    def query
      @query
    end
  end

  class WhereBuilderBase
    @query : Hash(String, Hash(String, String | Int32))

    def initialize
      @query = Hash(String, Hash(String, String | Int32)).new
    end

    def initialize(@query)
    end
  end
end
