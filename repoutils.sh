#!/bin/bash
makefilepath=$PWD/Makefile
gitignorepath=$PWD/.gitignore
reset="$(tput sgr0)"
ignore=(
     "cmake-build-debug"
     "CMakeLists.txt"
     ".idea"
     "a.out"
     "*.o"
     "*.old"
     "*.sh"
     "*.txt"
     )


get_font() {
    echo "$(tput bold)$(tput smul)$(tput setaf $1)"
}

get_verbose(){
    echo "$(tput rmso)$(tput setaf $1)"
}
#$1 = file pathf
read_file() {
    echo $(head -n 1 $1)
}

if [ -f "$HOME/.login" ]; then
        mail=$(head -n 1 $HOME/.login)
        clearpwd=$(sed -n '2p' < $HOME/.login)
else
    echo $(get_verbose 1)"No login found$reset"
    read -e -p $(get_verbose 3)"Enter your login :$reset " mail
    read -e -p $(get_verbose 3)"Enter your pwd : $reset " clearpwd
    touch $HOME/.login
    echo "$mail" >> $HOME/.login
    echo "$clearpwd" >> $HOME/.login
fi

pwd=$(echo -n "$(echo -n "$clearpwd" | sha512sum )" | rev | cut -c 4- | rev)






header="PEDRIIIITOOOO !$reset"
#$1 = project name
get_makefile(){
    echo -e "##
## EPITECH PROJECT, 2018
## $1
## File description:
## Project made by $mail
##

IFLAG           =       -I./
CFLAGS          +=      -W -Wall -Wextra \$(IFLAG)
RM              =       rm -rf
CC              =       gcc

$1		=	$1
$1_OBJS		=	\$($1_SRCS:.c=.o)

$1_SRCS		=

all	:	\$($1)

\$($1)	:	\$($1_OBJS)
		\$(CC) -o \$($1) \$($1_OBJS)

clean	:
		\$(RM) \$($1_OBJS)
		@\$(RM) *.c~
		@\$(RM) *#

fclean	:	clean
		\$(RM) \$($1)

re	:	fclean all

.PHONY	:	all clean fclean re

.SUFFIXES	:	.c .o"
}

#$1 = name
#$2 = path
 create_makefile() {
    if [ "$#" -lt 2 ]; then
        echo $(get_verbose 2)"Usage: $0 -Makefile <project_name>$reset"
        exit 84
    fi
    if [ -f "$2" ]; then
        echo $(get_font 1)"a Makefile already exist."
        read -e -p "Replace it ? (y/n) : $reset" answer
        if [ "$answer" = "y" ]; then
            rm $2
            touch $2
            echo  "$(get_makefile $1)" >> $2
            echo $(get_verbose 2)"Makefile created"
        else
            exit 0
        fi
    else
        touch $2
        echo   "$(get_makefile $1)" >> $2
    fi
    }

clean_repo() {
# RM
echo "$(tput bold)$(tput smul)$(tput setaf 3)Cleaning repo $reset"$(get_verbose 4)

echo -n "$reset"

# Makefile
if [  -f "$makefilepath" ]; then
     echo $(get_verbose 2)"Makefile Found ! $reset"
    makefileCat=`cat "$makefilepath"`
	cleanRule=$(echo "$makefileCat" | awk '$0 ~ /^clean[\t ]*:/ {print}')
	fcleanRule=$(echo "$makefileCat" | awk '$0 ~ /^fclean[\t ]*:/ {print}')
	if [ "$fcleanRule" != "" ]
        then
        echo $(get_verbose 4)"executing fClean $reset$(get_verbose 5)"
        make fclean
    elif [ "$cleanRule" != "" ]
    then
        echo $(get_verbose 4)"executing Clean $reset"
        make clean
    else
        echo  $(get_verbose 2)"No make fclean / clean rules found $reset"
	fi
else
    echo $(get_font 1)"No Makefile found $reset"
    read -e -p "$(get_verbose 2)Generate a makefile ? (y/n) :$reset " answer
    if [ "$answer" = "y" ]; then
        read -e -p "$(get_verbose 4)Project name :$reset " answer
        create_makefile $answer $makefilepath
        echo -n $(get_verbose 5)
        make fclean
        echo -n "$reset"
    else
        rm -rfv *~ *.o
    fi
fi
# Clean done
echo $(get_font 3)"Repo cleaned $reset"
}



