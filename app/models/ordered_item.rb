class OrderedItem < ApplicationRecord
    belongs_to :user_order
    has_one :order_item
end
