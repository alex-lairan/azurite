require "../spec_helper"

# class UserModel < Azurite::Entity
#   attribute name : String
#   attribute foo : Int32
# end

# class UserRepo < Azurite::Query(UserModel)
# end

module Foo
  class WhereBuilder
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
        {% klasses = @type.ancestors %}
        {% for name, index in klasses %}
          {% fields = FIELD_MAPPINGS[name.id] %}

          {% if fields && !fields.empty? %}
            {% for name, opts in fields %}
              def {{ name.id }}
                {{ opts[:klass] }}
              end
            {% end %}
          {% end %}
        {% end %}
      end

      def self.builder : WhereBuilder.class
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
    @find : WhereBuilder

    def initialize
      @find = T.builder.new
    end

    def builder
      @find
    end

    def where : Query(T)
      with @find yield
      self
    end
  end

  class User < Entity
    attribute age : Int32
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
  end
end