#$1 = path
create_git_ignore() {
if [ -f "$1" ]; then
    #EXIST
    echo $(get_font 2)".gitignore already exist $reset"
     for i in "${ignore[@]}"
     do
        if ! grep -q "$i" "$1"; then
            echo $(get_verbose 5)"added $i to gitignore $reset"
            echo "$i" >> $1
        fi
     done
    if [ -f "./$0" ]
    then
         if ! grep -q "$(echo $0 | cut -c 3-)" "$1"; then
            echo $(get_verbose 5)"$0 added to .gitignore $reset"
            echo -e "$(echo $0 | cut -c 3-)" >> $1
         fi
    fi
else
    #DOESNT EXIST
    touch .gitignore
    if [ $? -eq 0 ];
    then
        echo $(get_font 2)"Created .gitignore $reset"
        for i in "${ignore[@]}"
        do
            echo -e "$i" >> $1
            echo $(get_verbose 5)"Added $i to .gitignore $reset"
        done
         if [ -f "./$0" ]
        then
            echo -e "$(echo $0 | cut -c 3-)" >> $1
         fi
    else
        echo $(get_verbose 1)"Creation of gitignore failed $reset"
    fi
fi
}

#$1 = repo name
clone_repo() {
 git clone git@git.epitech.eu:/$mail/$1
 if [ $? -eq 0 ];
        then
        echo $(get_font 2)"Repository $1 cloned $reset"
              read -e -p $(get_verbose 2)"generate Makefile ? (y/n) $reset" answer
              if [ "$answer" = "y" ]; then
                  read -e -p "Project name : " answer
                  echo "PATH : $PWD/$1/$makefilepath"
                  create_makefile $answer $PWD/$1/Makefile
                  echo $(get_font 2)"Created Makefile $reset"
              fi
              read -e -p $(get_verbose 2)"generate .gitignore ? (y/n) $reset" answer
              if [ "$answer" = "y" ]; then
                  create_git_ignore $PWD/$1/.gitignore
              fi
            else
            echo $(get_font 2)"Clone Failed $reset"
            exit 84
        fi
}

display_help() {
    echo -e "Usage : \t[ -clean ]
    \t\t[ -norme < --install > ]
    \t\t[ -push < --all] > ] (clean the repo)
    \t\t[ -create [ repository ] < --clone > ]
    \t\t[ -clone [ repository ] ]
    \t\t[ -delete [ repository ] ]
    \t\t[ -acl < repository > ]
    \t\t[ -give < repository > [user] ]
    \t\t[ -list < search > ]
    \t\t[ -makefile [ project_name ] < path > ] (generate Makefile)
    \t\t[ -gitI < path > ] (generate a .gitignore file)
    \t\t[ -login ] (change the login)
    \t\t[ --help ] (display help)
    \t\t[ --install ]"
}

##Start



 echo -e "$(tput reset)$(get_font 1)Login :$reset $(get_verbose 2)$mail$reset"



if [ "$1" = "-update" ]; then
  if [ -f "/home/repoutils/repoutils.sh" ]; then
   sudo git fetch origin
   reslog=$(git log HEAD..origin/master --oneline)
   if [[ "${reslog}" != "" ]] ; then
    # Changes
    echo "$(get_verbose 2)New update available ! $reset"
    sudo git --git-dir=/home/repoutils/.git --work-tree=/home/repoutils fetch --all
    sudo git --git-dir=/home/repoutils/.git --work-tree=/home/repoutils reset --hard origin/master
    sudo git --git-dir=/home/repoutils/.git --work-tree=/home/repoutils pull origin master
    if [ $? -eq 0 ]; then
      echo "$(get_verbose 3)Updated !$reset"
    else
      echo "$(get_verbose 2)Update failed !$reset"
    fi
  else
    # No changes
    echo "$(get_verbose 2)No updates available$reset"
  fi
 fi
  exit 0
