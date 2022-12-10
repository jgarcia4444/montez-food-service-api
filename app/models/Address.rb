class Address < ApplicationRecord
    belongs_to :user
    
    def format_for_frontend
        {
            number: self.number,
            streetName: self.street_name,
            city: self.city,
            state: self.state,
            zipCode: self.zip_code,
        }
    end

end