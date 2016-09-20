# Change log

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

### Changed
* Major changelog reformat!

## [0.5.10] - 2016-09-07

### Fixed
* Projects will no longer be demoted to tasks if a project patch doesn't contain a "<project>" tag.

## [0.5.9] - 2016-09-04

### Fixed
* Blank entries in updates are now treated as "no change", rather than "new value is nil".

## [0.5.8] - 2016-09-02

### Fixed
* Projects inside folders were being reported as having no container, due to empty `<task/`> tags. Now fixed.

## [0.5.7] - 2016-09-02

### Fixed
* Empty `<project/>` tags in a task description will no longer cause Rubyfocus to treat said task as a project.

## [0.5.6] - 2016-09-01

### Added
* Added `Time.safely_parse`, which will not choke on empty strings or nil values

### Fixed
* `conditional_set` will no longer choke on empty string for times

## [0.5.5] - 2016-05-18

### Fixed

* If there are no patches, `Fetcher#head`s will return the ID of the base file.
* `Fetcher#head` will now return the ID of the most recent patch, not the patch itself.
* * `RankedItem#contained_within?` will now check against all objects matching a block or hash, rather than just the first one that the document can find.

### Added
* `Searchable` objects will now respond to `find_all`, which is an alias of `select`.

## [0.5.4] - 2016-02-08

### Fixed
* `LocalFetcher` will now try the default App Store location if it can't find anything at the normal location.

## [0.5.3] - 2016-02-04

### Fixed
* Re-did the code determining whether a task was blocked. Now tasks are considered blocked if their immediate container is blocked.
* Caching some task filters on the `Task` class was causing issues. Removed caching, which shouldn't hit performance much.

## [0.5.2] - 2016-02-04

### Added
* Whoops! Did I leave HTTParty out of the gem install list? My bad!

## [0.5.1] - 2016-02-03

### Fixed
* `Task#next_available_task` should no longer cause errors when a project has no tasks.

## [0.5.0] - 2016-01-20

### Added
* `Fetcher#head` returns the most recent patch.
* `Fetcher#can_reach_head_from?(id)` will inform you if you can get to the head from a given ID. 

## [0.4.0] - 2016-01-01

* Happy new year!

### Added
* RankedItems can look at their ancestry much more easily, using RankedItem#ancestry and RankedItem#contained_within?
* Documents now forbid elements with duplicate IDs unless Document#allow_duplicate_ids is set to true.
* Patchers now treate CREATE nodes on elements whose IDs already exist in the database as UPDATE nodes

### Changed
* Container IDRef is now located on RankedItem, rather than having several on each RankedItem subclass.

### Fixed
* Patchers will now interpret missing parameters as "default values" e.g. project update without `status` parameter assumed to be active.

## [0.3.1] - 2015-12-31

### Changed
* IDRefs will now return `nil` if the relevant ID is not set.

## [0.3.0] - 2015-10-17

### Added
* Now supports remote syncing with the Omni Sync Server!

## [0.2.0] - 2015-10-11

### Changed
* Will now turn tasks into projects and projects into tasks if the user has done this in OmniFocus.
* Rubyfocus::Patch now does patch application, rather than delegating to the Fetcher.

## [0.1.0] - 2015-10-10

### Added
* Hello, world!
