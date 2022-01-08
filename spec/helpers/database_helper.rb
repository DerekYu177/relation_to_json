require 'active_record'

config =  {
  adapter: 'sqlite3',
  database: ':memory:',
}

ActiveRecord::Base.establish_connection(config)

load "spec/db/schema.rb"

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

require_relative '../models'
