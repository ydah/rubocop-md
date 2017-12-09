require "test_helper"

using SquigglyHeredoc

class Rubocop::Markdown::PreprocessTest < Minitest::Test
  def described_module
    Rubocop::Markdown::Preprocess
  end

  def test_no_code_snippets
    source = <<-SOURCE.squiggly
      # Header

      Boby text
    SOURCE

    expected = <<-SOURCE.squiggly
      ## Header
      #
      #Boby text
    SOURCE

    assert_equal expected, described_module.call(source)
  end

  def test_with_one_snippet
    source = <<-SOURCE.squiggly
      # Header

      Code example:

      ```
      class Test < Minitest::Test
        def test_valid
          assert false
        end
      end
      ```
    SOURCE

    expected = <<-SOURCE.squiggly
      ## Header
      #
      #Code example:
      #
      #```
      class Test < Minitest::Test
        def test_valid
          assert false
        end
      end
      #```
    SOURCE

    assert_equal expected, described_module.call(source)
  end

  def test_only_snippet
    source = <<-SOURCE.squiggly
      ```
      class Test < Minitest::Test
        def test_valid
          assert false
        end
      end
      ```
    SOURCE

    expected = <<-SOURCE.squiggly
      #```
      class Test < Minitest::Test
        def test_valid
          assert false
        end
      end
      #```
    SOURCE

    assert_equal expected, described_module.call(source)
  end

  def test_many_snippets
    source = <<-SOURCE.squiggly
      # Header

      Code example:

      ```
      class Test < Minitest::Test
        def test_valid
          assert false
        end
      end
      ```

      More texts and lists:
      - One
      - Two

      ```ruby
      require "minitest/pride"
      require "minitest/autorun"

      ```
    SOURCE

    expected = <<-SOURCE.squiggly
      ## Header
      #
      #Code example:
      #
      #```
      class Test < Minitest::Test
        def test_valid
          assert false
        end
      end
      #```
      #
      #More texts and lists:
      #- One
      #- Two
      #
      #```ruby
      require "minitest/pride"
      require "minitest/autorun"

      #```
    SOURCE

    assert_equal expected, described_module.call(source)
  end

  def test_invalid_syntax
    source = <<-SOURCE.squiggly
      # Header

      Code example:

      ```
      class Test < Minitest::Test
        def test_valid
          ...
        end
      end
      ```
    SOURCE

    expected = <<-SOURCE.squiggly
      ## Header
      #
      #Code example:
      #
      #```
      #class Test < Minitest::Test
      #  def test_valid
      #    ...
      #  end
      #end
      #```
    SOURCE

    assert_equal expected, described_module.call(source)
  end

  def test_non_ruby_snippet
    source = <<-SOURCE.squiggly
      # Header

      Code example:

      ```
      -module(evlms).
      -export([martians/0, martians/1]).
      ```
    SOURCE

    expected = <<-SOURCE.squiggly
      ## Header
      #
      #Code example:
      #
      #```
      #-module(evlms).
      #-export([martians/0, martians/1]).
      #```
    SOURCE

    assert_equal expected, described_module.call(source)
  end
end
