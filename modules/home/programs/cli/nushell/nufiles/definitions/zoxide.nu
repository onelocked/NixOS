def --env Z [] {
  let dir = (zoxide query --interactive | str trim)

  if ($dir | is-not-empty) {
    cd $dir
    y
  }
}
