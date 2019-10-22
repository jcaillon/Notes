# GIT WORKSHOP

[See also the git training page.](./git_training.md)

[See also the git cheat sheet.](./git.md)

## Config

To do :

- Create a new folder
- Initialize a local repo
- Use git config to edit the global .gitconfig
- It should open in an external editor (notepad++ for instance). If in VIM, close the file with `:q!`
- Use git config to edit the local .git/config
- List current config
- Add a new alias
- See an alias content

<details>
<summary>Reveal solution</summary>
<p>

```bash
git init
git config --edit
# set notepad++ as your editor :
git config --global core.editor "'C:/Program Files/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
git config --edit --global
git config --list
git config --global alias.ceg "config --edit --global"
git config alias.ceg
git config core.hooksPath .git/hooks
```

</p>
</details>

## Basics

To do :

- From your local repo...
- Create a new file `file.md` (random content)
- Create a new file `file2.md` (random content)
- Show the repo status
- Add both files to the index
- Show the repo status
- remove `file.md` from the index (do not delete from your working directory!)
- Commit only `file2.md`
- Show the repo status
- Show the commit history
- Rename `file2.md` to `file3.md`
- Commit `file.md` and `file3.md`
- Remove `file.md` from the index and the working directory
- Show the repo status
- Commit to only keep `file3.md`
- Restore `file.md` in the working directory and the index as it was in the 2nd commit (make sure it restored its content)
- Create a new file `new.md`
- Add it to the index
- Show the repo status
- Remove `new.md` from the index but not from the working directory
- Amend the previous commit

<details>
<summary>Reveal solution</summary>
<p>

```bash
touch file.md
touch file2.md
git status
git add -- file.md file2.md # or git add --all
git status
git rm --cached -- file.md
git commit
git status
git log
git mv file2.md file3.md
git add file.md
git commit
git rm file.md
git status
git commit
git checkout HEAD~ -- file.md
git touch new.md
git add new.md
git status
git reset -- new.md
git commit --amend
```

</p>
</details>

## Branching

<details>
<summary>Script to initialize the distant repo.</summary>
<p>

```bash
git init
echo "repo" > README.md
git checkout -b v1/rel
git add README.md
git commit -m "v1/init"
touch .gitignore
git checkout -b v1/dev
git add .gitignore
git commit -m "v1/init added .gitignore"
git remote add origin <url>
git push origin v1/rel v1/dev
```

</p>
</details>

To do :

- Clone a distant repo
- Notice the current branch (HEAD position given in the git prompt) -> default branch in gitlab
- List all the local branches
- List all the branches (including remote branches)
- Create a new branch `mybranch`
- List all the local branches again, check that your new branch exists, check the last commit of the branch you created
- Delete it
- Create and switch to a new branch `myfeature` from `v1/dev`
- Create and switch to a new branch `v1/dev` that tracks the remote branch `v1/dev`
- Switch to `myfeature`
- Make it track `v1/rel` instead of the current `v1/dev`

<details>
<summary>Reveal solution</summary>
<p>

```bash
git clone <url>
git branch
git branch -av
git branch mybranch
git branch
git branch -d mybranch
git checkout -b myfeature origin/v1/dev
git checkout v1/dev
git checkout myfeature
git branch -u v1/rel
```

</p>
</details>

## Cooperating

Give each participant a personal number (starting from 10, incrementing by 10) and a team number. The personal number is your ID, a team is composed of 2 developers.

- Create a development branch `v<ID>/rel` from `v1/dev` and push it to the remote
- Create a development branch `v<ID>/dev` from `v<ID>/rel` and push it to the remote
- Create and switch to a new branch `v<ID>/ft/#1` from `v<ID>/dev`
- Create a new file `code.md`
- Add a new line in `code.md` (a random but readable sentence)
- Commit `code.md` with the message `v<ID>/ft/#1 added code.md`
- Push your branch `v<ID>/ft/#1` to the remote
- Checkout `v<ID>/dev`
- Commit a new empty file `new.md` with the message `added new.md`
- Push the `v<ID>/dev` branch
- In gitlab, create a merge request to merge `v<ID>/ft/#1` to `v<ID>/dev`, set the other team member as an approver : it should require a rebase, don't do it automatically with gitlab, we do it manually

<details>
<summary>Reveal solution</summary>
<p>

