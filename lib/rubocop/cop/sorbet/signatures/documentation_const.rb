# frozen_string_literal: true
module RuboCop
  module Cop
    module Sorbet
      # This cop checks for documentation on `const` property helpers.
      # @example
      #
      #   # bad
      #
      #   class Foo < T::Struct
      #     const :baz
      #   end
      #
      #   # good
      #
      #   class Foo < T::Struct
      #     # Neat little baz
      #     const :baz
      #   end
      class ConstDocumentation < Cop
        include DocumentationComment
        include DefNode

        MSG = 'Missing documentation comment for `const` attribute.'

        def_node_matcher :const_send?, <<~PATTERN
          (send nil? :const ...)
        PATTERN

        def on_send(node)
          return unless const_send?(node)
          return if documentation_comment?(node)
          add_offense(node)
        end
      end
    end
  end

