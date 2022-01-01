# frozen_string_literal: true

module RelationToJSON
  class BelongsToReflection < BaseReflection
    def pluck_association_columns(transposed)
      return recurse_json_with_schema(transposed) if nested_relations?

      required_columns = Set[primary_key, *@required_columns]
      plucked_attributes = association_relation(transposed)
        .pluck(*required_columns)
        .map { |plucked| required_columns.zip(Array.wrap(plucked)).to_h }

      primary_key_indexed_plucked_values = plucked_attributes
        .to_h { |attributes| [attributes[primary_key], attributes] }

      transposed.fetch(foreign_key, []).map do |record_primary_key|
        primary_key_indexed_plucked_values[record_primary_key]
      end
    end

    def association_relation(transposed)
      if polymorphic?
        active_record.where(
          primary_key => transposed[foreign_key],
        )
      else
        klass.where(
          primary_key => transposed[foreign_key],
        )
      end
    end
  end
end
