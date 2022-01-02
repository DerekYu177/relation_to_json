require 'spec_helper'

class FakeUser < ActiveRecord::Base
  has_one :fake_keyboard
end

class FakeKeyboard < ActiveRecord::Base
  belongs_to :fake_user
end

describe(RelationToJSON::Base) do
  context 'with has one relation' do
    create_new_database_with do
      create_table :fake_users do |t|
        t.string :first_name
        t.string :last_name
      end

      create_table :fake_keyboards do |t|
        t.integer :fake_user_id
        t.string :model
      end
    end

    describe(FakeUser, type: :model) do
      before do
        5.times do |n|
          FakeUser.find_or_create_by(
            first_name: "FirstName::#{n}",
            last_name: "LastName::#{n}",
          ) do |user|
            keyboard = FakeKeyboard.find_or_create_by(model: "Model::#{n}")
            user.update!(fake_keyboard: keyboard)
          end
        end
      end

      let(:relation) { FakeUser.all }

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
          FakeUser.third.fake_keyboard.destroy!
        end

        it 'will gracefully provide a nil entry' do
          expect(subject.third[:fake_keyboard]).to(be_nil)
        end
      end
    end
  end
end
