cd ../source
ocra --windows --chdir-first --no-lzma --innosetup ../build/dotsthegame.iss --icon media/icons/dotsthegame.ico --output dotsthegame.exe main.rb
rem ocra --windows --chdir-first --no-lzma --innosetup dotsthegame.iss --icon dotsthegame.ico --output dotsthegame.exe main.rb media/fonts/*.* docs/test/*.* settings.json
rem ocra main.rb --icon dotsthegame.ico --output dotsthegame.exe --add-all-core --no-dep-run --gem-full --chdir-first --no-lzma --innosetup dotsthegame.iss -- server