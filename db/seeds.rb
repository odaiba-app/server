require 'database_cleaner/active_record'
p 'emptying database'

StudentWorkGroup.destroy_all
StudentClassroom.destroy_all
Worksheet.destroy_all
WorksheetTemplate.destroy_all
WorkGroup.destroy_all
Classroom.destroy_all
User.destroy_all

DatabaseCleaner.allow_production = true
DatabaseCleaner.allow_remote_database_url = true
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

p 'creating teachers'

User.create!(name: Faker::Name.name, email: 'teacher@gmail.com', password: 'supersecret', role: 1)
User.first.update(authentication_token: ENV['TEACHER_CODE'])
User.create!(name: Faker::Name.name, email: 'sub-teacher@gmail.com', password: 'supersecret', role: 1)
User.create!(name: 'Ms. Tachibana', email: 'tachibanar@gmail.com', password: 'supersecret', role: 1)
User.create!(name: 'Mr. Murakami', email: 'murakami@gmail.com', password: 'supersecret', role: 1)
User.create!(name: 'Ms. Hayashi', email: 'hayashi@gmail.com', password: 'supersecret', role: 1)
User.create!(name: 'Ms. Dedachi', email: 'dedachi@gmail.com', password: 'supersecret', role: 1)
User.create!(name: 'Mr. Murata', email: 'murata@gmail.com', password: 'supersecret', role: 1)

p "Finished creating #{User.where(role: 1).size} Teachers"

p 'creating students'

User.create!(name: 'Paulo', email: 'paulo@gmail.com', password: 'secret')
User.create!(name: 'Dzakki', email: 'dzakki@gmail.com', password: 'secret')
User.create!(name: 'Ann', email: 'ann@gmail.com', password: 'secret')
User.create!(name: 'Myra', email: 'myra@gmail.com', password: 'secret')

40.times do
  name = Faker::Name.name
  User.create!(name: name, email: name.split.join('').downcase + '@gmail.com', password: 'secret')
end

p "Finished creating #{User.where(role: 0).size} students"

p 'creating classroom'

subjects = ['English', 'Maths', 'Science', 'Geography', 'History']
groups = ['A', 'B', 'C']

subjects.each do |subject|
  groups.each_with_index do |group, idx|
    user_id = idx.zero? ? User.first.id : User.where(role: 1)[(rand(User.where(role: 1).length))].id
    Classroom.create!(
      user_id: user_id,
      subject: subject,
      grade: 5,
      group: group,
      start_time: Time.now + 7200,
      end_time: Time.now + 10800
    )
  end
end

p "Finished creating #{Classroom.count} classrooms"

p 'assigning students to classrooms'

students = User.where(role: 0)

students.each_with_index do |student, idx|
  subjects.each do |subject|
    count = Classroom.where(subject: subject).count
    classroom = (0..3).include?(idx) ? Classroom.first : Classroom.where(subject: subject)[rand(count)]
    StudentClassroom.create!(
      user: student,
      classroom: classroom
    ) unless StudentClassroom.find_by(user: student, classroom: classroom)
  end
end

p 'Finished assigning students to classrooms'

p 'creating work groups'

Classroom.all.each do |classroom|
  # dynamically generate a number of groups based on the number of students in the class
  (1..(classroom.students.count / 4)).to_a.each do |number|
    WorkGroup.create!(
      name: "Group #{number}",
      video_call_code: "#{classroom.subject}#{classroom.grade}#{classroom.group}#{number}", # each video_call_code is unique
      classroom: classroom,
      session_time: 1_200_000, # time in miliseconds, 60000 == 1 minute
      turn_time: 300_000, # time in miliseconds, 60000 == 1 minute
      score: 0,
      answered: 0,
      start_at: DateTime.new(2030, 1, 1, 10, 30)
    )
  end
end

p "Finished creating #{WorkGroup.count} work groups"

p 'assigning students to workgroups'

Classroom.all.each do |classroom|
  work_groups = classroom.work_groups
  current_group_index = 0
  current_student_index = 0
  students = classroom.students
  until current_student_index >= students.size # will place each student in exactly 1 group
    StudentWorkGroup.create!(
      student: students[current_student_index],
      work_group: work_groups[current_group_index],
      joined: true,
      turn: work_groups[current_group_index].student_work_groups.size.zero? # sets the first student assigned to the group to turn = true
    )
    # increases the group index by 1 until it reaches the end of the max of the group, then starts over
    current_group_index == work_groups.size - 1 ? current_group_index = 0 : current_group_index += 1
    current_student_index += 1
  end
end

p 'Finished assigning students to work groups'

p 'creatin worksheet templates'

WorksheetTemplate.create!(
  title: 'Base Template',
  user: User.first,
  image_url: 'https://res.cloudinary.com/naokimi/image/upload/v1599052572/2ae04a8f96087c49dc2c06164f3efbc6_gaajwm.jpg'
)
User.where(role: 'teacher').each_with_index do |user, idx|
  WorksheetTemplate.create!(
    title: "Template #{idx}",
    user: user,
    image_url: 'https://res.cloudinary.com/naokimi/image/upload/v1599471022/zzsrgajrf5tshbhpxjtc.jpg'
  )
end

p "Finished creating #{WorksheetTemplate.count} worksheets"

p 'assigning worksheets to work groups'

work_groups = WorkGroup.all
Classroom.all.each_with_index do |classroom, index|
  template = WorksheetTemplate.where(user_id: classroom.teacher.id).first
  classroom.work_groups.each do |work_group|
    Worksheet.create!(
      title: "Worksheet #{index}",
      canvas: '',
      worksheet_template: template,
      work_group: work_group,
      template_image_url: template.image_url
    )
  end
end

p 'Finished assigning worksheets to work groups'

p 'finished'
