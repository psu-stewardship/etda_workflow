# frozen_string_literal: true

FactoryBot.define do
  factory :committee_role do
    sequence(:name) { |i| "Committee Role ##{i}" }
    is_active { true }
    num_required { 1 }
    degree_type
    is_program_head { false }
  end
end
