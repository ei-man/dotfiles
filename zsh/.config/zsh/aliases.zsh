alias cdtemp="cd $(mktemp -d)"

# git stuff
alias absorb="GIT_SEQUENCE_EDITOR=: git absorb --and-rebase"
alias slabsorb="sl absorb --apply-changes"
alias mend="git commit --all --amend --no-edit && sparc 1"
alias land="arc stack --disable-rebase-check --nounit"
fixup() {
    COMMIT=$(git log HEAD ^origin/main --reverse --format="%H" | sed -n $1p) # get nth commit from a reversed git log
    git commit --all --fixup=$COMMIT
    GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash $COMMIT~1
}
glog() {
    local current_count=$(git rev-list --count origin/main..HEAD) # start counter in reverse

    git log --pretty=format:"%h %s" origin/main..HEAD | while read -r hash title || [ -n "$hash" ]; do
        diff_id=$(git log -1 --format="%B" "$hash" | grep -o "D[0-9]\+" | head -1)
        printf "%3d %s %s -- %s\n" "$current_count" "${diff_id:-(no diff)}" "$hash" "$title"
        ((current_count--))
    done
}

alias gbc="git branch --show-current | tee >(tr -d '\n' | pbcopy)" # copy the current branch name to the clipboard (and still print it)
# git branch's parent
gbp() {
	git show-branch -a 2>/dev/null \
	| sed "s/].*//" \
	| grep "\*" \
	| grep -v "$(git rev-parse --abbrev-ref HEAD)" \
	| head -n1 \
	| sed "s/^.*\[//" \
	| tee >(tr -d '\n' | pbcopy)
}


# bazel
alias bb="bazel build '...'"
# executes bazel test '...' and tries to capture the interesting parts of the output and print them again at the end in red
bt() {
    testOutput="$(bazel test '...' --norun_validations --color=yes 2>&1 | tee /dev/stderr)" # tee to stderr to print the output as it's happening but also capture it in a variable

    highlightedPart=""
    highlighting="false"

    while read -r line; do
        if [[ $line == *"Use --verbose_failures to see the command lines of failed build steps"* ]]; then
            break
        fi

        if [[ $highlighting == "true" ]]; then
            highlightedPart+="$line\n"
        fi

        if [[ $line == *"Use --sandbox_debug to see verbose messages from the sandbox and retain the sandbox build root for debugging"* ]]; then
            highlightedPart="" # if we see the same line again, we need to reset the substring
            highlighting="true"
        fi
    done <<< "$testOutput"

    if [ ! -z "$highlightedPart" -a "$highlightedPart" != " " ]; then # not empty and not space
        RED='\033[0;31m'
        NC='\033[0m' # No Color
        printf "\n\n${RED}${highlightedPart}${NC}"
    fi

    # if bt received "--skip-fix" argument, skip fixing the errors to not get into an infinite loop, probably not the best bash way, but it works ay...
    if [[ $1 == "--skip-fix" ]]; then
        return
    fi


    if [[ $highlightedPart == *"missing strict dependencies"* ]]; then
        printf "\nMissing dependencies detected... Running gazelle...\n"
        gazelle
        printf "\nRe-executing bazel test...\n"
        bt --skip-fix
    fi
}

alias bg="gazelle"
# gazelle on changed directories
bgi() {
    modifiedDirsStr="$(git status --porcelain | cut -f 3 -d ' ' | tr '\n' '\0' | xargs -0 -n1 dirname | uniq | tr '\n' ' ')"
    modifiedDirs=($modifiedDirsStr)
    printf "detected modified dirs: %s\n" "${modifiedDirs[@]}"
    gazelle "${modifiedDirs[*]}"
}

alias bt_debug="bazel test --cache_test_results=no --sandbox_debug '...' --test_env=GO_TEST_WRAP_TESTV=1"
alias btr1="bt_debug --@io_bazel_rules_go//go/config:race"
alias btr10="btr1 --runs_per_test=10"
alias btr100="btr1 --runs_per_test=100"
alias btr1000="btr1 --runs_per_test=1000"
alias btr="btr1 && btr10 && btr100 && btr1000"
alias bta="btra_base --test_output=all"
alias btra="btra_base --@io_bazel_rules_go//go/config:race --runs_per_test=10 --test_output=all"

# clone OC object into a temp directory for some one-shot operation (e.g. land stakeholder's diff)
occlone() {
	cd $(mktemp -d)
	oc clone $@
	cd $@
}
alias occlonef="cd $(mktemp -d) && oc clone" # same as above but allows you to pass more flags than just object name (but doesn't cd inside the cloned dir)

# prettier ls
alias ls="eza --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions"

alias vim="nvim"
alias vi="vim"

