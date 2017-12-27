### Upgrading from 0.6 to 0.7

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
