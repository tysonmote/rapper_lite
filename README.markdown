# rapper_lite #

Bare-bones static asset packager and compressor. Currently supports CSS and JavaScript. Uses MD5 versioning to avoid re-compressing packages that don't need to be re-compressed. Uses a simple config file so that you don't have to wrangle wacky comment DSLs in your source code just to join and compress a few files.

## Packaging assets without wanting to claw your eyes out

1. Create a config file:

        --- !omap
        - root: public/javascripts/
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

2. Load `rapper` with the config path:

        engine = Rapper::Engine.new( "config/rapper.yml" )

3. Then package the assets:

        engine.package

# Development

Rapper's got a Gemfile. You know what to do.

    bundle package
    bundle exec rake spec

## Version history

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
