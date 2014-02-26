---
layout: post
title: "[번역]GitHub / Advanced Git / Remove sensitive data"
description: ""
categories: [translate, Advanced Git]
tags: [git, GitHub]
---
{% include JB/setup %}

이 문서는 [Remove sensitive data](https://help.github.com/articles/remove-sensitive-data)의 비공식 번역글이며 GitHub에서 보증, 유지 또는 감독하지 않습니다. 공식 도움글을 보시려면 [help.github.com](https://help.github.com)을 방문하세요.

---

## Remove sensitive data 중요한 데이터 제거하기

From time to time users accidentally commit data like passwords or keys into a git repository. While you can use `git rm` to remove the file, it will still be in the repository's history. Fortunately, it's possible to remove unwanted files from the whole of repository history too, using either Git's in-built `filter-branch` tool, or more easily & quickly using The BFG Repo-Cleaner.

<div class="alert-danger"><strong>Danger: Once the commit has been pushed you should consider the data to be compromised.</strong> If you committed a password, change it! If you committed a key, generate a new one.</div>

### Purge the file from your repository

Now that the password is changed, you want to remove the file from history and add it to the `.gitignore` to ensure it is not accidentally re-committed. For our examples, we're going to remove `Rakefile` from the [GitHub gem](https://github.com/defunkt/github-gem) repository.

	$ git clone https://github.com/defunkt/github-gem.git
	# Initialized empty Git repository in /Users/tekkub/tmp/github-gem/.git/
	# remote: Counting objects: 1301, done.
	# remote: Compressing objects: 100% (769/769), done.
	# remote: Total 1301 (delta 724), reused 910 (delta 522)
	# Receiving objects: 100% (1301/1301), 164.39 KiB, done.
	# Resolving deltas: 100% (724/724), done.

	$ cd github-gem

	$ git filter-branch --force --index-filter \
	  'git rm --cached --ignore-unmatch Rakefile' \
	  --prune-empty --tag-name-filter cat -- --all
	# Rewrite 48dc599c80e20527ed902928085e7861e6b3cbe6 (266/266)
	# Ref 'refs/heads/master' was rewritten

This command will run the entire history of every branch and tag, changing any commit that involved the file `Rakefile`, and any commits afterwards. Commits that are empty afterwards (because they only changed the Rakefile) are removed entirely. Note that you'll need to specify the path to the file you want to remove, not just its filename.

Now that we've erased the file from history, let's ensure that we don't accidentally commit it again.

Please note that *this will overwrite your existing tags.*

	$ echo "Rakefile" >> .gitignore

	$ git add .gitignore

	$ git commit -m "Add Rakefile to .gitignore"
	# [master 051452f] Add Rakefile to .gitignore
	#  1 files changed, 1 insertions(+), 0 deletions(-)

This would be a good time to double-check that you've removed everything that you wanted to from the history, and that all of your branches are checked out. If you're happy with the state of the repository, you need to force-push the changes to overwrite the remote repository. This process overwrites the entire remote repository, so your commits will no longer be made available online.

	$ git push origin master --force
	# Counting objects: 1074, done.
	# Delta compression using 2 threads.
	# Compressing objects: 100% (677/677), done.
	# Writing objects: 100% (1058/1058), 148.85 KiB, done.
	# Total 1058 (delta 590), reused 602 (delta 378)
	# To https://github.com/defunkt/github-gem.git
	#  + 48dc599...051452f master -> master (forced update)	

You will need to run this for every branch and tag that was changed. The `--all` and `--tags` flags may help make that easier.	


#### Purge files that have been moved

As a special note: if you need to purge a file that has been moved since creation, you need to also run the `filter-branch` step on all former paths.

### Using The BFG as an alternative to git-filter-branch

[The BFG](http://rtyley.github.io/bfg-repo-cleaner/) is a faster, simpler alternative to `git-filter-branch`, dedicated to removing unwanted data - for example:

	$ bfg --delete-file Rakefile
	# Remove any file named 'Rakefile' (leaves your latest commit untouched)

or

	$ bfg --replace-text passwords.txt
	# Search-and-replace text (in this case, passwords) in all files in repo history	

See [The BFG's documentation](http://rtyley.github.io/bfg-repo-cleaner/) for full usage and download instructions.

### Cleanup and reclaiming space

While `git filter-branch` rewrites the history for you, the objects remain in your local repository until they've been dereferenced and garbage collected. If you are working in your main repository, you might want to force these objects to be purged.


	$ rm -rf .git/refs/original/

	$ git reflog expire --expire=now --all

	$ git gc --prune=now
	# Counting objects: 2437, done.
	# Delta compression using up to 4 threads.
	# Compressing objects: 100% (1378/1378), done.
	# Writing objects: 100% (2437/2437), done.
	# Total 2437 (delta 1461), reused 1802 (delta 1048)

	$ git gc --aggressive --prune=now
	# Counting objects: 2437, done.
	# Delta compression using up to 4 threads.
	# Compressing objects: 100% (2426/2426), done.
	# Writing objects: 100% (2437/2437), done.
	# Total 2437 (delta 1483), reused 0 (delta 0)

Note that pushing the branch to a new or empty GitHub repository and then making a fresh clone from GitHub has the same effect.


### Dealing with collaborators

You may have collaborators that pulled your tainted branch and created their own branches off of it. After they fetch your new branch, they will need to use `git rebase` on their own branches to rebase them on top of the new one. The collab should also ensure that their branch doesn't reintroduce the file, as this will override the `.gitignore` file. Make sure your collab uses rebase and not merge, otherwise he will just reintroduce the file and the entire tainted history... and likely encounter some merge conflicts.	


### Cached data on GitHub

Be warned that force-pushing does not erase commits on the remote repository, it simply introduces new ones and moves the branch pointer to point to them. If you are worried about users accessing the bad commits directly via SHA1, you will have to delete the repository and recreate it. If the commits were viewed online the pages may also be cached. Check for cached pages after you recreate the repository, if you find any open a ticket on [GitHub Support](https://github.com/contact) and provide links so staff can purge them from the cache.


### Avoiding accidental commits in the future

There are a few simple tricks to avoid committing things you don't want committed. The first, and simplest, is to use a visual program like [GitHub for Mac](https://mac.github.com/) or [gitx](http://rowanj.github.io/gitx/) to make your commits. This lets you see exactly what you're committing, and ensure that only the files you want are added to the repository. If you're working from the command line, avoid the catch-all commands `git add .` and `git commit -a`, instead use `git add filename` and `git rm filename` to individually stage files. You can also use `git add --interactive` to review each changed file and stage it, or part of it, for commit. If you're working from the command line, you can also use `git diff --cached` to see what changes you have staged for commit. This is the exact diff that your commit will have as long as you commit without the `-a`	 flag.


### Other reading

- [Git-filter-branch man page](http://git-scm.com/docs/git-filter-branch)
- [Pro Git: Git 도구 - 히스토리 단장하기](http://git-scm.com/book/ko/Git-%EB%8F%84%EA%B5%AC-%ED%9E%88%EC%8A%A4%ED%86%A0%EB%A6%AC-%EB%8B%A8%EC%9E%A5%ED%95%98%EA%B8%B0)
- [The BFG Repo-Cleaner](http://rtyley.github.io/bfg-repo-cleaner/) - removes large or troublesome blobs like git-filter-branch does, but faster