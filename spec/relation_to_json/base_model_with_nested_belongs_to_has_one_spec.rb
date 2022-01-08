require 'spec_helper'

class FakeComplexMessage < ActiveRecord::Base
  belongs_to :sender, class_name: 'FakeComplexUser', inverse_of: :sent_messages
  belongs_to :receiver, class_name: 'FakeComplexUser', inverse_of: :received_messages
end

class FakeComplexUser < ActiveRecord::Base
  has_many :sent_messages, class_name: 'FakeComplexMessage', foreign_key: :sender_id
  has_many :received_messages, class_name: 'FakeComplexMessage', foreign_key: :receiver_id

  has_one :account, inverse_of: :user, foreign_key: :user_id
end

class FakeComplexAccount < ActiveRecord::Base
  belongs_to :user, polymorphic: true
end

class A < FakeComplexAccount; end
class B < FakeComplexAccount; end
class C < FakeComplexAccount; end

describe(RelationToJSON::Base) do
  context 'with nested belongs_to and has_one relation' do
    create_new_database_with do
      create_table :fake_complex_messages do |t|
        t.integer :sender_id
        t.integer :receiver_id
        t.string :content
      end

      create_table :fake_complex_users do |t|
        t.string :name
      end

      create_table :fake_complex_accounts do |t|
        t.integer :user_id
        t.string :type
      end
    end

    describe(FakeComplexMessage, type: :model) do
      before do
        a_account = A.create!
        b_account = B.create!

        FakeComplexUser.create!(name: "A", account: a_account)
        FakeComplexUser.create!(name: "B", account: b_account)
        FakeComplexUser.create!(name: "B+", account: b_account)

        FakeComplexMessage.create!(
          sender: FakeComplexUser.first,
          receiver: FakeComplexUser.second,
          content: "A::B::1",
        )
        FakeComplexMessage.create!(
          sender: FakeComplexUser.first,
          receiver: FakeComplexUser.third,
          content: "A::B+::1",
        )
        FakeComplexMessage.create!(
          sender: FakeComplexUser.first,
          receiver: FakeComplexUser.second,
          content: "A::B::2",
        )
        binding.pry
      end

      let(:relation) { FakeComplexMessage.all }

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      let(:schema) do
        [
          :content,
          sender: [
            :name,
            account: [ :type ],
          ],
          receiver: [
            :name,
            account: [ :type ],
          ]
        ]
      end

      it 'grabs all of the specified attributes' do
        expected = [
          {
            "id" => 1,
            "content" => "A::B::1",
            "sender" => {
              "name" => "A",
              "id" => 1,
              "account" => {
                "type" => "A",
                "id" => 1,
              },
            },
            "receiver" => {
              "name" => "B",
              "id" => 2,
              "account" => {
                "type" => "B",
                "id" => 2,
              },
            },
          },
          {
            "id" => 2,
            "content" => "A::B+::1",
            "sender" => {
              "name" => "A",
              "id" => 1,
              "account" => {
                "type" => "A",
                "id" => 1,
              },
            },
            "receiver" => {
              "name" => "B+",
              "id" => 3,
              "account" => {
                "type" => "B",
                "id" => 2,
              },
            },
          },
          {
            "id" => 3,
            "content" => "A::B::2",
            "sender" => {
              "name" => "A",
              "id" => 1,
              "account" => {
                "type" => "A",
                "id" => 1,
              },
            },
            "receiver" => {
              "name" => "B",
              "id" => 2,
              "account" => {
                "type" => "B",
                "id" => 2,
              },
            },
          },
        ]

        expect(subject).to(eq(expected))
      end
    end
  end
end
