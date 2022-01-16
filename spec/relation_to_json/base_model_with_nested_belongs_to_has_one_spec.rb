require 'spec_helper'

describe(RelationToJSON::Base) do
  context 'with nested belongs_to and has_one relation' do
    describe(Message, type: :model) do
      before do
        user_a = User.create!(first_name: "FirstName1")
        user_b = User.create!(first_name: "FirstName2")
        user_c = User.create!(first_name: "FirstName3")

        Developer.create!(title: "DeveloperA", user: user_a)
        Developer.create!(title: "DeveloperB", user: user_b)
        Developer.create!(title: "DeveloperC", user: user_c)

        Message.create!(
          sender: Developer.first,
          receiver: Developer.second,
          content: "DeveloperA::DeveloperB::1",
        )
        Message.create!(
          sender: Developer.first,
          receiver: Developer.third,
          content: "DeveloperA::DeveloperC::1",
        )
        Message.create!(
          sender: Developer.first,
          receiver: Developer.second,
          content: "DeveloperA::DeveloperB::2",
        )
      end

      let(:relation) { Message.all }

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      let(:schema) do
        [
          :content,
          sender: [
            :title,
            user: [ :first_name ],
          ],
          receiver: [
            :title,
            user: [ :first_name ],
          ]
        ]
      end

      it 'grabs all of the specified attributes' do
        expected = [
          {
            "id" => 1,
            "content" => "DeveloperA::DeveloperB::1",
            "sender" => {
              "title" => "DeveloperA",
              "id" => 1,
              "user" => {
                "first_name" => "FirstName1",
                "id" => 1,
              },
            },
            "receiver" => {
              "title" => "DeveloperB",
              "id" => 2,
              "user" => {
                "first_name" => "FirstName2",
                "id" => 2,
              },
            },
          },
          {
            "id" => 2,
            "content" => "DeveloperA::DeveloperC::1",
            "sender" => {
              "title" => "DeveloperA",
              "id" => 1,
              "user" => {
                "first_name" => "FirstName1",
                "id" => 1,
              },
            },
            "receiver" => {
              "title" => "DeveloperC",
              "id" => 3,
              "user" => {
                "first_name" => "FirstName3",
                "id" => 3,
              },
            },
          },
          {
            "id" => 3,
            "content" => "DeveloperA::DeveloperB::2",
            "sender" => {
              "title" => "DeveloperA",
              "id" => 1,
              "user" => {
                "first_name" => "FirstName1",
                "id" => 1,
              },
            },
            "receiver" => {
              "title" => "DeveloperB",
              "id" => 2,
              "user" => {
                "first_name" => "FirstName2",
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
