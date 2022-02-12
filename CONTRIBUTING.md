# Contributing to Lucky

We love pull requests from everyone. By participating in this project, you
agree to abide by the project [code of conduct].

[code of conduct]: https://github.com/luckyframework/lucky/blob/main/CODE_OF_CONDUCT.md

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code ( **no patch is too small** : fix typos, add comments, clean up inconsistent whitespace )
* by refactoring code
* by closing [issues][]
* by reviewing patches

[issues]: https://github.com/luckyframework/lucky/issues

## Submitting an Issue

* We use the [GitHub issue tracker][issues] to track bugs and features.
* Before submitting a bug report or feature request, check to make sure it hasn't
already been submitted.
* When submitting a bug report, please include a [Gist][] that includes a stack
  trace and any details that may be necessary to reproduce the bug, including
  your Crystal version, and operating system.  Ideally, a bug report
  should include a pull request with failing specs.

[gist]: https://gist.github.com/

## Cleaning Up Issues

* Issues that have no response from the submitter will be closed after 30 days.
* Issues will be closed once they're assumed to be fixed or answered. If the
  maintainer is wrong, it can be opened again.
* If your issue is closed by mistake, please understand and explain the issue.
  We will happily reopen the issue.

## Setting Up Local Environment

1. Fork it ( https://github.com/luckyframework/lucky/fork )
1. Create your feature branch (git checkout -b my-new-feature)
1. Install docker and docker-compose: https://docs.docker.com/compose/install/
1. Run `script/setup` to build the Docker containers with everything you need.
1. Make your changes
1. Make sure specs pass: `script/test`.
1. Add a note to the CHANGELOG
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create a new Pull Request

> Run specific tests with `script/test <path_to_spec>`

## Submitting a Pull Request
1. [Fork][fork] the [official repository][repo].
2. [Create a topic branch.][branch]
3. Implement your feature or bug fix.
4. Add, commit, and push your changes.
5. [Submit a pull request.][pr]

## Notes
* Please add tests if you changed code. Contributions without tests won't be accepted.
* If you don't know how to add tests, please put in a PR and leave a comment
  asking for help. We love helping!
* Please don't update the Gem version.

[repo]: https://github.com/luckyframework/lucky/
[fork]: https://help.github.com/articles/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/
[pr]: https://help.github.com/articles/using-pull-requests/

Inspired by https://github.com/middleman/middleman-heroku/blob/master/CONTRIBUTING.md
