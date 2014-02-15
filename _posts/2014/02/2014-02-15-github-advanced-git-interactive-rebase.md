---
layout: post
title: "[번역]GitHub / Advanced Git / 대화형 Rebase"
description: ""
categories: [translate, Advanced Git]
tags: [git, GitHub, rebase]
---
{% include JB/setup %}

## Interactive rebase

One often overlooked feature of git is the `git rebase` command. Rebase allows you to easily change a series of commits, reordering, editing, or squashing commits together into a single commit.

**Warning**: It is considered bad practice to rebase commits which you have already pushed to a remote repository. Doing so may invoke the wrath of the git gods.	


<h3>Using rebase --interactive</h3>

#### Invocation

To rebase all the commits between master and the current branch's head, back on to master:

	git rebase --interactive master

Another common practice is to rebase the last few commits in your current branch:

	git rebase --interactive HEAD~5

Running the command with the `--interactive` flag will launch your text editor with a file detailing the commits that will be rebased. This will also list the commands available:

	pick 1fc6c95 Patch A
	pick 6b2481b Patch B
	pick dd1475d something I want to split
	pick c619268 A fix for Patch B
	pick fa39187 something to add to patch A
	pick 4ca2acc i cant' typ goods
	pick 7b36971 something to move before patch B

	# Rebase 41a72e6..7b36971 onto 41a72e6
	#
	# Commands:
	#  p, pick = use commit
	#  r, reword = use commit, but edit the commit message
	#  e, edit = use commit, but stop for amending
	#  s, squash = use commit, but meld into previous commit
	#  f, fixup = like "squash", but discard this commit's log message
	#  x, exec = run command (the rest of the line) using shell
	#
	# If you remove a line here THAT COMMIT WILL BE LOST.
	# However, if you remove everything, the rebase will be aborted.
	#

At this point you can edit the file to change the order of the commits. There are six commands available:

#### Pick

Pick is used to include a commit. By default you will be given a list of the commits you chose to rebase, in order of oldest (top) to newest (bottom). Rearranging the order of the pick commands will change the order of the commits when you begin the rebase.

#### Reword

This is similar to pick, but the rebase process will pause and give you a chance to change the commit message. The contents of the commit are not modified.

#### Edit

This will pick the commit and then pause the rebase. During this pause you can amend the commit, adding to or removing from it. You can also make more commits before you continue the rebase, this allows you to split a large commit into smaller ones. You should always ensure that your working tree and index are clean before you resume the rebase.

#### Squash

This command lets you combine two or more commits into a single commit. When used the commit will be picked and then amended into the commit before it. Git will then pause the rebase and open your text editor with the commit messages from both commits. After you have edited the message to your satisfaction save the file and close the editor. Git will resume the rebase.

#### Fixup

This is similar to squash, but the commit's message is discarded. The commit is simply merged into the commit before it and the first commit's message is used.

#### Exec

This allows you to run arbitrary shell commands automatically against a commit.

#### Example

In this rebase we will cover all the commands except exec. We start our rebase with git rebase `--interactive HEAD~7` and are presented with this file in our editor:

	pick 1fc6c95 Patch A
	pick 6b2481b Patch B
	pick dd1475d something I want to split
	pick c619268 A fix for Patch B
	pick fa39187 something to add to patch A
	pick 4ca2acc i cant' typ goods
	pick 7b36971 something to move before patch B

	# Rebase 41a72e6..7b36971 onto 41a72e6
	#
	# Commands:
	#  p, pick = use commit
	#  r, reword = use commit, but edit the commit message
	#  e, edit = use commit, but stop for amending
	#  s, squash = use commit, but meld into previous commit
	#  f, fixup = like "squash", but discard this commit's log message
	#  x, exec = run command (the rest of the line) using shell
	#
	# If you remove a line here THAT COMMIT WILL BE LOST.
	# However, if you remove everything, the rebase will be aborted.
	#

There are a few things we want to do here, we want to move the fifth and last commits up before the "Patch B" commit. One of those commits will be squashed into the "Patch A" commit. We also want to squash the "fix for Patch B" commit into Patch B and discard its commit message (a fixup). We want to edit the third commit to split it into two commits. Finally we need to reword the sixth commit and fix our wonderful typing.

We'll change the file as such:

	pick 1fc6c95 Patch A
	squash fa39187 something to add to patch A
	pick 7b36971 something to move before patch B
	pick 6b2481b Patch B
	fixup c619268 A fix for Patch B
	edit dd1475d something I want to split
	reword 4ca2acc i cant' typ goods

Now we save and close the editor to begin the rebase. Since the first operation is a squash our editor opens:

	# This is a combination of two commits.
	# The first commit's message is:

	Patch A

	# This is the 2nd commit message:

	something to add to patch A

	# Please enter the commit message for your changes. Lines starting
	# with '#' will be ignored, and an empty message aborts the commit.
	# Not currently on any branch.
	# Changes to be committed:
	#   (use "git reset HEAD <file>..." to unstage)
	#
	# modified:   a
	#

As usual, edit the file as we wish, save, and close the editor. The rebase will proceed until it gets to the edit operation, where it tells us:

	You can amend the commit now, with

	        git commit --amend

	Once you are satisfied with your changes, run

	        git rebase --continue

At this point we would edit the files we need, do a `git commit --amend`, make our second commit, and ensure that our working tree and index are clean. On to the next one! `git rebase --continue`

Finally, git hits our `reword` commit. It opens up the text editor one last time:

	i cant' typ goods

	# Please enter the commit message for your changes. Lines starting
	# with '#' will be ignored, and an empty message aborts the commit.
	# Not currently on any branch.
	# Changes to be committed:
	#   (use "git reset HEAD^1 <file>..." to unstage)
	#
	# modified:   a
	#

Fix, save, and close the editor. Git finishes the rebase and returns us to our command prompt.



<h3>Using --autosquash</h3>

In git 1.7 the `--autosquash` flag was added to `git rebase --interactive`. This option allows you to craft commit messages that tell rebase what you want to do. This is great if you're committing something that you know you want to squash or fixup against an earlier commit.

The basic syntax is to use "squash!" or "fixup!" followed by the first part of the commit message. For example, if we used these commit messages:

	Patch A
	Patch B
	fixup! Patch B
	squash! Patch A

When we run `git rebase --interactive --autosquash` It opens with our commits already where we want them:

	pick 1fc6c95 Patch A
	squash fa39187 squash! Patch A
	pick 6b2481b Patch B
	fixup c619268 fixup! Patch B

If you use autosquash often (who wouldn't?), you can save yourself some typing by telling git to use it by default:

	git config --global rebase.autosquash true



### References

- [Git rebase man page](http://git-scm.com/docs/git-rebase)
- [Progit: Git Branching - Rebasing](http://git-scm.com/book/en/Git-Branching-Rebasing)
- [Progit: Interactive Rebasing](http://git-scm.com/book/en/Git-Tools-Rewriting-History#Changing-Multiple-Commit-Messages)
- [Git ready: squashing commits with rebase](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html)
- [Fun with git rebase --interactive --autosquash](http://technosorcery.net/blog/2010/02/07/fun-with-the-upcoming-1-7-release-of-git-rebase---interactive---autosquash/)