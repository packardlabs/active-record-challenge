begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  gem 'rails'
  gem 'arel'
  gem 'pg'
end

require 'active_record'
require 'minitest/autorun'
require 'logger'

#Needs to setup a database named 'ar_test' and add a user_name and password if setup for db
ActiveRecord::Base.establish_connection(adapter: 'postgresql',
                                        host: 'localhost',
                                        database: 'ar_test',
                                        encoding: 'unicode')
ActiveRecord::Base.logger = Logger.new(STDOUT)



# create schema
ActiveRecord::Schema.define do
  create_table :posts, force: true  do |t|
    t.boolean :viewed
    t.integer :author_id
  end

  create_table :authors, force: true  do |t|
    t.boolean :admin
    t.string :name
  end
end

#create models
class Post < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
  has_many :posts
end

class Seeds
  def self.populate
    5.times do |n|
      author = Author.create(name: "Joe#{n}")
      author.posts.create(viewed: true)
    end

    3.times do |n|
      author = Author.create(name: "")
      2.times { author.posts.create(viewed: false) }
    end

    7.times do |n|
      author = Author.create(name: "Jim#{n}", admin: true)
      author.posts.create(viewed: false)
    end
  end
end

########### Only commit changes below this line
class DbTest < Minitest::Test
  def test_association_stuff
    Seeds.populate

    #change these to be correct
    authors_with_viewed_posts = Author.all

    assert_equal 5, authors_with_viewed_posts.count
  end
end