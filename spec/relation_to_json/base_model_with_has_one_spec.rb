require 'spec_helper'

class FakeDeveloper < ActiveRecord::Base
  has_one :fake_keyboard
end

class FakeKeyboard < ActiveRecord::Base
  belongs_to :fake_developer
end

describe(RelationToJSON::Base) do
  context 'with has one relation' do
    create_new_database_with do
      create_table :fake_developers do |t|
        t.string :first_name
        t.string :last_name
      end

      create_table :fake_keyboards do |t|
        t.integer :fake_developer_id
        t.string :model
      end
    end

    describe(FakeDeveloper, type: :model) do
      before do
        5.times do |n|
          FakeDeveloper.find_or_create_by(
            first_name: "FirstName::#{n}",
            last_name: "LastName::#{n}",
          ) do |user|
            keyboard = FakeKeyboard.find_or_create_by(model: "Model::#{n}")
            user.update!(fake_keyboard: keyboard)
          end
        end
      end

      let(:relation) { FakeDeveloper.all }

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      let(:schema) do
        [ :first_name, fake_keyboard: [ :model ] ]
      end

      it 'grabs all of the specified attributes' do
        expected = 5.times.map do |n|
          {
            "first_name" => "FirstName::#{n}",
            "id" => n+1,
            "fake_keyboard" => {
              "id" => n+1,
              "model" => "Model::#{n}",
            }
          }
        end

        expect(subject).to(eq(expected))
      end

      context 'when one of the relations is nil' do
        before do
          FakeDeveloper.third.fake_keyboard.destroy!
        end

        it 'will gracefully provide a nil entry' do
          expect(subject.third[:fake_keyboard]).to(be_nil)
        end
      end
    end
  end
end
