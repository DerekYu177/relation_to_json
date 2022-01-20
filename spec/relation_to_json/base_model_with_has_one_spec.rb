require 'spec_helper'

describe(RelationToJSON::Base) do
  context 'with has_one relation' do
    describe(Developer, type: :model) do
      before do
        5.times do |n|
          Developer.create!(title: "Title#{n}") do |developer|
            user = User.create!(first_name: "FirstName#{n}")
            developer.update!(user: user)
          end
        end
      end

      let(:relation) { Developer.all }

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      let(:schema) do
        [ :title, user: [ :first_name ] ]
      end

      it 'grabs all of the specified attributes' do
        expected = 5.times.map do |n|
          {
            "title" => "Title#{n}",
            "id" => n+1,
            "user" => {
              "id" => n+1,
              "first_name" => "FirstName#{n}",
            }
          }
        end

        expect(subject).to(eq(expected))
      end

      it 'raises if attribute requested is not a valid attribute' do
        schema = [:invalid_attribute]
        expect { RelationToJSON::Base.new(relation, schema).as_json }
          .to(raise_error(InvalidSchemaError))
      end

      context 'when one of the relations is nil' do
        before do
          Developer.third.user.destroy!
        end

        it 'will gracefully provide a nil entry' do
          expect(subject.third[:user]).to(be_nil)
        end
      end
    end
  end
end
