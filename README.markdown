# RapperLite #

RapperLite is a bare-bones static asset packager and compressor. It currently supports CSS, JavaScript, and CoffeeScript. It uses MD5 versioning to avoid re-compressing packages that don't need to be re-compressed. RapperLite can be set up with a single config file so that you don't have to wrangle wacky comment DSLs in your source code just to join and compress a few files.

## Configuring ##

Create a YAML file (say, "rapper.yml") that defines your static asset packages like so:

    --- !omap
    - root: public/src/
    - destination: public/assets/
    - compress: true
    - css: !omap
      - base: !omap
        - files:
          - reset
          - layout
          - typography
          - colores
        - version: 683e
    - js: !omap
      - mootools: !omap
        - files:
          - mootools-core
          - mootools-more
        - version: f3d9
      - base_combined: !omap
        - files:
          - preloader
          - +mootools
          - widgets
        - version: ccfc

(Why the excessive use of `omap`? I'm doing this to ensure that the line order is maintained when I write updated version strings to the file. Why maintain order? Two words: merge conflicts.)

The above configuration will create the following compressed asset packages when RapperLite is run:

    * `public/assets/base.css`
    * `public/assets/mootools.js`
    * `public/assets/base_combined.js`

Component files can be nested in subfolders:

    ...
    - base: !omap
      - files:
        - mootools-core
        - extras/mootools-more
        - extras/crazybox
      - version: f3d9
    ...

The "css" and "js" nodes of the config can override the "root" and "destination" config variables:

    --- !omap
    - destination: public/assets/
    - compress: true
    - css: !omap
      - root: public/stylesheets/
      - base: !omap
        ...
    - js: !omap
      - root: public/javascripts/
      - base: !omap
        ...

## Packaging assets ##

You can run RapperLite from the command line:

    $ rapper_lite path/to/config.yml
    or:
    $ rapper_lite --watch path/to/config.yml

If no config file is passed in, RapperLite will search for the config file at:

        ./rapper.yml
        ./assets.yml
        ./config/rapper.yml
        ./config/assets.yml

You can also run RapperLite from Ruby:

    require "rapper_lite"
    RapperLite::Engine.new( "config/rapper.yml" ).package

Or use the included Rake tasks by adding this to your `Rakefile`:

    Rapper::Tasks.new do |config|
      config[:path] = "config/assets.yml"
    end

You can specify a custom namespace, if you want:

    Rapper::Tasks.new( :assets ) do |config| ...

## CoffeeScript ##

RapperLite transparently supports CoffeeScript. You don't have to do anything. Refer to the file in your config like you would any regular ol' JavaScript file.

# Development

Rapper's got a Gemfile. You know what to do.

    bundle package
    bundle exec rake spec

## Version history

* **0.1.2** - Update Gemfile, add "rapper-lite" command.
* **0.1.1** - Turns out you can only release `master`, which `jeweler` doesn't tell you. Oops.
* **0.1.0** - Add CoffeeScript support. Re-write `rapper_lite` command to allow watching for changes. Add watch support to Rake task.
* **0.0.2** - Fix gem homepage link.
* **0.0.1** - Initial release.

## Contributing to rapper_lite
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Tyson Tate. See LICENSE.txt for further details.
