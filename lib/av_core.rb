Dir.glob("#{File.expand_path('av_core', __dir__)}/**/*.rb").sort.each(&method(:require))
