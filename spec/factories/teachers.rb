# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :teacher, parent: :user, class: Teacher do
    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name }
    email        { Faker::Internet.safe_email }
  end
end
