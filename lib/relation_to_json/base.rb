# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"

module RelationToJSON
  class Base
    attr_reader :relation, :schema

    def initialize(relation, schema)
      @relation = relation
      @schema = schema
    end

    def as_json
      # put everything here, anything else is private
      attributes, schema_associations = schema
        .partition { |e| e.is_a?(Symbol) }
      schema_associations = schema_associations.first.dup || []

      attributes = Set[:id] + attributes

      reflections = ReflectionBuilder.build(schema_associations, relation)
      schema_associations.each do |schema_association, association_attributes|
        reflection = reflections[schema_association]

        case reflection
        when RelationToJSON::BelongsToReflection
          attributes << reflection.foreign_key.to_sym
        when RelationToJSON::HasOneReflection
          association_attributes << reflection.foreign_key.to_sym
        end
      end

      result = relation
        .pluck(*attributes)
        .map { |plucked| attributes.zip(Array.wrap(plucked)).to_h }

      transposed = transpose(result)

      reflections.each do |reflection_name, reflection|
        foreign_key = reflection.foreign_key
        primary_key = reflection.primary_key

        # if the current schema still has associations
        # then we need to recursively find the JSON
        # representation of that association
        # Otherwise, we can perform a shallow .pluck
        # of the association attributes
        # and map them back onto the transposed hash
        # this returns an array of hashes that map association attributes to plucked values
        plucked_values = reflection.pluck_association_columns(transposed)

        case reflection
        when RelationToJSON::BelongsToReflection
        # build a temporary mapping of id => assigned_attributes
          associated_model_primary_key_indexed_plucked_values = if reflection.polymorphic?
            plucked_values
              .compact
              .to_h { |attrs| [attrs[primary_key], attrs] }
          else
            plucked_values
              .to_h { |attrs| [attrs[primary_key], attrs] }
          end

          result.each do |record|
            foreign_key_value = record[foreign_key]
            plucked_values = associated_model_primary_key_indexed_plucked_values[foreign_key_value]
            record[reflection_name] = plucked_values
            record.except!(foreign_key)
          end
        when RelationToJSON::HasOneReflection
        # build a temporary mapping of id => assigned_attributes
          associated_model_foreign_key_indexed_plucked_values = plucked_values
            .to_h { |attrs| [attrs[foreign_key], attrs] }

          result.each do |record|
            primary_key_value = record[primary_key]
            plucked_values = associated_model_foreign_key_indexed_plucked_values[primary_key_value]
            plucked_values.except!(foreign_key)
            record[reflection_name] = plucked_values
          end
        end
      end

      result&.map { |partial| partial.with_indifferent_access }
    end

    private

    def transpose(values)
      # values is a list of hashes
      # each hash should be identical
      # i.e. [{id: 1, clinical_sender_id: 2}, {id: 2, clinical_sender_id: 3}]
      # and tranposes into a hash
      # with identical keys
      # but values are arrays
      # i.e. { id: [1, 2], clinical_sender_id: [2, 3] }

      result = {}

      values.each do |value|
        value.each do |k, v|
          if result.include?(k)
            result[k] << v
          else
            result[k] = [v]
          end
        end
      end

      result
    end
  end
end