```bash
git branch v10/rel origin/v1/dev
git push origin v10/rel
git branch v10/dev origin/v10/rel
git push origin v10/dev
git checkout -b v10/ft/\#1 v10/dev
echo "my line of code" > code.md
git add code.md
git commit -m "added code.md"
git push origin v10/ft/\#1
git checkout v10/dev
touch new.md
git add new.md
git commit -m "added new.md"
git push origin v10/dev
```

</p>
</details>

We now need to rebase our feature branch onto dev, to take into account the latest changes in the dev branch.

- Switch to the feature branch `v<ID>/ft/#1`
- Rebase your current branch onto `v<ID>/dev`
- Push your feature branch (this will be a force push)
- Go back to the merge request, the **merge** button should be available
- Merge it, fetch on your local repo and check with the log that your commit on ft/#1 is indeed merged in the dev branch

<details>
<summary>Reveal solution</summary>
<p>

```bash
git checkout v10/ft/\#1
git rebase origin/v10/dev
git push origin v10/ft/\#1 #  fails
git push origin v10/ft/\#1 -f
git fetch
git checkout v10/dev
git rebase origin/v10/dev # or git pull, or git merge origin/v10/dev
git log
```

</p>
</details>

Delivery/release :

- Merge request dev branch into your release branch (this should be a fast-forward)
- Fetch the changes in your local repo
- checkout the release branch and make sure it is up to date
- create a new release tag `v<ID>/rel/mypackage`
- Push it to the remote

<details>
<summary>Reveal solution</summary>
<p>

```bash
git fetch
git checkout v10/rel
git pull
git tag v10/rel/mypackage
git push origin v10/rel/mypackage
```

</p>
</details>

Update a version with another version : we have a v10 and initiate a new v11, we add a new feature to v10, how to merge this feature in v11.

- Create a new release branch `v<ID+1>/rel` from `v<TEAMMATE_ID>/rel` (this will be our v11) and push it to the remote
- `v<ID>/rel` is ahead of `v<ID+1>/rel` by 2 commits (your code.md + new.md commits) and behind of `v<ID+1>/rel` by 2 commits (your teammate code.md and new.md commits)
- Create a merge request to merge `v<ID>/rel` into `v<ID+1>/rel` : it says you have to manually merge the branches, no fast-forward possible
- Checkout `v<ID+1>/rel`
- Merge with `v<ID>/rel` (there will be conflicts, keep both sentences)
- push `v<ID+1>/rel` to the remote
- The merge request should indicate that the branches have been merged

<details>
<summary>Reveal solution</summary>
<p>

```bash
git checkout -b v11/rel v20/rel
git push origin v20/rel
git merge # conflicts
git mergetool
git add code.md
git merge --continue
```

</p>
</details>

## Cooperating on omega

### Develop a feature

Give each participant a feature (number starting from 1 incrementing by 1). 2 participant on each feature.

- *developer 1*: Create your feature branch `v1/ft/INC000000x` from `v1/dev` and push it to the remote
- *both*: Create your personal branch `v1/ft/INC000000x-tri` from `v1/ft/INC000000x`, switch to it and push it to the remote
- Develop the feature:
  - *developer 1*: Change line 11 in `GreetingController` (change the template), commit `GreetingController.java` with the message `v1/ft/INC000000x modified greeting template`
  - *developer 2*: Change line 15 in `GreetingController` (change the default value), commit `GreetingController.java` with the message `v1/ft/INC000000x modified default value`
- *both*: Push your personal branch `v1/ft/INC000000x-tri` to the remote
- *both*: Open a new merge request, with target `v1/ft/INC000000x` (do not merge yet)
- *developer 2*: checkout `v1/ft/INC000000x`, merge with `v1/ft/INC9999999` and push the branch to the remote
- *both*: In gitlab, refresh the merge request, both need a rebase and can't be merged instantly

<details>
<summary>Reveal solution</summary>
<p>

```bash
git branch v1/ft/INC000000x origin/v1/dev
git push origin v1/ft/INC000000x -u
git checkout -b v1/ft/INC000000x-tri v1/ft/INC000000x
# modification
git add src/main/java/hello/GreetingController.java
git commit -m "v1/ft/INC000000x modified greeting template"
git push origin v1/ft/INC000000x-tri
git checkout v1/ft/INC000000x
git merge origin/v1/ft/INC9999999
git push origin
```

</p>
</details>

### Rebase personal branch

We now need to rebase our personal branch onto our feature branch.

