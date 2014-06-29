guard :minitest do
  ignore(%r{.*sw[pon]$})

  watch(%r{^lib/builder_dsl.rb}) { 'test' }
  watch(%r{^lib/builder_dsl/(.+)\.rb}) { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^test/(?:.+/).+_test\.rb$})
  watch('test/test_helper.rb')  { 'test' }
end
