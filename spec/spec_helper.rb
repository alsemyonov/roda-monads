# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'rspec'
require 'rspec/its'
require 'roda/monads'
require 'rack/test'

RSpec.shared_context 'Roda plugin', roda: :plugin do
  include Rack::Test::Methods

  def self.included(child)
    super(child)
    roda
  end

  # @param [Symbol] plugin
  # @param [Proc] block
  def self.roda(plugin = metadata[:name], &block)
    let(:roda_class) do
      route_block = self.route_block
      Class.new(Roda) do
        plugin plugin
        instance_exec(&block) if block
        route do |r|
          instance_exec(r, &route_block)
        end if route_block
      end
    end
  end

  def self.route(&block)
    let(:route_block) { block }
    roda # re-initiate app
  end

  def app
    roda_class.app.freeze
  end

  let(:roda_instance) { roda_class.new(env) }
  let(:route_block) { proc { |r| } }
  let(:env) { {} }
end

RSpec.shared_context 'Monads', roda: :plugin, name: :monads do
  include Dry::Monads::Either::Mixin
end

RSpec.shared_context 'Monads shortcuts', monads: :methods do
  it { is_expected.to respond_to :Right }
  it { is_expected.to respond_to :Left }
end
