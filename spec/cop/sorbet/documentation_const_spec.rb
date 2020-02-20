# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../lib/rubocop/cop/sorbet/documentation_const'

RSpec.describe(RuboCop::Cop::Sorbet::DocumentationConst, :config) do
  subject(:cop) { described_class.new(config) }

  it('adds offense when consts are not documented') do
    expect_offense(<<~RUBY)
      const :foo, String
      ^^^^^^^^^^^^^^^^^^ Missing documentation comment for `const` attribute.
    RUBY
  end

  it('does not add offense when consts are documented') do
    expect_no_offenses(<<~RUBY)
      # Documentation for this nice const
      const :foo, String
    RUBY
  end
end
