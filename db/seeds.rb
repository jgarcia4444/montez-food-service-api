# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# require '/db/product_list.csv'
csv_text = File.read(Rails.root.join('db', 'product_list.csv'))
product_list_csv = CSV.parse(csv_text, :headers => true)
product_list_csv.each_with_index do |product, i|
    if i != product_list_csv.count - 1
        OrderItem.create(
            upc: product[0],
            item: product[1],
            description: product[2],
            dept: product[3],
            price: product[4],
            cost_per_unit: product[5],
            case_cost: product[6],
            five_case_cost: product[7],
        )
    end
end
puts OrderItem.all.count

