require_relative "relation_to_json/base"
require_relative "relation_to_json/base_reflection"
require_relative "relation_to_json/belongs_to_reflection"
require_relative "relation_to_json/has_one_reflection"

class InvalidSchemaError < StandardError
  def initialize(invalid_attributes, klass)
    @invalid_attributes = invalid_attributes
    @klass = klass
  end

  def message
    "The attributes: #{@invalid_attributes} do not exist on the model: #{@klass.name}, which has attributes #{@klass.column_names}"
  end
end
