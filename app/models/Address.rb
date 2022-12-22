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

end