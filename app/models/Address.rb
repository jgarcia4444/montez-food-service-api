class Address < ApplicationRecord
    belongs_to :user
    
    def format_for_frontend
        {
            street: self.street,
            city: self.city,
            state: self.state,
            zipCode: self.zip_code,
        }
    end

    def format_address
        "#{self.street}, #{self.city}, #{self.state}, #{self.zip_code}"
    end

end