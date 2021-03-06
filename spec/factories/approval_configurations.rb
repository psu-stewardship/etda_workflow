# frozen_string_literal: true

FactoryBot.define do
  factory :approval_configuration do |_ac|
    approval_deadline_on { Date.yesterday }
    use_percentage { 0 }
    configuration_threshold { 1 }
    head_of_program_is_approving { 1 }
    email_authors { 1 }
    email_admins { 1 }
    degree_type
  end
end
