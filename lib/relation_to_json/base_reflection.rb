# frozen_string_literal: true

module RelationToJSON
  class BaseReflection
    attr_reader :reflection, :name
    attr_accessor :required_columns

    def initialize(reflection, reflection_name, reflection_columns)
      @reflection = reflection
      @name = reflection_name
      @required_columns = reflection_columns
    end

    delegate :active_record, :polymorphic?, :klass, to: :reflection

    def primary_key
      reflection.active_record.primary_key.to_sym
    end

    def foreign_key
      reflection.foreign_key.to_sym
    end

    private

    def recurse_json_with_schema(transposed)
      association_relation(transposed).as_json_with_schema(required_columns)
    end

    def nested_relations?
      required_columns.any? { _1.is_a?(Hash) }
    end
  end
end
