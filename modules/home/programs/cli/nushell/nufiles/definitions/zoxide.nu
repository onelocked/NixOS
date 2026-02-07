# --- Zoxide interactive on Shift+Z ---
$env.config.keybindings ++= [
  {
    name: zoxide_interactive
    modifier: shift
    keycode: char_z
    mode: [emacs, vi_normal, vi_insert]
    event: {
      send: executehostcommand
      cmd: "Z"
    }
  }
]

def --env Z [] {
  let dir = (zoxide query --interactive | str trim)

  if ($dir | is-not-empty) {
    cd $dir
    y
  }
}
