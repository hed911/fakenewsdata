SAMPLE_COUNT = 250
$education_levels = [
  { name:'None' },
  { name:'Colegio' },
  { name:'Tecnico' },
  { name:'Profesional' },
  { name:'Profesional especializacion/master' },
  { name:'Profesional doctorado' }
]
$classifications = [
  'Politica',
  'Farandula',
  'Cientifica', 
  'Economica'
]
cities = ['Barranquilla', 'Santa Marta', 'Cartagena']
$ages = [(14..23), (24..35), (36..45), (46..60)]

def toss_coin(yes_value, no_value, yes_percentage)
  coin = Faker::Number.between(from: 1, to: 100 - yes_percentage)
  coin > yes_percentage ? yes_value : no_value
end

def generate_line(city, age_range)
  age = Faker::Number.between(from: age_range.first, to: age_range.last)
  gender = ['F', 'M'][Faker::Number.between(from: 0, to: 1)]
  social_status = Faker::Number.between(from: 1, to: 6)

  education_level = $education_levels[1][:name] if age <= 15
  if education_level.nil?
    education_level = toss_coin(
      $education_levels[3][:name],
      $education_levels[2][:name],
      30
    )
  end
  if education_level == $education_levels[3][:name] && age > 26
    education_level = toss_coin(
      $education_levels[4][:name],
      $education_levels[3][:name],
      40
    )
  end 
  if education_level == $education_levels[4][:name] && age > 30
    education_level = toss_coin(
      $education_levels[5][:name],
      $education_levels[4][:name],
      40
    )
  end
  if age.between?(14, 21) || age.between?(46, 60)
    if !toss_coin(true, false, 82) 
      fake_news_count = Faker::Number.between(from: 4, to: 6)
    else
      fake_news_count = Faker::Number.between(from: 0, to: 1)
    end
  else
    if !toss_coin(true, false, 85) 
      fake_news_count = Faker::Number.between(from: 0, to: 1)
    else
      fake_news_count = Faker::Number.between(from:4, to: 6)
    end
  end
  $classifications.shuffle!
  if fake_news_count > 0
    classifications = $classifications.take(Faker::Number.between(from: 1, to: $classifications.count)).join(",")
  end
  [
    Faker::Name.name, # NAME
    city, # CITY
    Faker::IDNumber.valid, # ID NUMBER
    gender, # GENDER
    social_status, # SOCIAL STATUS LEVEL
    age,  # AGE
    education_level, # EDUCATION LEVEL
    classifications,
    fake_news_count # COUNTER OF FAKE NEWS SHARED LAST MONTH
  ].join(';')
end

headers = [
  'NAME',
  'CITY',
  'ID NUMBER',
  'GENDER',
  'SOCIAL STATUS',
  'AGE',
  'EDUCATION LEVEL',
  'NEWS TYPE',
  'FAKE NEWS SHARED THIS MONTH'
].join(";")

result = []
cities.each do |city|
  $ages.each do |age_range|
    SAMPLE_COUNT.times{ result << generate_line(city, age_range) }
  end
end
result.shuffle!
result.unshift headers
File.write('dataset.csv', result.join("\n"))
