module Mocktail
  class DemoConfig < Struct.new(
    :ignore_blocks,
    :ignore_extra_args,
    :ignore_arity,
    :times,
    keyword_init: true
  )
  end
end
