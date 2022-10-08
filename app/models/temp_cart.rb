class TempCart < ApplicationRecord
    has_many :temp_cart_items
    belongs_to :user
end