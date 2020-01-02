#/usr/bin/env bash
LIST_COMMANDS=(remove view edit)
OTHERS=(add list shop datadir export)
COMMANDS=("${LIST_COMMANDS[@]}" "${OTHERS[@]}")

RECIPES=()

_refreshRecipes(){
	# The following grep matches lines starting with a number, dot and space.
	# Then keeps just the recipe name, discarding the number, dot and space. 
	recipeNames=$(herms list | grep -oP '(^[0-9].[[:space:]])\K.*') 
	readarray -t RECIPES <<<"$recipeNames"
}

_listToString(){
	arr=("$@")
	for i in "${arr[@]}"; do 
		echo "$i"
	done
}

_hermsCommandCompletions(){
	_refreshRecipes
	local cur prev

    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

	if [ ${#COMP_WORDS[@]} -gt 3 ]; then
    	return
    fi

    case ${COMP_CWORD} in
        1)
			mapfile -t patterns < <( _listToString "${COMMANDS[@]}" )
			mapfile -t COMPREPLY < <( compgen -W "$( printf '%q ' "${patterns[@]}" )" -- "$cur" | awk '/ / { print "\""$0"\"" } /^[^ ]+$/ { print $0 }' )
            ;;
        2)
			if [[ " ${LIST_COMMANDS[*]} " == *"${prev}"* ]]; then
				mapfile -t patterns < <( _listToString "${RECIPES[@]}" )
				mapfile -t COMPREPLY < <( compgen -W "$( printf '%q ' "${patterns[@]}" )" -- "$cur" | awk '/ / { print "\""$0"\"" } /^[^ ]+$/ { print $0 }' )
			else
				COMPREPLY=()
			fi
			;;
        *)
            COMPREPLY=()
            ;;
    esac
}
complete -F  _hermsCommandCompletions herms
# _listToString "${RECIPES[@]}"
# _refreshRecipes