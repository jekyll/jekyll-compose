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
  rename     # Moves a draft to a given NAME and sets the title
  compose    # Creates a new file with the given NAME
```

Create your new page using:

```sh
    $ bundle exec jekyll page "My New Page"
```

Create your new post using:

```sh
    $ bundle exec jekyll post "My New Post"
    # or specify a custom format for the date attribute in the yaml front matter
    $ bundle exec jekyll post "My New Post" --timestamp-format "%Y-%m-%d %H:%M:%S %z"
```

```sh
    # or by using the compose command
    $ bundle exec jekyll compose "My New Post"
```

```sh
    # or by using the compose command with post specified
    $ bundle exec jekyll compose "My New Post" --post
```

```sh
    # or by using the compose command with the posts collection specified
    $ bundle exec jekyll compose "My New Post" --collection "posts"
```

Create your new draft using:

```sh
    $ bundle exec jekyll draft "My new draft"
```

```sh
    # or by using the compose command with draft specified
    $ bundle exec jekyll compose "My new draft" --draft
```

```sh
    # or by using the compose command with the drafts collection specified
    $ bundle exec jekyll compose "My new draft" --collection "drafts"
```

Rename your draft using:

```sh
$ bundle exec jekyll rename _drafts/my-new-draft.md "My Renamed Draft"
```

```sh
# or rename it back
$ bundle exec jekyll rename _drafts/my-renamed-draft.md "My new draft"
```

Publish your draft using:

```sh
    $ bundle exec jekyll publish _drafts/my-new-draft.md
```

```sh
    # or specify a specific date on which to publish it
    $ bundle exec jekyll publish _drafts/my-new-draft.md --date 2014-01-24
    # or specify a custom format for the date attribute in the yaml front matter
    $ bundle exec jekyll publish _drafts/my-new-draft.md --timestamp-format "%Y-%m-%d %H:%M:%S %z"
```

Rename your post using:

```sh
$ bundle exec jekyll rename _posts/2014-01-24-my-new-draft.md "My New Post"
```

```sh
# or specify a specific date
$ bundle exec jekyll rename _posts/2014-01-24-my-new-post.md "My Old Post" --date "2012-03-04"
```

```sh
# or specify the current date
$ bundle exec jekyll rename _posts/2012-03-04-my-old-post.md "My New Post" --now
```

Unpublish your post using:

```sh
    $ bundle exec jekyll unpublish _posts/2014-01-24-my-new-draft.md
```

Create your new file in a collection using:

```sh
    $ bundle exec jekyll compose "My New Thing" --collection "things"
```

## Configuration

To customize the default plugin configuration edit the `jekyll_compose` section within your jekyll config file.

### auto-open new drafts or posts in your editor

```yaml
  jekyll_compose:
    auto_open: true
```

and make sure that you have `EDITOR`, `VISUAL` or `JEKYLL_EDITOR` environment variable set.
For instance if you wish to open newly created Jekyll posts and drafts in Atom editor you can add the following line in your shell configuration:
```sh
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
 - The creation timestamp under the `date` attribute.
 - The title attribute under the `title` attribute


For collections, you can add default front matter to newly created collection files using `default_front_matter` and the collection name as a config key, for instance for the collection `things`:

```yaml
jekyll_compose:
  default_front_matter:
    things:
      description:
      image:
      category:
      tags:
```

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
