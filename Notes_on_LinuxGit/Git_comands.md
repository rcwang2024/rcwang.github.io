# Comands that often used Git and GitHub

This note summarizes the often-used Commands of Git and GitHub for daily work, maintaining a repository, and cooperating on projects with multiple members.

## What is Git
**Git** is a popular content-addressable distributed version control system. Version control systems allow people to record when and what has been done to files so that people can check different versions of files. The feature that distinguishes Git from other VCSs is: 
> "Git thinks of its data more like a series of snapshots of a miniature filesystem. With Git, every time you commit, or save the state of your project, Git basically takes a picture of what all your files look like at that moment and stores a reference to that snapshot." --- <https://git-scm.com/book/de/v2>
> 
> To be efficient, **Git** only snap the modifications usually

In **Git**, files may have three stages, **_modified_**, **_staged_**, and **_committed_**.

>**_modified_**: Files have been changed but not committed to the database

>**_staged_**: The modified files are marked in the current version and ready to be committed as a new snap for a new version.

>**_committed_**: The staged files are committed to the local database and safely stored.

How **Git** workflow looks like:

- Files are modified for a project 
- Selected files were staged for commit
- Staged files are committed

## Install Git on macOS
**Git** is usually installed on MAC by default. We can update it with the following code with home brew
>brew update # update the homebrew
>
>brew upgrade git # update git to latest version
>
>git --version # check the version of git

## Setup git 

Using `git config`, we can set up the configuration of git on the computer for once, and we can modify the configuration at any time we want
>`git config --list --show-origin` # show the configures of git

>`git config --global user.name "Ruichao Wang"` # set the user name

>`git config --global user.email "bruim2010@gmai.com"` # set the email address

>`git config --global core.editor vim` # set the editor

>`git config --global init.defaultBranch main` # set the `main` as the default branch name

>`git config --list` # check the settings of config

>`git config user.name` # check the user name

check which configuration file had the final say in setting that value
>`git config --show-origin rerere.autoUpdate`
>
>`git help config` # get help of config or other action
>
>`git add h` # more concise help of 'add'
>

## Getting a Git repository

- One way, we can take a local directory which has not under version control and turn it to a git repository

- The other way is we clone an existing repository 

Initialize a repository from a local directory on macOS.
>`cd /users/user/my_project` # move to the project directory

>`git init` # initialize the git for version control

>`git add *.c` # track all the .c file to staging

>`git add LICENCE` # add LICENCE

>`git commit -m 'Initial project version'` # commit the files

Clone, get a copy of an existing git repository.

>`git clone https://github.com/rcwang2024/rcwang.github.io`

>`git clone https://github.com/rcwang2024/rcwang.github.io myProject` # clone a repository and give it a new name

Remember, Each file can be in one of two stages: tracked or untracked.

Checking the status of files:

>`vim README` # create a file

>`git status` # Check the status; will say README not tracked

>`git add README` # track the README file

>`vim README` # modify the file

>`git status` # show the files modified

>`git add README` # track/stage the modified file 

>`git status -s` # short version of status

We can tell git which files we want git to ignore:

> vim .gitignore # build a file name .gitignore and put the format of files we dont want to track, such as: `*.[oa]`, `*~`.

Here is another example .gitignore file:

> \# ignore all .a files

> *.a

> \# but do track lib.a, even though you're ignoring .a files above

>!lib.a

> \# only ignore the TODO file in the current directory, not subdir/TODO

> /TODO

> \# Ignore all files in any directory named build

>build/

> \# Ignore doc/notes.txt, but not doc/server/arch.txt

> doc/*.txt
 
> \# Ignore all .pdf files in the doc/ directory and any of its subdirectories

> doc/**/\*.pdf

**`git diff`** viewing the difference between changed and unchanged files

> `git status`

> `git diff`

> `git diff --staged` ## check the difference that going to be committed

> `git diff --cached` ## see what have staged, similar to --staged

**Committing the changes**

> `git commit -m 'Message shown about the commit'` 

>  or if use `git commit` only, then there will be a file opened for to check and add info about this commit

> `git commit -a -m 'add all the new files'` ## `-a` allow you stage all the untracked files, same as `git add *` before commit

We can remove the files
> `rm file.txt` # simply remove the file

> `git rm -f file.txt` # force to remove the staged files if it is committed, 

> `git rm --cached README` # remove the cached file
 
> `git rm --cached README` # will remove the staged file, but keep the local file

We can rename files:

> `git move file_A file_B`

> `git status`

We can view the commit history
> `git log`
 
> `git log --patch` ## show the difference of commit, the output patch
 
> `git log --stat` ## Simplified version of log

> `git log --pretty=oneline` ## pretty version with only one line
 
> `git log --pretty=format:"%h - %an, %ar : %s"` ## `%h` simple hash code, `%an` Auther name, `%ar` Author date, relative, `%s` subject

 
> `git log --pretty=format:"%h %s" --graph`

> `git log --since=2.weeks` ## limiting log output

If we forget something before committing, we can add the files and commit again

> git commit -m 'Initial commit'

> git add forgotten_file
> 
> git commit --amend
> 
> git reset HEAD README.md # unstaging a file
> 
> git restore --staged README.md # unstaging a file

## Working Remote 

> git remote

> git remote -v ## liste the remote repository

> git remote add example http://github.example.com ## add an remote repository

> git fetch example.remote ## fetch data from remote repository named example

> git remote show origin ## check the info of the remote repository
 
> git remote rename example example0 ## rename the local name of remote repo
 
> git remote remove example0 ## remove the remote repo


## Git Branch, the key feature of Git

**Git branch** can make a new moveable pointer to the main branch; when moving the pointer, a new branch will be created beside the main branch. Modifying the data in each branch will not change other branches before merging branches.

Create a new branch, and do something, and commit it

> `git branch testing` ## Create a new branch

> `git checkout testing` ## switch to the new branch. All the data are the same as the main branch
 
> `vim newREADME.md` ## create a new "readme" file in the new branch
 
> `git add newREADME.md` ## staging the new file in the new branch
 
> `git commit -m "Commit a new branch"` # commit the new branch

To merge the testing branch to the main branch, we first need to switch to the main branch and then merge. After merging, we can delete the branch

> `git checkout main` # switch to main
 
> `git merge testing` # merge the branch to the main branch, 
 
> `git branch -d testing` # Delete the testing branch

Other ways of creating and switching to new branches:

> `git checkout -b testing` ## build and switching to the testing branch
 
> `git switch -c test0` ## build and switch to test0

