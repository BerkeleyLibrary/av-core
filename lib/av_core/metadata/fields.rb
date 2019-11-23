Dir.glob("#{File.expand_path('fields', __dir__)}/**/*.rb").sort.each(&method(:require))
