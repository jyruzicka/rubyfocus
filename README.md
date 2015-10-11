Rubyfocus is a one-way (read-only) ruby bridge to OmniFocus. Analyse, store, inspect, or play with your projects and tasks in OmniFocus from the comfort and flexibility of ruby!

# Installation

Rubyfocus is a ruby gem. It's not currently hosted on rubygems, though, so you'll have to download and install locally.

## Via git

First download rubyfocus to your computer:

```
git clone https://github.com/jyruzicka/rubyfocus.git
```

Now build and install it!

```
gem build rubyfocus.gemspec
gem install rubyfocus-0.1.0.gem
```

# Usage

## Getting set up

To create a new database from your local OmniFocus install:

```ruby
require "rubyfocus"

f = Rubyfocus::LocalFetcher.new # This class lets you access a local OmniFocus install
d = Rubyfocus::Document.new(f)  # This is how we create a document linked up to a local fetcher

d.update                        # This is how we get the document to update using its built-in fetcher

d.save("ofocus.yml")            # Save the whole database to yaml!
```

To open it up again, it's even easier:

```ruby
require "rubyfocus"

d = Rubyfocus::Document.load_from_file("ofocus.yml")   # Your document will remember everything
d.update                                               # Updates it against the local cache, in case you made changes
```

## Grabbing data

How do you access all that lovely data? Easy!

```ruby
d.projects
d.tasks
d.contexts
d.folders
```

And if you want to select a certain project's tasks:

```ruby
d.projects.first.tasks
```

What if you want to select only certain projects? Sure, you can use standard `Array#find` or `Array#select` methods, but you can also make use of a hash of values:

```
d.projects.select(name: "Sample project")
```

Once you have your objects, you can query them for more information:

```
t = d.tasks.first
t.name # => "Sample task"
t.project.name # => "Sample project"
t.deferred? # => true/false
t.start # => Time or nil
```

# Behind the scenes

OmniFocus stores its data as a "base" XML file plus a series of "patches". These are all stored as zip files inside an ".ofocus" package. This means that you can have several different devices, all storing the OmniFocus task database at different states, and each one can easily update its database by comparing the various patches against its own database and downloading/applying only what's needed.

Rubyfocus makes use of this by fetching and reading OmniFocus' local store on your machine. As long as your local OmniFocus is up to date, `rubyfocus` will be able to fetch the database in its latest state.

# Further work

`rubyfocus` is a work in progress. In the near future I hope to release a more comprehensive document detailing exactly which details of OmniFocus' projects and tasks are available to the user, and what you can do with them.

Other goals include:

* Updating via the [Omni Sync Server](https://manage.sync.omnigroup.com/) rather than relying on local files.
* A couple of example projects using rubyfocus

# History

## 0.2.0 // 2015-10-11

* [Bugfix] Will now turn tasks into projects and projects into tasks if the user has done this in OmniFocus.
* [Bugfix] Rubyfocus::Patch now does patch application, rather than delegating to the Fetcher.

## 0.1.0 // 2015-10-10

* Hello, world!