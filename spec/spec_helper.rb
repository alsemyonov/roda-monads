# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'rspec'
require 'rspec/roda'
require 'roda/monads'
require 'rack/test'


RSpec.shared_context 'Monads', roda: :plugin, name: :monads do
  include Dry::Monads::Either::Mixin
end

RSpec.shared_context 'Monads shortcuts', monads: :methods do
  it { is_expected.to respond_to :Right }
  it { is_expected.to respond_to :Left }
end
