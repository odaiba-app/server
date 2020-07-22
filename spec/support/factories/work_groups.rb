FactoryBot.define do
  factory :work_group do
    name            { 'Test Group' }
    video_call_code { 'abc' }
    session_time    { 1_200_000 }
    turn_time       { 3000 }
    score           { 0 }
    answered        { 0 }
    aasm_state      { 'in_progress' }
    start_at        { DateTime.now + 1.hour }
    association :classroom
  end
end