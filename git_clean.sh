#!/bin/bash


# n - dry run; f - force to clean; X - ignored files only
clean_cmd="git clean -fX :/"     # :/ is the magic pathspec used by git
git_prompt=$(git clean -nX :/)  # :/ is the magic pathspec used by git

echo "$git_prompt"
[ "$git_prompt" == "" ] && echo "Folder already clean. Exit." && exit

echo "You sure to delete all these files? ($clean_cmd)[Y/n]"
read response
[ "$response" != "Y" ] && [ "$response" != "y" ]      \
                       && echo "User canceled. Exit." \
		       && exit

# Either 'Y' or 'y' is entered. Execute the command.
exec $clean_cmd