- *both*: Switch to your personal branch `v1/ft/INC000000x-tri`
- *both*: Rebase your current branch onto `v1/ft/INC000000x`
- *both*: Push your feature branch (this will be a force push)
- *both*: Go back to the merge request, the **merge** button should be available

<details>
<summary>Reveal solution</summary>
<p>

```bash
git checkout v1/ft/INC000000x-tri
git rebase origin/v1/ft/INC000000x
git push origin v1/ft/INC000000x-tri #  fails
git push origin v1/ft/INC000000x-tri -f
git log
```

</p>
</details>

### Rebase feature branch

We now simulate a new feature done in the version branch `v1/dev` that we need to have in our feature branch `v1/ft/INC000000x`.

- *developer1*: Checkout `v1/ft/INC000000x`, rebase onto `v2/dev` then push force the branch
- *both*: check the gitlab merge request, a rebase is needed
- *both*: checkout and rebase your personal branch onto the `v1/ft/INC000000x`, see that you have a commit appearing twice in the log
- *both*: rebase interactive to delete the additional commit

<details>
<summary>Reveal solution</summary>
<p>

```bash
git checkout v1/ft/INC000000x
git rebase origin/v2/dev
git push origin v1/ft/INC000000x -f
git checkout v1/ft/INC000000x-tri
git fetch
git rebase origin/v1/ft/INC000000x
git rebase -i v1/ft/INC000000x
```

</p>
</details>

Delivery/release :

- Merge request dev branch into your release branch (this should be a fast-forward)
- Fetch the changes in your local repo
- checkout the release branch and make sure it is up to date
- create a new release tag `v1/rel/mypackagex`
- Push it to the remote

<details>
<summary>Reveal solution</summary>
<p>

```bash
git fetch
git checkout v10/rel
git pull
git tag v10/rel/mypackage
git push origin v10/rel/mypackage
```

</p>
</details>

Update a version with another version : we have a v10 and initiate a new v11, we add a new feature to v10, how to merge this feature in v11.

- Create a new release branch `v<ID+1>/rel` from `v<TEAMMATE_ID>/rel` (this will be our v11) and push it to the remote
- `v<ID>/rel` is ahead of `v<ID+1>/rel` by 2 commits (your code.md + new.md commits) and behind of `v<ID+1>/rel` by 2 commits (your teammate code.md and new.md commits)
- Create a merge request to merge `v<ID>/rel` into `v<ID+1>/rel` : it says you have to manually merge the branches, no fast-forward possible
- Checkout `v<ID+1>/rel`
- Merge with `v<ID>/rel` (there will be conflicts, keep both sentences)
- push `v<ID+1>/rel` to the remote
- The merge request should indicate that the branches have been merged

<details>
<summary>Reveal solution</summary>
<p>

```bash
git checkout -b v11/rel v20/rel
git push origin v20/rel
git merge # conflicts
git mergetool
git add code.md
git merge --continue
```

</p>
</details>


## Rebase interactive

<details>
<summary>Script to create the local repo.</summary>
<p>

Create a .sh file, copy the following commands in it then execute it with `sh file.sh`.

```bash
git init
touch A
git add --all
git commit -m "added A"
touch B
touch C
git add --all
git commit -m "added B and C"
touch F
git add --all
git commit -m "added F"
touch E
git add --all
git commit -m "derp E"
touch D1
git add --all
git commit -m "added D part 1"
touch D2
git add --all
git commit -m "added D part 2"
```

</p>
</details>

To do :

- Show the log of this repo
- Commits should be in alphabetical order (oldest A, newest F)
- Correct the message `derp E` to be `added E`
- Split the commit `added B and C` into 2 commits adding 1 file each
- Squash the 2 commits `added D part 1` and `added D part 2` into a single commit `added D` with the 2 files D1 and D2

<details>
<summary>Reveal solution</summary>
<p>

```bash
git rebase -i HEAD~5
```

Rebase file :

```text
e 36047e2 added B and C
pick e206ef8 added D part 1
s b05c717 added D part 2
r 4259336 derp E
pick 783b96b added F
```

The rebase stops after applying B and C :

```bash
git log
git rm --cached C
git commit --amend -m "added B"
git add C
git commit -m "added C"
git rebase --continue
```

The rebase stops asking the commit message from squashing D1 and D2 together. Input `added D`.

Finally it stops asking the new message for `derp E`. Input `added E`.

</p>
</details>