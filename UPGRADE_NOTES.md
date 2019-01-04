### Upgrading from 0.12 to the beta version on master

- Add `Lucky::AssetHelpers.load_manifest` below `require "dependencies"` in `src/app.cr` for browser apps. Skip for API only apps.

### Upgrading from 0.11 to 0.12

- Upgrade Lucky CLI (macOS)

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date. Requires 0.27
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/installing/#install-lucky

> Use your package manager to update Crystal to v0.27

- In `db/migrations`, change `LuckyMigrator::Migration` -> `LuckyRecord::Migrator::Migration` for every migration

- Remove `lucky_migrator` from `shard.yml`

- Remove `lucky_migrator` from `src/dependencies`

- Remove the `LuckyMigrator.configure` block from `config/database.cr`

- Configuration now requires passing an argument. Find and replace `.configure do` with `.configure do |settings|` in all files in `config`

- Update `config/session.cr`

  - Change `Lucky::Session::Store.configure` to `Lucky::Session.configure do |settings|`

  - Change your session key because signing/encryption has changed. For example: add `_0_12_0` to the end of the key.

  - Remove `settings.secret = Lucky::Server.settings.secret_key_base`

- If using `cookies[]` anywhere in your app, change the key you use. Lucky now signs and encrypts all cookies. Old cookies will not decrypt properly.

- Change `session[]=` and `cookies[]=` to `session|cookies.set|get`

- Change `session|cookies.destroy` to `session/cookies.clear`

- `cookies.unset(:key)` and `delete.unset(:key)` should be `cookies|session.delete(:key)`

- Remove `unexpose current_user` from `src/actions/home/index.cr`

- `Query#count` has been renamed to `Query#select_count`. For example: `UserQuery.new.count` is now `UserQuery.new.select_count`

- Change `flash.danger` to `flash.failure` in your actions.

- Update `Lucky::Flash::Handler` to `Lucky::FlashHandler` in `src/app.cr`

- Update usages of `Lucky::Response` to `Lucky::TextResponse`

- Update usages of `LuckyInflector::Inflector` to `Wordsmith::Inflector`

