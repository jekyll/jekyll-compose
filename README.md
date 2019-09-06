# Jekyll::Compose

Streamline your writing in Jekyll with some commands.

[![Linux Build Status](https://img.shields.io/travis/jekyll/jekyll-compose/master.svg?label=Linux%20build)][travis]
[![Windows Build status](https://img.shields.io/appveyor/ci/jekyll/jekyll-compose/master.svg?label=Windows%20build)][appveyor]

[travis]: https://travis-ci.org/jekyll/jekyll-compose
[appveyor]: https://ci.appveyor.com/project/jekyll/jekyll-compose

## Installation

Add this line to your application's Gemfile:

    gem 'jekyll-compose', group: [:jekyll_plugins]

And then execute:

    $ bundle

## Usage

After you have installed (see above), run `bundle exec jekyll help` and you should see:

Listed in help you will see new commands available to you:

```sh
  draft      # Creates a new draft post with the given NAME
  post       # Creates a new post with the given NAME
  publish    # Moves a draft into the _posts directory and sets the date
  unpublish  # Moves a post back into the _drafts directory
  page       # Creates a new page with the given NAME
```

Create your new page using:

    $ bundle exec jekyll page "My New Page"

Create your new post using:

    $ bundle exec jekyll post "My New Post"

Create your new draft using:

    $ bundle exec jekyll draft "My new draft"

Publish your draft using:

    $ bundle exec jekyll publish _drafts/my-new-draft.md
    # or specify a specific date on which to publish it
    $ bundle exec jekyll publish _drafts/my-new-draft.md --date 2014-01-24

Unpublish your post using:

    $ bundle exec jekyll unpublish _posts/2014-01-24-my-new-draft.md

## Configuration

To customize the default plugin configuration edit the `jekyll_compose` section within your jekyll config file.

### auto-open new drafts or posts in your editor

```yaml
  jekyll_compose:
    auto_open: true
```

and make sure that you have `EDITOR`, `VISUAL` or `JEKYLL_EDITOR` environment variable set.
For instance if you wish to open newly created Jekyll posts and drafts in Atom editor you can add the following line in your shell configuration:
```
export JEKYLL_EDITOR=atom
```

`JEKYLL_EDITOR` will override default `EDITOR` or `VISUAL` value.
`VISUAL` will override default `EDITOR` value.

### Set default front matter for drafts and posts

If you wish to add default front matter to newly created posts or drafts, you can specify as many as you want under `default_front_matter` config keys, for instance:

```yaml
jekyll_compose:
  default_front_matter:
    drafts:
      description:
      image:
      category:
      tags:
    posts:
      description:
      image:
      category:
      tags:
      published: false
      sitemap: false
```

This will also auto add:
 - The creation timestamp under the `date` attribure.
 - The title attribute under the `title` attribute

## Contributing

1. Fork it ( http://github.com/jekyll/jekyll-compose/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the specs and our linter (`script/cibuild`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

### Submitting a Pull Request based on an existing proposal

When submitting a pull request that uses code from an unmerged pull request, please be aware of the following:
  * Changes proposed in the older pull request is still the original author's property. Moving forward from where they left it
    means that you're a `co-author`.
  * GitHub allows attributing
    [credit to multiple authors](https://help.github.com/en/articles/creating-a-commit-with-multiple-authors)
    However, pull requests in this project are automatically squashed and then merged onto the base branch. So, only authors and
    co-authors of the opening commit gets credit once the pull request gets merged.
  * If the original pull request contained multiple commits, you may squash them into a single commit but ensure that you list
    any additional authors (and yourselves) as co-authors of that commit.
  * Use appropriate [keywords](https://help.github.com/en/articles/closing-issues-using-keywords) in your pull request post to
    link to the existing pull request or issue-ticket so that they're automatically closed when your pull request gets merged.
