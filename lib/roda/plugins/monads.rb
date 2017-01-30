# frozen_string_literal: true

require 'roda'
require 'dry-monads'

class Roda
  # Module containing `Roda` plugins.
  module RodaPlugins
    # Makes `Roda` understand `Dry::Monads::Either` monad and provide results
    # based on `Right` or `Left` monad handler.
    #
    # @see Monads::RequestMethods
    # @see Monads::InstanceMethods
    #
    # @example
    #   plugin :monads
    #   route do |r|
    #     r.on '/right' do
    #       Right('Alright!')
    #     end
    #     r.on '/left' do
    #       Left('Wrong!')
    #     end
    #     r.on '/rack' do
    #       r.on '/right' do
    #         Right([:ok, {}, ['Alright!']])
    #       end
    #       r.on '/left' do
    #         Left('Wrong!')
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

      # Extends `app` with `Dry::Monads::Either::Mixin` to create monads easily
      # @param [Roda] app
      def self.configure(app, *)
        app.extend Dry::Monads::Either::Mixin
        app.include Dry::Monads::Either::Mixin
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
      # `Dry::Monads::Either` or compatible object (that responds to
      # `#to_either` method, returning `Dry::Monads::Either`).
      module RequestMethods
        # Handle match block return values.  By default, if a string is given
        # and the response is empty, use the string as the response body.
        def block_result(result)
          return super(result) unless result.respond_to?(:to_either)
          respond_with_either(result)
        end

        private

        # @param [Dry::Monads::Either, #to_either] either
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

        # @param [Dry::Monads::Either::Right] either
        def match_right(either)
          return false unless either.right?
          populate_body(either.value)
          true
        end

        # @param [Dry::Monads::Either::Left] either
        def match_left(either)
          return false unless either.left?
          response.status, body = either.value
          populate_body(body)
          true
        end

        def match_rack_either(either)
          response.status, headers, body = either.value
          headers.each { |header, value| response.headers[header] = value }
          populate_body(body)
          true
        end

        # @param [Dry::Monads::Either] either
        def rack_either?(either)
          either.value.is_a?(Array) && either.value.size == 3
        end

        # @param [String, Object] body
        def populate_body(body)
          response.write block_result_body(body) if response.empty?
        end

        # @param [Dry::Monads::Either, #to_either] either
        # @return [void]
        def respond_with_either(either)
          instance_exec either, &roda_class.either_matcher(:either)
        end
      end
    end

    register_plugin :monads, Monads
  end
end
