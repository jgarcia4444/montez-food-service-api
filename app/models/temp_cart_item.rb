class TempCartItem < ApplicationRecord
    belongs_to :temp_cart_
    has_one :order_item
end
