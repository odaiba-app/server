# == Schema Information
#
# Table name: classrooms
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_classrooms_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Classroom, type: :model do
  let(:teacher) { create(:teacher) }
  subject do
    described_class.new(name: 'Test Classroom', user: teacher)
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a name' do
    subject.name = nil
    expect(subject).not_to be_valid
  end

  it 'is not valid without a user' do
    subject.user = nil
    expect(subject).not_to be_valid
  end

  it 'is not valid with a student' do
    subject.user = create(:student)
    expect(subject).not_to be_valid
  end
end
