# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../lib/rubocop/cop/sorbet/sig_documentation_method'

RSpec.describe(RuboCop::Cop::Sorbet::SigDocumentationMethod, :config) do
  subject(:cop) { described_class.new(config) }

  before(:each) do
    # this is cleared before the spec, and is required by a dependency of the documentation helper
    config.for_cop('Style/CommentAnnotation') = {'Keywords': []}
  end

  it('adds offense when public methods are not documented') do
    expect_offense(<<~RUBY)
      class F < T::Struct
        sig{void}
        def foo; end
      end
    RUBY
  end

  it('does not add offense when public methods are documented') do
    expect_no_offenses(<<~RUBY)
      class F < T::Struct
        # documented so well
        sig{void}
        def foo; end
      end
    RUBY
  end

  it('does not add offense when private methods are not documented') do
    expect_no_offenses(<<~RUBY)
      class F < T::Struct
        private
        sig{void}
        def foo; end
      end
    RUBY
  end


  describe('with private method documentation required') do
    let(:cop_config) do
      {
        'Enabled' => true,
        'RequireForNonPublicMethods' => true,
      }
    end

    it('adds offense when private methods are not documented') do
      expect_offense(<<~RUBY)
        class F < T::Struct
          private
          sig{void}
          def foo; end
        end
      RUBY
    end
  end
end
