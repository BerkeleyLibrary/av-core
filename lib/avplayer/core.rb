Dir.glob("#{File.expand_path('core', __dir__)}/**/*.rb").sort.each(&method(:require))
