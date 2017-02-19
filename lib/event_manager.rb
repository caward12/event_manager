require "csv"
require 'sunlight/congress'
require 'erb'
require 'pry'
Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

  @hours = []
  @weekdays= []

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_number)
  if phone_number.nil?
    "0000000000"
  end
  phone_number.gsub!(/[^0-9A-Za-z]/, '')
  if phone_number.length == 11 && phone_number.start_with?("1")
    phone_number[1..10]
  elsif phone_number.length == 10
    phone_number
  else
    phone_number = "0000000000"
  end
end

def find_hours_registered(register_date)
  DateTime.strptime(register_date, '%m/%d/%Y %H:%M').hour
end

def find_popular_hours(hours)
  popular_hours = hours.inject(Hash.new(0)) do |count, hour|
    count[hour] +=1
    count
  end
  popular_hours.sort_by {|k, v| v}.reverse.to_h
end

def find_weekdays(register_date)
  #binding.pry
  DateTime.strptime(register_date, '%m/%d/%Y %H:%M').wday
end

def find_popular_weekday(weekdays)
  popular_weekday = weekdays.inject(Hash.new(0)) do |count, day|
    count[day] +=1
    count
  end
  popular_weekday.sort_by {|k, v| v}.reverse.to_h

end

def weekdays_to_word(weekday)
  if weekday == 0
    "sunday"
  elsif  weekday == 1
    "monday "
  elsif weekday == 2
    "tuesday"
  elsif weekday == 3
    "wednesday"
  elsif weekday == 4
    "thursday"
  elsif weekday == 5
    "friday"
  else
    "saturday"
  end
end


def legislators_by_zipcode(zipcode)
   Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  register_hour = find_hours_registered(row[:regdate])
  register_weekday = find_weekdays(row[:regdate])
  @hours << register_hour
  @weekdays << register_weekday

  # name = row[:first_name]
  #
  # phone_number = clean_phone_number(row[:homephone])
  #
  # puts phone_number
  #
  # zipcode = clean_zipcode(row[:zipcode])
  #
  # legislators = legislators_by_zipcode(zipcode)
  #
  # form_letter = erb_template.result(binding)
  #
  # save_thank_you_letters(id,form_letter)

end
puts "The most popular time is #{find_popular_hours(@hours).keys[0]}:00"
puts "the most poular day is #{weekdays_to_word(find_popular_weekday(@weekdays).keys[0])}"
