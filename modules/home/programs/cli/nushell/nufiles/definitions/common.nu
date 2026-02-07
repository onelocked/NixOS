# Common ls aliases and sort them by type and then name
def lla [...args] { ls -la ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }
def la  [...args] { ls -a  ...(if $args == [] {["."]} else {$args}) | sort-by type name -i }

alias ff = fastfetch
alias fastfetish = fastfetch

def nrun [package: string] {
    ^nix run $"nixpkgs#($package)"
}

def nget [package: string] {
    ^nix shell $"nixpkgs#($package)"
}



def nix-develop [] {
    nix develop -c nu
}
