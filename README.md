[![github banner-short](https://user-images.githubusercontent.com/22394/26989908-dd99cc2c-4d22-11e7-9576-c6aeada2bd63.png)](http://luckyframework.org)

[![Version](https://img.shields.io/github/tag/luckyframework/lucky.svg?maxAge=360&label=version)](https://github.com/luckyframework/lucky/releases/latest)
[![License](https://img.shields.io/github/license/luckyframework/lucky.svg)](https://github.com/luckyframework/lucky/blob/main/LICENSE)

[![API Documentation Website](https://img.shields.io/website?down_color=red&down_message=Offline&label=API%20Documentation&up_message=Online&url=https%3A%2F%2Fluckyframework.github.io%2Flucky%2F)](https://luckyframework.github.io/lucky)
[![Lucky Guides Website](https://img.shields.io/website?down_color=red&down_message=Offline&label=Lucky%20Guides&up_message=Online&url=https%3A%2F%2Fluckyframework.org%2Fguides)](https://luckyframework.org/guides)

[![Discord](https://img.shields.io/discord/743896265057632256)](https://discord.gg/HeqJUcb)

The goal: prevent bugs, forget about most performance issues, and spend more
time on code instead of debugging and fixing tests.

In summary, make writing stunning web applications fast, fun, and easy.

## Coming from Rails?

- [Ruby on Rails to Lucky on Crystal: Blazing fast, fewer bugs, and even more fun.
  ](https://hackernoon.com/ruby-on-rails-to-lucky-on-crystal-blazing-fast-fewer-bugs-and-even-more-fun-104010913fec)

## Try Lucky

Lucky has a [fresh new set of guides](https://luckyframework.org/guides/) that
make it easy to get started.

Feel free to say hi or ask questions on our
[chat room](https://luckyframework.org/chat).

Or you can copy a real working app with [Lucky JumpStart](https://github.com/stephendolan/lucky_jumpstart/).

## Installing Lucky

To install Lucky, read the [Installing Lucky](https://luckyframework.org/guides/getting-started/installing) guides for your Operating System.
The guide will walk you through installing a command-line utility used for generating new Lucky applications.

## Keep up-to-date

Keep up to date by following [@luckyframework](https://twitter.com/luckyframework) on Twitter.

## Documentation

[API (main)](https://luckyframework.github.io/lucky/)

## What's it look like?

### JSON endpoint:

```crystal
class Api::Users::Show < ApiAction
  get "/api/users/:user_id" do
    user = UserQuery.find(user_id)
    json UserSerializer.new(user)
  end
end
```

- If you want you can set up custom routes like `get "/sign_in"` for non REST routes.
- A `user_id` method is generated because there is a `user_id` route parameter.
- Use `json` to render JSON. [Extract
  serializers](https://luckyframework.org/guides/writing-json-apis/#respond-with-json)
  for reusable JSON responses.

### Database models

```crystal
# Set up the model
class User < BaseModel
  table do
    column last_active_at : Time
    column last_name : String
    column nickname : String?
  end
end
```

- Sets up the columns that you’d like to use, along with their types
- You can add `?` to the type when the column can be `nil` . Crystal will then
  help you remember not to call methods on it that won't work.
- Lucky will set up presence validations for required fields
  (`last_active_at` and `last_name` since they are not marked as nilable).

### Querying the database

```crystal
# Add some methods to help query the database
class UserQuery < User::BaseQuery
  def recently_active
    last_active_at.gt(1.week.ago)
  end

  def sorted_by_last_name
    last_name.lower.desc_order
  end
end

# Query the database
UserQuery.new.recently_active.sorted_by_last_name
```

- `User::BaseQuery` is automatically generated when you define a model. Inherit
  from it to customize queries.
- Set up named scopes with instance methods.
- Lucky sets up methods for all the columns so that if you mistype a column
  name it will tell you at compile-time.
- Use the `lower` method on a `String` column to make sure Postgres sorts
  everything in lowercase.
- Use `gt` to get users last active greater than 1 week ago. Lucky has lots
  of powerful abstractions for creating complex queries, and type specific
  methods (like `lower`).

### Rendering HTML:

```crystal
class Users::Index < BrowserAction
  get "/users" do
    users = UserQuery.new.sorted_by_last_name
    render IndexPage, users: users
  end
end

class Users::IndexPage < MainLayout
  needs users : UserQuery

  def content
    render_new_user_button
    render_user_list
  end

  private def render_new_user_button
    link "New User", to: Users::New
  end

  private def render_user_list
    ul class: "user-list" do
      users.each do |user|
        li do
          link user.name, to: Users::Show.with(user.id)
          text " - "
          text user.nickname || "No Nickname"
        end
      end
    end
  end
end
```

- `needs users : UserQuery` tells the compiler that it must be passed users
  of the type `UserQuery`.
- If you forget to pass something that a page needs, it will let you know at
  compile time. **Fewer bugs and faster debugging**.
- Write tags with Crystal methods. Tags are automatically closed and
  whitespace is removed.
- Easily extract named methods since pages are made of regular classes and
  methods. **This makes your HTML pages incredibly easy to read.**
- Link to other pages with ease. Just use the action name: `Users::New`. Pass
  params using `with`: `Users::Show.with(user.id)`. No more trying to remember path
  helpers and whether the helper is pluralized or not - If you forget to pass a
  param to a route, Lucky will let you know at compile-time.
- Since we defined `column nickname : String?` as nilable, Lucky would fail
  to compile the page if you just did `text user.nickname` since it disallows
  printing `nil`. So instead we add a fallback `"No Nickname"`. **No more
  accidentally printing empty text in HTML!**

## Testing

You need to make sure to install the Crystal dependencies.

1. Run `shards install`
1. Run `crystal spec` from the project root.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

### Lucky to have you!

We love all of the community members that have put in hard work to make Lucky better.
If you're one of those people, we want to give you a t-shirt!

To get a shirt, we ask that you have made a significant contribution to Lucky.
This includes things like submitting PRs with bug fixes and feature implementations, helping other members
work through problems, and deploying real world applications using Lucky!

To claim your shirt, [fill in this form](https://forms.gle/w3PJ4pww8WDAuJov5).

## Contributors

- [paulcsmith](https://github.com/paulcsmith) Paul Smith - creator, maintainer
- [Our wonderful community](https://github.com/luckyframework/lucky/graphs/contributors) - ❤️

## Thanks & attributions

- SessionHandler, CookieHandler and FlashHandler are based on [Amber](https://github.com/amberframework/amber). Thank you to the Amber team!
- Thanks to Rails for inspiring many of the ideas that are easy to take for
  granted. Convention over configuration, removing boilerplate, and most
  importantly - focusing on developer happiness.
- Thanks to Phoenix, Ecto and Elixir for inspiring Avram's save operations,
  Lucky's single base actions and pipes, and focusing on helpful error
  messages.
- `lucky watch` based heavily on [Sentry](https://github.com/samueleaton/sentry). Thanks [@samueleaton](https://github.com/samueleaton)!
