require 'spec_helper'

class FakeUser < ActiveRecord::Base; end

describe(RelationToJSON::Base) do
  context 'with only model attributes' do
    switch_to_SQLite do
      create_table :fake_users do |t|
        t.string :first_name
        t.string :last_name
      end
    end

    describe(FakeUser, type: :model) do
      let(:relation) do
        5.times do |n|
          FakeUser.create!(first_name: "FirstName#{n}")
        end

        FakeUser.all
      end

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      let(:schema) do
        [ :first_name ]
      end

      it 'only grabs the specified attribute' do
        expected = 5.times.map { |n| { 'first_name' => "FirstName#{n}", 'id' => n + 1 }}
        expect(subject).to(eq(expected))
      end
    end
  end
end
