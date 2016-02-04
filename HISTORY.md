# History

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

* [Bugfix] IDRefs will now return +nil+ if the relevant ID is not set.

## 0.3.0 // 2015-10-17

* [New] Now supports remote syncing with the Omni Sync Server!

## 0.2.0 // 2015-10-11

* [Bugfix] Will now turn tasks into projects and projects into tasks if the user has done this in OmniFocus.
* [Bugfix] Rubyfocus::Patch now does patch application, rather than delegating to the Fetcher.

## 0.1.0 // 2015-10-10

* Hello, world!
