class UserOrder < ApplicationRecord
    has_many :ordered_items
    belongs_to :user
end
