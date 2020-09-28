# == Schema Information
#
# Table name: work_groups
#
#  id              :bigint           not null, primary key
#  aasm_state      :string
#  answered        :integer
#  name            :string
#  score           :integer
#  session_time    :integer
#  start_at        :datetime
#  turn_time       :integer
#  video_call_code :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  classroom_id    :bigint           not null
#
# Indexes
#
#  index_work_groups_on_classroom_id  (classroom_id)
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#
require 'rails_helper'

RSpec.describe WorkGroup, type: :model do
  it 'has a valid factory' do
    expect(build(:work_group)).to be_valid
  end

  let(:classroom) { create(:classroom) }
  subject do
    described_class.new(
      aasm_state: 'next_up',
      # answered: 0,
      name: 'Test Group',
      # score: 0,
      session_time: 1_000_000,
      start_at: DateTime.current + 1.hour,
      turn_time: 1000,
      video_call_code: 'abc',
      classroom: classroom
    )
  end

  context 'valid' do
    it 'with valid attributes' do
      expect(subject).to be_valid
    end
  end

  context 'not valid' do
    it 'without a state' do
      subject.aasm_state = nil
      expect(subject).not_to be_valid
    end

    it 'without a video call code' do
      subject.video_call_code = nil
      expect(subject).not_to be_valid
    end

    it 'without a classroom' do
      subject.classroom = nil
      expect(subject).not_to be_valid
    end

    it 'without a session time' do
      subject.session_time = nil
      expect(subject).not_to be_valid
    end

    it 'without a turn time' do
      subject.turn_time = nil
      expect(subject).not_to be_valid
    end

    it 'without a start time' do
      subject.start_at = nil
      expect(subject).not_to be_valid
    end

    it 'with a start time in the past' do
      subject.start_at = DateTime.current - 1.hour
      expect(subject).not_to be_valid
    end

    it 'with a turn time bigger than session time' do
      subject.turn_time = 2_000_000
      expect(subject).not_to be_valid
    end

    # TODO: it can be only one student's turn
  end
end
