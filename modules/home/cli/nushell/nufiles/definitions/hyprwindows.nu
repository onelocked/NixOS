# Custom command to list Hyprland clients neatly
def hyprwindows [] {
    hyprctl clients -j | from json | each { |client|
        {
            title: $client.title,
            class: $client.class,
            size: ( ($client.size | get 0 | into string) + "x" + ($client.size | get 1 | into string) ),
            at: ( ($client.at | get 0 | into string) + "," + ($client.at | get 1 | into string) )
        }
    } | select class size at title
}
