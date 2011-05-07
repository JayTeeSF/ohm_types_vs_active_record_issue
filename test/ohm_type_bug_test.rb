require File.expand_path("./helper", File.dirname(__FILE__))
require 'active_support'
require 'active_support/time_with_zone'
require 'active_support/core_ext/time/conversions'
include ActiveSupport
require File.expand_path("../lib/exact_ohm_type_converter", File.dirname(__FILE__))

class CacheClassWithOhmTypes < Ohm::Model
  include Ohm::Typecast
  attribute :created_at, Time
end

class CacheClassWithOhmTypesOverride < Ohm::Model
  include Ohm::Typecast
  attribute :created_at, Time
  extend ExactOhmTypeConverter
  
  convert :created_at => Time
end

test "should be able to convert an overriden Time-attribute to db-friendly format" do
  ohm = CacheClassWithOhmTypesOverride.create(:created_at => NOW)
  # puts "ohm.created_at.to_s(:db): #{ohm.created_at.to_s(:db)}"

 assert_nothing_raised do
   ohm.created_at.to_s(:db)
 end
end

test "should be able to convert the ActiveSupport Time-val to db-friendly format" do
  # puts "can I get NOW.to_s(:db): #{NOW.to_s(:db)}"
  assert NOW.is_a?(Time)

  assert_nothing_raised do
    NOW.to_s(:db)
  end
end

test "should return the same sort of Time object" do
  assert_nothing_raised do
    NOW.to_s(:db)
  end

  ohm = CacheClassWithOhmTypes.create(:created_at => NOW)
  # puts "ohm.created_at: #{ohm.created_at}"
  assert ohm.created_at.is_a?(Time)
  assert(ohm.created_at == NOW)
end

test "should be able to convert a Time-attribute to db-friendly format" do
  assert_nothing_raised do
    NOW.to_s(:db)
  end

  ohm = CacheClassWithOhmTypes.create(:created_at => NOW)
  # puts "this fails -- created_at isn't really a Time value: #{ohm.created_at}"
 assert_nothing_raised do
   ohm.created_at.to_s(:db)
 end
end