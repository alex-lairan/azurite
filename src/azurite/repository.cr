require "./database"

module Azurite
  # A `Repository` represent a query interface.
  #
  # The type T represent an Entity that build a `WhereBuilder`
  #
  # Example :
  # ```
  # repo = Repository(SomeEntity).new
  # repo.where { some_property { gt(5) } }
  # repo.limit(50)
  # repo.execute
  # ```
  class Repository(T)
    @@collection_name = ""

    # Define the database collection.
    def self.collection_name=(name : String)
      @@collection_name = name
    end

    # :nodoc:
    def self.collection_name
      @@collection_name
    end

    @limit = 0
    @query = Hash(String, Hash(String, String | Int32)).new

    def initialize(@repo : Azurite::Database)
    end

    def builder
      T.builder.new(@query)
    end

    def where : Repository(T)
      _builder = with builder yield
      @query = _builder.query
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
