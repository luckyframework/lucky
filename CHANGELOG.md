### In master but not released (since v0.12)

- Use `Dexter` as the logger. https://github.com/luckyframework/lucky_cli/pull/300 and https://github.com/luckyframework/lucky_cli/pull/299

- Move scripts from `bin` to `script`. Ignore all of `bin` directory in `.gitignore`. See https://github.com/luckyframework/lucky_cli/pull/288 and https://github.com/luckyframework/lucky_cli/pull/301

- `App` in `src/app.cr` should now inherit from `Lucky::BaseApp`. See https://github.com/luckyframework/lucky_cli/pull/287/files for an example.

- Prefix id params with the resource name [#659](https://github.com/luckyframework/lucky/issues/659)

- Added Action#url_without_query_params [#662](https://github.com/luckyframework/lucky/pull/662)

- Added `Lucky::AssetHelpers.load_manifest` so that API apps don't need a blank manifest to compile.

- Pages ignore unused exposures [#666](https://github.com/luckyframework/lucky/issues/666)

- `unexpose` and `unexpose_if_exposed` have been removed because they are no
longer necessary now that pages ignore unused exposures.

- `is` in queries has been renamed to `eq`. For example: `UserQuery.new.name.not.is("Emily")` should now be `UserQuery.new.name.not.eq("Emily")`. If passing in something that could be `Nil`, one must use `nilable_eq` instead. [avram#46](https://github.com/luckyframework/avram/pull/46)
