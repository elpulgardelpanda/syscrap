Syscrap
=======

** TODO: Add description **


## Development setup
We will try to use pull --rebase.
Run this once the project is cloned, from the root directory of the project:

```
git config branch.autosetuprebase always
```
http://stevenharman.net/git-pull-with-automatic-rebase


## Project components

- SSH connector
- Supervisor: fault tolerance system
- DBConnector
- Mailer
- Loggers: check node parameter and log it on BD
- Checkers: check BD for trends and launches an alert when an action needs to be taken: TempChecker, CpuChecker, StorageChecker, KeepaliveChecker
- Actors: respond to checkers alerts taken the necessary action
