# RelationToJSON

`RelationToJSON` allows the conversion of `ActiveRecord::Relation` objects into an array of hash-like objects, provided a schema.
It allows nesting across different relations, and uses `pluck` to optimize queries over multiple tables.
This also acts as a useful interface in a React on Rails application where data needs to be passed to the front end in a simple serializable object, rather than passing a Rails object.

## Installation
Add this line to your application's Gemfile
```rb
gem 'relation_to_json'
```

and then execute:
```sh
bundle
```

## Usage
A schema is an array of attributes that you would like your resultant JSON object to have.
```rb
class User < ApplicationRecord
  has_one :keyboard
  validate :first_name, :last_name, presence: true
end

class Keyboard < ApplicationRecord
  belongs_to :user
  validate :make, :model, presence: true
end
```

You can write the following schema:
```rb
[
  :first_name,
  :last_name,
  keyboard: [
    :make,
    :model,
  ]
]
```

Thus with the following `ActiveRecord::Relation`, such as `User.all`, we can write out the following:
```rb
User.all.to_json_with_schema(schema)
```

Assuming that all of the relations exist, we can expect a response of the format:
```rb
[
  {
    id: 1,
    first_name: ...,
    last_name: ...,
    keyboard: {
      make: ...,
      model: ...,
    }
  },
  {
    id: 2,
    first_name: ...,
    last_name: ...,
    keyboard: {
      make: ...,
      model: ...,
    }
  }
]
```

## Contributing
Bug reports and pull requests are welcome on Github at https://github.com/DerekYu177/relation_to_json.

## License
This gem is available as open source under the terms of the MIT License.
