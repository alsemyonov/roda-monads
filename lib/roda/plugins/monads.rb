# frozen_string_literal: true

require 'roda'
require 'dry-monads'

class Roda
  # Module containing `Roda` plugins.
  module RodaPlugins
    # Makes `Roda` understand `Dry::Monads::Result` monad and provide results
    # based on `Success` or `Failure` monad handler.
    #
    # @see Monads::RequestMethods
    # @see Monads::InstanceMethods
    #
    # @example
    #   plugin :monads
    #   route do |r|
    #     r.on '/right' do
    #       Success('Alright!')
    #     end
    #     r.on '/left' do
    #       Failure('Wrong!')
    #     end
    #     r.on '/rack' do
    #       r.on '/right' do
    #         Success([:ok, {}, ['Alright!']])
    #       end
    #       r.on '/left' do
    #         Failure('Wrong!')
    #       end
    #     end
    #   end
    module Monads
      # Loads `Dry::Monads` gem
      # @param [Roda] app
      # @raise [LoadError] if gem `dry-monads` cannot be loaded
      def self.load_dependencies(app, *)
        app.plugin :symbol_status
      end

      # Extends `app` with `Dry::Monads::Result::Mixin` to create monads easily
      # @param [Roda] app
      def self.configure(app, *)
        app.extend Dry::Monads::Result::Mixin
        app.include Dry::Monads::Result::Mixin
        app.either_matcher(:right,
                           aliases: [:value]) { |either| match_right(either) }
        app.either_matcher(:left,
                           aliases: [:status]) { |status| match_left(status) }
        app.either_matcher(:either) { |either| match_either(either) }
        app.either_matcher(:rack_either) { |value| match_rack_either(value) }
      end

      # Extends `Roda` class interface with {ClassMethods#either_matcher} method
      module ClassMethods
        # @param name [Symbol] name
        # @param aliases [<Symbol>] aliases
        # @param matcher [Proc] matcher
        # @return [Proc]
        def either_matcher(name = :either, aliases: [], &matcher)
          @matchers ||= {}
          @matchers[name] = matcher if block_given?
          aliases.each { |alt| @matchers[alt] = @matchers[name] }
          @matchers[name]
        end
      end

      # Extends {Roda::RodaRequest#block_result}’s with an ability to respond to
      # `Dry::Monads::Result` or compatible object (that responds to
      # `#to_either` method, returning `Dry::Monads::Result`).
      module RequestMethods
        # Handle match block return values.  By default, if a string is given
        # and the response is empty, use the string as the response body.
        def block_result(result)
          return super(result) unless result.respond_to?(:to_either)
          respond_with_either(result)
        end

        private

        # @param [Dry::Monads::Result, #to_either] either
        def match_either(either)
          either = either.to_either if respond_to?(:to_either)
          matcher = if rack_either?(either)
                      :rack_either
                    elsif either.right?
                      :right
                    else
                      :left
                    end
          instance_exec(either, &roda_class.either_matcher(matcher))
        end

        # @param [Dry::Monads::Result::Success] either
        def match_right(either)
          return false unless either.right?
          populate_body(either.success)
          true
        end

        # @param [Dry::Monads::Result::Failure] either
        def match_left(either)
          return false unless either.left?
          response.status, body = either.failure
          populate_body(body)
          true
        end

        def match_rack_either(either)
          response.status, headers, body = either.value_or(&:itself)
          headers.each { |header, value| response.headers[header] = value }
          populate_body(body)
          true
        end

        # @param [Dry::Monads::Result] either
        def rack_either?(either)
          value = either.value_or(&:itself)
          value.is_a?(Array) && value.size == 3
        end

        # @param [String, Object] body
        def populate_body(body)
          response.write block_result_body(body) if response.empty?
        end

        # @param [Dry::Monads::Result, #to_either] either
        # @return [void]
        def respond_with_either(either)
          instance_exec either, &roda_class.either_matcher(:either)
        end
      end
    end

    register_plugin :monads, Monads
  end
end