fi

 if [ "$#" -lt 1 ]; then
    display_help
    exit 0
 fi


 #CHANGE LOGIN
 if [ "$1" = "-login" ]; then
    if [ "$#" -lt 1 ]; then
              echo $(get_verbose 2)"Usage : $0 [ -login ]"
              exit 84
    fi
    read -e -p $(get_verbose 3)"New login : $reset" answer
    if [ ! -f "$HOME/.login" ]; then
        touch $HOME/.login
    fi
    read -e -p $(get_verbose 3)"New password : $reset" pass
    echo -e "$answer\n$pass" > $HOME/.login
    echo $(get_verbose 2)"Login changed."
    exit 0
 fi

#HELP
if [ "$1" = "--help" ]; then
    display_help
    exit 0
fi

if [ "$1" = "read" ]; then
    read_file $2
fi


#CLEAN
if [ "$1" = "-clean" ]; then
    clean_repo
    exit 0
fi

#Makefile
if [ "$1" = "-makefile" ]; then
    read -e -p $(get_verbose 4)"Project name : $reset" answer
    if [ -z "$2" ]; then
        create_makefile $answer $makefilepath
    else
        create_makefile $answer $2/./Makefile
    fi
    exit 0
fi

#GitIgnore
if [ "$1" = "-gitI" ]; then
    if [ -z "$2" ]; then
        create_git_ignore $gitignorepath
    else
        create_git_ignore $2/./.gitignore
    fi
    exit 0
fi

#BLIH DELETE
if [ "$1" = "-delete" ]; then
    if [ "$#" -lt 2 ];then
        echo $(get_verbose 2)"[ -delete [ repository ] ]"
        exit 84
    fi
    blih -u "$mail" -t "$pwd" repository delete $2
    exit 0
fi

#BLIH CREATE
if [ "$1" = "-create" ]; then
    if [ "$#" -lt 2 ]; then
        echo $(get_verbose 2)"[ -create [ repository ] < --clone > ]"
        exit 84
    fi
    blih -u "$mail" -t "$pwd"  repository create $2
     if [ !  $? -eq 0 ];
     then
        echo $(get_font 1)"Creation of repository $2 failed $reset"
	exit 84
     fi
      blih -u "$mail" -t "$pwd" repository setacl $2 ramassage-tek r
      if [ $? -eq 0 ];
      then
            echo $(get_verbose 2)"acl ramassage-tek added to repository $2 created $reset"
      else
            exit 84
      fi
    if [ "$3" = "--clone" ]; then
	#BLIH CLONE
    clone_repo $2
    else
        read -e -p "Clone the repo ? (y/n) : $reset" answer
        if [ "$answer" = "y" ]; then
            clone_repo $2
        fi
    fi
    exit 0
fi

if [ "$1" = "-give" ]; then
  if [ "$#" -eq 3 ]; then
    blih -u "$mail" -t "$pwd" repository setacl $2 $3 rw
  else
if [ ! -f ".git/config" ]; then
    echo $(get_font 1)"Not in a git repository$reset"
    exit 84
fi
url=$(cat .git/config | grep "url")
reponame=$(basename "$url")
blih -u "$mail" -t "$pwd" repository setacl $reponame $2 rw

  fi
  exit 0
fi


if [ "$1" = "-clone" ]; then
    if [ "$#" -ne 2 ]; then
        echo $(get_verbose 2)"Usage : $0 -clone [repository]."
    exit 84
    fi
    clone_repo $2
    exit 0
fi

