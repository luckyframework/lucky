### Changes in 0.20

- Added: support for Crystal 0.34.0
- Fixed: error on some generated pages from missing sourcemap [#1019](https://github.com/luckyframework/lucky/pull/1019)
- Updated: `options_for_select` to accept more types [#295](https://github.com/luckyframework/lucky/pull/295)
- Added: ability to pass boolean attrs in link helper methods [#1032](https://github.com/luckyframework/lucky/pull/1032)
- Removed: setting `needs` with `?`. Lucky now generates a method ending in `?` for you when the type is `Bool` [#1034](https://github.com/luckyframework/lucky/pull/1034)
- Added: `needs` on pages can now be accessed by a method and not just instance variable [#1034](https://github.com/luckyframework/lucky/pull/1034)
- Removed: `link` helper method with a `String` path. [#1035](https://github.com/luckyframework/lucky/pull/1035)
- Added: new `Lucky::CookieNotFoundError` class. [#1038](https://github.com/luckyframework/lucky/pull/1038)
- Added: `cookies.deleted?()` method for checking if a cookie has been deleted. [#1040](https://github.com/luckyframework/lucky/pull/1040)
- Added: new `Lucky::Paginator` component with built-in styles for different different CSS frameworks. [#1020](https://github.com/luckyframework/lucky/pull/1020)
- Fixed: `needs` accidentally overwriting methods of the same name. [#1046](https://github.com/luckyframework/lucky/pull/1046)
- Updated: `label_for` to be a little more flexible with `nil` text. [#1047](https://github.com/luckyframework/lucky/pull/1047)
- Updated: resource generator to be a little easier to read and digest. [#1050](https://github.com/luckyframework/lucky/pull/1050)
- Updated: development `ENV` now uses `ENV["DEV_PORT"]` instead of `ENV["PORT"]` to fix issues with process managers. [#1051](https://github.com/luckyframework/lucky/pull/1051)
- Added: new `Lucky::CatchUnpermittedAttribute` mixin for `Shared::Field` component. [#1052](https://github.com/luckyframework/lucky/pull/1052)
- Added: new methods in Actions for accessing params from different sources like `from_json`, `from_query`, `from_form`, and `from_multipart`. [#1053](https://github.com/luckyframework/lucky/pull/1053)
- Updated: generated pages to have some default text pointing to the location of the file to edit. [#1057](https://github.com/luckyframework/lucky/pull/1057)
- Fixed: incorrect pluralization of resources on `NewPage`. [#1058](https://github.com/luckyframework/lucky/pull/1058)
- Updated: all action "callbacks" are officially named "pipes". All pipes only log when halted by default. [#1062](https://github.com/luckyframework/lucky/pull/1062)
- Updated: the `lucky dev` watcher does not print which file changes because you know you just changed that file. [#1065](https://github.com/luckyframework/lucky/pull/1065)
- Added: a new HTTP handler to set the `request.remote_address` if the `X-Forwarded-For` header is set. [#1059](https://github.com/luckyframework/lucky/pull/1059)
- Added: a `current_page?` helper method for pages. [#1074](https://github.com/luckyframework/lucky/pull/1074)
- Added: `FormFields` component for generated resources. [#1081](https://github.com/luckyframework/lucky/pull/1081)
- Updated: all HTML tag methods explicitly return `Nil` now. [#1083](https://github.com/luckyframework/lucky/pull/1083)
- Updated: page markup to render directly to the IO instead of creating an additional string. [#1084](https://github.com/luckyframework/lucky/pull/1084)
- Added: `String#squish` method. [#1085](https://github.com/luckyframework/lucky/pull/1085)
- Updated: error message from returning invalid type in Actions. [#1086](https://github.com/luckyframework/lucky/pull/1086)
- Added: ability to set custom directory when generating a new Lucky project [See LuckyCli](https://github.com/luckyframework/lucky_cli/pull/464)
- Added: ability to set your postgres DB port with ENV var. [See LuckyCli](https://github.com/luckyframework/lucky_cli/pull/469)
- Added: a `robots.txt` file to generated web apps by default. [See LuckyCli](https://github.com/luckyframework/lucky_cli/pull/472)
- Added: new compiling spinner graphic for a cleaner UX. [See LuckyCli](https://github.com/luckyframework/lucky_cli/pull/481)
- Updated: some comments on the generated main app file. [See LuckyCli](https://github.com/luckyframework/lucky_cli/pull/484)
- Added: lots of internal documentation. (many small commits to LuckyCli)
- Updated: generated `UserSerializer` to inherit from `BaseSerializer`. [See LuckyCli](https://github.com/luckyframework/lucky_cli/pull/489)
- Updated: cookies to default to `http_only`. [See LuckyCli](https://github.com/luckyframework/lucky_cli/pull/491)
- Updated: node dependencies in generated web apps. [See LuckyCli](https://github.com/luckyframework/lucky_cli/pull/493)
- Added: new `system_check` script along with some refactors to make checking that your app is setup a lot easier. [See LuckyCli](https://github.com/luckyframework/lucky_cli/pull/482)
- Removed: ability to pass a raw hash to an `Avram::SaveOperation`. [See Avram](https://github.com/luckyframework/avram/pull/312)
- Added: ability to `skip_schema_enforcer` for certain models. [See Avram](https://github.com/luckyframework/avram/pull/314)
- Added: `Avram::Model#reload` to reload all of the attributes that may have been updated since the instance was created. [See Avram](https://github.com/luckyframework/avram/pull/324)
- Added: `Query#reset_where` to reset the WHERE clause on a specific column. [See Avram](https://github.com/luckyframework/avram/pull/325)
- Added: logging queries that fail. [See Avram](https://github.com/luckyframework/avram/pull/326)
- Fixed: using `fill_existing_with` when you already had data in your table. [See Avram](https://github.com/luckyframework/avram/pull/328)
- Added: bulk updating records straight from a query object. [See Avram](https://github.com/luckyframework/avram/pull/329)
- Added: new "soft delete" feature. [See Avram](https://github.com/luckyframework/avram/pull/323)
- Fixed: saving empty array columns when the column can't be `nil`, but it can be `[]`. [See Avram](https://github.com/luckyframework/avram/pull/330)
- Updated: `SaveOperation.new` to set attributes directly. [See Avram](https://github.com/luckyframework/avram/pull/332)
- Removed: the `on` option for `needs` in `SaveOperation`. [See Avram](https://github.com/luckyframework/avram/pull/332)
- Fixed: connecting to databases running on a unix domain socket. [See Avram](https://github.com/luckyframework/avram/pull/333)
- Added: new shard for turning an Avram column in to a URL slug. [AvramSlugify](https://github.com/luckyframework/avram_slugify)

### v0.19.0 (2020-02-29)

- Added: missing docs for time helpers [#943](https://github.com/luckyframework/lucky/pull/943)
- Added: HTML boolean attributes to checkbox and textarea helpers [#955](https://github.com/luckyframework/lucky/pull/955)
- Fixed: generated templates with proper naming conventions [#956](https://github.com/luckyframework/lucky/pull/956)
- Added: `to_param` for `UUID` allowing UUID to be passed in params [#945](https://github.com/luckyframework/lucky/pull/945)
- Updated: watcher error message to be a little less abrupt [#968](https://github.com/luckyframework/lucky/pull/968)
- Updated: generated migrations using the `table_for` macro [#970](https://github.com/luckyframework/lucky/pull/970)
- Fixed: using `with_defaults` when the tag has content [#972](https://github.com/luckyframework/lucky/pull/972)
- Added: `any?` and `empty?` to `flash` [#977](https://github.com/luckyframework/lucky/pull/977)
- Fixed: allowing `false` values for `needs` [#979](https://github.com/luckyframework/lucky/pull/979)
- Updated: `needs` to now infer a value of `nil` when the type is nilable [#980](https://github.com/luckyframework/lucky/pull/980)
- Fixed: allowing the `-h` flag for the watch task [#958](https://github.com/luckyframework/lucky/pull/958)
- Added: gzip response for assets when it's configured [#983](https://github.com/luckyframework/lucky/pull/983)
- Added: Lucky API docs are now generated from the CI which is deployed to Github pages [#989](https://github.com/luckyframework/lucky/pull/989)
- Fixed: when using `needs` with different values in random order and Lucky would not compile [#993](https://github.com/luckyframework/lucky/pull/993)
- Added: more context to the resource generator [See commit](https://github.com/luckyframework/lucky/commit/ae7301750c9b49c99d5b530ddc93cda91e73f288)
- Added: ability to pass Crystal's `--error-tace` flag to `lucky watch` [#957](https://github.com/luckyframework/lucky/pull/957)
- Fixed: generating resource.browser when using a `JSON::Any` column type [#997](https://github.com/luckyframework/lucky/pull/997)
- Fixed: issue when using HTML boolean attributes with custom tags [#1010](https://github.com/luckyframework/lucky/pull/1010)
- Added: the option to define columns in the model generator [#1009](https://github.com/luckyframework/lucky/pull/1009)
- Updated: permitting columns generated from the resource generator [#1014](https://github.com/luckyframework/lucky/pull/1014)
- Added: new `to_prepared_sql` method to generate fully prepared sql for debugging [See Avram](https://github.com/luckyframework/avram/pull/264)
- Fixed: cloning distinct queries [See Avram](https://github.com/luckyframework/avram/pull/285)
- Added: new predicate methods variants for boolean columns [See Avram](https://github.com/luckyframework/avram/pull/300)
- Added: new `changed?`, `changes`, and `original_value` methods for attributes in Operations [See Avram](https://github.com/luckyframework/avram/pull/295)
- Updated: `validate_size_of` and `validate_inclusion_of` to allow `nil` values [See Avram](https://github.com/luckyframework/avram/pull/299)
- Updated: error messages on some callbacks [See Avram](https://github.com/luckyframework/avram/pull/282)
- Fixed: `select_sum` when the column is any number type [See Avram](https://github.com/luckyframework/avram/pull/304)
- Fixed: issues with `has_one` when your model is namespaced, and how it's queried [See Avram](https://github.com/luckyframework/avram/pull/263)
- Fixed: aggregate query methods to work on all number types [See Avram](https://github.com/luckyframework/avram/pull/307)
- Fixed: bug when using a Box that had no columns [See Avram](https://github.com/luckyframework/avram/pull/310)
- Updated: preloads to only call when there are parent records. This is a query optimization update. [See Avram](https://github.com/luckyframework/avram/pull/306)


### v0.18.3 (2020-02-17)

- Added: support for Crystal 0.33.0

### v0.18.2 (2019-12-13)

- Added: support for Crystal 0.32.0

### v0.18.1 (2019-10-18)

- Fixed: debug page in development with reset context
- Updated: lucky exec works more like a REPL
- Updated: Log time measured with monotonic
- Fixed: Record deletion when primary key is UUID
- Fixed: Setting empty array as default to array column
- Added: Overflow cast catch from Int64 to Int32
- Fixed: UUID primary key issue in SaveOperation
- Fixed: required attribute validations on custom before_save callbacks
- Added: New `reset_limit` query method
- Added: New `reset_offset` query method

### v0.18.0 (2019-10-03)

- Added: support for Crystal 0.31.1
- Fixed: how accept / content-type headers are handled [#869](https://github.com/luckyframework/lucky/pull/869)
- Added: `ParamParsingError` for when parsing JSON params fails [#874](https://github.com/luckyframework/lucky/pull/874)
- Updated: `Lucky::BaseHTTPClient` [#875](https://github.com/luckyframework/lucky/pull/875)
- Updated: shell scripts for POSIX compliance [#879](https://github.com/luckyframework/lucky/pull/879)
- Added: `date_input`, `time_input`, `datetime_input` [#877](https://github.com/luckyframework/lucky/pull/877)
- Added: support for HTTP `PATCH` [#885](https://github.com/luckyframework/lucky/pull/885)
- Added: `abbr` HTML tag [#886](https://github.com/luckyframework/lucky/pull/886)
- Fixed: missing primary_key and timestamps in generated migrations [#888](https://github.com/luckyframework/lucky/pull/888)
- Fixed: `pluralize` to take any Int [#890](https://github.com/luckyframework/lucky/pull/890)
- Fixed: generation of migrations with resource [see Commit](https://github.com/luckyframework/lucky/commit/31848d916bdba9d2e6333e508ae2e95d9788263a)
- Rename: `Lucky::HttpRespondable` to `Lucky::RenderableError` [see Commit](https://github.com/luckyframework/lucky/commit/026f2e3bf9c1085376537c27bc2a28bfde590eb1)
- Fixed: `accepts_format`, and a few other mime type issues [#896](https://github.com/luckyframework/lucky/pull/896)
- Fixed: default curl requests to server not responding properly [#899](https://github.com/luckyframework/lucky/pull/899)
- Rename: `handle_error` to `render` in `ErrorAction` [#903](https://github.com/luckyframework/lucky/pull/903)
- Rename: `render` to `html` in Actions [#905](https://github.com/luckyframework/lucky/pull/905)
- Update: error message when missing type declaration for `needs` [#907](https://github.com/luckyframework/lucky/pull/907)
- Fixed: model generation allowing for non alphanumeric characters [#910](https://github.com/luckyframework/lucky/pull/910)
- Updated: make more errors renderable [#911](https://github.com/luckyframework/lucky/pull/911)
- Fixed: help messages now display for precompiled tasks [#923](https://github.com/luckyframework/lucky/pull/923)
- Updated: default help messages for tasks [#923](https://github.com/luckyframework/lucky/pull/923)
- Fixed: issue with precompile tasks running in some directories [#924](https://github.com/luckyframework/lucky/pull/924)
- Added: SQL logging [see Avram](https://github.com/luckyframework/avram/pull/213)
- Updated: error message when postgres isn't running [see Avram](https://github.com/luckyframework/avram/pull/218)
- Updated: `Box.create_pair` allows for setting attributes, and returns instances [see Avram](https://github.com/luckyframework/avram/pull/215)
- Added: ability to `clone` a query [see Avram](https://github.com/luckyframework/avram/pull/214)
- Fixed: `add_belongs_to` in alter statement using wrong Int size [see Avram](https://github.com/luckyframework/avram/pull/224)
- Fixed: incorrect error message from `SaveOperation` updates in 0.17 [see Avram](https://github.com/luckyframework/avram/pull/225)
- Added: `between` query method [see Avram](https://github.com/luckyframework/avram/pull/227)
- Added: ordering queries by `NULLS FIRST` and `NULLS LAST` [see Avram](https://github.com/luckyframework/avram/pull/228)
- Fixed: missing attributes from SaveOperation [see Avram](https://github.com/luckyframework/avram/pull/232)
- Added: `db.schema.restore` and `db.schema.dump` tasks [see Avram](https://github.com/luckyframework/avram/pull/216)
- Added: `group` query method for doing GROUP BY [see Avram](https://github.com/luckyframework/avram/pull/234)
- Updated: SchemaEnforcer [see Avram](https://github.com/luckyframework/avram/pull/237)
- Fixed: issue when calling `before` in SaveOperation [see Avram](https://github.com/luckyframework/avram/pull/240)
- Added: JWT auth generation for API apps [see LuckyCli](https://github.com/luckyframework/lucky_cli/pull/395)
- Updated: Serializers to be smarter with collections [see LuckyCli](https://github.com/luckyframework/lucky_cli/pull/397)
- Updated: webpack to ignore `node_modules` directory [see LuckyCli](https://github.com/luckyframework/lucky_cli/pull/401)
- Removed: cli `lucky init` task args [see LuckyCli](https://github.com/luckyframework/lucky_cli/pull/420)
- Added: new `lucky init.custom` task to take args as `init` did before.
- Fixed: `lucky init` to catch invalid project names properly.
- Added: support for `browser_binary` in LuckyFlow [see LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/59)


### v0.17 (2019-08-13)

- Rename: `Avram::BaseForm` to `Avram::SaveOperation` [see Avram](https://github.com/luckyframework/avram/pull/104)
- Rename: `Avram::Field` to `Avram::Attribute` [see Avram](https://github.com/luckyframework/avram/commit/d3503a161670077c1d7b14484382132ea3ab423d)
- Update: `number_to_currency` now returns `String` instead of writing to the view directly. [#809](https://github.com/luckyframework/lucky/pull/809)
- Fixed: bug in running `build.release` task.
- Update: mounted components render comments to show start and end of component. [#817](https://github.com/luckyframework/lucky/pull/817)
- Revert: returning `String` for `highlight` helper. [#818](https://github.com/luckyframework/lucky/pull/818)
- Update: text helpers that write to the view moved to their own module. [#820](https://github.com/luckyframework/lucky/pull/820)
- Rename: `fillable` to `permit_columns`. [see Avram](https://github.com/luckyframework/avram/commit/b32b5a9b53688762e22c063ebad9f858cba636c0)
- Added: `skip_if` option to `LogHandler`. [#824](https://github.com/luckyframework/lucky/pull/824)
- Rename: `Lucky::Exposeable` to `Lucky::Exposable`. [#827](https://github.com/luckyframework/lucky/pull/827)
- Rename: `Lucky::Routeable` to `Lucky::Routable`. [#827](https://github.com/luckyframework/lucky/pull/827)
- Added: `memoize` macro. [#832](https://github.com/luckyframework/lucky/pull/832)
- Added: `table_for` macro. [see Avram](https://github.com/luckyframework/avram/pull/127)
- Added: `xml` render method for Actions. [#838](https://github.com/luckyframework/lucky/pull/838)
- Rename: `text` render action to `plain_text`. [#838](https://github.com/luckyframework/lucky/pull/838)
- Update: `responsive_meta_tag` to be flexible. [#835](https://github.com/luckyframework/lucky/pull/835)
- Added: `Int16#to_param` and `Int64#to_param`.
- Fixed: `append/replace_class` with no default. [#842](https://github.com/luckyframework/lucky/pull/842)
- Added: multi database support. [see Avram](https://github.com/luckyframework/avram/pull/136)
- Rename: `form_name` to `param_key`. [see Avram](https://github.com/luckyframework/avram/pull/140)
- Fixed: 3rd party shards versions. [#855](https://github.com/luckyframework/lucky/pull/855)
- Added: JSON support. [see Avram](https://github.com/luckyframework/avram/pull/108)
- Update: calling `first` ensures proper order by. [see Avram](https://github.com/luckyframework/avram/pull/118)
- Update: specifying primary keys is more explicit now. [see Avram](https://github.com/luckyframework/avram/commit/c6fe426a455fc1bf397d0b3b32069a97cd89d2df)
- Added: custom primary key name support. [see Avram](https://github.com/luckyframework/avram/commit/a97c2b7dba359dda775bc587458a3d00571979e9)
- Added: column and primary key support for `Int16`. [see Avram](https://github.com/luckyframework/avram/pull/131)
- Rename: `Query.destroy_all` to `Query.truncate`. [see Avram](https://github.com/luckyframework/avram/pull/134)
- Fixed: model inference with table names. [see Avram](https://github.com/luckyframework/avram/pull/144)
- Rename: `virtual` to `attribute`. [see Avram](https://github.com/luckyframework/avram/pull/112)
- Rename: `VirtualForm` to `Operation`. [see Avram](https://github.com/luckyframework/avram/commit/daaf55955c8131dea8533584720257ca444f23a7)
- Added: support for `Array` fields. [see Avram](https://github.com/luckyframework/avram/pull/151)
- Rename: association query methods now prefixed with `where_`. [see Avram](https://github.com/luckyframework/avram/commit/f298b8a2be2b0d9b753f33517093c72c261cd148)
- Added: query method to bulk delete. [see Avram](https://github.com/luckyframework/avram/pull/169)
- Update: association query methods no longer take a block. [see Avram](https://github.com/luckyframework/avram/commit/a8112f3b0abca05c06da0c3ba3f599dc6b06110b)
- Added: support for polymorphic associations. [see Avram](https://github.com/luckyframework/avram/pull/165)
- Added: `db.rollback_to` task. [see Avram](https://github.com/luckyframework/avram/pull/133)
- Added: `db.migrations.status` task. [see Avram](https://github.com/luckyframework/avram/pull/135)
- Added: `db.verify_connection` task. [see Avram](https://github.com/luckyframework/avram/pull/167)
- Fixed: calling `lucky -v` from a lucky project failed. [see CLI](https://github.com/luckyframework/lucky_cli/pull/387)
- Update: name convention for operations to be `VerbNoun`. [see CLI](https://github.com/luckyframework/lucky_cli/pull/386)
- Added: `change_type` macro for migrations. [see Avram](https://github.com/luckyframework/avram/pull/209)

### v0.16 (2019-08-03)

- Added: support for Crystal 0.30.0

### v0.15 (2019-06-12)

- Removed `Lucky::Action::Status`. Use Crystal's `HTTP::Status` enum. [#769](https://github.com/luckyframework/lucky/pull/769)
- CookieOverflowError is now checked when the cookie is set instead of later in middleware. [#761](https://github.com/luckyframework/lucky/pull/761)
- Crystal 0.29.0 support added
- Rename `Lucky::BaseApp` to `Lucky::BaseAppServer`
- Rename `Sentry` to `LuckySentry`
- **Breaking change** - Many text helpers now return a `String` instead of appending to the view (`cycle`, `excerpt`, `highlight`, `pluralize`, `time_ago_in_words`, `to_sentence`, `word_wrap`) [#781](https://github.com/luckyframework/lucky/pull/781)
- Added new asset host option [#795](https://github.com/luckyframework/lucky/pull/795)
- Added new secure header modules [#735](https://github.com/luckyframework/lucky/pull/735)
- Added fallback routing [#731](https://github.com/luckyframework/lucky/pull/731)
- Updated SSL Handler with HSTS option [#734](https://github.com/luckyframework/lucky/pull/734)
- Components are now classes instead of modules [#714](https://github.com/luckyframework/lucky/pull/714)
- Fixed `BaseHTTPClient` params [#726](https://github.com/luckyframework/lucky/pull/726)
- Fixed passing `Symbol` for statuses in redirects [#730](https://github.com/luckyframework/lucky/pull/730)
- More helpful errors [#733](https://github.com/luckyframework/lucky/pull/733), [#732](https://github.com/luckyframework/lucky/pull/732)


### v.0.14 (2019-04-18)

- Crystal 0.28.0 support added


### v0.13 (2019-02-27)

- Use [`Dexter`](https://github.com/luckyframework/dexter) as the logger. https://github.com/luckyframework/lucky_cli/pull/300 and https://github.com/luckyframework/lucky_cli/pull/299

- Move scripts from `bin` to `script`. Ignore all of `bin` directory in `.gitignore`. See https://github.com/luckyframework/lucky_cli/pull/288 and https://github.com/luckyframework/lucky_cli/pull/301

- `App` in `src/app.cr` should now inherit from `Lucky::BaseApp`. See https://github.com/luckyframework/lucky_cli/pull/287/files for an example.

- Prefix id params with the resource name [#659](https://github.com/luckyframework/lucky/issues/659)

- Added Action#url_without_query_params [#662](https://github.com/luckyframework/lucky/pull/662)

- Added `Lucky::AssetHelpers.load_manifest` so that API apps don't need a blank manifest to compile.

- Pages ignore unused exposures [#666](https://github.com/luckyframework/lucky/issues/666)

- `unexpose` and `unexpose_if_exposed` have been removed because they are no
longer necessary now that pages ignore unused exposures.

- `is` in queries has been renamed to `eq`. For example: `UserQuery.new.name.not.is("Emily")` should now be `UserQuery.new.name.not.eq("Emily")`. If passing in something that could be `Nil`, one must use `nilable_eq` instead. [avram#46](https://github.com/luckyframework/avram/pull/46)
