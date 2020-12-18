### Changes in 0.25

- Rename: component `with_defaults` renamed to `tag_defaults` [#1262](https://github.com/luckyframework/lucky/pull/1262)
- Fixed: send HSTS headers over HTTPS. [#1268](https://github.com/luckyframework/lucky/pull/1268)
- Updated: `memoize` can be used on any `Object` [#1270](https://github.com/luckyframework/lucky/pull/1270)
- Added: `tfoot()` tag method. [#1296](https://github.com/luckyframework/lucky/pull/1296)
- Added: routes now support glob routing [#1294](https://github.com/luckyframework/lucky/pull/1294)
- Fixed: passing a `UUID` in to a tag for text [#1280](https://github.com/luckyframework/lucky/pull/1280)
- Fixed: calling route helper methods on actions with `route_prefix` set. [#1298](https://github.com/luckyframework/lucky/pull/1298)
- Added: clearing cookies with specific options passed in [#966](https://github.com/luckyframework/lucky/pull/966)
- Fixed: passing a `name` prop to a custom tag. [#1309](https://github.com/luckyframework/lucky/pull/1309)
- Added: `blockquote()` and `cite()` tag methods. [#1317](https://github.com/luckyframework/lucky/pull/1317)
- Added: type name in error message for action classes [#1321](https://github.com/luckyframework/lucky/pull/1321)
- Fixed: params that use `Bool` with a default value of `false` [#1352](https://github.com/luckyframework/lucky/pull/1352)
- Updated: generated `start_server` binary is now output to the `bin` directory instead of top-level. [#1358](https://github.com/luckyframework/lucky/pull/1358)
- Fixed: HTTP status description in the log output. [#1362](https://github.com/luckyframework/lucky/pull/1362)
- Updated: reverted the `DATABASE_URL` ENV. [#551 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/551)
- Updated: emails will print to the log in development for easier debugging. [#555 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/555)
- Updated: Tasks can use the `output` property for easier testing. Added an `example` option to task args. [#557 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/557)
- Added: New generated Lucky projects will come with Github Actions out of the box. [#559 In Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/559)
- Updated: front-end `package.json` dependencies. [#553](https://github.com/luckyframework/lucky_cli/pull/553)
- Fixed: Signal trap is properly caught when running `lucky dev`. [#572 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/572)
- Updated: the built-in seed tasks to better match the common structure. [#584 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/584)
- Added: new `Lucky::Env.task?` method will return true if `ENV["LUCKY_TASK"] = "true"` is set. [#576 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/576)
- Updated: Query objects no longer mutate which fixes calling aggregate methods without needing to `clone`. [#411 in Avram](https://github.com/luckyframework/avram/pull/411)
- Updated: the error message when a required primary key is missing. [#454 in Avram](https://github.com/luckyframework/avram/pull/454)
- Updated: `fill_existing_with` to be used with nilable columns. [#452 in Avram](https://github.com/luckyframework/avram/pull/452)
- Fixed: `Bool` columns with a default `false` value. [#461 in Avram](https://github.com/luckyframework/avram/pull/461)
- Fixed: `belongs_to` using the wrong key in some cases. [#465 in Avram](https://github.com/luckyframework/avram/pull/465)
- Fixed: using optional Arrays in columns and migrations. [#471 in Avram](https://github.com/luckyframework/avram/pull/471)
- Fixed: calling `to_s` or `to_i` on an enum column to get the enum's proper value. [#474 in Avram](https://github.com/luckyframework/avram/pull/474)
- Updated: using `raw_where` will now be deprecated in favor of a unified `where`. [#460 in Avram](https://github.com/luckyframework/avram/pull/460)
- Fixed: issues with invalid SQL with joins. [#451 in Avram](https://github.com/luckyframework/avram/pull/451)
- Added: a whole new interface for `Avram::Operation`. [#469 in Avram](https://github.com/luckyframework/avram/pull/469)
- Updated: `Avram::SaveOperation` callback methods `after_save` and `after_commit` work with blocks, and more. [#481 in Avram](https://github.com/luckyframework/avram/pull/481)
- Added: a compile-time error catch when passing a raw hash in to a `SaveOperation`. [#485 in Avram](https://github.com/luckyframework/avram/pull/485)
- Removed: `register_setup_step` macro used for hooking in to the Avram model setup. [#486 in Avram](https://github.com/luckyframework/avram/pull/486)
- Added: new `or()` query method to perform `WHERE x OR y` SQL calls. [#442 in Avram](https://github.com/luckyframework/avram/pull/442)
- Updated: database calls to be optimized for speed. [#491 in Avram](https://github.com/luckyframework/avram/pull/491)
- Added: `params.has_key_for?` to check if params contains a key for an operation. [#500 in Avram](https://github.com/luckyframework/avram/pull/500)
- Added: conditional callbacks for `Avram::SaveOperation`. [#495 in Avram](https://github.com/luckyframework/avram/pull/495)
- Updated: the `has_many` count method to not preload when just a number is being returned. [#509 in Avram](https://github.com/luckyframework/avram/pull/509)
- Fixed: passing a `file_attribute` as a named arg to an operation. [#514 in Avram](https://github.com/luckyframework/avram/pull/514)
- Removed: unique filtering on `WHERE` clauses. [#518](https://github.com/luckyframework/avram/pull/518)
- Updated: error message when using `remove` incorrectly in migrations. [#524 in Avram](https://github.com/luckyframework/avram/pull/524)
- Added: error message when trying to generate a migration by a name that already exists. [#528 in Avram](https://github.com/luckyframework/avram/pull/528)
- Added: new custom errors for Operation objects. [#534 in Avram](https://github.com/luckyframework/avram/pull/534)
- Updated: `add_belongs_to` can now set a unique index. [#536 in Avram](https://github.com/luckyframework/avram/pull/536)
- Fixed: creating records by passing in values that match the default. [#540 in Avram](https://github.com/luckyframework/avram/pull/540)
- Updated: how `has_many through` associations are defined to fix has_many through a has_many through association. [#525 in Avram](https://github.com/luckyframework/avram/pull/525)
- Added: new `after_completed` callback on `Avram::SaveOperation` which is called even if no updates are made. [#544 in Avram](https://github.com/luckyframework/avram/pull/544)
- Added: `UUID` primary key checks to the SchemaEnforcer. [#546 in Avram](https://github.com/luckyframework/avram/pull/546)
- Added: records already loaded in to memory can now preload associations. [#542 in Avram](https://github.com/luckyframework/avram/pull/542), [#553 in Avram](https://github.com/luckyframework/avram/pull/553), [#561 in Avram](https://github.com/luckyframework/avram/pull/561)
- Added: support for models to use `VIEW`. [#555 in Avram](https://github.com/luckyframework/avram/pull/555)
- Added: new `defaults` method for defining default query methods on Query objects. [#564 in Avram](https://github.com/luckyframework/avram/pull/564)
- Fixed: setting two routes that use different path variable names. [#38 in LuckyRouter](https://github.com/luckyframework/lucky_router/pull/38)
- Added: route globbing. [#40 in LuckyRouter](https://github.com/luckyframework/lucky_router/pull/40)
- Fixed: catching when duplicate routes are defined. [#42 in LuckyRouter](https://github.com/luckyframework/lucky_router/pull/42)
- Added: flow spec matcher method `have_current_path`. [#96 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/96)
- Fixed: flow spec `have_text` matcher method to check if the text is included and not exact. [#99 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/99)
- Added: flow method to confirm and accept javascript modal boxes. [#101 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/101)
- Added: flow to fill a select field. [#104 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/104)
- Added: flow to select multiple values from a select field. [#106 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/106)
- Added: flow method `element.hover` to hover over an element. [#108 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/108)


### v0.24.0 (2020-09-05)

- Fixed: `send_text_response` default status to nil [#1214](https://github.com/luckyframework/lucky/pull/1214)
- Added: `data` method for Actions to return file contents [#1220](https://github.com/luckyframework/lucky/pull/1220)
- Updated: Component `m` is renamed to `mount` [#1226](https://github.com/luckyframework/lucky/pull/1226)
- Updated: Components with UrlHelpers like `current_page?` [#1228](https://github.com/luckyframework/lucky/pull/1228)
- Added: optional param routing [#1229](https://github.com/luckyframework/lucky/pull/1229)
- Updated: docs on `accept_format` [#1234](https://github.com/luckyframework/lucky/pull/1234)
- Updated: generator templates to use getter methods over instance variables [#1236](https://github.com/luckyframework/lucky/pull/1236)
- Updated: our community to use Discord for community [chat room](https://discord.gg/HeqJUcb) [#1237](https://github.com/luckyframework/lucky/pull/1237)
- Updated: compile-time error when path params are defined with dashes [#1238](https://github.com/luckyframework/lucky/pull/1238)
- Updated: path helpers to render query params even if default value is passed [#1239](https://github.com/luckyframework/lucky/pull/1239)
- Updated: `redirect_back` to disallow external referrers by default with config option [#1241](https://github.com/luckyframework/lucky/pull/1241)
- Updated: generated api apps will use `disable_cookies` by default [#535 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/535)
- Fixed: generating an app with the name "app" will raise an error [#543 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/543)
- Updated: `AppClient` renamed to `ApiClient` [#534 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/534)
- Updated: generated projects to use `--ignore-crystal-version` flag when running `shards install`. NOTE: this is a temporary update, and will be reverted in a future release. [Read Crystal Blog](https://crystal-lang.org/2020/08/20/preparing-our-shards-for-crystal-1.0.html) [See commit](https://github.com/luckyframework/lucky_cli/pull/547/files#diff-154806d6e0faa0b1aa1e518f3bbd3647R25)
- Added: ability to set default values on model columns [#424 in Avram](https://github.com/luckyframework/avram/pull/424)
- Added: `file_attribute` for operations to specify a file from params [#428 in Avram](https://github.com/luckyframework/avram/pull/428)
- Added: new `Database.delete` strategy for cleaning up data in specs [#426 in Avram](https://github.com/luckyframework/avram/pull/426)
- Added: `create_function` and `drop_function` to create SQL functions [#427 in Avram](https://github.com/luckyframework/avram/pull/427)
- Updated: `Avram::PostgresURL` renamed to `Avram::Credentials` with a new interface [#433 in Avram](https://github.com/luckyframework/avram/pull/433)
- Added: `create_trigger` and `drop_trigger` to create SQL triggers [#436 in Avram](https://github.com/luckyframework/avram/pull/436)
- Added: association `_count` method to easily return a count of a has_many association [#392 in Avram](https://github.com/luckyframework/avram/pull/392)
- Added: new `Pulsar` shard for pub/sub style communication in Lucky [See Pulsar](https://github.com/luckyframework/pulsar)
- Added: Pulsar instrumentation to Avram for subscribing to queries [#441 in Avram](https://github.com/luckyframework/avram/pull/441)
- Added: support for `Array(Float64)` in databases [#443 in Avram](https://github.com/luckyframework/avram/pull/443)
- Updated: `fill_existing_with` option on `add_belongs_to` in migrations [#444 in Avram](https://github.com/luckyframework/avram/pull/444)
- Added: `Box.build_attributes` method to build the attributes of a model in specs [#449 in Avram](https://github.com/luckyframework/avram/pull/449)
- Fixed: blank strings causing parse exceptions in save operations [#448 in Avram](https://github.com/luckyframework/avram/pull/448)
- Updated: LuckyRouter with many performance and structural refactors [#28](https://github.com/luckyframework/lucky_router/pull/28), [#30](https://github.com/luckyframework/lucky_router/pull/30), [#31](https://github.com/luckyframework/lucky_router/pull/31), [#32](https://github.com/luckyframework/lucky_router/pull/32)

### v0.23.1 (2020-07-07)

- Fixed: generated apps using deprecated `mount` instead of `m` [#531 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/531)

### v0.23.0 (2020-06-26)

- Updated: password reset tokens to be URL safe [#1118](https://github.com/luckyframework/lucky/pull/1118)
- Added: `radio` input helper [#1125](https://github.com/luckyframework/lucky/pull/1125)
- Added: component file paths to rendered comments in markup for development [#1126](https://github.com/luckyframework/lucky/pull/1126)
- Added: `query_param_declarations` method to Action classes [#1122](https://github.com/luckyframework/lucky/pull/1122)
- Fixed: generating a model that already exists now raises an error [#1127](https://github.com/luckyframework/lucky/pull/1127)
- Added: `select_prompt` helper method [#1124](https://github.com/luckyframework/lucky/pull/1124)
- Updated: `lucky routes` UI to now include query params [#1128](https://github.com/luckyframework/lucky/pull/1128)
- Added: `route_prefix` method for Actions to prefix all routes [#1121](https://github.com/luckyframework/lucky/pull/1121)
- Fixed: error when deleting cookies that don't exist [#1132](https://github.com/luckyframework/lucky/pull/1132)
- Fixed: handling ajax form submissions with TurboLinks [#1133](https://github.com/luckyframework/lucky/pull/1133)
- Fixed: issue with `ajax?` method not returning correct value [#1134](https://github.com/luckyframework/lucky/pull/1134)
- Fixed: security issue by escaping HTML helpers by default [#1135](https://github.com/luckyframework/lucky/pull/1135)
- Updated: `memoize` to allow for arguments, and `nil` and `false` values [#1139](https://github.com/luckyframework/lucky/pull/1139)
- Updated: model generator to provide more helpful error messages [#1140](https://github.com/luckyframework/lucky/pull/1140)
- Added: `get_raw` method to params along with striping blankspace on param `get` calls [#1144](https://github.com/luckyframework/lucky/pull/1144)
- Removed: `mount` with deprecation in favor of new `m` method.
- Added: `m` helper method as a `mount` replacement with a new interface. [#1151](https://github.com/luckyframework/lucky/pull/1151)
- Updated: `String#squish` method to be faster [#1159](https://github.com/luckyframework/lucky/pull/1159)
- Removed: `Lucky::SessionHandler` and `Lucky::FlashHandler`. [#518 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/518)
- Fixed: issue with session cookies not being written at the right time. [#1160](https://github.com/luckyframework/lucky/pull/1160)
- Added: `template` HTML method for `<template>` tags. [#1164](https://github.com/luckyframework/lucky/pull/1164)
- Fixed: flash messages being lost during multiple redirects. [#1169](https://github.com/luckyframework/lucky/pull/1169)
- Added: `redirect_back` for actions to redirect back to previous referrer [#1168](https://github.com/luckyframework/lucky/pull/1168)
- Added: `component` method to render a Component directly from an Action [#1172](https://github.com/luckyframework/lucky/pull/1172)
- Added: `canonical_link` HTML helper method. [#1182](https://github.com/luckyframework/lucky/pull/1182)
- Added: `disable_cookies` macro to stop cookies from being written on a specific action [#1180](https://github.com/luckyframework/lucky/pull/1180)
- Fixed: setting `samesite` on cookies in your `Lucky::CookieJar` `on_set` [#1183](https://github.com/luckyframework/lucky/pull/1183)
- Fixed: compilation bug in generated page when running `lucky gen.page` [#1191](https://github.com/luckyframework/lucky/pull/1191)
- Added: `multipart: true` option to `form_for` to set multipart enctype [#1200](https://github.com/luckyframework/lucky/pull/1200)
- Added: `Lucky.root` method to raise compile-time error directing people to use `Dir.current` instead. [#1206](https://github.com/luckyframework/lucky/pull/1206)
- Added: native CLI args to `LuckyCli::Task`. [#466 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/466)
- Updated: generated projects to disable StaticFileHandler directory listing by default. [#510 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/510)
- Updated: error action to return a 404 for `Avra::RecordNotFoundError` [#524 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/524)
- Fixed: `select_count` failing when postgres returns no counts. [#357 in Avram](https://github.com/luckyframework/avram/pull/357)
- Added: support for postgres extensions with `enable_extension`, `disable_extension`, and `update_extension`. [#356 in Avram](https://github.com/luckyframework/avram/pull/356)
- Added: enum support for models with `avram_enum` macro. [#339 in Avram](https://github.com/luckyframework/avram/pull/339)
- Fixed: the error message when using `remove` in migrations, and not passing a Symbol.
- Added: `rename` and `rename_belongs_to` in migrations [#366 in Avram](https://github.com/luckyframework/avram/pull/366)
- Added: new `lucky db.setup` task which runs `db.create` and `db.migrate`. [#361 in Avram](https://github.com/luckyframework/avram/pull/361)
- Added: ability to set a custom index name for table indices. [#386 in Avram](https://github.com/luckyframework/avram/pull/386)
- Fixed: using a custom primary key name of type `UUID`. [#401 in Avram](https://github.com/luckyframework/avram/pull/401)
- Added: checking for a connection to the PostgreSQL engine before running the `lucky db.create` task. [#397 in Avram](https://github.com/luckyframework/avram/pull/397)
- Fixed: logging issues related to Crystal 0.35.0. [#31 in Dexter](https://github.com/luckyframework/dexter/pull/31)
- Updated: which selenium library was being used for LuckyFlow. [#76 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/76)
- Added: initial work to support using other browsers aside from Chrome in LuckyFlow. [#79 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/79), [#88 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/88)
- Added: support to auto fetch latest webdrivers in LuckyFlow. [#80 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/80)
- Fixed: issue with really long stacktrace in LuckyFlow. [#83 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/83)
- Added: `have_text` expectation method for Flow specs. [#87 in LuckyFlow](https://github.com/luckyframework/lucky_flow/pull/87)
- Added: optional path param routing. [#18 in LuckyRouter](https://github.com/luckyframework/lucky_router/pull/18)
- Update: routing to ensure matching dynamic fragments all work. [#23 in LuckyRouter](https://github.com/luckyframework/lucky_router/pull/23)
- Added: a little bit of speed to the routing lookup. [#26 in LuckyRouter](https://github.com/luckyframework/lucky_router/pull/26)
- Added: a new `validation` option to Habitat settings. [#49 in Habitat](https://github.com/luckyframework/habitat/pull/49)
- Renamed: the internal Habitat `Settings` class to `HabitatSettings` to avoid name conflicts in some Lucky apps. [#48 in Habitat](https://github.com/luckyframework/habitat/pull/48)
- Fixed: bug when setting a default value in a Habitat setting that could potentially raise an exception. [#51 in Habitat](https://github.com/luckyframework/habitat/pull/51)


### v0.22.0 (2020-06-17)

- Added: support for Crystal 0.35.0

### v0.21.0 (2020-04-19)

- Added: support for Crystal 0.34.0 `Log` class [#506 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/506/files)
- Added: `paginate_array` for paginating Arrays [#1108](https://github.com/luckyframework/lucky/pull/1108)
- Improve error logging [#1114](https://github.com/luckyframework/lucky/pull/1114)
- Improve http status logging [#1114](https://github.com/luckyframework/lucky/pull/1114)
- Upgraded: Dexter to v0.2.0
  - Type-safe log configuration
  - New JSON formatter
  - Helpers for testing logs
- Fix for issues with the system check in Procfile.dev [#505 in Lucky CLI](https://github.com/luckyframework/lucky_cli/pull/505)

### v0.20.0 (2020-04-08)

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
