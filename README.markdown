# rapper

Static asset packager and compressor with versioning and built-in view helpers. Easy to configure, easy to use, and easy to ignore when you want to. No crazy JavaScript comment DSLs, either.

Merb and Sinatra view helpers are coming soon, as well as pluggable compression backends (YUI Compressor, Google Closure Compiler, etc.) `rapper` currently only includes YUI Compressor.

## Packaging assets without wanting to claw your eyes out

1. Create a config file and one or more asset type definition files.
2. Load `rapper` with the config path and current environment:

        engine = Rapper::Engine.new( "config/assets.yml", "development" )

3. Then package the assets:

        engine.package

4. That's it. Stop fussing with ridiculous asset packagers that want you to spend an hour shuffling files around for them.

## Rapper configuration

Rapper is configured using a YAML file that defines the settings to be used in various server environments. Example:

    base: &base
      definition_root: config/assets
      tag_style: html   # optional, ["html", "xhtml", "html5"], default: html5
    
    development:
      <<: *base
      bundle: false     # optional, default: true
      compress: false   # optional, default: true
      version: false    # optional, default: true
      log: stdout       # optional, ["stdout", file path], default: off
      log_verbose: true # optional, default: off
    
    production:
      <<: *base
      bundle: true
      compress: true
      version: true
      # optional, passed to YUI Compressor
      yui_compressor:
        line_break: 2000           # default: 2000
        munge: false               # default: false
        optimize: true             # default: true
        preserve_semicolons: false # default: false

The only required setting is `definition_root`. (Of course, you'll still need definition files to define the asset packages that you want build. More on that below.)

## Rapper definitions

The `definition_root` setting in the rapper config is a path to a folder containing more YAML files that define the various types of bundles you want to build (eg. `stylesheets.yml`, `javascripts.yml`). For example, JavaScripts:

    --- !omap
    - root: public/javascripts
    - destination_root: public/assets # optional, default: root + "/assets"
    - component_tag_root: /javascripts
    - asset_tag_root: /javascripts/assets
    - suffix: js
    - assets: !omap
        - base: !omap
            - files: 
              - mootools
            - version: 7b06
        - stats: !omap
            - files: 
              - protovis
              - ext_js_full
            - version: db62

The above definition will create two asset files: `public/assets/base.js` and `public/assets/stats.js` from the component files in `public/javascripts` (in this case: `public/javascripts/protovis.js` and `public/javascripts/ext_js_full.js`).

**Note:** Definition files are YAML ordered mapping documents. This is so that version updates (which involves rapper updating the version numbers and writing out the updated definition as YAML) don't change the order of the file. This is especially useful when using git and merging branches because it prevents nasty merge conflicts.

## Combining bundles

Rapper allows you to combine bundles by referring to the other bundle with a "+"
prefix in the files list:

    - assets: !omap
        - base: !omap
            - files: 
              - mootools
            - version: 7b06
        - extras: !omap
            - files: 
              - mootools-more
              - protovis
            - version: 25c1
        - full: !omap
            - files: 
              - +base
              - +extras
            - version: db62

## View helpers

Rapper provides helper methods to generate HTML include tags for your assets in the `Rapper::ViewHelpers` module. Simply `include` it in the appropriate place for your web app / framework / widget / spaceship / row boat / whatever. It's automaticallly included for Merb because Merb people are notoriously lazy.

Rapper's view helpers respect your `bundle` setting. If it is `true`, a singe include tag for the joined asset will be returned. If bundling is `false`, it will return include tags for every component file of the asset (as a single string).

Rapper provides helper methods for each definition type. For instance, if you have "javascripts.yml" and "stylesheets.yml" definition files, Rapper will provide `include_javascripts` and `include_stylesheets` helper methods. Just pass the name of the asset to the helper method as a symbol and the correct HTML will be returned:

    include_stylesheets :mootools
    # <script src="/javascripts/assets/mootools.js"></script>

## Versioning

Version strings are short hashes of the before-compression asset file. This means that they will only change when the contents of the component files for an asset change and time-consuming compression will only happen when a bundle needs to be re-packaged.

Version strings are also used to enforce good browser caching habits, especially when you have a far-future expires header configured on your web server. For example, suppose you had the following asset:

    <script type="text/javascript" src="/assets/milkshake.js?v=d3va"></script>

When the contents of the asset change, the version will change in the query string:

    <script type="text/javascript" src="/assets/milkshake.js?v=ae51"></script>

Browsers will automatically re-download and cache the new asset.

# Rake tasks

Rapper includes Rake tasks for packaging assets. Set this up in your `Rakefile`:

    Rapper::Tasks.new do |config|
      config[:path] = "config/assets.yml"
      config[:env] = "production"
    end

Default namespace is `rapper`. The namespace can be changed as the first param:

    Rapper::Tasks.new :assets do ...

Both config options are required.

# Development

Rapper's got a Gemfile. You know what to do.

    bundle install --path vendor
    bundle exec rake spec

## Wishlist

* Watch for CoffeeScript changes and automatically compile
* Watch for Sass changes and automatically compile
* Per-asset configuration overrides
* Auto-setup Sinatra helpers (?)
* Auto-setup Rails helpers (?)

## Version history

* **0.5.0** - Added ability to nest bundles.
* **0.4.0** - Switching to YUI Compressor for JavaScript compression due to its better handling of local variable compressing in scopes with eval() usage (I'm looking at you, ExtJS). Adding `component_tag_root` and `asset_tag_root` options to allow better control over URLs.
* **0.3.0** - Remove hard Closure Compiler dependency (it will still need to be installed to compress JS), shorter view helper method names.
* **0.2.4** - Add tag_paths() to get all file paths for a given asset.
* **0.2.2** - Change tag_root behavior to not add `.../assets` path suffix when a `destination_root` is defined.
* **0.2.1** - Add tag_files() to get all file paths for a given asset.
* **0.2.0** - Custom asset destination roots, fix Rake task.
* **0.1.1** - Rake tasks.
* **0.1.0** - View helpers.
* **0.0.3** - New `Definition` object to make working with definitions significantly easier, don't re-package assets that don't need re-packaging.
* **0.0.2** - Compression now works and is specced.
* **0.0.1** - Initial release. Functioning bundler, minus the view helpers.

## Contributing to rapper
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Tyson Tate. See LICENSE.txt for further details.
