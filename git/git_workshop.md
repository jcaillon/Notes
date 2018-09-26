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

- Create a development branch `v<ID>/dev` from `v1/dev` and push it to the remote
- Create and switch to a new branch `v<ID>/ft/#1` from `v<ID>/dev`
- Create a new file `code.md`
- Add a new line in `code.md` (a random but readable sentence)
- Commit `code.md` with the message `v<ID>/ft/#1 added code.md`
- Push your branch `v<ID>/ft/#1` to the remote
- Checkout `v<ID>/dev`
- Commit a new empty file `new.md`
- Push the `v<ID>/dev` branch
- In gitlab, create a merge request to merge `v<ID>/ft/#1` to `v<ID>/dev`, set the other team member as an approver : it should require a rebase, don't do it automatically with gitlab, we do it manually

We now need to rebase our feature branch onto dev, to take into account the latest changes in the dev branch.

- Switch to the feature branch `v<ID>/ft/#1`
- Rebase your current branch onto `v<ID>/dev`
- Push your feature branch (this will be a force push)
- Go back to the merge request, the **merge** button should be available
- Merge it, fetch on your local repo and check with the log that your commit on ft/#1 is indeed merged in the dev branch

Second part :

- Merge your dev branch into your release branch (this should be a fast-forward)
- Create a new release branch `v<ID+1>/rel`

<details>
<summary>Reveal solution</summary>
<p>

```bash
git branch v2/dev origin/v1/dev
git checkout -b v2/ft/#1
echo "my line of code" > code.md
git add code.md
git commit -m "added code.md"

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