- Remove `config/session.cr` and copy [`config/cookies.cr`](https://github.com/luckyframework/lucky_cli/blob/baaeeb0b8c7a410625320af394437f8665442664/src/web_app_skeleton/config/cookies.cr.ecr)

- Replace `config/email.cr` with [this one](https://github.com/luckyframework/lucky_cli/blob/baaeeb0b8c7a410625320af394437f8665442664/src/web_app_skeleton/config/email.cr).

- Add this line to `spec_helper.cr` (around line 19) -> `LuckyRecord::Migrator::Runner.new.ensure_migrated!`

- In `config/server.cr`, copy the new block starting at [`line 15`](https://github.com/luckyframework/lucky_cli/blob/baaeeb0b8c7a410625320af394437f8665442664/src/web_app_skeleton/config/server.cr.ecr#L15-L23).

- Update shard versions in `shard.yml`:

  - Lucky `~> 0.12`
  - LuckyRecord `~> 0.7`
  - Authentic `~> 0.2`
  - LuckyFlow `~> 0.3`

- Change `.crystal-version` to `0.27.0`

- Run `shards update` to install the new shards

### Upgrading from 0.10 to 0.11

- Upgrade Lucky CLI (macOS)

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/installing/#install-lucky

> Use your package manager to update Crystal to v0.25

- Update `.crystal-version` to `0.25.0`

- Change `crystal deps` to `shards install` in `bin/setup`

- Update `lucky_flow` and `lucky_migrator` in `shard.yml`

  - `lucky_flow` should now be `0.2`
  - `lucky_migrator` should now be `0.6`

- Remove any cached shards: rm -rf ~/.cache/shards

  > This is to address a bug in shards: https://github.com/crystal-lang/shards/issues/211

- Run `shards update`

- Find all instances of `nested_action` and replace with `nested_route`

- Find all instances of `action` and replace with `route` in your actions

  > To make it easier to only change the right thing, search for `action do` and
  > replace with `route do`. This will make it fairly easy to find and replace
  > across your whole project.

- Move static assets from `static/assets` to `public/assets`

- Move `static/js` to `src/js`

- Move `static/css` to `src/css`

- Remove `/public` from `.gitignore`

- Add these to `.gitignore`

  - `/public/mix-manifest.json`
  - `/public/js`
  - `/public/css`

- Update `src/app.cr` lines:

  - Remove host and port: https://github.com/luckyframework/lucky_cli/blob/ce677b8aefbbef2f06587d835795cbb59c5801dd/src/web_app_skeleton/src/app.cr.ecr#L25
  - Add `bind_tcp` with host and port: https://github.com/luckyframework/lucky_cli/blob/ce677b8aefbbef2f06587d835795cbb59c5801dd/src/web_app_skeleton/src/app.cr.ecr#L50

- Update webpack config to match this: https://github.com/luckyframework/lucky_cli/blob/ce677b8aefbbef2f06587d835795cbb59c5801dd/src/browser_app_skeleton/webpack.mix.js#L12-L37

- Calls to the `asset` method no longer require prefixing `/assets`. You may not
  be using this. The compiler will complain and help you find the right asset if
  you need to update this.

### Upgrading from 0.8 to 0.10

> Note: Lucky skipped version 0.9 so that Lucky and Lucky CLI are on the same version.

- Upgrade Lucky CLI

On macOS:

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date
brew upgrade lucky
```

If you are on Linux, remove the existing Lucky binary and follow the Linux
instructions in this section
https://luckyframework.org/guides/installing/#install-lucky

- View the upgrade diff and make changes to your app

In previous upgrade guides (below) every change is listed individually. This was
time consuming and error-prone. Now,
you can [view all changes in this GitHub commit](https://github.com/luckyframework/upgrade-diffs/commit/c279b0d0c0b9936301c5ea93fd25a549c9cd4c06).

- Ensure node version is at least 6.0 `node -v`. Install a newer version if
  yours is older.

- Move files in `src/pipes` to `src/actions/mixins`

- Change `allow` to `fillable` in forms

- Change `allow_virtual` to `virtual` in forms

- Run `shards update`

- Run `bin/setup` to run new migrations, Laravel Mix and seeds file

> If you have any problems or want to add extra details please open an issue or
> Pull Request. Thank you!

### Upgrading from 0.7 to 0.8

- Upgrade Lucky CLI

On macOS:

```
brew update
brew upgrade crystal-lang
brew upgrade lucky
```

If you are on Linux, remove the existing Lucky binary and follow the Linux
instructions in this section:
https://luckyframework.org/guides/installing/#install-lucky

- Update dependencies in `shard.yml`

```yml
dependencies:
  lucky:
    github: luckyframework/lucky
    version: "~> 0.8.0"
  lucky_migrator:
    github: luckyframework/lucky_migrator
    version: ~> 0.4.0
```

Then run `shards update`

- Update `config/server.cr`

You can probably copy this as-is, but if you have made customizations to your
`config/server.cr` then you'll need to customize this:

```crystal
Lucky::Server.configure do |settings|
  if Lucky::Env.production?
    settings.secret_key_base = secret_key_from_env
    settings.host = "0.0.0.0"
    settings.port = ENV["PORT"].to_i
  else
    settings.secret_key_base = "<%= secret_key_base %>"
    # Change host/port in config/watch.yml
    # Alternatively, you can set the PORT env to set the port
    settings.host = Lucky::ServerSettings.host
    settings.port = Lucky::ServerSettings.port
  end
end

private def secret_key_from_env
  ENV["SECRET_KEY_BASE"]? || raise_missing_secret_key_in_production
end

private def raise_missing_secret_key_in_production
  raise "Please set the SECRET_KEY_BASE environment variable. You can generate a secret key with 'lucky gen.secret_key'"
end
```

- Add `config/watch.yml`

This is used by the watcher so it knows what port the server is running on.

```yaml
host: 0.0.0.0
port: 5000
```

- Update `config/database.cr`

Put this inside of the `LuckyRecord::Repo.configure do |settings|` block:

```
# In development and test, raise an error if you forget to preload associations
settings.lazy_load_enabled = Lucky::Env.production?
```

See a full example here: https://github.com/luckyframework/lucky_cli/blob/a25472cc7461b1803735d086e57a632f92f93a1c/src/web_app_skeleton/config/database.cr.ecr

- You will need to preload associations now:

This will make N+1 queries a thing of the past.

```crystal
# Will now raise a runtime error in dev/test
post = PostQuery.new.find(id)
post.comments # Must preload comments

# Now, you need to preload the comments
post = PostQuery.new.preload_comments.find(id)
post.comments
```

- Rename `field` to `column` in your models. For example

```crystal
class Post < BaseModel
  table :posts do
    column title : String # was "field title : String" previously
  end
end
```

- Optionally include `responsive_meta_tag` in `MainLayout`

You can include this in `head` to make your app layout responsive.

- Change `abstract def inner` to `abstract def content` in `MainLayout`

- Change method call to `inner` to `content` in the render method of `MainLayout`

- Change instances of `def inner` to `def content` in Pages

- Change form `needs` to use `on: :create`

`needs` in forms should now use `on: :save` if you want the old behavior.

See https://luckyframework.org/guides/saving-with-forms/#passing-extra-data-to-forms for more info

- Must pass extra params using `create` or `update`

You can no longer pass params to `Form#new`. You must pass them in the
`create` or `update`.

```crystal
UserForm.new(name: "Jane").save!
UserForm.create!(name: "Jane")
```

More info at https://luckyframework.org/guides/saving-with-forms/#passing-data-without-route-params

- Change calls from `form.save_succeeded?` to `form.saved?`

- Trap int in src/server.cr

Add this to your `src/server.cr` before `server.listen`

```crystal
Signal::INT.trap do
  server.close
end
```

- Add `bin/lucky/` to `.gitignore`

```
# Add to .gitignore
bin/lucky/
```

- Add nice HTML error page

Copy contents of the linked file to `src/pages/errors/show_page.cr`
https://github.com/luckyframework/lucky_cli/blob/a25472cc7461b1803735d086e57a632f92f93a1c/src/web_app_skeleton/src/pages/errors/show_page.cr

- Add default `Error::ShowSerializer`

This is used for serializering errors to JSON. Add this to
`src/serializers/errors/show_serializer.cr`

```crystal
# This is the default error serializer generated by Lucky.
# Feel free to customize it in any way you like.
class Errors::ShowSerializer < Lucky::Serializer
  def initialize(@message : String, @details : String? = nil)
  end

  def render
    {message: @message, details: @details}
  end
end
```

- Update `Errors::Show` action

The error handling action now supports more errors and renders better output.

Copy the contents of the linked file to `src/actions/errors/show.cr`
https://github.com/luckyframework/lucky_cli/blob/a25472cc7461b1803735d086e57a632f92f93a1c/src/web_app_skeleton/src/actions/errors/show.cr

- Require serializers

Add the following to `src/app.cr`.

```crystal
require "./serializers/**"
```

### Upgrading from 0.6 to 0.7

- Update to Crystal v0.24.1. Lucky will fail on earlier versions

```
brew update
brew upgrade crystal-lang
brew upgrade lucky
```

If you are on Linux, remove the existing Lucky binary and follow the Linux instructions in this section: https://luckyframework.org/guides/installing/#install-lucky

- Update dependencies in `shard.yml`

```yml
dependencies:
  lucky:
    github: luckyframework/lucky
    version: "~> 0.7.0"
  lucky_migrator:
    github: luckyframework/lucky_migrator
    version: ~> 0.4.0
```

Then run `shards update`

- Configure the domain to use for the RouteHelper:

```crystal
# Add to config/route_helper.cr
Lucky::RouteHelper.configure do |settings|
  if Lucky::Env.production?
    # The APP_DOMAIN is something like https://myapp.com
    settings.domain = ENV.fetch("APP_DOMAIN")
  else
    settings.domain = "http:://localhost:3001"
  end
end
```

- Add `csrf_meta_tags` to your `MainLayout`

```crystal
# src/pages/main_layout.cr
# Somewhere in the head tag:
csrf_meta_tags
```

- Remove `needs flash` from `MainLayout`

```crystal
# Delete this line
needs flash : Lucky::Flash::Store
```

- Remove `expose flash` from `BrowserAction` and add forgery protection

```crystal
# src/actions/browser_action.cr
abstract class BrowserAction < Lucky::Action
  include Lucky::ProtectFromForgery
end
```

- Change `Shared::FlashComponent` to get the flash from `@context`

```crystal
# src/components/shared/flash_component.cr
# Change this:
@flash.each
# To:
@context.flash.each
```

- Add `*.dwarf` to the .gitignore

```
# Add to .gitignore
*.dwarf
```
