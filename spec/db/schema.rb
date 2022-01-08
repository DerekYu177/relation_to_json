ActiveRecord::Schema.define(version: 2022_01_01_000001) do
  create_table :users do |t|
    t.string :userable_type
    t.integer :userable_id

    t.string :first_name
    t.string :last_name
  end

  create_table :companies do |t|
    t.string :name
  end

  create_table :developers do |t|
    t.belongs_to :company, null: false
    t.string :title
  end

  create_table :customers do |t|
    t.string :phone_number
  end

  create_table :messages do |t|
    t.references :sender
    t.references :receiver

    t.string :content
  end
end
