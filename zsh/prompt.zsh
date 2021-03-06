autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  st=$($git status --porcelain 2>/dev/null)
  if [[ $? -ne 0 ]]
  then
    echo ""
  else
    if [[ $st == "" ]]
    then
      echo "[%{$fg[green]%}$(git_prompt_info)$(need_push)%{$reset_color%}]"
    else
      echo "[%{$fg[red]%}$(git_prompt_info)$(need_push)%{$reset_color%}]"
    fi
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) ||
   ref="detached!"
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "${ref#refs/heads/}"
}

unpushed () {
  $git cherry -v @{upstream} 2>/dev/null | wc -l
}

need_push () {
  unicode_arrow_up="\xE2\x86\x91"
  count=$(unpushed)
  if [[ $count == "0" ]]
  then
    echo ""
  else
    echo "%{$fg_bold[white]%}$unicode_arrow_up$count%{$reset_color%}"
  fi
}

ruby_version() {
  if (( $+commands[rbenv] )) && [[ -f .ruby-version ]]
  then
    echo "$(rbenv version | awk '{print $1}')"
  fi
}

rb_prompt() {
  if ! [[ -z "$(ruby_version)" ]]
  then
    echo "%{$fg_bold[white]%}(%{$reset_color%}%{$fg_bold[red]%}$(ruby_version)%{$reset_color%}%{$fg_bold[white]%})%{$reset_color%}"
  else
    echo ""
  fi
}

directory_name() {
  echo "%{$fg_bold[green]%}%c%{$reset_color%}"
}

export PROMPT=$'$(directory_name)$(git_dirty) $ '
set_prompt () {
  export RPROMPT="%{$fg_bold[cyan]%}$(rb_prompt)%{$reset_color%}"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}
