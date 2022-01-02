require 'spec_helper'

class FakeEmployee < ActiveRecord::Base
  belongs_to :fake_overlord
end

class FakeOverlord < ActiveRecord::Base
  has_one :fake_employee
end

describe(RelationToJSON::Base) do
  context 'with belongs to relation' do
    create_new_database_with do
      create_table :fake_employees do |t|
        t.integer :fake_overlord_id
        t.string :first_name
      end

      create_table :fake_overlords do |t|
        t.string :name
      end
    end

    describe(FakeEmployee, type: :model) do
      before do
        5.times do |n|
          FakeOverlord.find_or_create_by(name: "Company#{n}") do |fake_overlord|
            FakeEmployee.find_or_create_by(first_name: "FirstName#{n}", fake_overlord: fake_overlord)
          end
        end
      end

      let(:relation) { FakeEmployee.all }

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      let(:schema) do
        [ :first_name, fake_overlord: [ :name ] ]
      end

      it 'grabs all of the specified attributes' do
        expected = 5.times.map do |n|
          {
            "first_name" => "FirstName#{n}",
            "id" => n+1,
            "fake_overlord" => {
              "id" => n+1,
              "name" => "Company#{n}"
            }
          }
        end

        expect(subject).to(eq(expected))
      end
    end
  end
end
