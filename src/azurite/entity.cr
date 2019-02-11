require "./where_builder"

module Azurite
  # class FindBuilder(T)
  #   @query : Hash(String, SearchType)

  #   def initialize
  #     @query = Hash(String, SearchType).new
  #   end

  #   def initialize(@query)
  #   end

  #   def age
  #     procedure = with FindProcedure.new(@query, "age") yield
  #     @query = procedure.query
  #     self
  #   end

  #   def query
  #     @query
  #   end
  # end

  abstract class Entity
    FIELD_MAPPINGS = {} of Nil => Nil

    macro inherited
      # Macro level constants
      FIELDS = {} of Nil => Nil
      DEFAULTS = {} of Nil => Nil
      HAS_KEYS = [false]

      macro finished
        __process_attributes__
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
end
