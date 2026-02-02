# Completions
let carapace_completer = {|spans: list<string>|
  carapace $spans.0 nushell ...$spans
  | from json
  | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
}

# Nushell configuration settings
$env.config = {
  highlight_resolved_externals: true,
  show_banner: false,
  completions: {
    case_sensitive: false # case-sensitive completions
    quick: true          # set to false to prevent auto-selecting completions
    partial: true        # set to false to prevent partial filling of the prompt
    algorithm: "fuzzy"   # prefix or fuzzy
    external: {
      # set to false to prevent nushell looking into $env.PATH to find more suggestions
      enable: true
      # set to lower can improve completion performance at the cost of omitting some options
      max_results: 100
      completer: $carapace_completer
    }
  }
}

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
