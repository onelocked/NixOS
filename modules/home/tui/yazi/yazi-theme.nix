{
  m.yazi =
    { lib, ... }:
    let
      c = {
        fg = "#e5e1e6";
        bg = "#131316";
        primary = "#c5c0ff";
        onPrimary = "#2a2277";
        alt = "#c7c4dc";
        altFg = "#c8c5d0";
        altBg = "#47464f";
        pink = "#ebb9d0";
        pinkFg = "#472538";
        red = "#ffb4ab";
        redBg = "#93000a";
        redFg = "#ffdad6";
        marker = "#603b4f";
        copiedFg = "#ffd8e9";
        sepBlue = "#413b8e";
        selectFg = "#302e42";
        devDir = "#96ca6b";
        nixDir = "#7ebae4";
        imageFt = "#94e2d5";
        mediaFt = "#f9e2af";
        archiveFt = "#f5c2e7";
        docFt = "#a6e3a1";
        white = "#FFFFFF";
      };
    in
    {
      custom.programs.yazi = {
        theme.flavor = lib.genAttrs [ "dark" "light" ] (_: "oneshill");
        flavorContent = # toml
          ''
            [mgr]
            cwd = { fg = "${c.fg}" }

            find_keyword = { fg = "${c.red}", bold = true, italic = true, underline = true }
            find_position = { fg = "${c.red}", bold = true, italic = true }

            marker_copied = { fg = "${c.marker}", bg = "${c.marker}" }
            marker_cut = { fg = "${c.marker}", bg = "${c.marker}" }
            marker_marked = { fg = "${c.red}", bg = "${c.red}" }
            marker_selected = { fg = "${c.pink}", bg = "${c.pink}" }

            count_copied = { fg = "${c.copiedFg}", bg = "${c.marker}" }
            count_cut = { fg = "${c.copiedFg}", bg = "${c.marker}" }
            count_selected = { fg = "${c.onPrimary}", bg = "${c.pink}" }

            border_style  = { fg = "${c.primary}" }


            [indicator]
            padding = { open = "▐", close = "▌" }


            [status]
            overall = { fg = "${c.primary}" }
            sep_left  = { open = "", close = "" }
            sep_right = { open = "", close = "" }

            progress_label = { bold = true }
            progress_normal = { fg = "${c.primary}", bg = "${c.bg}" }
            progress_error = { fg = "${c.red}", bg = "${c.bg}" }

            perm_type = { fg = "${c.alt}" }
            perm_write = { fg = "${c.pink}" }
            perm_exec = { fg = "${c.red}" }
            perm_read = { fg = "${c.marker}" }
            perm_sep = { fg = "${c.sepBlue}" }


            [mode]

            normal_main = { bg = "${c.primary}", fg = "${c.onPrimary}", bold = true }
            normal_alt  = { bg = "${c.altBg}", fg = "${c.altFg}" }

            select_main = { bg = "${c.alt}", fg = "${c.selectFg}", bold = true }
            select_alt  = { bg = "${c.altBg}", fg = "${c.altFg}" }

            unset_main = { bg = "${c.pink}", fg = "${c.pinkFg}", bold = true }
            unset_alt  = { bg = "${c.altBg}", fg = "${c.altFg}" }


            [input]
            border = { fg = "${c.primary}" }
            title = {}
            value = { fg = "${c.fg}" }
            selected = { reversed = true }

            [tabs]
            active = { fg = "${c.bg}", bold = true, bg = "${c.primary}" }
            inactive = { fg = "${c.alt}", bg = "${c.bg}" }
            sep_inner = { open = "", close = "" }

            [cmp]
            border = { fg = "${c.primary}", bg = "${c.onPrimary}" }

            [tasks]
            border = { fg = "${c.primary}" }
            title = {}
            hovered = { fg = "${c.marker}", underline = true }


            [which]
            cols = 3
            mask = { bg = "${c.bg}" }
            cand = { fg = "${c.primary}" }
            rest = { fg = "${c.onPrimary}" }
            desc = { fg = "${c.fg}" }
            separator = " ▶ "
            separator_style = { fg = "${c.fg}" }

            [spot]
            border   = { fg = "${c.primary}" }
            title    = { fg = "${c.primary}" }
            tbl_col  = { fg = "${c.fg}" }
            tbl_cell = { fg = "${c.fg}", bg = "${c.bg}" }


            [help]
            on = { fg = "${c.fg}" }
            run = { fg = "${c.fg}" }
            hovered = { reversed = true, bold = true }
            footer = { fg = "${c.selectFg}", bg = "${c.alt}" }

            [notify]
            title_info = { fg = "${c.pink}" }
            title_warn = { fg = "${c.primary}" }
            title_error = { fg = "${c.red}" }

            [filetype]

            rules = [
                { mime = "image/*", fg = "${c.imageFt}" },
                { mime = "{audio,video}/*", fg = "${c.mediaFt}" },
                { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "${c.archiveFt}" },
                { mime = "application/{pdf,doc,rtf}", fg = "${c.docFt}" },
                { mime = "*", is = "orphan", fg = "${c.redFg}", bg = "${c.redBg}" },
                { mime = "application/*exec*", fg = "${c.red}" },
                { url = "*", fg = "${c.fg}" },
                { url = "*/", fg = "${c.primary}" },
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
