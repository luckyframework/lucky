## Upgrading from 0.16 to 0.17

- Ensure you've upgraded to crystal 0.30.0
- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date. Requires 0.30.0
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

- Update `.crystal-version` to `0.30.0`

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Lucky should be `~> 0.17`
- Run `shards update`

### General updates
- Rename: Action rendering method `text` to `plain_text`.
- Update: use of `number_to_currency` now returns a String instead of writing to the view directly.
- Delete: `config/static_file_handler.cr`. The `Lucky::StaticFileHandler` no longer has config settings.
- Add: a new `Lucky::LogHandler` configure to `config/logger.cr`.
```
Lucky::LogHandler.configure do |settings|
  # Skip logging static assets in development
  if Lucky::Env.development?
    settings.skip_if = ->(context : HTTP::Server::Context) {
      context.request.method.downcase == "get" &&
      context.request.resource.starts_with?(/\/css\/|\/js\/|\/assets\//)
    }
  end
end
```

### Database updates
- Add: a new `AppDatabase` class in `config/database.cr` that inherits from `Avram::Database`. (e.g. `class AppDatabase < Avram::Database`)
- Rename: `Avram::Repo.configure` to `AppDatabase.configure` in `config/database.cr`.
- Add: `Avram.configure` block.
```
Avram.configure do |settings|
  settings.database_to_migrate = AppDatabase
  # this is moved from your old `Avram::Repo.configure` block.
  settings.lazy_load_enabled = Lucky::Env.production?
end
```
- Move: the `settings.lazy_load_enabled` from `AppDatabase.configure` to `Avram.configure` block.

### Updating queries
- Rename: `Query.new.destroy_all` to `Query.truncate`. (e.g. `UserQuery.new.destroy_all` => `UserQuery.truncate`)
- Rename: all association query methods from the association name to `where_{association_name}`. (e.g. `UserQuery.new.posts` => `UserQuery.new.where_posts`)
- Update: all association query methods no longer take a block. Pass the query in as an argument. (e.g. `UserQuery.new.posts { |post_query| }` => `UserQuery.new.where_posts(PostQuery.new)`)
- Update: `where_{association_name}` methods no longer need to be preceeded by a `join_{assoc}`, unless you need a custom join (i.e. `left_join_{assoc}`). If you use a custom join, you will need to add the `auto_inner_join: false` option to your `where_{assoc}` method.

### Moving forms to operations
- Rename: the `src/forms` directory to `src/operations`.
- Rename: all `BaseForm` mentions to `SaveOperation` in `src/operations`. (e.g. `User::BaseForm` => `User::SaveOperation`)
- Rename: `fillable` to `permit_columns`
- Rename: form class names to new naming convention. (e.g. `class UserForm < User::SaveOperation` => `class SaveUser < User::SaveOperation`). This step is optional, but still recommended to avoid future confusion.
- Rename: `Avram::VirtualForm` to `Avram::Operation`.
- Rename: virtual form class names to new naming convention. (e.g. `class SignInForm < Avram::Operation` => `class SignInUser < Avram::Operation`).
- Rename: `virtual` to `attribute`.
- Update: all `SaveOperation` classes to call `before_save prepare`. The `prepare` method is no longer called by default, which allows you to rename this method as well.

## Upgrading from 0.15 to 0.16

- Upgrade to crystal 0.30.0

No updates to Lucky itself are required. There may be Crystal 0.30.0 related changes you may need to make.

## Upgrading from 0.14 to 0.15

- Upgrade to crystal 0.29.0
- Upgrade Lucky CLI (macOS)

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date. Requires 0.29.0
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

- Update `.crystal-version` to `0.29.0`

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Lucky should be `~> 0.15`

- Run `shards update`

- Rename `src/server.cr` to `src/start_server.cr`.
- Edit `src/start_server.cr` by changing 
    * `app` to `app_server` and `App` to `AppServer`.
    * delete the line that starts with `puts "Listening on`
- Update `src/{your app name}.cr` to require `./start_server`
- Rename `src/dependencies.cr` to `src/shards.cr`
- Move the `App` class to a new file in `src/app_server.cr`
- Rename `App` to `AppServer` and rename `Lucky::BaseApp` to `Lucky::BaseAppServer` in your new `src/app_server.cr`
- Update `src/app.cr` to require new `./app_server` file
- Update `src/app.cr` to require new `./shards` file
- Replace usages of `Lucky::Action::Status::` with the respective crystal `HTTP::Status::`

