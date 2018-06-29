
## Cool sites 

- http://onlywei.github.io/explain-git-with-d3/#branch
- http://marklodato.github.io/visual-git-guide/index-en.html
- http://think-like-a-git.net/sections/graph-theory/reachability.html
- https://github.com/pluralsight/git-internals-pdf/releases

```git
------------
*   Merge branch 'report-a-bug'
|\
| * Add the feedback button
* | Merge branch 'refactor-button'
|\ \
| |/
| * Use the Button class for all buttons
| * Extract a generic Button class from the DownloadButton one
------------

    o---o---o---o---o---o---o---o  master
	 \			 \
	  o---o---o---o---o	  o'--o'--o'--o'--o'--M	 subsystem
			   \			     /
			    *---*---*-..........-*--*  topic

```

## Basics

### git config

Sets configuration values for things like your user name, email, and gpg key, your preferred diff algorithm, file formats to use, proxies, remotes and tons of other stuff. For a full list, see the git-config docs (http://www.kernel.org/pub/software/scm/git/docs/git-config.html)


```bash
git help
git config --global user.name "Julien"
git config --global user.email "mymail@truc.com"
git config --global color.ui true # pretty cmd line colors
git config --global core.editor E:/outils/notepad++.exe
git config --global merge.tool E:/outils/winmerge++.exe
git config http.proxy http://proxy:8080 # for local repo only
git config user.name # get current value for this property
git config --list
git config --global alias.lol "log --oneline --graph --decorate --abbrev-commit --all"
git lol
```

### git init

Initializes a git repository – creates the initial ‘.git’ directory in a new or existing project.


### git clone

Copies a Git repository from another place and adds the original location as a remote you can fetch from again and possibly push to. if you have permission.

### git add

Adds changes in files in your working directory to your index, or staging area.

### git rm

Removes files from your index and your working directory so they will stopped being tracked.

### git commit

Takes all of the changes staged in the index (that have been ‘git add’ed), creates a new commit object pointing to it, and advances the branch to point to that new commit.

### git status

Shows you the status of files in your index versus your working directory. It will list out files that are untracked (only in your working directory), modified (tracked but not yet updated in your index), and staged (added to your index and ready for committing).

### git branch

Lists existing branches, including remote branches if ‘-a’ is provided. Creates a new branch if a branch name is provided. Branches can also be created with ‘-b’ option to ‘git checkout’

### git checkout

Checks out a different branch – makes your working directory look like the tree of the commit that branch points to and updates your HEAD to point to this branch now, so your next commit will modify it.

### git merge

Merges one or more branches into your current branch and automatically creates a new commit if there are no conflicts.

### git reset

Resets your index and working directory to the state of your last commit, in the event that something screwed up and you just want to go back.

### git rebase

An alternative to merge that rewrites your commit history to move commits since you branched off to apply to the current head instead. A bit dangerous as it discards existing commit objects.

### git stash

Temporarily saves changes that you don’t want to commit immediately for later. Can re-apply the saved changes at any time.

### git tag

Tags a specific commit with a simple, human readable handle that never moves.

### git fetch

Fetches all the objects that a remote version of your repository has that you do not yet so you can merge them into yours or simply inspect them.

### git pull

Runs a `git fetch` then a `git merge`.

### git push

Pushes all the objects that you have that a remote version does not yet have to that repository and advances its branches

### git remote

Lists all the remote versions of your repository, or can be used to add and delete them.

## Inspecting repo

### git log

Shows a listing of commits on a branch or involving a specific file and optionally details about what changed between it and its parents.

### git show

Shows information about a git object, normally used to view commit information.

### git ls-tree

Shows a tree object, including the mode and name of each node and the SHA-1 value of the blob or tree that it points to. Can also be run recursively to see all subtrees as well.

### git cat-file

Used to view the type of an object if you only have the SHA-1 value, or used to redirect contents of files or view raw information about any object.

### git grep

Lets you search through your trees of content for words and phrases without having to actually check them out.

### git diff

Generates patch files or statistics of differences between paths or files in your git repository, or your index or your working directory.

### gitk

Graphical Tcl/Tk based interface to a local Git repository.

### instaweb

Wrapper script to quickly run a web server with an interface into your repository and automatically directs a web browser to it

## Extra tools

### git archive

Creates a tar or zip file of the contents of a single tree from your repository. Easiest way to export a snapshot of content from your repository.

### git gc

Garbage collector for your repository. Packs all your loose objects for space and speed efficiency and optionally removes unreachable objects as well. Should be run occasionally on each of your repos.

### git fsck

Does an integrity check of the Git “filesystem”, identifying dangling pointers and corrupted objects.

### git prune

Removes objects that are no longer pointed to by any object in any reachable branch.

### git-daemon

Runs a simple, unauthenticated wrapper on the git-upload-pack program, used to provide efficient, anonymous and unencrypted fetch access to a Git repository.

Basics

```bash
git init # initialize a local repo
git status
git add file.md file2.md # stage new files (start to track them)
git add --all
git add *.txt # all .txt in current directory
git add "*.txt" # all .txt in project
git add docs/*.txt
git add -i
git commit -m "description" # take a snapshot of the stage area
git rm README # deleted from the local filesystem and untracked
git rm --README # only untracked, not deleted from fs
```

Diff/status

```bash
git diff # show unstaged differences since last commit
git diff HEAD # diff between last commit and current state
git status # show changes to be commited
```

Unstage/reset a file

```bash
git reset HEAD LICENSE # unstage a file (HEAD is the last commit)
git checkout -- LICENSE # blow away all the changes since last commit
```

Undoing/modifying a commit

```bash
git reset --soft HEAD^ # undo last commit, put changes into staging, moving to the commit BEFORE HEAD = HEAD^
git commit --amend  -m "new message # change commit message
git reset --hard HEAD^ # undo last commit and all changes
git reset --hard HEAD^^ # undo last 2 commit and all changes

git add todo.txt
git commit --ammend -m "modify" # what was staged is added to the last commit (--amend)
```

Add and commit

```bash
git commit -a -m "description" # -a add changes from all tracked files
```

Remote

```bash
git remote add origin https://git/repo/proj.git # add a new remote, where origin is the remote name
git remote add <name> <url>
git remote rename <oldname> <name>
git remote -v # list remotes
git push -u <name> <branch> # where branch is the local branch to push
git push -u <name> --all # all branches
git push -u <name> --tags # tags
git remote rm <name>
git pull
git clone <url>
git clone <url> <localfolder>
```

Branches

```bash
git branch <branch> # create new branch
git checkout <branch> # switch to branch
git checkout -b <branch> # create then switch to branch
git branch # list branches
git branch -r # list all remote branches
git checkout master
git merge <branch> # merge branch onto the currently checked out branch (master)
git branch -d <branch> # soft delete
git push origin :<branch> # delete remote branch (still need to delete the local branch)
git push origin <branch> # links local branch to remote branch = tracking
git remote prune origin # clean up all deleted remote branches
```

Remote show

```bash
git remote show origin # show which branches are tracked for the given remote
```

Vi to handle merge

```bash
ESC # leave mode
:wq # save and quit
i # insert mode
:q! # cancel and quit
```

Fetch/pull

```bash
git fetch # sync the origin/branches of our local repo
git checkout master
git pull = git fetch & git merge origin/master
```

Merge conflict

```bash
git status # will list the unmerged files
git commit -a # open the commit editor once you modified the file
```

Tag

```bash
git tag # list all tags
git checkout <tag>
git tag -a <tag> -m "description" # create a new tag
git push --tags # push tags to remote
```

Log/diff/blame

```bash
git log --pretty=oneline
git log --pretty=format:"%h %ad- %s [%an]"
git log --oneline -p # patch
git log --oneline --stat # stats
git log --oneline --graph # graphical representation
git log --since=1.day.ago
git log --until=1.minute.ago
git log --since=2000-01-01 --until=1.minute.ago

git diff HEAD^ # parent of latest commit
git diff HEAD^^ # grandparent of latest commit
git diff HEAD~5 # 5 commits ago
git diff HEAD^..HEAD
git diff <SHA1>..<SHA2>
git diff <branch1> <branch2>

git blame file.txt --date short
```

.gitignore patterns

```bash
file.txt
*.ext
directory/
logs/*.logs
```

rebase

1. move all changes to <currentbranch> which are not in <branch> to a temp area
2. run all <branch> commits
3. run all commits in the temp area, one at a time

```bash
git checkout <currentbranch>
git rebase <branch>
git rebase # will rebase from origin/<currentbranch>

# merge feature to master :
git checkout feature
git rebase master # at this point, our local feature branch has been modified and is no longer the same as the origin! it has all the commits
git checkout master
git merge feature
```

rebase conflicts

```bash
git status
# edit unmerged files
git add file.txt
git rebase --continue # --skip/--abort
```

