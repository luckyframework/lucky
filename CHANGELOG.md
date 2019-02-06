### In master but no released (since v0.12)

- Prefix id params with the resource name [#659](https://github.com/luckyframework/lucky/issues/659)

- Added Action#url_without_query_params [#662](https://github.com/luckyframework/lucky/pull/662)

- Added `Lucky::AssetHelpers.load_manifest` so that API apps don't need a blank manifest to compile.

- Pages ignore unused exposures [#666](https://github.com/luckyframework/lucky/issues/666)

- `unexpose` and `unexpose_if_exposed` have been removed because they are no
longer necessary now that pages ignore unused exposures.

- `is` in queries has been renamed to `eq`. For example: `UserQuery.new.name.not.is("Emily")` should now be `UserQuery.new.name.not.eq("Emily")`. If passing in something that could be `Nil`, one must use `nilable_eq` instead. [avram#46](https://github.com/luckyframework/avram/pull/46)
