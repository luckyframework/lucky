### Upgrading from 0.6 to 0.7

* Update to Crystal v0.24.1. Lucky will fail on earlier versions

```
brew upgrade crystal-lang
brew upgrade lucky
```

If you are on Linux, remove the existing Lucky binary and follow the Linux instructions in this section: https://luckyframework.org/guides/installing/#install-lucky

* Update `shard.yml`

```yml
dependencies:
  lucky:
    github: luckyframework/lucky
    version: "~> 0.7.0"
```

Then run `shards update`

* Configure the domain to use for the RouteHelper:

```crystal
# Add to src/config/route_helper.cr
Lucky::RouteHelper.configure do
  if Lucky::Env.production?
    # The APP_DOMAIN is something like https://myapp.com
    settings.domain = ENV.fetch("APP_DOMAIN")
  else
    settings.domain = "http:://localhost:3001"
  end
end
```

* Add `csrf_meta_tags` to your `MainLayout`

```crystal
# src/pages/main_layout.cr
# Somewhere in the head tag:
csrf_meta_tags
```

* Remove `needs flash` from MainLayout

```crystal
# Delete this line
needs flash : Lucky::Flash::Store
```

* Change `Shared::FlashComponent` to get the flash from `@context`

```crystal
# src/components/shared/flash_component.cr
# Change this:
@flash.each
# To:
@context.flash.each
```
