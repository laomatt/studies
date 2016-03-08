# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'faker'
# 50.times do
#   user = User.create(email:Faker::Internet.email, password:"password",name:Faker::Name.name, avatar_url:Faker::Avatar.image)
# end

# 150.times do
#   user = User.all.sample
#   slideshow = Slideshow.create(title: Faker::Lorem.sentence, user_id:user.id)
#   num_of_pics = 5 + rand(40)
#   num_of_pics.times do
#     slide = Slide.create(title: Faker::Lorem.word, ext_url: Faker::Avatar.image, slideshow_id: slideshow.id)
#   end
# end


# Slide.all.each do |slide|
#   url = UrlBank.find(slide.id).url
#   tag = UrlBank.find(slide.id).tags
#   slide.update_attributes(:ext_url => url, :tags => tag)
# end
