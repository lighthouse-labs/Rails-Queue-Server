# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :code_review_request, parent: :assistance_request, class: CodeReviewRequest do
  end
end
