Dir.glob("#{File.expand_path('metadata', __dir__)}/**/*.rb").sort.each(&method(:require))
