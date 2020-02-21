# frozen_string_literal: true
module RuboCop
  module Cop
    module Sorbet
      # Variant of DocumentationMethod that is aware if the sig preceding the method
      # has documentation
      # This cop checks for missing documentation comment for public methods.
      # It can optionally be configured to also require documentation for
      # non-public methods.
      #
      # @example
      #
      #   # bad
      #
      #   class Foo
      #     sig { void }
      #     def bar
      #       puts baz
      #     end
      #   end
      #
      #   module Foo
      #     sig { void }
      #     def bar
      #       puts baz
      #     end
      #   end
      #
      #   sig { void }
      #   def foo.bar
      #     puts baz
      #   end
      #
      #   # good
      #
      #   class Foo
      #     # Documentation
      #     sig { void }
      #     def bar
      #       puts baz
      #     end
      #   end
      #
      #   module Foo
      #     # Documentation
      #     sig { void }
      #     def bar
      #       puts baz
      #     end
      #   end
      #
      #   # Documentation
      #   sig { void }
      #   def foo.bar
      #     puts baz
      #   end
      #
      # @example RequireForNonPublicMethods: false (default)
      #   # good
      #   class Foo
      #     protected
      #     sig { ... }
      #     def do_something
      #     end
      #   end
      #
      #   class Foo
      #     private
      #     sig { ... }
      #     def do_something
      #     end
      #   end
      #
      # @example RequireForNonPublicMethods: true
      #   # bad
      #   class Foo
      #     protected
      #     sig { ... }
      #     def do_something
      #     end
      #   end
      #
      #   class Foo
      #     private
      #     sig { ... }
      #     def do_something
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     protected
      #     # Documentation
      #     sig { ... }
      #     def do_something
      #     end
      #   end
      #
      #   class Foo
      #     private
      #     # Documentation
      #     sig { ... }
      #     def do_something
      #     end
      #   end
      #
      class SigDocumentationMethod < Cop
        include DocumentationComment
        include DefNode

        MSG = 'Missing method documentation comment.'

        def_node_matcher :module_function_node?, <<~PATTERN
          (send nil? :module_function ...)
        PATTERN

        def_node_matcher :signature?, <<~PATTERN
          (block (send nil? :sig) (args) ...)
        PATTERN

        def on_def(node)
          parent = node.parent
          module_function_node?(parent) ? check(parent) : check(node)
        end
        alias on_defs on_def

        private

        def check(node)
          return if non_public?(node) && !require_for_non_public_methods?
          return if documentation_comment?(node)

          preceding = preceding_node(node)
          return if signature?(preceding) && documentation_comment?(preceding)

          add_offense(node)
        end

        def preceding_node(node)
          parent = node.parent
          return nil unless parent
          parent.children[node.sibling_index - 1]
        end

        def require_for_non_public_methods?
          cop_config['RequireForNonPublicMethods']
        end
      end
    end
  end

