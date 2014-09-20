# encoding: utf-8
require 'helper'

class TestSanitizer < Minitest::Unit::TestCase

  def test_special_cases
    items = [nil, '', '      ']
    Scrapouille::Sanitizer.clean!(items)
    assert_equal [nil, '', ''], items
  end

  def test_squeeze_and_strip_whitespaces
    items = ['1  2    3 4  ', '   a b c d ']
    Scrapouille::Sanitizer.clean!(items)
    assert_equal ['1 2 3 4', 'a b c d'], items
  end

  def test_replace_html_non_breaking_spaces_by_whitespaces
    with_html_nbsp = 'B. Firat F'
    refute with_html_nbsp.ascii_only?
    items = [with_html_nbsp]
    Scrapouille::Sanitizer.clean!(items)
    assert_equal ['B. Firat F'], items, 'Should have removed &nbsp; (\u00A0) char'
    assert items.first.ascii_only?
  end

end