## Upgrading from 0.13 to 0.14

- Upgrade to crystal 0.28.0
- Create new file `config/force_ssl_handler.cr` with the following content:

```crystal
Lucky::ForceSSLHandler.configure do |settings|
  settings.enabled = Lucky::Env.production?
end
```

## Upgrading from 0.12 to 0.13

- Upgrade Lucky CLI (macOS)

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date. Requires 0.27.2
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

- Update `.crystal-version` to `0.27.2`

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/installing/#install-lucky

- Update versions in `shard.yml`
  - Lucky should be `~> 0.13`
  - LuckyFlow should be `~> 0.4`
  - Authentic should be `~> 0.3`

- Run `shards update`

- Find and replace `LuckyRecord` with `Avram`

- Add `Lucky::AssetHelpers.load_manifest` below `require "dependencies"` in `src/app.cr` for browser apps. Skip for API only apps.

- `Query#preload` with a query now includes the association name -> [`Query#preload_{{ assoc_name }}`](https://github.com/luckyframework/lucky_record/pull/307)

- Remove `unexpose` and `unexpose_if_exposed` from your actions. Pages now
  ignore unused exposures so these methods have been removed.

- Change `require "lucky_record"` to `require "avram"` in `src/dependencies`

- Rename `config/log_handler.cr` to `config/logger.cr`

- Replace `config/logger.cr` with this:

```crystal
require "file_utils"

logger =
  if Lucky::Env.test?
    # Logs to `tmp/test.log` so you can see what's happening without having
    # a bunch of log output in your specs results.
    FileUtils.mkdir_p("tmp")
    Dexter::Logger.new(
      io: File.new("tmp/test.log", mode: "w"),
      level: Logger::Severity::DEBUG,
      log_formatter: Lucky::PrettyLogFormatter
    )
  elsif Lucky::Env.production?
    # This sets the log formatter to JSON so you can parse the logs with
    # services like Logentries or Logstash.
    #
    # If you want logs like in develpoment use `Lucky::PrettyLogFormatter`.
    Dexter::Logger.new(
      io: STDOUT,
      level: Logger::Severity::INFO,
      log_formatter: Dexter::Formatters::JsonLogFormatter
    )
  else
    # For development, log everything to STDOUT with the pretty formatter.
    Dexter::Logger.new(
      io: STDOUT,
      level: Logger::Severity::DEBUG,
      log_formatter: Lucky::PrettyLogFormatter
    )
  end

Lucky.configure do |settings|
  settings.logger = logger
end

Avram::Repo.configure do |settings|
  settings.logger = logger
end
```

- If using `is` in queries, rename the calls to `eq`

- App in `src/app.cr` should now inherit from `Lucky::BaseApp`. See [the changes you need to make](https://github.com/luckyframework/lucky_cli/commit/7794306c55b8e00ded0d816def5cd62dc6fe4367).

- Move `bin/setup` to `script/setup`

- In your `README` replace `bin/setup` with `script/setup`

- Replace `bin/lucky` in your `.gitignore` with just `/bin/`. Lucky projects
  should now put bash scripts in `/script`. Binaries go in `/bin/` and are
  ignored.
- `id` in actions using `route` now have the underscored version of the
  resource name prepended. You'll need to rename your `id` calls to
  `<resource_name>_id`.

```crystal
# Example from v0.12
class Users::Show < BrowserAction
  route do
    # Using the 'id' param
    UserQuery.find(id)
  end
end

# Would now be
class Users::Show < BrowserAction
  route do
    # Now it is 'user_id'
    UserQuery.find(user_id)
  end
end
```

- Make changes to [laravel.mix](https://github.com/luckyframework/lucky_cli/commit/88ad5af5b40f3a29c4abcb0581db505019d7003f#diff-cd19e42e70bfbcf2a12480b0b6b1f590)

- Make changes to [package.json](https://github.com/luckyframework/lucky_cli/commit/88ad5af5b40f3a29c4abcb0581db505019d7003f#diff-73db280623fcd1a64ac1ab76c8700dbc)

- Run `yarn install`

And you should now be good to go!

## Upgrading from 0.11 to 0.12

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

## Upgrading from 0.10 to 0.11

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
