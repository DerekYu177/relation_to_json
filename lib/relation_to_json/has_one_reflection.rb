# frozen_string_literal: true

module RelationToJSON
  class HasOneReflection < BaseReflection
    def pluck_association_columns(transposed)
      return recurse_json_with_schema(transposed) if nested_relations?

      required_columns = Set[primary_key, *@required_columns]
      plucked_attributes = association_relation(transposed)
        .pluck(*required_columns)
        .map { |plucked| required_columns.zip(Array.wrap(plucked)).to_h }

      foreign_key_indexed_plucked_values = plucked_attributes
        .to_h { |attributes| [attributes[foreign_key], attributes] }

      transposed.fetch(primary_key, []).map do |record_foreign_key|
        foreign_key_indexed_plucked_values[record_foreign_key]
      end
    end

    def association_relation(transposed)
      query = { foreign_key => transposed[primary_key] }
      query[polymorphic_association_key] = foreign_class if polymorphic?
      klass.where(**query)
    end

    def polymorphic?
      reflection.inverse_of.polymorphic?
    end

    def polymorphic_association_key
      # *_type
      reflection.type
    end

    def foreign_class
      reflection.active_record.name
    end
  end
end
