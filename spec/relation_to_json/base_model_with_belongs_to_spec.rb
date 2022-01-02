require 'spec_helper'

class FakeEmployee < ActiveRecord::Base
  belongs_to :fake_overlord
end

class FakeOverlord < ActiveRecord::Base
  has_one :fake_employee
end

class FakeAccount < ActiveRecord::Base
end

class FakeMessage < ActiveRecord::Base
  belongs_to :sender, class_name: 'FakeAccount'
  belongs_to :receiver, class_name: 'FakeAccount'
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

  context 'with multiple belongs_to of the same class' do
    create_new_database_with do
      create_table :fake_accounts do |t|
        t.string :first_name
      end

      create_table :fake_messages do |t|
        t.integer :sender_id
        t.integer :receiver_id
      end
    end

    describe(FakeMessage, type: :model) do
      before do
        5.times do |n|
          FakeMessage.find_or_create_by(id: n+1) do |message|
            sender = FakeAccount.find_or_create_by(first_name: "FirstName::Sender::#{n}")
            receiver = FakeAccount.find_or_create_by(first_name: "FirstName::Receiver::#{n}")
            message.update!(sender: sender, receiver: receiver)
          end
        end
      end

      let(:relation) { FakeMessage.all }

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      let(:schema) do
        [ sender: [ :first_name ], receiver: [ :first_name ] ]
      end

      it 'grabs all of the specified attributes' do
        expected = 5.times.map do |n|
          {
            "id" => n+1,
            "sender" => {
              "first_name" => "FirstName::Sender::#{n}",
              "id" => (2*n)+1,
            },
            "receiver" => {
              "first_name" => "FirstName::Receiver::#{n}",
              "id" => (2*n)+2,
            }
          }
        end

        expect(subject).to(eq(expected))
      end
    end
  end
end