# Repo acl
if [ "$1" = "-acl" ]; then
    if [ "$#" -eq 2 ]; then
	blih -u "$mail" -t "$pwd" repository  getacl $2
    else
	if [ ! -f ".git/config" ]; then
	    echo $(get_font 1)"Not in a git repository$reset"
	    exit 84
	fi
	url=$(cat .git/config | grep "url")
	reponame=$(basename "$url")
    blih -u "$mail" -t "$pwd" repository  getacl $reponame
    fi
    exit 0
fi

# List repo

if [ "$1" = "-list" ]
then
    if [ "$#" -gt 1 ]; then
      blih -u "$mail" -t "$pwd" repository list | grep "$2"
    else
      blih -u "$mail" -t "$pwd" repository list
    fi
    exit 0
fi

#Norme
if [ "$1" = "-norme" ]; then
    if [ "$2" = "--install"  ]; then
        ruby -h > /.r
        if [ ! $? -eq 0 ]; then
            sudo apt-get install ruby
        fi
        git clone https://github.com/ronanboiteau/NormEZ
        sudo mv NormEZ /home/
    fi
    ruby /home/NormEZ/./NormdEZ.rb -m | grep -vi "cmake" | grep -v "\.sh" | grep -v "\.o" | grep -v "\.so"
    if [ ! $? -eq 0 ]; then
        echo $(get_verbose 1)"Error : $reset Try to reinstall the norme checker"
    fi
    exit 0;
fi

#SL
if [ "$1" = "-sl" ]; then
    sl
    if [ ! $? -eq 0 ]; then
        sudo apt-get install sl
        sl
    fi
    exit 0
fi

# INSTALL
if [ "$1" = "--install" ]; then
    name="$(echo $0 | cut -c 3-)";
    #COPY TO HOME
    if [ -f "/home/repoutils/repoutils.sh" ]; then
        echo $(get_verbose 1)"You already have the script in your /home$reset"
    else
        git clone https://github.com/BarrosoK/repoutils.git
        sudo mv repoutils /home/
    fi
    read -p $(get_verbose 2)"Alias name : $reset$(get_verbose 3)" alias
    #ZSH
    if [ -f "$HOME/.zshrc" ]; then
        grep -q "alias $alias" "$HOME/.zshrc"
        if [ $? -eq 0 ]; then
            echo $(get_verbose 1)"You already have an alias '$alias' in zsh$reset"
        else
            echo "alias $alias='/home/repoutils/./repoutils.sh ' " >> $HOME/.zshrc
            echo $(get_verbose 2)"Alias '$alias' added to $reset"$(get_verbose 3)"ZSH$reset"
            zsh
        fi
    fi
    #BASH
    if [ -f "$HOME/.bashrc" ]; then
        grep -q "alias $alias" "$HOME/.zshrc"
        if [ $? -eq 0 ]; then
            echo $(get_verbose 1)"You already have an alias '$alias' in bash$reset"
        else
            echo "alias $alias='/home/repoutils/./repoutils.sh ' " >> $HOME/.bashrc
            echo $(get_verbose 2)"Alias '$alias' added to $reset"$(get_verbose 3)"bash$reset"
            bash
        fi
    fi
    exit 0
fi

# Git part rfgrege
if [ "$1" = "-push" ]
then
    clean_repo
    echo ""
    if [ "$2" = "--all" ]
    then
        echo $(get_font 1) "Push All $reset"
        git add .
    else
        read -e -p "Files to push : " files
        git add $files
    fi
    if [ ! $? -eq 0 ]; then
        echo $(get_font 1)"Push failed."
        exit 84
    fi
     read -e -p "Commit description: " desc
     git commit -m "$desc" && \
     git push origin master
    if [ $? -eq 0 ]; then
        echo $(get_font 2) "Push done $reset"
    else
        echo $(get_font 1) "Push failed $reset"
    fi
    exit 0
fi

echo $(get_verbose 1)"Invalid command :$reset '$1'"
display_help
exit -1
