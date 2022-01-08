class User < ActiveRecord::Base
  delegated_type :userable, types: %w[developer customer]
end

class Developer < ActiveRecord::Base
  has_one :user, foreign_key: :userable_id, inverse_of: :user, as: :userable
  belongs_to :company
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'
end

class Customer < ActiveRecord::Base
  has_one :user, foreign_key: :userable_id, inverse_of: :user, as: :userable
end

class Company < ActiveRecord::Base
  has_many :developers
end

class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'Developer', inverse_of: :sent_messages
  belongs_to :receiver, class_name: 'Developer', inverse_of: :received_messages
end
