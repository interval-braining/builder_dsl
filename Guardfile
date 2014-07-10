guard :minitest do
  ignore(%r{.*sw[pon]$})

  watch(%r{^lib/building_blocks.rb}) { 'test' }
  watch(%r{^lib/building_blocks/(.+)\.rb}) { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^test/(?:.+/).+_test\.rb$})
  watch('test/test_helper.rb')  { 'test' }
end
