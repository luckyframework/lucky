### Changes since v0.15

- Rename `Avram::BaseForm` to `Avram::SaveOperation` [see Avram](https://github.com/luckyframework/avram/pull/104)
- Rename `Avram::Field` to `Avram::Attribute` [see Avram](https://github.com/luckyframework/avram/commit/d3503a161670077c1d7b14484382132ea3ab423d)
- Update `number_to_currency` now returns `String` instead of writing to the view directly. [#809](https://github.com/luckyframework/lucky/pull/809)
- Fixed bug in running `build.release` task.
- Update mounted components render comments to show start and end of component. [#817](https://github.com/luckyframework/lucky/pull/817)
- Revert returning `String` for `highlight` helper. [#818](https://github.com/luckyframework/lucky/pull/818)
- Update text helpers that write to the view moved to their own module. [#820](https://github.com/luckyframework/lucky/pull/820)
- Rename `fillable` to `permit_columns`. [see Avram]()
- Added `skip_if` option to `LogHandler`. [#824](https://github.com/luckyframework/lucky/pull/824)
- Rename `Lucky::Exposeable` to `Lucky::Exposable`. [#827](https://github.com/luckyframework/lucky/pull/827)
- Rename `Lucky::Routeable` to `Lucky::Routable`. [#827](https://github.com/luckyframework/lucky/pull/827)
- Added `memoize` macro. [#832](https://github.com/luckyframework/lucky/pull/832)
- Added `table_for` macro. [see Avram](https://github.com/luckyframework/avram/pull/127)
- Added `xml` render method for Actions. [#838](https://github.com/luckyframework/lucky/pull/838)
- Rename `text` render action to `plain_text`. [#838](https://github.com/luckyframework/lucky/pull/838)
- Update `responsive_meta_tag` to be flexible. [#835](https://github.com/luckyframework/lucky/pull/835)
- Added `Int16#to_param` and `Int64#to_param`.
- Fixed `append/replace_class` with no default. [#842](https://github.com/luckyframework/lucky/pull/842)
- Added multi database support. [see Avram](https://github.com/luckyframework/avram/pull/136)
- Rename `form_name` to `param_key`. [see Avram](https://github.com/luckyframework/avram/pull/140)
- Fixed 3rd party shards versions. [#855](https://github.com/luckyframework/lucky/pull/855)

### v0.15 (2019-06-12)

- Removed `Lucky::Action::Status`. Use Crystal's `HTTP::Status` enum. [#769](https://github.com/luckyframework/lucky/pull/769)
- CookieOverflow is now checked when the cookie is set instead of later in middleware. [#761](https://github.com/luckyframework/lucky/pull/761)
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
