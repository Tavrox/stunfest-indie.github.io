#!/bin/ruby

# Public: Generate markdown files for each games registered on Intrazik.

require 'date'

# Private: generate a markdown file from an entry
def generate(raw)

  fields = raw.split('";"')

  studio = fields[0]
  name = fields[2]
  description = fields[3]
  platforms = fields[4]
  website = fields[6]
  video = fields[7]
  screen1 = fields[8]
  screen2 = fields[9]
  screen3 = fields[10]
  boxart = fields[11]
  release = fields[12]

  # Cleans
  safename = String.new(name)
  safename.gsub!(/^.*(\\|\/)/, '')

  # Special cases
  safename.gsub!('û', 'u')
  safename.gsub!('é', 'e')
  safename.gsub!('è', 'e')
  safename.gsub!('ê', 'e')
  safename.gsub!('à', 'a')

  safename.gsub!(/[^0-9A-Za-z.\-]/, '_')

  safename.gsub!(/__+/, "_")

  if safename[safename.length - 1] == "_" then
    safename[safename.length - 1] = ''
  end

  safename = safename.downcase

  release.gsub!(/^.*(:)/, '')

  content = ""

  content += "---\n"
  content += "title:     #{name}\n"
  content += "website:   #{website}\n"
  content += "studio:    #{studio}\n"
  content += "platforms: #{platforms}\n"
  content += "screen1:   #{screen1}\n"
  content += "screen2:   #{screen2}\n"
  content += "screen3:   #{screen3}\n"
  content += "boxart:    #{boxart}\n"
  content += "video:     #{video}\n"
  content += "release:   #{release}\n"
  content += "---\n"
  content += "\n"
  content += "#{description}"

  return safename, content

end

# Check parameters
if ARGV.length < 1 then
  puts "Usage: ruby inrazik2md.rb <export.csv>"
  exit -1
end

# Create output folder
if Dir.exists?('generated') == false then
  Dir.mkdir 'generated'
end

# Read all entries and store as string
csv = File.open(ARGV[0], "r")
data = csv.read
csv.close

# Clean
data=data.gsub(/\r/, '')

# Fucking piece of shitty csv!!!!!!!!!!!
# Newlines inside rows so I had to find a hack to detect entry. FUCK
columns = data.split(/;"";"";"""/)

count = 1
games = {}

columns.each do |c|

  if count > 1 then
    name, content = generate(c)

    games[name] = content

    puts "#{name}"
  end
  count += 1
end

puts "#{count-1} games found."

# Sort by name
games = Hash[games.sort]

# Write files
date = Date.new(2015,12,31)

games.each do |n, c|

  puts n

  f = File.new("generated/#{date.strftime '%Y-%m-%d'}-"+n+".md", "w")
  f.write c
  f.close

  date -= 3
end

