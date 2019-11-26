Dir.glob("#{File.expand_path('util', __dir__)}/**/*.rb").sort.each(&method(:require))
