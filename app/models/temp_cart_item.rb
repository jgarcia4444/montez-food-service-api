class TempCartItem < ApplicationRecord
    belongs_to :temp_cart
    has_one :order_item
end
