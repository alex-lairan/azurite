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
    macro inherited
      @@collection_name : String = ""

      # Define the database collection.
      def self.collection(name : String)
        @@collection_name = name
      end

      # :nodoc:
      def self.collection_name : String
        @@collection_name
      end
    end

    @limit = 0
    @query = Hash(String, Hash(String, String | Int32)).new

    def initialize(@repo : Azurite::Database)
    end

    def builder
      T.builder.new(@query)
    end

    def where : Repository(T)
      _builder = builder
      with _builder yield
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
      collection_name = self.class.collection_name
      pp collection_name
      collection = @repo.database[collection_name]

      result = collection.find(@query)
      pp result

      result.map do |bson|
        T.from_bson(bson)
      end
    end

    def self.all : Array(T)
      new.all
    end

    def all : Array(T)
      where.exec
    end

    def find : T?
      where.limit(1).exec.first
    end

    def insert(values : Array(T)) : Bool
      true
    end
  end
end
