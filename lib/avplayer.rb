Dir.glob("#{File.expand_path('avplayer', __dir__)}/**/*.rb").sort.each(&method(:require))
