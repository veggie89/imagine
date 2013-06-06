# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#onion quote fetch
def fetch_by_authors(authors)
	authors.each do |name|
		p Onion::Quote.new(:author => name).fetch
	end
end

def fetch_by_tags(tags)
	tags.each do |tag|
		p Onion::Quote.new(:tag => tag).fetch
	end
end

if Quote.count == 0
	p Onion::Quote.new.fetch
end

authors = Quote.authors
author_count = authors.length
p "start fetch quotes by #{author_count} authors"
fetch_by_authors(authors)

tags = Quote.tags
tag_count = tags.length
p "start fetch quotes by #{tag_count} tags"
fetch_by_tags(tags)

total_count = Quote.count 
total_authors = Quote.authors.length
total_tags = Quote.tags.length
p "Total: #{total_count} Authors: #{total_authors} Tags: #{total_tags}"