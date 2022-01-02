module Helpers
  module InMemoryDatabaseHelper
    extend ActiveSupport::Concern

    class_methods do
      def create_new_database_with(&block)
        before(:all) { switch_to_in_memory_database(&block) }
        after(:all)  { clear_in_memory_database }
      end
    end

    private

    def switch_to_in_memory_database(&block)
      raise 'No migration given' unless block_given?

      config = {
        test: {
          adapter: 'sqlite3',
          database: ':memory:',
        }
      }
      ActiveRecord::Base.configurations = config

      ::ActiveRecord::Migration.verbose = false
      ::ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      ::ActiveRecord::Schema.define(version: 1, &block)
    end

    def clear_in_memory_database
      ::ActiveRecord::Base.remove_connection
    end
  end
end
