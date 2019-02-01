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

  class FindBuilder(T)
    @query = Hash(String, SearchType).new

    def initialize
      @query = Hash(String, SearchType).new
    end

    def initialize(@query)
    end

    def age
      procedure = with FindProcedure.new(@query, "age") yield
      @query = procedure.query
      self
    end

    def query
      @query
    end
  end


  class Query(T)
    @@collection_name = ""

    def self.set_collection_name(name : String)
      @@collection_name = name
    end

    def self.collection_name
      @@collection_name
    end

    @find = FindBuilder(T).new
    @limit = 0

    def initialize(@repo : Repository)
    end

    def where : Query(T)
      with @find yield
      self
    end

    def limit(count : Int) : Query(T)
      @limit = count
      self
    end

    def count : Query(T)
      self
    end

    def query
      @find.query
    end

    def exec : Array(T)
      [] of T
    end

    def find : T?
      where.limit(1).exec.first
    end
  end
end
