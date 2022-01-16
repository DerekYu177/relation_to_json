require 'spec_helper'

describe(RelationToJSON::Base) do
  context 'with belongs to relation' do
    describe(Developer, type: :model) do
      before do
        5.times do |n|
          Company.create(name: "Company#{n}") do |company|
            Developer.create(title: "Title#{n}", company: company)
          end
        end
      end

      let(:relation) { Developer.all }

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      let(:schema) do
        [ :title, company: [ :name ] ]
      end

      it 'grabs all of the specified attributes' do
        expected = 5.times.map do |n|
          {
            "title" => "Title#{n}",
            "id" => n+1,
            "company" => {
              "id" => n+1,
              "name" => "Company#{n}"
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
          Company.first.destroy!
        end

        it 'will gracefully provide a nil entry' do
          expect(subject.first[:company]).to(be_nil)
        end
      end

      context 'when associations may not be unique' do
        let(:schema) do
          [ company: [ :name ] ]
        end

        let(:supreme_company) { Company.last }

        before do
          Developer.where(id: [2, 4]).each do |employee|
            employee.update!(company: supreme_company)
          end
        end

        it 'grabs all of the specified attributes' do
          expected = 5.times.map do |n|
            {
              "id" => n+1,
              "company" => {
                "id" => [2, 4].include?(n+1) ? supreme_company.id : n+1,
                "name" => [2, 4].include?(n+1) ? supreme_company.name : "Company#{n}",
              }
            }
          end

          expect(subject).to(eq(expected))
        end
      end
    end
  end

  # what happens when you call attributes that don't exist?
  # we should raise

  context 'with multiple belongs_to of the same class' do
    describe(Message, type: :model) do
      before do
        5.times do |n|
          company = Company.create!(name: "Company#{n}")

          Message.create!(id: n+1, content: "Content#{n}") do |message|
            sender = Developer.create!(title: "Title::Sender::#{n}", company: company)
            receiver = Developer.create!(title: "Title::Receiver::#{n}", company: company)
            message.update!(sender: sender, receiver: receiver)
          end
        end
      end

      let(:relation) { Message.all }

      subject { RelationToJSON::Base.new(relation, schema).as_json }

      let(:schema) do
        [ sender: [ :title ], receiver: [ :title ] ]
      end

      it 'grabs all of the specified attributes' do
        expected = 5.times.map do |n|
          {
            "id" => n+1,
            "sender" => {
              "title" => "Title::Sender::#{n}",
              "id" => (2*n)+1,
            },
            "receiver" => {
              "title" => "Title::Receiver::#{n}",
              "id" => (2*n)+2,
            }
          }
        end

        expect(subject).to(eq(expected))
      end
    end
  end
end
