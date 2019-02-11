require "./where_builder"
require "./repository"

module Azurite
  class Query(T)
    @@collection_name = ""

    def self.set_collection_name(name : String)
      @@collection_name = name
    end

    def self.collection_name
      @@collection_name
    end

    @find : WhereBuilderBase = T._where_builder.new
    @limit = 0

    def builder
      @find
    end

    def initialize(@repo : Azurite::Repository)
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
