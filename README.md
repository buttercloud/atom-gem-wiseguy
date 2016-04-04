# gem-wiseguy package

Get quick info about your Gemfile gems without leaving your editor.

# Installing
`apm install inline-messenger gem-wiseguy`

If you're using rbenv, you need to make sure your PATH is set correctly for Atom.  You can do this inside of the `~/.atom/init.coffee` file.
 
Add a line like this for rbenv:
```coffee 
process.env.PATH = "#{process.env.HOME}/.rbenv/shims:#{process.env.HOME}/.rbenv/bin:#{process.env.PATH}" 
```
There is probably a similar process to get RVM to work.

# Usage

* Open your Gemfile.

To get info on all gems:

* Toggle gem-wiseguy using the command:

`Gem Wiseguy: Toggle All`
or keyboard shortcut
`CTRL-ALT-g`
 
To get info on specific gems only (faster):

* Place cursor on one or more gems then run the command:

`Gem Wiseguy: Toggle At Cursor`
or keyboard shortcut
`CTRL-ALT-i`

To turn off:

* Simple run the command:
`Gem Wiseguy: Toggle All`

Will take a second to load the gem info form rubygems.org

# Current features:
- Scans your Gemfile and creates a tooltip for each gem with:
  - Quick Links to Documentation, Source Code and Issue Tracker
  - Current installed version (based on Gemfile.lock)
  - Latest version of the gem on rubygems.org
  - Description of the gem
  - Development and Runtime dependencies

# Screenshot
![Screenshot](https://raw.githubusercontent.com/buttercloud/atom-gem-wiseguy/master/gem-wiseguy-screenshot-1.png
)

# Author & Contributors

This package was developed by [Buttercloud](http://www.buttercloud.com).

Maintained by: Ahmad Hammad [@afhammad](https://github.com/afhammad)
