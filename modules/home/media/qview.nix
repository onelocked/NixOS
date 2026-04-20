{
  m.qview =
    { pkgs, lib, ... }:
    {
      hj = {
        packages = [ pkgs.qview ];
        xdg.config.files."qView/qView.conf".text = lib.generators.toINI { } {
          General = {
            configversion = "7.1";
            firstlaunch = true;
            geometry = "@ByteArray(\\x1\\xd9\\xd0\\xcb\\0\\x3\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\aG\\0\\0\\x4R\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\aG\\0\\0\\x4R\\0\\0\\0\\0\\0\\0\\0\\0\\rp\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\aG\\0\\0\\x4R)";
            optionsgeometry = "@ByteArray(\\x1\\xd9\\xd0\\xcb\\0\\x3\\0\\0\\0\\0\\x2\\x95\\0\\0\\0\\xdd\\0\\0\\x4\\x9e\\0\\0\\x3%\\0\\0\\x2\\x95\\0\\0\\0\\xdd\\0\\0\\x4\\x9e\\0\\0\\x3%\\0\\0\\0\\0\\0\\0\\0\\0\\rp\\0\\0\\x2\\x95\\0\\0\\0\\xdd\\0\\0\\x4\\x9e\\0\\0\\x3%)";
            optionstab = 1;
          };
          options = {
            afterdelete = 2;
            allowmimecontentdetection = false;
            askdelete = true;
            bgcolor = "#131316";
            bgcolorenabled = true;
            colorspaceconversion = 1;
            cropmode = 1;
            cursorzoom = true;
            filteringenabled = true;
            fractionalzoom = false;
            fullscreendetails = false;
            language = "system";
            loopfoldersenabled = true;
            maxwindowresizedpercentage = 70;
            menubarenabled = false;
            minwindowresizedpercentage = 20;
            pastactualsizeenabled = false;
            preloadingmode = 1;
            quitonlastwindow = false;
            saverecents = true;
            scalefactor = 5;
            scalingenabled = true;
            scalingtwoenabled = false;
            scrollzoom = 1;
            skiphidden = true;
            slideshowreversed = 0;
            slideshowtimer = 5;
            sortdescending = 0;
            sortmode = 0;
            titlebaralwaysdark = true;
            titlebarmode = 1;
            updatenotifications = false;
            windowresizemode = 0;
          };

          shortcuts = {
            copy = "Ctrl+C, Ctrl+Ins, F16, Copy";
            decreasespeed = "[";
            delete = "Ctrl+Backspace, Del, Ctrl+D";
            deletepermanent = "Shift+Del";
            firstfile = "Home";
            flip = "Ctrl+F";
            fullscreen = "@Invalid()";
            increasespeed = "]";
            lastfile = "End";
            mirror = "F";
            nextfile = "Right";
            nextframe = "N";
            open = "Ctrl+O, Open";
            opencontainingfolder = "@Invalid()";
            openurl = "Ctrl+Shift+O";
            options = "Settings";
            originalsize = "O";
            paste = "Ctrl+V, Ctrl+Shift+Ins, Shift+Ins, F18, Paste";
            pause = "P";
            previousfile = "Left";
            quit = "Ctrl+Q, Exit, Ctrl+W";
            reloadfile = "F5, Refresh";
            rename = "Ctrl+Return, F2, Ctrl+R";
            resetspeed = "\\\\";
            resetzoom = "Ctrl+0";
            rotateleft = "Down";
            rotateright = "Up";
            saveframeas = "Ctrl+S, Save";
            showfileinfo = "I";
            slideshow = "@Invalid()";
            undo = "Ctrl+Z, F14, Undo";
            zoomin = "Ctrl++, Zoom In, \"Ctrl+=\"";
            zoomout = "Ctrl+-, Zoom Out";
          };
        };
      };
    };
}
