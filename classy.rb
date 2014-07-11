def reup
  load __FILE__
end

class Direct < Class
  attr_accessor :foo
end

class Other < Class.new
  attr_accessor :doo
end
