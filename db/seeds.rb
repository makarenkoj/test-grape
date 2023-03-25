# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

user_token = UserToken.create
user_token.update_attribute(:token, 'TvR9o2RbGFyCW9hxbkTJmsj5')

puts 'Creating users ...'
password = '12345678Qq!'

if Rails.env.development?
  puts 'Creating customer'

  3.times do |i|
    User.create!(username: FFaker::Name.first_name,
                 email: FFaker::Internet.unique.email,
                 password: password,
                 role: User::CUSTOMER)
  end

  puts 'Creating admin'

  2.times do |i|
    User.create!(username: FFaker::Name.first_name,
                 email: FFaker::Internet.unique.email,
                 password: password,
                 role: User::ADMIN)
  end

  ["tv,", "pool,", "conditioner,", "washing machine,", "elevator,", "garage,", "parking"].each do |option|
    Option.create!(name: option)
  end
end
