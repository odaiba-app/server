# == Schema Information
#
# Table name: student_work_groups
#
#  id            :bigint           not null, primary key
#  joined        :boolean
#  turn          :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#  work_group_id :bigint           not null
#
# Indexes
#
#  index_student_work_groups_on_user_id        (user_id)
#  index_student_work_groups_on_work_group_id  (work_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (work_group_id => work_groups.id)
#
class StudentWorkGroup < ApplicationRecord
  belongs_to :student
  belongs_to :work_group
end