# GIT WORKSHOP

[See also the git training page.](./git_training.md)
[See also the git cheat sheet.](./git.md)

## Config

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
<summary>Distant repo creation...</summary>
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

- Clone a distant repo
- Check the current branch (HEAD position given in the git prompt)
- List all the local branches
- List all the branches (including remote branches)
- Create a new branch `mybranch`
- List and see it exists, check where it points to
- Delete it
- Create a new branch `myfeature` from `v1/dev` and immediately switch to it
- Create a new branch `v1/dev` that tracks the remote branch `v1/dev`
- Switch to `myfeature`
- Make it track `v1/rel`

<details>
<summary>Reveal solution</summary>
<p>

```bash
git clone <url>
git branch
git branch -a
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

Give each participant a personal number and a team number. The personal number is your ID, a team is composed of 2 developers.



<details>
<summary>Reveal solution</summary>
<p>

```bash

```

</p>
</details>