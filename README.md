# Version: 0.5.7

Rubyfocus is a one-way (read-only) ruby bridge to OmniFocus. Analyse, store, inspect, or play with your projects and tasks in OmniFocus from the comfort and flexibility of ruby!

# Installation

## Via rubygems

```
gem install rubyfocus
```

## Via git

First download rubyfocus to your computer:

```
git clone https://github.com/jyruzicka/rubyfocus.git
```

Now build and install it!

```
gem build rubyfocus.gemspec
gem install rubyfocus-0.5.7.gem
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

```ruby
d.projects.select(name: "Sample project")
```

Once you have your objects, you can query them for more information:

```ruby
t = d.tasks.first
t.name # => "Sample task"
t.project.name # => "Sample project"
t.deferred? # => true/false
t.start # => Time or nil
```

## SyncServer-ing

To access an instance of the [Omni Sync Server](http://sync.omnigroup.com), use an `OSSFetcher` object:

```ruby
f = Rubyfocus::OSSFetcher.new(my_username, my_password)
d = Rubyfocus::Document.new(f)
d.update
```

If you use the Omni Sync Server, you'll definitely want to save your data locally and just update what's necessary - it takes a while to download and apply all those files.

# Behind the scenes

OmniFocus stores its data as a "base" XML file plus a series of "patches". These are all stored as zip files inside an ".ofocus" package. This means that you can have several different devices, all storing the OmniFocus task database at different states, and each one can easily update its database by comparing the various patches against its own database and downloading/applying only what's needed.

Rubyfocus makes use of this by fetching and reading OmniFocus' local store on your machine. As long as your local OmniFocus is up to date, `rubyfocus` will be able to fetch the database in its latest state.

# Further work

`rubyfocus` is a work in progress. In the near future I hope to release a more comprehensive document detailing exactly which details of OmniFocus' projects and tasks are available to the user, and what you can do with them.

My main goal is to register with the Omni Sync Server, so you don't need to always delete + reinstantiate the database.
