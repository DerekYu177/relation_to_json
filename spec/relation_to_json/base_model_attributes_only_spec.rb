require 'spec_helper'

describe(RelationToJSON::Base) do
  context 'with only model attributes' do
    describe(User, type: :model) do
      before do
        5.times do |n|
          User.find_or_create_by(first_name: "FirstName#{n}", last_name: "LastName#{n}")
        end
      end

      let(:relation) { User.all }

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      context 'with only a single attribute' do
        let(:schema) do
          [ :first_name ]
        end

        it 'only grabs the specified attribute' do
          expected = 5.times.map { |n| { 'first_name' => "FirstName#{n}", 'id' => n + 1 }}
          expect(subject).to(eq(expected))
        end

        it 'return values are indifferent to access key' do
          expect(subject.first['first_name']).to(eq(subject.first[:first_name]))
        end
      end

      context 'with multiple attributes' do
        let(:schema) do
          [ :first_name, :last_name ]
        end

        it 'only grabs the specified attributes' do
          expected = 5.times.map { |n| { 'first_name' => "FirstName#{n}", 'last_name' => "LastName#{n}", 'id' => n + 1 }}
          expect(subject).to(eq(expected))
        end
      end
    end
  end
end
