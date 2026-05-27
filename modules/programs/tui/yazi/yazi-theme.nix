{
  m.yazi =
    { lib, scheme, ... }:
    let
      c = with scheme.withHashtag; {
        fg = base05; # Default foreground
        bg = base00; # Default background
        primary = base0D; # Navy — main UI accent
        onPrimary = base07; # Near-black — readable on navy
        alt = base06; # Light foreground
        altFg = base05; # Default foreground
        altBg = base03; # Comments/muted — subtle bg
        pink = base0E; # Mauve/violet
        pinkFg = base17; # Selection bg — light enough on mauve
        red = base08; # Red
        redBg = base10; # Darker background
        redFg = base06; # Light foreground on red bg
        marker = base0F; # Selection background
        copiedFg = base17; # Bright magenta
        sepBlue = base0D; # Navy — consistent with primary
        selectFg = base01; # Borders/lighter bg
        devDir = base0B; # Green
        nixDir = base16; # Bright violet
        imageFt = base15; # Petrol blue
        mediaFt = base0A; # Yellow/olive
        archiveFt = base0F; # Warm brown — fitting for archives
        docFt = base14; # Bright green
        white = base07; # Lightest foreground
      };
    in
    {
      forte.yazi = with scheme.withHashtag; {
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
                { name = ".config", text = "", fg = "${base0D}" },
                { name = ".git", text = "", fg = "${base0D}" },
                { name = ".github", text = "", fg = "${base0D}" },
                { name = ".npm", text = "", fg = "${base0D}" },
                { name = "Desktop", text = "", fg = "${base0D}" },
                { name = "Development", text = "", fg = "${base0B}" }, # Mapped to Green
                { name = "Documents", text = "", fg = "${base0D}" },
                { name = "Downloads", text = "", fg = "${base0D}" },
                { name = "NixOS", text = "", fg = "${base0C}" }, # Mapped to Cyan
                { name = "Library", text = "", fg = "${base0D}" },
                { name = "Movies", text = "", fg = "${base0D}" },
                { name = "Music", text = "", fg = "${base0D}" },
                { name = "Pictures", text = "", fg = "${base0D}" },
                { name = "Public", text = "", fg = "${base0D}" },
                { name = "Videos", text = "", fg = "${base0D}" },
            ]
              conds = [
                # Special files
                { if = "orphan", text = "", fg = "${base08}" }, # Mapped to Red
                { if = "link", text = "", fg = "${base03}" }, # Mapped to Muted Grey
                { if = "block", text = "", fg = "${base0D}" },
                { if = "char", text = "", fg = "${base0D}" },
                { if = "fifo", text = "", fg = "${base0D}" },
                { if = "sock", text = "", fg = "${base0D}" },
                { if = "sticky", text = "", fg = "${base0D}" },
                { if = "dummy", text = "", fg = "${base0D}" },

                # Fallback
                { if = "dir", text = "", fg = "${base0D}" },
                { if = "exec", text = "", fg = "${base08}" }, # Mapped to Red
                { if = "!dir", text = "", fg = "${base05}" }, # Mapped to Default Fg
            ]
          '';
      };
    };
}
