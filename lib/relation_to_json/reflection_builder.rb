# frozen_string_literal: true

module RelationToJSON
  class ReflectionBuilder
    class UnsupportedReflectionType < StandardError
      def initialize(reflection)
        @reflection = reflection
      end

      def message
        "Unrecognized reflection type: #{reflection.class}"
      end
    end

    def self.build(schema_associations, relation)
      schema_associations.to_h do |reflection_name, reflection_columns|
        # for each association
        # we first have to get the relation that the association has
        # with the active record relation
        active_record_reflection = relation.model.reflections.fetch(reflection_name.to_s)

        klass = case active_record_reflection
        when ActiveRecord::Reflection::BelongsToReflection
          RelationToJSON::BelongsToReflection
        when ActiveRecord::Reflection::HasOneReflection
          RelationToJSON::HasOneReflection
        else
          raise UnsupportedReflectionType.new(active_record_reflection)
        end

        [
          reflection_name,
          klass.new(active_record_reflection, reflection_name, reflection_columns),
        ]
      end
    end
  end
end
