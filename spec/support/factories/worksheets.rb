FactoryBot.define do
  factory :worksheet do
    title              { 'Test' }
    canvas             { '' }
    template_image_url { 'https://res.cloudinary.com/naokimi/image/upload/v1563422680/p7ojmgdtwshkrhxmjzh1.jpg' }
    worksheet_template { create(:worksheet_template) }
    work_group         { create(:work_group) }
  end
end
