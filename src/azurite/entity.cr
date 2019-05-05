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
        __initializers__
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
          { :id, BSON::ObjectId },
          {% for name, opts in FIELDS %}
            { :{{name}}, {{opts[:klass]}}},
          {% end %}
        ] {% if !HAS_KEYS[0] %} of Nil {% end %}
      end

      def self.from_bson(bson : BSON)
        model = new

        model.id = bson["_id"].as(BSON::ObjectId)

        {% for name, opts in FIELDS %}
          if bson.has_key?({{name.stringify}})
            {% if opts[:klass].resolve < Array %}
              model.{{name}} = bson[{{name.stringify}}].as(BSON).map { |item| item.value.as({{ opts[:klass].type_vars[0] }}) }
            {% else %}
              model.{{name}} = bson[{{name.stringify}}].as({{opts[:klass]}})
            {% end %}
          end
        {% end %}

        model
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
      @{{name.var}} : {{name.type}} | Nil

      def {{name.var}} : {{name.type}} | Nil
        @{{name.var}}
      end

      def {{name.var}}! : {{name.type}}
        @{{ name.var }}.not_nil!
      end

      def {{name.var}}=(val : {{name.type}})
        @{{ name.var }} = val
      end

      {%
        FIELDS[name.var] = {
          klass:          name.type,
          converter:      converter,
        }
      %}
      {% HAS_KEYS[0] = true %}
    end

    property id : BSON::ObjectId?

    macro __initializers__
      def initialize(**args : Object)
        set_attributes(args.to_h)
      end

      def initialize(args : Hash(Symbol | String, Azurite::Type))
        set_attributes(args)
      end

      private def set_attributes(args : Hash(String | Symbol, Azurite::Type))
        args.each do |k, v|
          cast_to_field(k, v.as(Azurite::Type))
        end
      end

      private def cast_to_field(name, value : Azurite::Type)
        {% unless FIELDS.empty? %}
          case name.to_s
            {% for _name, options in FIELDS %}
              {% type = options[:klass] %}
              when "{{_name.id}}" then @{{_name.id}} = cast_value(value, {{type}}).as({{type}}?)
            {% end %}
          end
        {% end %}
      end

      private def cast_value(value : Nil, type)
        nil
      end

      private def cast_value(value : Azurite::Type, type : Int32.class)
        value.is_a?(String) ? value.to_i32(strict: false) : value.is_a?(Int64) ? value.to_i32 : value.as(Int32)
      end

      private def cast_value(value : Azurite::Type, type : Int64.class)
        value.is_a?(String) ? value.to_i64(strict: false) : value.as(Int64)
      end

      private def cast_value(value : Azurite::Type, type : Float32.class)
        value.is_a?(String) ? value.to_f32(strict: false) : value.is_a?(Float64) ? value.to_f32 : value.as(Float32)
      end

      private def cast_value(value : Azurite::Type, type : Float64.class)
        value.is_a?(String) ? value.to_f64(strict: false) : value.as(Float64)
      end

      private def cast_value(value : Azurite::Type, type : Bool.class)
        Set.new(["1", "yes", "true", true, 1]).includes?(value)
      end

      private def cast_value(value : Azurite::Type, type : Time.class)
        value
      end

      private def cast_value(value : Azurite::Type, type : String.class)
        value.to_s
      end

      private def cast_value(value : Azurite::Type, type : Array(T).class)
        value.map { |val| cast_value(val, {{ type.resolve.type_vars[0] }}) }
      end

      private def cast_value(value : Azurite::Type, type)
        pp type

        nil
      end

      # private def cast_value(value : Azurite::Type, type)
      #   value.to_s
      # end
    end

    def new_record?
      @id == nil
    end
  end
end


# Add attributes for instance
# Insert to database
