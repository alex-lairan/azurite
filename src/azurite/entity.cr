require "./query/builder"
require "./query/procedure"

module Azurite
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
      class InternalBuilder < Azurite::Query::Builder
        {% for name, opts in FIELDS %}
          def {{ name.id }}
            procedure = with Azurite::Query::Procedure.new(@query, {{name.stringify}}) yield
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
end
