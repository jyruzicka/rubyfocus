# History

## 0.5.8 // 2016-09-02

Heading off edge cases, again a result of the new Omnifocus database format

* [Fixed] Projects inside folders were being reported as having no container, due to empty `<task/`> tags. Now fixed.

## 0.5.7 // 2016-09-02

A quick fix for the new OF database format

* [Fixed] Empty `<project/>` tags in a task description will no longer cause Rubyfocus to treat said task as a project.

## 0.5.6 // 2016-09-01

* [New] Added `Time.safely_parse`, which will not choke on empty strings or nil values
* [Fixed] `conditional_set` will no longer choke on empty string for times

## 0.5.5 // 2016-05-18

* [Fixed] If there are no patches, `Fetcher#head`s will return the ID of the base file.
* [Fixed] `Fetcher#head` will now return the ID of the most recent patch, not the patch itself.
* [New] `Searchable` objects will now respond to `find_all`, which is an alias of `select`.
* [Fixed] `RankedItem#contained_within?` will now check against all objects matching a block or hash, rather than just the first one that the document can find.

## 0.5.4 // 2016-02-08

* [Fixed] `LocalFetcher` will now try the default App Store location if it can't find anything at the normal location.

## 0.5.3 // 2016-02-04

* [Fixed] Re-did the code determining whether a task was blocked. Now tasks are considered blocked if their immediate container is blocked.
* [Fixed] Caching some task filters on the `Task` class was causing issues. Removed caching, which shouldn't hit performance much.

## 0.5.2 // 2016-02-04

* [Fixed] Whoops! Did I leave HTTParty out of the gem install list? My bad!

## 0.5.1 // 2016-02-03

* [Fixed] `Task#next_available_task` should no longer cause errors when a project has no tasks.

## 0.5.0 // 2016-01-20

Now work out how close to (or far from) the head of your document you are!

* [New] `Fetcher#head` returns the most recent patch.
* [New] `Fetcher#can_reach_head_from?(id)` will inform you if you can get to the head from a given ID. 

## 0.4.0 // 2016-01-01

* Happy new year!
* [Modified] Container IDRef is now located on RankedItem, rather than having several on each RankedItem subclass.
* [New] RankedItems can look at their ancestry much more easily, using RankedItem#ancestry and RankedItem#contained_within?
* [New] Documents now forbid elements with duplicate IDs unless Document#allow_duplicate_ids is set to true.
* [New] Patchers now treate CREATE nodes on elements whose IDs already exist in the database as UPDATE nodes
* [Fixed] Patchers will now interpret missing parameters as "default values" e.g. project update without `status` parameter assumed to be active.

## 0.3.1 // 2015-12-31

* [Bugfix] IDRefs will now return `nil` if the relevant ID is not set.

## 0.3.0 // 2015-10-17

* [New] Now supports remote syncing with the Omni Sync Server!

## 0.2.0 // 2015-10-11

* [Bugfix] Will now turn tasks into projects and projects into tasks if the user has done this in OmniFocus.
* [Bugfix] Rubyfocus::Patch now does patch application, rather than delegating to the Fetcher.

## 0.1.0 // 2015-10-10

* Hello, world!
