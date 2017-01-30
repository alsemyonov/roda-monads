# frozen_string_literal: true
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec do |t|
  t.rspec_path = 'bin/rspec'
end
