{
  m.yazi = {
    custom.programs.yazi = {
      theme.flavor = {
        dark = "oneshill";
        light = "oneshill";
      };
      flavorContent = # toml
        ''
          [mgr]
          cwd = { fg = "#e5e1e6" }

          find_keyword = { fg = "#ffb4ab", bold = true, italic = true, underline = true }
          find_position = { fg = "#ffb4ab", bold = true, italic = true }

          marker_copied = { fg = "#603b4f", bg = "#603b4f" }
          marker_cut = { fg = "#603b4f", bg = "#603b4f" }
          marker_marked = { fg = "#ffb4ab", bg = "#ffb4ab" }
          marker_selected = { fg = "#ebb9d0", bg = "#ebb9d0" }

          count_copied = { fg = "#ffd8e9", bg = "#603b4f" }
          count_cut = { fg = "#ffd8e9", bg = "#603b4f" }
          count_selected = { fg = "#2a2277", bg = "#ebb9d0" }

          border_style  = { fg = "#c5c0ff" }


          [indicator]
          padding = { open = "▐", close = "▌" }


          [status]
          overall = { fg = "#c5c0ff" }
          sep_left  = { open = "", close = "" }
          sep_right = { open = "", close = "" }

          progress_label = { bold = true }
          progress_normal = { fg = "#c5c0ff", bg = "#131316" }
          progress_error = { fg = "#ffb4ab", bg = "#131316" }

          perm_type = { fg = "#c7c4dc" }
          perm_write = { fg = "#ebb9d0" }
          perm_exec = { fg = "#ffb4ab" }
          perm_read = { fg = "#603b4f" }
          perm_sep = { fg = "#413b8e" }


          [mode]

          normal_main = { bg = "#c5c0ff", fg = "#2a2277", bold = true }
          normal_alt  = { bg = "#47464f", fg = "#c8c5d0" }

          select_main = { bg = "#c7c4dc", fg = "#302e42", bold = true }
          select_alt  = { bg = "#47464f", fg = "#c8c5d0" }

          unset_main = { bg = "#ebb9d0", fg = "#472538", bold = true }
          unset_alt  = { bg = "#47464f", fg = "#c8c5d0" }


          [input]
          border = { fg = "#c5c0ff" }
          title = {}
          value = { fg = "#e5e1e6" }
          selected = { reversed = true }

          [tabs]
          active = { fg = "#131316", bold = true, bg = "#c5c0ff" }
          inactive = { fg = "#c7c4dc", bg = "#131316" }
          sep_inner = { open = "", close = "" }

          [cmp]
          border = { fg = "#c5c0ff", bg = "#2a2277" }

          [tasks]
          border = { fg = "#c5c0ff" }
          title = {}
          hovered = { fg = "#603b4f", underline = true }


          [which]
          cols = 3
          mask = { bg = "#131316" }
          cand = { fg = "#c5c0ff" }
          rest = { fg = "#2a2277" }
          desc = { fg = "#e5e1e6" }
          separator = " ▶ "
          separator_style = { fg = "#e5e1e6" }

          [spot]
          border   = { fg = "#c5c0ff" }
          title    = { fg = "#c5c0ff" }
          tbl_col  = { fg = "#e5e1e6" }
          tbl_cell = { fg = "#e5e1e6", bg = "#131316" }


          [help]
          on = { fg = "#e5e1e6" }
          run = { fg = "#e5e1e6" }
          hovered = { reversed = true, bold = true }
          footer = { fg = "#302e42", bg = "#c7c4dc" }

          [notify]
          title_info = { fg = "#ebb9d0" }
          title_warn = { fg = "#c5c0ff" }
          title_error = { fg = "#ffb4ab" }

          [filetype]

          rules = [
              # Images
              { mime = "image/*", fg = "#94e2d5" },

              # Media
              { mime = "{audio,video}/*", fg = "#f9e2af" },

              # Archives
              { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "#f5c2e7" },

              # Documents
              { mime = "application/{pdf,doc,rtf}", fg = "#a6e3a1" },

              # Special files
              { mime = "*", is = "orphan", fg = "#ffdad6", bg = "#93000a" },
              { mime = "application/*exec*", fg = "#ffb4ab" },

              # Fallback
              { url = "*", fg = "#e5e1e6" },
              { url = "*/", fg = "#c5c0ff" },
          ]

          [icon]
          globs = []
          dirs  = [
          	{ name = ".config", text = "", fg = "#c5c0ff" },
          	{ name = ".git", text = "", fg = "#c5c0ff" },
          	{ name = ".github", text = "", fg = "#c5c0ff" },
          	{ name = ".npm", text = "", fg = "#c5c0ff" },
          	{ name = "Desktop", text = "", fg = "#c5c0ff" },
          	{ name = "Development", text = "", fg = "#96ca6b" },
          	{ name = "Documents", text = "", fg = "#c5c0ff" },
          	{ name = "Downloads", text = "", fg = "#c5c0ff" },
          	{ name = "NixOS", text = "", fg = "#7ebae4" },
          	{ name = "Library", text = "", fg = "#c5c0ff" },
          	{ name = "Movies", text = "", fg = "#c5c0ff" },
          	{ name = "Music", text = "", fg = "#c5c0ff" },
          	{ name = "Pictures", text = "", fg = "#c5c0ff" },
          	{ name = "Public", text = "", fg = "#c5c0ff" },
          	{ name = "Videos", text = "", fg = "#c5c0ff" },
          ]
          conds = [
          	# Special files
          	{ if = "orphan", text = "", fg = "#c5c0ff" },
          	{ if = "link", text = "", fg = "#e5e1e6" },
          	{ if = "block", text = "", fg = "#c5c0ff" },
          	{ if = "char", text = "", fg = "#c5c0ff" },
          	{ if = "fifo", text = "", fg = "#c5c0ff" },
          	{ if = "sock", text = "", fg = "#c5c0ff" },
          	{ if = "sticky", text = "", fg = "#c5c0ff" },
          	{ if = "dummy", text = "", fg = "#c5c0ff" },

          	# Fallback
          	{ if = "dir", text = "", fg = "#c5c0ff" },
          	{ if = "exec", text = "", fg = "#ffb4ab" },
          	{ if = "!dir", text = "", fg = "#FFFFFF" },
          ]
        '';
    };
  };
}
