require "../spec_helper"

# class UserModel < Azurite::Entity
#   attribute name : String
#   attribute foo : Int32
# end

# class UserRepo < Azurite::Query(UserModel)
# end

module Foo
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

  class WhereBuilder
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
  end

  class Entity
    FIELD_MAPPINGS = {} of Nil => Nil

    macro inherited
      FIELDS = {} of Nil => Nil
      HAS_KEYS = [false]

      macro finished
        __process_attributes__
        __build_query__
      end
    end

    macro __process_attributes__
      {% FIELD_MAPPINGS[@type.name.id] = FIELDS %}
      {% klasses = @type.ancestors %}
      {% for name, index in klasses %}
        {% fields = FIELD_MAPPINGS[name.id] %}

        {% if fields && !fields.empty? %}
          {% for name, opts in fields %}
            {% FIELDS[name] = opts %}
            {% HAS_KEYS[0] = true %}
          {% end %}
        {% end %}
      {% end %}

      def self.attributes
        [
          {% for name, opts in FIELDS %}
            { :{{name}}, {{opts[:klass]}}},
          {% end %}
        ] {% if !HAS_KEYS[0] %} of Nil {% end %}
      end
    end

    macro __build_query__
      class InternalBuilder < WhereBuilder
        {% for name, opts in FIELDS %}
          def {{ name.id }}
            procedure = with FindProcedure.new(@query, {{name.stringify}}) yield
            @query = procedure.query
            self
          end
        {% end %}
      end

      def self.builder : InternalBuilder.class
        InternalBuilder
      end
    end

    macro attribute(name, converter = nil)
      def {{name.var}} : {{name.type}} | Nil
        {% if name.value %}
          {{ name.value }}
        {% else %}
          nil
        {% end %}
      end

      {%
        FIELDS[name.var] = {
          klass:          name.type,
          converter:      converter,
        }
      %}
      {% HAS_KEYS[0] = true %}
    end
  end

  class Repository(T)
    @@collection_name = ""

    def self.set_collection_name(name : String)
      @@collection_name = name
    end

    def self.collection_name
      @@collection_name
    end

    @limit = 0
    @query = Hash(String, Hash(String, String | Int32)).new

    def builder
      T.builder.new(@query)
    end

    def where : Repository(T)
      _builder = with builder yield
      @query = _builder.query
      self
    end
  end

  class User < Entity
    attribute age : Int32
    attribute name : String
  end

  class Users < Repository(User)
  end
end

describe Azurite::Entity do
  it "debug" do
    # pp "debug"
    # pp UserModel.attributes
    # repo = Azurite::Repository.new("mongodb://localhost:27017", "test")
    # pp UserRepo.new(repo).builder

    pp Foo::User.attributes
    pp Foo::User.builder.new

    repo = Foo::Users.new
    pp repo
    pp repo.builder

    repo.where {
      age { gt(5) & lt(100) } & name { gt(5) }
    }

    pp repo.builder
  end
end
