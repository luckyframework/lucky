## Upgrading from 0.30 to 1.0.0-rc1

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.30.0&to=1.0.0-rc1).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Lucky should be `~> 1.0.0-rc1`
  - Avram should be `~> 1.0.0-rc1`
  - Authentic should be `~> 0.9.0`
  - Carbon (and carbon_sendgrid_adapter) should be `~> 0.3.0`
  - LuckyFlow should be `~> 0.9.0`

- Run `shards update`

### General updates

- Add: Avram to your `shard.yml` as a dependency.
- Add: `require "avram/lucky"` to `src/shards.cr` right below `require "lucky"`. [See PR](https://github.com/luckyframework/avram/pull/772)
- Add: `require "avram/lucky/tasks"` to `tasks.cr` right below `require "lucky/tasks/**"`. [See PR](https://github.com/luckyframework/lucky_cli/pull/764)
- Update: to Crystal 1.4 or later.
- Add: `include Lucky::RedirectableTurbolinksSupport` in your `BrowserAction` if you are using turbolinks.
- Add: `live_reload_connect_tag` to your `src/components/shared/layout_head.cr` and `reload_port: 3001` to your `config/watch.yml` file for live browser reloading. [See this PR](https://github.com/luckyframework/lucky_cli/pull/767) and [this PR](https://github.com/luckyframework/lucky/pull/1693)
- Update: `Avram::Params.new()` now takes `Hash(String, Array(String))` instead of `Hash(String, String)`. [See PR](https://github.com/luckyframework/avram/pull/847)
- Update: arg names in `validate_numeric` from `less_than` and `greater_than` to `at_least` and `no_more_than`. [See PR](https://github.com/luckyframework/avram/pull/867)
- Update: your LuckyFlow configuration...
```crystal
# spec/spec_helper.cr
# ...
require "spec"
# ...
require "lucky_flow"
require "lucky_flow/ext/lucky"
require "lucky_flow/ext/avram"
# ...

# spec/setup/configure_lucky_flow.cr
# ...
LuckyFlow::Spec.setup
```

### Optional updates

- Update the `lucky_sec_tester` shard to version `0.1.0`
- Replace turbolinks with [Turbo](https://turbo.hotwired.dev/)
- Replace laravel-mix with [Vite](https://vitejs.dev/)


## Upgrading from 0.29 to 0.30

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.29.0&to=0.30.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Lucky should be `~> 0.30.0`
  - Authentic should be `~> 0.8.2`
  - LuckyFlow should be `~> 0.7.3` *NOTE*: 0.8.0 is released, but may not be compatible yet

- Run `shards update`

### General updates

- Update: `spec/support/api_client.cr` with `app AppServer.new` defined in the class.
```crystal
class ApiClient < Lucky::BaseHTTPClient
  app AppServer.new

  def initialize
    super
    headers("Content-Type": "application/json")
  end

  def self.auth(user : User)
    new.headers("Authorization": UserToken.generate(user))
  end
end
```
- Update: the `request.remote_ip` method now pulls from the last (instead of first) valid IP in the `X-Forwarded-For` list. [See PR for details](https://github.com/luckyframework/lucky/pull/1675)
- Update: All primary repo branches are now `main`. Adjust any references accordingly.
- Update: `./script/system_check` and remove mentions of `ensure_process_runner_installed`. Nox is built-in [See PR for details](https://github.com/luckyframework/lucky_cli/pull/720)


### Optional updates

- Update: uses of `AvramSlugify` to `Avram::Slugify`. [See PR for details](https://github.com/luckyframework/avram/pull/786)
- Update: specs to use transactions instead of truncate. [See PR for details](https://github.com/luckyframework/avram/pull/780)
```crystal
# in spec/spec_helper.cr
require "./setup/**"

# Add this line
Avram::SpecHelper.use_transactional_specs(AppDatabase)

include Carbon::Expectations
include Lucky::RequestExpectations
include LuckyFlow::Expectations
```
- Remove: the `spec/setup/clean_database.cr` file. This accompanies the transactional specs update
- Update: the `spec/setup/start_app_server.cr` file. This file is no longer needed if your action specs make standard calls, and are not using LuckyFlow. [See PR for details](https://github.com/luckyframework/lucky/pull/1644)


## Upgrading from 0.28 to 0.29

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.28.2&to=0.29.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `">= 1.0.0"`
  - Lucky should be `~> 0.29.0`
  - Authentic should be `~> 0.8.1`
  - Caron SendgidAdapter should be `~> 0.2.0` if you're using SendGrid
  - LuckyEnv should be `~> 0.1.4`
  - LuckyTask should be `~> 0.1.1`
  - JWT should be `~> 1.6.0`

- Run `shards update`

### General updates

- Remove: any usage of the `lucky build.release` task. Use `shards build --release --production` instead. [See PR for details](https://github.com/luckyframework/lucky/pull/1612)
- Update: to Crystal version 1.0.0 or greater. Versions below 1.0 are no longer supported. [See PR for details](https://github.com/luckyframework/lucky/pull/1618)
- Update: your `AppServer` in `src/app_server.cr` to have a `listen` method defined. This method is now abstract on `Lucky::BaseAppServer`. [See PR for details](https://github.com/luckyframework/lucky/pull/1622)
- Update: if you use UUID for primary keys in your models, ensure you've added the "pgcrypto" extension to your DB. The `id` value will no longer be generated on the Crystal side. [See PR for details](https://github.com/luckyframework/avram/pull/725)
- Update: any usage of the `Status` enums in your SaveOperations to be `OperationStatus`. [See PR for details](https://github.com/luckyframework/avram/pull/759)
- Remove: any usage of `route` or `nested_route` from your actions, and replace them with the actual route. (Optionally, you can use the [Legacy Routing Shard](https://github.com/matthewmcgarvey/lucky_legacy_routing)) [See PR for details](https://github.com/luckyframework/lucky/pull/1597)
- Update: your `src/app.cr`, and move the requires for `config/server` and `config/**` to the top of the require stack. [See PR for details](https://github.com/luckyframework/lucky_cli/pull/676)
- Update: your `package.json` (Full Apps only) to use `yarn run mix` instead of just `mix`. [See PR for details](https://github.com/luckyframework/lucky_cli/pull/682)
- Update: your `src/app_server.cr` middleware stack with `Lucky::RequestIdHandler.new` at the top of the stack before `Lucky::ForceSSLHandler.new`. [See PR for details](https://github.com/luckyframework/lucky_cli/pull/700)
- Update: any usage of `add_belongs_to` with namespaced models to specify the `references` option. [See PR for details](https://github.com/luckyframework/avram/pull/742)
- Update: the `error_html` method in `src/actions/errors/show.cr`. Replace the following code
```diff
- html Errors::ShowPage, message: message, status: status
+ html_with_status Errors::ShowPage, status, message: message, status_code: status
```
- Rename: the `status` variable to `status_code` in `src/pages/errors/show_page.cr`


### Optional updates

- Add: a new config `Lucky::RequestIdHandler` in `config/server.cr` to set a request ID.
```crystal
#...

Lucky::RequestIdHandler.configure do |settings|
  settings.set_request_id = ->(context : HTTP::Server::Context) {
    UUID.random.to_s
  }
end
```
- Add: query cache to `config/database.cr`. [See PR for details](https://github.com/luckyframework/avram/pull/763)
```crystal
Avram.configure do |settings|
  settings.database_to_migrate = AppDatabase

  # In production, allow lazy loading (N+1).
  # In development and test, raise an error if you forget to preload associations
  settings.lazy_load_enabled = LuckyEnv.production?

  # Disable query cache during tests
  settings.query_cache_enabled = !LuckyEnv.test?
end
```


## Upgrading from 0.27 to 0.28

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.27.2&to=0.28.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `">= 1.0.0"`
  - Lucky should be `~> 0.28.0`
  - Authentic should be `~> 0.8.0`
  - Carbon should be `~> 0.2.0`
  - Caron SendgidAdapter should be `~> 0.1.0` if you're using SendGrid
  - Dotenv should be replaced with [LuckyEnv ~> 0.1.3](https://github.com/luckyframework/lucky_env)

- Run `shards update`

### General updates

- Remove: `needs context : HTTP::Server::Context` from any component, as well as passing it in to the `mount()` for the components. [See PR for details](https://github.com/luckyframework/lucky/pull/1488)
- Rename: all `DeleteOperation.destroy` calls to `DeleteOperation.delete`
- Update: `avram_enum` to use the Crystal `enum`. [See PR for details](https://github.com/luckyframework/avram/pull/698)
```diff
# Models get this update
- avram_enum State do
+ enum State
    Started
    Ended
  end

# Factories get this update
- state Thing::State.new(:started)
+ state Thing::State::Started

# Operations get this update
- SaveThing.create(state: Thing::State.new(:started)) do |op, t|
+ SaveThing.create(state: Thing::State::Started) do |op, t|

# Queries get this update
- ThingQuery.new.state(Thing::State.new(:started).value)
+ ThingQuery.new.state(Thing::State::Started)
```
- Update: your `config/env.cr` to this.
```crystal
# Environments are managed using `LuckyEnv`. By default, development, production
# and test are supported.

# If you need additional environment support, add it here
# LuckyEnv.add_env :staging
```
- Update: any use of `Lucky::Env` to use `LuckyEnv`. (e.g. `Lucky::Env.test?` -> `LuckyEnv.test?`). [See PR for details](https://github.com/luckyframework/lucky_cli/pull/655)
- Update: any use of `Lucky::Env.name` to use `LuckyEnv.environment`.
- Update: any use of `route` or `nested_route`, and replace them with the generated routes. Use `lucky routes` to view all generated routes. If you still need this, you can use the [Lucky Legacy Routing](https://github.com/matthewmcgarvey/lucky_legacy_routing) shard.
- Add: the [luckyframework/carbon_sendgrid_adapter](https://github.com/luckyframework/carbon_sendgrid_adapter) shard if you're using Sendgrid to send mail. Be sure to `require "carbon_sendgrid_adapter"` in `config/email.cr`.


### Optional updates

- Update: all routes to use underscore (`_`) instead of dash (`-`) as word separator. Include the `Lucky::EnforceUnderscoredRoute` module in your base actions. (e.g. `/this-route` -> `/this_route`)
```crystal
class BrowserAction < Lucky::Action
  include Lucky::EnforceUnderscoredRoute
  # ...
end
```
- Update: `send_text_response()` responses if you're passing a raw JSON string to use `raw_json()` instead.
- Add: `include Lucky::SecureHeaders::DisableFLoC` to your `BrowserAction` to disable FLoC.
```crystal
class BrowserAction < Lucky::Action
  include Lucky::SecureHeaders::DisableFLoC
  # ...
end
```
- Remove: `normalize-scss` from your `package.json` and replace with `modern-normalize` if you're using `normalize-scss`.
- Update: any query where you write code like `if SomeQuery.new.first?` to `if SomeQuery.new.any?`. `.any?` returns a Bool instead of loading the whole object which has a small performance gain.
- Add: the [Breeze](https://github.com/luckyframework/breeze) shard to your development workflow!


## Upgrading from 0.26 to 0.27

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.26.0&to=0.27.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `">= 0.36.1, < 2.0.0"`
  - Lucky should be `~> 0.27.0`
  - Authentic should be `~> 0.7.3`
  - Carbon should be `~> 0.1.4`
  - Dotenv should be `~> 1.0.0` or replace with [LuckyEnv 0.1.0](https://github.com/luckyframework/lucky_env)
  - LuckyFlow should be `~> 0.7.3`
  - JWT (if you use Auth) should be `~> 1.5.1`
  - LuckyTask needs to be added as a dependency
    ```
    lucky_task:
      github: luckyframework/lucky_task
      version: ~> 0.1.0
    ```

- Run `shards update`

### General updates

- Add: the new `lucky_task` shard as a dependency.
- Update: your `tasks.cr` file with the new require, and module name change:
  ```crystal
  # tasks.cr
  ENV["LUCKY_TASK"] = "true"
  # Load Lucky and the app (actions, models, etc.)
  require "./src/app"
  require "lucky_task"

  require "./tasks/**"
  require "./db/migrations/**"
  require "lucky/tasks/**"

  LuckyTask::Runner.run
  ```
- Update: all tasks in your `tasks/` directory to inherit from `LuckyTask::Task` instead of `LuckyCli::Task`. (e.g. `Db::Seed::RequiredData < LuckyCli::Task` -> `Db::Seed::RequiredData < LuckyTask::Task`)
- Update: your `config/cookies.cr` with a default cookie path of `"/"`.
  ```crystal
  Lucky::CookieJar.configure do |settings|
    settings.on_set = ->(cookie : HTTP::Cookie) {
      # ... other defaults

      # Add this line. See ref: https://github.com/crystal-lang/crystal/pull/10491
      cookie.path("/")
    }
  end
  ```

### Optional updates

- Update: to Crystal 1.0.0. You can continue to use Crystal 0.36.1 if you need.
- Update: `LuckyFlow` to be a `development_dependency`.


## Upgrading from 0.25 to 0.26

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.25.0&to=0.26.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `0.36.1`
  - Lucky should be `~> 0.26.0`
  - Authentic should be `~> 0.7.2`
  - LuckyFlow should be `~> 0.7.2`

- Run `shards update`

### General updates

- Update: your `Procfile` web to point to `./bin/YOUR APP NAME` instead of `./app`. NOTE: this is dependant on how you deploy your app, so only required if you use the heroku_buildpack for Lucky. [read more](https://github.com/luckyframework/lucky_cli/pull/601) and [more](https://github.com/luckyframework/heroku-buildpack-crystal/pull/11)
- Update: any references directly to an `Avram::Attribute(T)` generic. e.g. `Avram::Attribute(String?)` -> `Avram::Attribute(String)`. [read more](https://github.com/luckyframework/avram/pull/586)
- Update: any custom database types to include the class method `adapter` that returns the `Lucky` constant. [read more](https://github.com/luckyframework/avram/pull/587)
- Update: any custom database types to include the class method `criteria(query : T, column) forall T`. [read more](https://github.com/luckyframework/avram/pull/591)
- Remove: any call to `after_completed` in a SaveOperation. The `after_save` and `after_commit` now run even if no change is updated. [read more](https://github.com/luckyframework/avram/pull/612)
- Rename: all `Avram::Box` classes, filenames, and the `spec/support/boxes` directory (sorry 😬) to `Avram::Factory`, etc.... e.g. `UserBox` -> `UserFactory` [read more](https://github.com/luckyframework/avram/pull/614). [view discussion](https://github.com/luckyframework/lucky/discussions/1282)
- Notice: the `Avram::Operation` now avoids calling `run` if there were validation errors in any `before_run`. This may change some of your logic, or create surprised. [read more](https://github.com/luckyframework/avram/pull/621)


### Optional updates

- Update: any calls made in Github CI config to `lucky db.create_required_seeds` to `lucky db.seed.required_data`. [read more](https://github.com/luckyframework/lucky_cli/pull/600)
- Update: any use of `route` or `nested_route` in your actions to explicitly specify the route. This isn't deprecated, yet, but will be in a future version and eventually removed.
- Add: `DB::Log.level = :info` to your `config/log.cr` file to quiet the excessive "Executing query" notices
- Update: your Laravel Mix to version 6. [read more](https://github.com/luckyframework/lucky_cli/pull/592)
- Add: a new migration to have UUID primary keys generated from the database for existing tables. [read more](https://github.com/luckyframework/avram/pull/578)
```crystal
# in a new migration file
def migrate
  enable_extension "pgcrypto"
  execute("ALTER TABLE products ALTER COLUMN id SET DEFAULT gen_random_uuid();")
  execute("ALTER TABLE users ALTER COLUMN id SET DEFAULT gen_random_uuid();")
end
```
- Remove: all calls to `flash.keep` in your actions. [read more](https://github.com/luckyframework/lucky/pull/1374)

## Upgrading from 0.24 to 0.25

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.24.0&to=0.25.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `0.35.1`
  - Lucky should be `~> 0.25.0`
  - Authentic should be `~> 0.7.1`
  - LuckyFlow should be `~> 0.7.1`

- Run `shards update`

### General updates

- Update: all `Avram::Operation` to implement the new interface.
  - Your main instance method should be called `run`
  - The `run` method should return just the value you need. No more `yield self, thing` / `yield self, nil`.
  - Call the operation with `MyOperation.run(params)` instead of `MyOperation.new(params).submit`
  - The `MyOperation.run` class method takes a block that yields the operation, and your return value. Similar to `SaveOperation`.

  ```crystal
  # Before Update
  class RequestPasswordReset < Avram::Operation
    #...
    def submit
      if valid?
        yield self, user
      else
        yield self, nil
      end
    end
  end

  # Use in your Action
  RequestPasswordReset.new(params).submit do |operation, user|
  end

  # After Update
  class RequestPasswordReset < Avram::Operation
    #...
    def run
      if valid?
        user
      else
        nil
      end
    end
  end

  # Use in your Action
  RequestPasswordReset.run(params) do |operation, user|
  end
  ```
- Rename: all usage of `with_defaults` to `tag_defaults`
- Update: query objects to no longer rely on mutating the query.
  ```crystal
  # Before update
  q = UserQuery.new
  q.age.gte(21)
  q.to_sql #=> SELECT * FROM users WHERE age >= 21

  # After update
  q = UserQuery.new
  q.age.gte(21)
  q.to_sql #=> SELECT * FROM users
  ```
- Rename: all usage of `raw_where` to `where`
- Update: query objects that set a default query in the initializer to use the `defaults` method.
  ```crystal
  # Before update
  class UserQuery < User::BaseQuery
    def initialize
      admin(false)
    end
  end

  UserQuery.new.to_sql #=> SELECT * FROM users WHERE admin = false

  # After update
  class UserQuery < User::BaseQuery
    def initialize
      defaults &.admin(false)
    end
  end

  UserQuery.new.to_sql #=> SELECT * FROM users WHERE admin = false
  ```
- Update: any `has_many through` model association to include the new assocation chain.
  ```crystal
  # Before update
  has_many posts : Post
  has_many comments : Comment, through: :posts

  # After update
  # The first in the array is the association you're going through
  # The second is that through's association.
  has_many posts : Post
  has_many comments : Comment, through: [:posts, :comments]
  ```
- Update: any query that used a `where_XXX` on a `belongs_to` from the pluralized name to singularized.
  ```crystal
  # assuming Post belongs_to User

  # Before update
  PostQuery.new.where_users(UserQuery.new)

  # After update
  PostQuery.new.where_user(UserQuery.new) # Notice the 'where_user' is single now
  ```

### Optional updates

- Update: any mention of `DB_URL` that we told you to use should actually be `DATABASE_URL`
- Remove: any include for `include Lucky::Memoizable`. This is now included in `Object` and available everywhere
- Update: HTML tags that display a `UUID` no longer need to cast to String. `link uuid, to: Whatever`
- Remove: any `start_server` or `start_server.dwarf` files in the top-level directory. These are now built to your `bin/`
- Update: `config/email.cr` to include a case for development to print emails.
  ```crystal
  # config/email.cr
  BaseEmail.configure do |settings|
    if Lucky::Env.production?
      # ...
    elsif Lucky::Env.development?
      settings.adapter = Carbon::DevAdapter.new(print_emails: true)
    else
      # ...
    end
  end
  ```
- Update: any `call(io : IO)` method in your tasks, and use the `output` property instead for testing. [read more](https://github.com/luckyframework/lucky_cli/pull/557)
- Update: your `package.json` with all the latest front-end updates. [read more](https://github.com/luckyframework/lucky_cli/pull/553)
- Rename: your seed tasks `tasks/create_required_seeds.cr` -> `tasks/db/seed/required_data.cr`, and `tasks/create_sample_seeds.cr` -> `tasks/db/seed/sample_data.cr`
- Update: `config/log.cr` to silence some of the query logging with `DB::Log.level = :info`.


## Upgrading from 0.23 to 0.24

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.23.0&to=0.24.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `0.35.1`
  - Lucky should be `~> 0.24.0`
  - Authentic should be `~> 0.7.0`

- Run `shards update`

### General updates

- Rename: all instances of the `m` method to `mount`. e.g. `m Shared::Footer, year: 2020` -> `mount Shared::Footer, year: 2020`.
- Update: `config/database.cr` with new `Avram::Credentials`.
```crystal
AppDatabase.configure do |settings|
  if Lucky::Env.production?
    settings.credentials = Avram::Credentials.parse(ENV["DATABASE_URL"])
  else
    settings.credentials = Avram::Credentials.parse?(ENV["DATABASE_URL"]?) || Avram::Credentials.new(
      database: database_name,
      hostname: ENV["DB_HOST"]? || "localhost",
      # NOTE: This was changed from `String` to `Int32`
      port: ENV["DB_PORT"]?.try(&.to_i) || 5432,
      username: ENV["DB_USERNAME"]? || "postgres",
      password: ENV["DB_PASSWORD"]? || "postgres"
    )
  end
end
```
- Rename: all instances of `AppClient` to `ApiClient` in your `spec/` directory.
- Update: `script/setup` with `shards install --ignore-crystal-version`. Alternatively, you can set a global `SHARDS_OPTS=--ignore-crystal-version` environment variable

### Optional updates

- Update: `redirect_back` with `allow_external: true` argument if you need to allow external referers
- Update: your database credentials with the new `query` option to pass query string options
```crystal
# config/database.cr
settings.credentials = Avram::Credentials.new(
  database: database_name,
  hostname: ENV["DB_HOST"]? || "localhost",
  port: ENV["DB_PORT"]?.try(&.to_i) || 5432,
  username: ENV["DB_USERNAME"]? || "postgres",
  password: ENV["DB_PASSWORD"]? || "postgres",
  # This option is new
  query: "initial_pool_size=5&max_pool_size=20"
)
```
- Add: `disable_cookies` to `ApiAction` in `src/actions/api_action.cr`.

## Upgrading from 0.22 to 0.23

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.22.0&to=0.23.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `0.35.0`
  - Lucky should be `~> 0.23.0`
  - Authentic should be `~> 0.6.1`
  - LuckyFlow should be `~> 0.7.0`
  - jwt should be `~> 1.4.2`

- Run `shards update`

### General updates

- Update: `params.get` now strips white space. If you need the raw value, use `params.get_raw`.
- Rename: `mount` to `m` in all pages that use components. **Note: This was reverted in the next version**
- Update: all mounted components to use new signature `mount(MyComponent.new(x: 1, y: 2))` -> `m(MyComponent, x: 1, y:2)`.
- Remove: `Lucky::SessionHandler` and `Lucky::FlashHandler` from `src/app_server.cr`

### Optional updates

- Add: `Avram::RecordNotFoundError` to the `dont_report` array in `src/actions/errors/show.cr`
- Update: `def render(error : Lucky::RouteNotFoundError` to `def render(error : Lucky::RouteNotFoundError | Avram::RecordNotFoundError)` in `src/actions/errors/show.cr`.
- Update: any CLI tasks that use `ARGV` to use the native args [See implementation](https://github.com/luckyframework/lucky_cli/pull/466)


## Upgrading from 0.21 to 0.22

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.21.0&to=0.22.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `0.35.0`
  - Lucky should be `~> 0.22.0`
  - Authentic should be `~> 0.6.0`
  - jwt should be `~> 1.4.2`

- Run `shards update`

## Upgrading from 0.20 to 0.21

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.20.0&to=0.21.0).

- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `0.34.0`
  - Lucky should be `~> 0.21.0`
  - Authentic should be `~> 0.5.4`
  - LuckyFlow should be `~> 0.6.3`

- Run `shards update`

### General updates

- Rename: `config/logger.cr` to `config/log.cr`
- Update: `config/log.cr` to use the new `Log`. [See implementation](https://github.com/luckyframework/lucky_cli/blob/v0.21.0/src/web_app_skeleton/config/log.cr#L1)
- Update: `Procfile.dev` and update the `system_check` to `script/system_check && sleep 100000`.
- Update: all `Lucky.logger.{level}("message")` calls to use the new Crystal Log `Log.{level} { "message" }`
- Remove: the following lines from `config/database.cr`
```crystal
# Uncomment the next line to log all SQL queries
# settings.query_log_level = ::Logger::Severity::DEBUG
```

### Updating `Lucky.logger`

Before this version, you would log data like this:

```crystal
Lucky.logger.debug("Logging some message")
Lucky.logger.info({path: @context.request.path})
```

Now, you would write this like:

```crystal
# Use the Crystal std-lib log for simple String messages
Log.debug { "Logging some message" }

# Use the Dexter extension for logging key/value data
Log.dexter.info { {path: @context.request.path} }
```


## Upgrading from 0.19 to 0.20

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.19.0&to=0.20.0).

- Update `.crystal-version` file to `0.34.0`
- Upgrade to crystal 0.34.0
- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date. Requires 0.34.0
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `0.34.0`
  - Lucky should be `~> 0.20.0`
  - Authentic should be `~> 0.5.2`
  - LuckyFlow should be `~> 0.6.2`
- Run `shards update`

### General updates

- Update: `link` no longer accepts a `String` path or URL, it must be an Action. Change `link()` to an `a` tag with an `href` (`a "Google", href: "https://google.com"`), or use an action class with `link` (`link "Home", to: "/" ` becomes `link("Home", to: Home::Index)`.
- Remove: the `?` from any `needs` using a predicate method. e.g. `needs signed_in? : Bool` -> `needs signed_in : Bool`. Lucky now automatically creates a method ending with `?` for `needs` with a `Bool` type.
- Update: your development `ENV["PORT"]` to be `ENV["DEV_PORT"]` if you need to customize the port your local server is running on.
- Update: all `SaveOperation` classes where a raw hash is being passed in. e.g. `MyOperation.new({"name" => "Gary"})` -> `MyOperation.new(name: "Gary")`, or if you must use a hash, wrap it in params first: `MyOperation.new(Avram::Params.new({"name" => "Gary"})`
- Remove: the `on:` option from `needs` inside every Operation class. e.g. `needs created_by : String, on: :create` -> `needs created_by : String`. You will need to explicitly pass these when calling `new`, `create`, and `update`.


### Optional updates

- Update: all instance variables called from a `needs` on a page or component can now just use the method of that name. e.g. `@current_user` -> `current_user`
- Add: `include Lucky::CatchUnpermittedAttribute` to the `class Shared::Field(T)` in `src/components/shared/field.cr`. This will raise a nicer error if you forget to permit a column in your SaveOperation
- Add: the new `Lucky::RemoteIpHandler.new` to your app handlers in `src/app_server.cr` just before `Lucky::RouteHandler.new`.
- Add: `robots.txt` to your `public/` directory.
  ```
  User-agent: *
  Disallow:
  ```
- Update: `UserSerializer` to inherit from the `BaseSerializer` if it doesn't already.
- Add: `cookie.http_only(true)` to your `config/cookies.cr` file. This goes inside your `settings.on_set` block.
- Update: your node dependencies where needed
- Update: the `setup` script in `script/setup`. [See implementation](https://github.com/luckyframework/lucky_cli/tree/ee7699bddde50b80e495a89edb442b754f627239/src/web_app_skeleton/script/setup.ecr). Be sure to remove the ECR tags.
- Add: this line `system_check: script/system_check && $SHELL` to your `Procfile.dev`
- Add: the new `system_check` script in `script/system_check`. Note: you may need to `chmod +x script/system_check`. [See implementation](https://github.com/luckyframework/lucky_cli/tree/ee7699bddde50b80e495a89edb442b754f627239/src/web_app_skeleton/script/system_check.ecr). Be sure to remove the ECR tags.
- Add: the new `function_helpers` script in `script/helpers/function_helpers`. [See implementation](https://github.com/luckyframework/lucky_cli/tree/ee7699bddde50b80e495a89edb442b754f627239/src/web_app_skeleton/script/helpers/function_helpers)
- Add: the new `text_helpers` script in `script/helpers/text_helpers`. [See implementation](https://github.com/luckyframework/lucky_cli/tree/ee7699bddde50b80e495a89edb442b754f627239/src/web_app_skeleton/script/helpers/text_helpers)


## Upgrading from 0.18 to 0.19

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.18.0&to=0.19.0).

- Update `.crystal-version` file to `0.33.0`
- Upgrade to crystal 0.33.0
- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date. Requires 0.33.0
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Crystal should be `0.33.0`
  - Lucky should be `~> 0.19.0`
  - Authentic should be `~> 0.5.1`
  - LuckyFlow should be `~> 0.6.2`
- Run `shards update`

### Recommended (but optional) changes


#### GZip static assets

* [Add the compression plugin](https://github.com/luckyframework/lucky_cli/commit/8bc002ab51cb13e67f515c4de977766f96825a18#diff-73db280623fcd1a64ac1ab76c8700dbc) to `package.json`
* Make [these changes](https://github.com/luckyframework/lucky_cli/commit/8bc002ab51cb13e67f515c4de977766f96825a18#diff-cd19e42e70bfbcf2a12480b0b6b1f590)
  to your `webpack.mix.js` file
* In `src/app_server.cr` add `Lucky::StaticCompressionHandler.new("./public", file_ext: "gz", content_encoding: "gzip")` above the `Lucky::StaticFileHandler.new`.

#### GZip text responses

* Make [these changes](https://github.com/luckyframework/lucky_cli/commit/8bc002ab51cb13e67f515c4de977766f96825a18#diff-83ca1a783e82ef6f0d38f400b7c1eaa1) to `config/server.cr` to gzip text responses.

## Upgrading from 0.17 to 0.18

For a full diff of necessary changes, please see [LuckyDiff](https://luckydiff.com?from=0.17.0&to=0.18.0).

- Upgrade to crystal 0.31.1
- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date. Requires 0.31.1
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update `.crystal-version` to `0.31.1`

- Update versions in `shard.yml`
  - Crystal should be `0.31.1`
  - Lucky should be `~> 0.18`
  - Authentic should be `~> 0.5.0`
  - LuckyFlow should be `~> 0.6.0`
- Run `shards update`

### General updates

- Rename: all `render` calls in actions to `html`.
- Update: the `src/actions/errors/show.cr` file to the new format:

  ```crystal
  class Errors::Show < Lucky::ErrorAction
    DEFAULT_MESSAGE = "Something went wrong."
    default_format :html
    dont_report [Lucky::RouteNotFoundError]

    def render(error : Lucky::RouteNotFoundError)
      if html?
        error_html "Sorry, we couldn't find that page.", status: 404
      else
        error_json "Not found", status: 404
      end
    end

    # When the request is JSON and an InvalidOperationError is raised, show a
    # helpful error with the param that is invalid, and what was wrong with it.
    def render(error : Avram::InvalidOperationError)
      if html?
        error_html DEFAULT_MESSAGE, status: 500
      else
        error_json \
          message: error.renderable_message,
          details: error.renderable_details,
          param: error.invalid_attribute_name,
          status: 400
      end
    end

    # Always keep this below other 'render' methods or it may override your
    # custom 'render' methods.
    def render(error : Lucky::RenderableError)
      if html?
        error_html DEFAULT_MESSAGE, status: error.renderable_status
      else
        error_json error.renderable_message, status: error.renderable_status
      end
    end

    # If none of the 'render' methods return a response for the raised Exception,
    # Lucky will use this method.
    def default_render(error : Exception) : Lucky::Response
      if html?
        error_html DEFAULT_MESSAGE, status: 500
      else
        error_json DEFAULT_MESSAGE, status: 500
      end
    end

    private def error_html(message : String, status : Int)
      context.response.status_code = status
      html Errors::ShowPage, message: message, status: status
    end

    private def error_json(message : String, status : Int, details = nil, param = nil)
      json ErrorSerializer.new(message: message, details: details, param: param), status: status
    end

    private def report(error : Exception) : Nil
      # Send to Rollbar, send an email, etc.
    end
  end
  ```

- Rename: `title` to `message` in `src/pages/errors/show_page.cr`.
- Add: `BaseSerializer` to `src/serializers/`.

  ```crystal
  abstract class BaseSerializer < Lucky::Serializer
    def self.for_collection(collection : Enumerable, *args, **named_args)
      collection.map do |object|
        new(object, *args, **named_args)
      end
    end
  end
  ```

- Add: `require "./serializers/base_serializer"` to your `src/app.cr` above `require "./serializers/**"`
- Optional: Update all serializers to inherit from `BaseSerializer`. Also merge Show/Index serializers in to a single class.

  ```crystal
  # Merge these two classes
  class Users::IndexSerializer < Lucky::Serializer
  end

  class Users::ShowSerializers < Lucky::Serializer
  end

  # in to this class
  class UserSerializer < BaseSerializer
    # Same contents as Users::ShowSerializer
    # Calls to Users::IndexSerializer now become:
    #
    #    UserSerializer.for_collection(users)
  end
  ```

- Rename: `Errors::ShowSerializer` to `ErrorSerializer`
- Update: `ErrorSerializer` to inherit from the new `BaseSerializer`
- Update: `ErrorSerializer` contents with:

  ```crystal
  class ErrorSerializer < BaseSerializer
    def initialize(
      @message : String,
      @details : String? = nil,
      @param : String? = nil # If there was a problem with a specific param
    )
    end

    def render
      {message: @message, param: @param, details: @details}
    end
  end

  ```
- Add: `Avram::SchemaEnforcer.ensure_correct_column_mappings!` to `src/start_server.cr` below `Avram::Migrator::Runner.new.ensure_migrated!`.
- Update: any mention to renamed errors in [this commit](https://github.com/luckyframework/lucky/pull/911/files#diff-02d01a64649367eb50f82f303c2d07e2R248). You can likely ignore this as most people do not rescue these specific errors.
- Add: `accepted_formats [:json]` to `ApiAction` in `src/actions/api_action.cr`.

  ```crystal
  abstract class ApiAction < Lucky::Action
    accepted_formats [:json]
  end
  ```

- Add: `accepted_formats [:html, :json], default: :html` to `BrowserAction` in `src/actions/browser_action.cr`

  ```crystal
  abstract class BrowserAction < Lucky::Action
    accepted_formats [:html, :json], default: :html
  end
  ```

- Update: `src/app_server.cr` with explicit return type on the `middleware` method.
```crystal
# Add return type here
def middleware : Array(HTTP::Handler)
  [
    # ...
  ] of HTTP::Handler # Add this or app will fail to compile
end
```

- Add: `include Lucky::RequestExpectations` to `spec/spec_helper.cr` below `include Carbon::Expectations`
- Add: `Avram::SchemaEnforcer.ensure_correct_column_mappings!` to `spec/spec_helper.cr` below `Avram::Migrator::Runner.new.ensure_migrated!`
- Update: Change `at_exit do` in `spec/setup/start_app_server.cr` to `Spec.after_suite do`

## Upgrading from 0.16 to 0.17

- Ensure you've upgraded to crystal 0.30.1
- Upgrade Lucky CLI (homebrew)

```
brew update
brew upgrade crystal-lang # Make sure you're up-to-date. Requires 0.30.1
brew upgrade lucky
```

- Upgrade Lucky CLI (Linux)

- Update `.crystal-version` to `0.30.1`

> Remove the existing Lucky binary and follow the Linux
> instructions in this section
> https://luckyframework.org/guides/getting-started/installing#on-linux

- Update versions in `shard.yml`
  - Lucky should be `~> 0.17`
- Run `shards update`

### Example upgrade

If you're not sure about an upgrade step, or simply want to look at an example, see the [lucky_bits upgrade](https://github.com/edwardloveall/lucky_bits/commit/47473a19084f1781062ce3767e3fbcf527c11e4d).

### General updates
- Rename: Action rendering method `text` to `plain_text`.
- Update: use of `number_to_currency` now returns a String instead of writing to the view directly.
- Delete: `config/static_file_handler.cr`.
- Add: a new `Lucky::LogHandler` configure to the bottom of `config/logger.cr`.
- Update: `Avram::Repo.configure` to `Avram.configure` in `config/logger.cr`.
<details>
  <summary>config/logger.cr</summary>

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
      # If you want logs like in development use `Lucky::PrettyLogFormatter`.
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

  Lucky::LogHandler.configure do |settings|
    # Skip logging static assets in development
    if Lucky::Env.development?
      settings.skip_if = ->(context : HTTP::Server::Context) {
        context.request.method.downcase == "get" &&
        context.request.resource.starts_with?(/\/css\/|\/js\/|\/assets\//)
      }
    end
  end

  Avram.configure do |settings|
    settings.logger = logger
  end
  ```
</details>

- Update: `script/setup` to include the new postgres checks.

```diff
# This must go *after* the 'shards install' step
+ printf "\n▸ Checking that postgres is installed\n"
+ check_postgres | indent
+ printf "✔ Done\n" | indent

+ printf "\n▸ Verifying postgres connection\n"
+ lucky db.verify_connection | indent

printf "\n▸ Setting up the database\n"
lucky db.create | indent
```

### Database updates
- Add: a new `AppDatabase` class in `src/app_database.cr` that inherits from `Avram::Database`.

```crystal
class AppDatabase < Avram::Database
end
```

- Add: `require "./app_database"` to `src/app.cr` right below the `require "./shards"`.
- Rename: `Avram::Repo.configure` to `AppDatabase.configure` in `config/database.cr`.
- Add: `Avram.configure` block.
<details>
  <summary>config/database.cr</summary>

  ```crystal
  database_name = "..."

  AppDatabase.configure do |settings|
    if Lucky::Env.production?
      settings.url = ENV.fetch("DATABASE_URL")
    else
      settings.url = ENV["DATABASE_URL"]? || Avram::PostgresURL.build(
        database: database_name,
        hostname: ENV["DB_HOST"]? || "localhost",
        # Some common usernames are "postgres", "root", or your system username (run 'whoami')
        username: ENV["DB_USERNAME"]? || "postgres",
        # Some Postgres installations require no password. Use "" if that is the case.
        password: ENV["DB_PASSWORD"]? || "postgres"
      )
    end
  end

  Avram.configure do |settings|
    settings.database_to_migrate = AppDatabase

    # this is moved from your old `Avram::Repo.configure` block.
    settings.lazy_load_enabled = Lucky::Env.production?
  end
  ```
</details>

- Move: the `settings.lazy_load_enabled` from `AppDatabase.configure` to `Avram.configure` block.
- Add: a `database` class method to `src/models/base_model.cr` that returns `AppDatabase`.
```crystal
abstract class BaseModel < Avram::Model
  def self.database : Avram::Database.class
    AppDatabase
  end
end
```
- Update: `Avram::Repo` to `AppDatabase` in `spec/setup/clean_database.cr`.
- Avram no longer automatically adds a timestamp and primary key to migrations.
  Add a primary key and timestamps to your old migrations.

  > Also note that the syntax for a UUID has changed. You use
  > `primary_key id : UUID` instead of an option on 'create'

  ```crystal
  def migrate
    create :users do
      # Add these to your 'create' statements in your migrations
      primary_key id : Int64 # Or 'UUID' if using UUID
      add_timestamps
    end
  end
  ```

- Note: Avram now defaults primary keys to `Int64` instead of `Int32`. You
can use the `change_type` macro to migrate your **primary keys and foreign keys**
to `Int64` if you need. Run `lucky gen.migration UpdatePrimaryKeyTypes`.
```crystal
class UpdatePrimaryKeyTypesV20190723233131 < Avram::Migrator::Migration::V1
  def migrate
    alter table_for(User) do
      change_type id : Int64
    end
    alter table_for(Post) do
      change_type id : Int64
      change_type user_id : Int64
    end
  end
end
```
- Update: models now default the primary key to `Int64`. This can be
overridden if your tables uses a different column type for your primary keys,
such as Int32 or UUID

```crystal
abstract class BaseModel < Avram::Model
  macro default_columns
    primary_key id : UUID
    timestamps
  end
end
```

This also means that any model that uses `UUID` for a primary key can remove the `primary_key_type` option

```crystal
class User < BaseModel
  # 0.16 and earlier
  table :users, primary_key_type: :uuid do
    column email : String
  end

  # Now with 0.17 it will use the 'default_columns' from the 'BaseModel'
  table :users do
    column email : String
  end
end
```

### Updating queries
- Rename: `Query.new.destroy_all` to `Query.truncate`. (e.g. `UserQuery.new.destroy_all` => `UserQuery.truncate`)
- Rename: all association query methods from the association name to `where_{association_name}`. (e.g. `UserQuery.new.posts` => `UserQuery.new.where_posts`)
- Update: all association query methods no longer take a block. Pass the query in as an argument. (e.g. `UserQuery.new.posts { |post_query| }` => `UserQuery.new.where_posts(PostQuery.new)`)
- Update: `where_{association_name}` methods no longer need to be preceded by a `join_{assoc}`, unless you need a custom join (i.e. `left_join_{assoc}`). If you use a custom join, you will need to add the `auto_inner_join: false` option to your `where_{assoc}` method.

### Moving forms to operations
- Rename: the `src/forms` directory to `src/operations`.
- Update: `require "./forms/mixins/**"` and `require "./forms/**"` to `require "./operations/mixins/**"` and `require "./operations/**"` respectively in `src/app.cr`
- Rename: `BaseForm` to `SaveOperation` in `src/operations`. (e.g. `User::BaseForm` => `User::SaveOperation`)
- Rename: `fillable` to `permit_columns`
- Rename: form class names to new naming convention. (e.g. `class UserForm < User::SaveOperation` => `class SaveUser < User::SaveOperation`). This step is optional, but still recommended to avoid future confusion.
- Rename: `Avram::VirtualForm` to `Avram::Operation`.
- Rename: virtual form class names to new naming convention VerbNoun. (e.g. `class SignInForm < Avram::Operation` => `class SignInUser < Avram::Operation`).
- Rename: `virtual` to `attribute`.
- Update: all `SaveOperation` classes to call `before_save prepare`. The `prepare` method is no longer called by default, which allows you to rename this method as well.
- Update: `FillableField` to `PermittedAttribute` in `src/components/shared/`. Check `field.cr` and `field_errors.cr`.
- Update: all authentic classes and modules to use new operation setup. This may require renaming some files to fit the `VerbNoun` `verb_noun.cr` convention.
<details>
  <summary>Files in src/operations/</summary>

  ```diff
  # src/operations/mixins/password_validations.cr
  module PasswordValidations
  +  macro included
  +    before_save run_password_validations
  +  end
    #...
  end


  # src/operations/request_password_reset.cr
  - class RequestPasswordReset < Avram::VirtualForm
  + class RequestPasswordReset < Avram::Operation
    #...
  end


  # src/operations/reset_password.cr
  - def prepare
  -   run_password_validations
  + before do
      Authentic.copy_and_encrypt password, to: encrypted_password


  # src/operations/sign_in_user.cr
  - class SignInUser < Avram::VirtualOperation
  + class SignInUser < Avram::Operation


  # src/operations/sign_up_user.cr
  - def prepare
  + before_save do
      validate_uniqueness_of email
  -   run_password_validations
  ```
</details>

- Update `sign_in_user.cr` to match [the new template](https://github.com/luckyframework/lucky_cli/blob/c45e1860751bba25a16120402f93e7537c0be5b5/src/base_authentication_app_skeleton/src/operations/sign_in_user.cr).
- Rename the `FindAuthenticatable` mixin to `UserFromEmail`, again the Lucky CLI [template](https://github.com/luckyframework/lucky_cli/blob/c45e1860751bba25a16120402f93e7537c0be5b5/src/base_authentication_app_skeleton/src/operations/mixins/user_from_email.cr) is a helpful guide.

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
    # If you want logs like in development use `Lucky::PrettyLogFormatter`.
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

This is used for serializing errors to JSON. Add this to
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
