module Dentaku
  module CustomFunctions
    FUNCTIONS = [
      [
        :length,
        :numeric,
        ->(str) { str.length }
      ],
      [
        :blank,
        :logical,
        ->(str) { str.blank? }
      ],
      [
        :contains,
        :logical,
        ->(mainStr, subStr) { mainStr.include?(subStr) }
      ],
      [
        :startswith,
        :logical,
        ->(mainStr, subStr) { mainStr.starts_with?(subStr) }
      ],
      [
        :endswith,
        :logical,
        ->(mainStr, subStr) { mainStr.ends_with?(subStr) }
      ],
      [
        :matches,
        :logical,
        ->(str, regexStr) { !Regexp.new(regexStr).match(str).nil? }
      ]
    ]
  end
end
