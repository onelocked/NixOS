{
  flake.modules.nixos.vesktop =
    { pkgs, ... }:
    {
      hj = {
        packages = [ pkgs.vesktop ];
        xdg.config.files."vesktop/settings/settings.json".text = # json
          ''
            {
              "autoUpdate": false,
              "autoUpdateNotification": false,
              "cloud": {
                "authenticated": false,
                "settingsSync": false,
                "settingsSyncVersion": 1773894758681,
                "url": ""
              },
              "disableMinSize": false,
              "eagerPatches": false,
              "enableReactDevtools": false,
              "enabledThemes": [],
              "frameless": false,
              "notifications": {
                "logLimit": 50,
                "position": "bottom-right",
                "timeout": 5000,
                "useNative": "not-focused"
              },
              "plugins": {
                "AccountPanelServerProfile": {
                  "enabled": false
                },
                "AlwaysAnimate": {
                  "enabled": false
                },
                "AlwaysExpandRoles": {
                  "enabled": false
                },
                "AlwaysTrust": {
                  "enabled": false
                },
                "AnonymiseFileNames": {
                  "enabled": false
                },
                "AppleMusicRichPresence": {
                  "enabled": false
                },
                "BadgeAPI": {
                  "enabled": true
                },
                "BetterFolders": {
                  "enabled": false
                },
                "BetterGifAltText": {
                  "enabled": false
                },
                "BetterGifPicker": {
                  "enabled": false
                },
                "BetterNotesBox": {
                  "enabled": false
                },
                "BetterRoleContext": {
                  "enabled": false
                },
                "BetterRoleDot": {
                  "bothStyles": false,
                  "copyRoleColorInProfilePopout": false,
                  "enabled": true
                },
                "BetterSessions": {
                  "enabled": false
                },
                "BetterSettings": {
                  "enabled": false
                },
                "BetterUploadButton": {
                  "enabled": false
                },
                "BiggerStreamPreview": {
                  "enabled": false
                },
                "BlurNSFW": {
                  "enabled": false
                },
                "CallTimer": {
                  "enabled": false
                },
                "ChatInputButtonAPI": {
                  "enabled": true
                },
                "ClearURLs": {
                  "enabled": false
                },
                "ClientTheme": {
                  "enabled": false
                },
                "ColorSighted": {
                  "enabled": false
                },
                "CommandsAPI": {
                  "enabled": true
                },
                "ConsoleJanitor": {
                  "enabled": false
                },
                "ConsoleShortcuts": {
                  "enabled": false
                },
                "CopyEmojiMarkdown": {
                  "enabled": false
                },
                "CopyFileContents": {
                  "enabled": false
                },
                "CopyStickerLinks": {
                  "enabled": false
                },
                "CopyUserURLs": {
                  "enabled": false
                },
                "CrashHandler": {
                  "enabled": true
                },
                "CtrlEnterSend": {
                  "enabled": false
                },
                "CustomCommands": {
                  "enabled": false
                },
                "CustomIdle": {
                  "enabled": false
                },
                "CustomRPC": {
                  "enabled": false
                },
                "Dearrow": {
                  "enabled": false
                },
                "Decor": {
                  "enabled": false
                },
                "DisableCallIdle": {
                  "enabled": false
                },
                "DisableDeepLinks": {
                  "enabled": true
                },
                "DontRoundMyTimestamps": {
                  "enabled": false
                },
                "DynamicImageModalAPI": {
                  "enabled": false
                },
                "Experiments": {
                  "enabled": false
                },
                "ExpressionCloner": {
                  "enabled": false
                },
                "F8Break": {
                  "enabled": false
                },
                "FakeNitro": {
                  "enabled": false
                },
                "FakeProfileThemes": {
                  "enabled": false
                },
                "FavoriteEmojiFirst": {
                  "enabled": false
                },
                "FavoriteGifSearch": {
                  "enabled": false
                },
                "FixCodeblockGap": {
                  "enabled": true
                },
                "FixImagesQuality": {
                  "enabled": false
                },
                "FixSpotifyEmbeds": {
                  "enabled": false
                },
                "FixYoutubeEmbeds": {
                  "enabled": false
                },
                "ForceOwnerCrown": {
                  "enabled": true
                },
                "FriendInvites": {
                  "enabled": false
                },
                "FriendsSince": {
                  "enabled": false
                },
                "FullSearchContext": {
                  "enabled": false
                },
                "FullUserInChatbox": {
                  "enabled": false
                },
                "GameActivityToggle": {
                  "enabled": false
                },
                "GifPaste": {
                  "enabled": false
                },
                "GreetStickerPicker": {
                  "enabled": false
                },
                "HideMedia": {
                  "enabled": false
                },
                "IgnoreActivities": {
                  "enabled": false
                },
                "ImageFilename": {
                  "enabled": false
                },
                "ImageLink": {
                  "enabled": false
                },
                "ImageZoom": {
                  "enabled": true,
                  "invertScroll": true,
                  "nearestNeighbour": false,
                  "saveZoomValues": true,
                  "size": 550,
                  "square": false,
                  "zoom": 5,
                  "zoomSpeed": 0.5
                },
                "ImplicitRelationships": {
                  "enabled": false
                },
                "IrcColors": {
                  "enabled": false
                },
                "KeepCurrentChannel": {
                  "enabled": false
                },
                "LastFMRichPresence": {
                  "enabled": false
                },
                "LoadingQuotes": {
                  "enabled": false
                },
                "MemberCount": {
                  "enabled": false
                },
                "MemberListDecoratorsAPI": {
                  "enabled": true
                },
                "MentionAvatars": {
                  "enabled": false
                },
                "MessageAccessoriesAPI": {
                  "enabled": true
                },
                "MessageClickActions": {
                  "enabled": false
                },
                "MessageDecorationsAPI": {
                  "enabled": true
                },
                "MessageEventsAPI": {
                  "enabled": false
                },
                "MessageLatency": {
                  "enabled": false
                },
                "MessageLinkEmbeds": {
                  "enabled": false
                },
                "MessageLogger": {
                  "enabled": false
                },
                "MessagePopoverAPI": {
                  "enabled": false
                },
                "MessageUpdaterAPI": {
                  "enabled": false
                },
                "MoreQuickReactions": {
                  "enabled": false
                },
                "MutualGroupDMs": {
                  "enabled": false
                },
                "NewGuildSettings": {
                  "enabled": false
                },
                "NoBlockedMessages": {
                  "enabled": false
                },
                "NoDefaultHangStatus": {
                  "enabled": false
                },
                "NoDevtoolsWarning": {
                  "enabled": false
                },
                "NoF1": {
                  "enabled": false
                },
                "NoMaskedUrlPaste": {
                  "enabled": false
                },
                "NoMosaic": {
                  "enabled": false
                },
                "NoOnboardingDelay": {
                  "enabled": false
                },
                "NoPendingCount": {
                  "enabled": false
                },
                "NoProfileThemes": {
                  "enabled": false
                },
                "NoReplyMention": {
                  "enabled": false
                },
                "NoServerEmojis": {
                  "enabled": false
                },
                "NoTrack": {
                  "disableAnalytics": true,
                  "enabled": true
                },
                "NoTypingAnimation": {
                  "enabled": false
                },
                "NoUnblockToJump": {
                  "enabled": false
                },
                "NotificationVolume": {
                  "enabled": false
                },
                "OnePingPerDM": {
                  "enabled": false
                },
                "OpenInApp": {
                  "enabled": false
                },
                "OverrideForumDefaults": {
                  "enabled": false
                },
                "PauseInvitesForever": {
                  "enabled": false
                },
                "PermissionFreeWill": {
                  "enabled": false
                },
                "PermissionsViewer": {
                  "enabled": false
                },
                "PictureInPicture": {
                  "enabled": false
                },
                "PinDMs": {
                  "canCollapseDmSection": false,
                  "enabled": true,
                  "pinOrder": 0,
                  "userBasedCategoryList": {
                    "613524063809437736": []
                  }
                },
                "PlainFolderIcon": {
                  "enabled": false
                },
                "PlatformIndicators": {
                  "enabled": false
                },
                "PreviewMessage": {
                  "enabled": false
                },
                "QuickMention": {
                  "enabled": false
                },
                "QuickReply": {
                  "enabled": false
                },
                "ReactErrorDecoder": {
                  "enabled": false
                },
                "ReadAllNotificationsButton": {
                  "enabled": false
                },
                "RelationshipNotifier": {
                  "enabled": false
                },
                "ReplaceGoogleSearch": {
                  "enabled": false
                },
                "ReplyTimestamp": {
                  "enabled": false
                },
                "RevealAllSpoilers": {
                  "enabled": false
                },
                "ReverseImageSearch": {
                  "enabled": false
                },
                "ReviewDB": {
                  "enabled": false
                },
                "RoleColorEverywhere": {
                  "chatMentions": true,
                  "colorChatMessages": false,
                  "enabled": true,
                  "memberList": true,
                  "pollResults": true,
                  "reactorsList": true,
                  "voiceUsers": true
                },
                "SecretRingToneEnabler": {
                  "enabled": false
                },
                "SendTimestamps": {
                  "enabled": false
                },
                "ServerInfo": {
                  "enabled": false
                },
                "ServerListAPI": {
                  "enabled": false
                },
                "ServerListIndicators": {
                  "enabled": false
                },
                "Settings": {
                  "enabled": true,
                  "settingsLocation": "aboveNitro"
                },
                "ShikiCodeblocks": {
                  "enabled": false
                },
                "ShowAllMessageButtons": {
                  "enabled": false
                },
                "ShowConnections": {
                  "enabled": false
                },
                "ShowHiddenChannels": {
                  "enabled": false
                },
                "ShowHiddenThings": {
                  "enabled": false
                },
                "ShowMeYourName": {
                  "enabled": false
                },
                "ShowTimeoutDuration": {
                  "enabled": false
                },
                "SilentMessageToggle": {
                  "enabled": false
                },
                "SilentTyping": {
                  "enabled": true,
                  "isEnabled": true,
                  "showIcon": false
                },
                "SortFriendRequests": {
                  "enabled": false
                },
                "SpotifyControls": {
                  "enabled": false
                },
                "SpotifyCrack": {
                  "enabled": false
                },
                "SpotifyShareCommands": {
                  "enabled": false
                },
                "StartupTimings": {
                  "enabled": false
                },
                "StickerPaste": {
                  "enabled": false
                },
                "StreamerModeOnStream": {
                  "enabled": false
                },
                "Summaries": {
                  "enabled": false
                },
                "SuperReactionTweaks": {
                  "enabled": false
                },
                "SupportHelper": {
                  "enabled": true
                },
                "TextReplace": {
                  "enabled": false
                },
                "ThemeAttributes": {
                  "enabled": false
                },
                "Translate": {
                  "enabled": false
                },
                "TypingIndicator": {
                  "enabled": true,
                  "includeCurrentChannel": true,
                  "includeMutedChannels": false,
                  "indicatorMode": 3
                },
                "TypingTweaks": {
                  "alternativeFormatting": true,
                  "enabled": true,
                  "showAvatars": true,
                  "showRoleColors": true
                },
                "USRBG": {
                  "enabled": false
                },
                "Unindent": {
                  "enabled": true
                },
                "UnlockedAvatarZoom": {
                  "enabled": false
                },
                "UnsuppressEmbeds": {
                  "enabled": false
                },
                "UserMessagesPronouns": {
                  "enabled": false
                },
                "UserSettingsAPI": {
                  "enabled": true
                },
                "UserVoiceShow": {
                  "enabled": true,
                  "showInMemberList": true,
                  "showInMessages": true,
                  "showInUserProfileModal": true
                },
                "ValidReply": {
                  "enabled": false
                },
                "ValidUser": {
                  "enabled": false
                },
                "VcNarrator": {
                  "enabled": false
                },
                "VencordToolbox": {
                  "enabled": false
                },
                "ViewIcons": {
                  "enabled": false
                },
                "ViewRaw": {
                  "enabled": false
                },
                "VoiceChatDoubleClick": {
                  "enabled": true
                },
                "VoiceDownload": {
                  "enabled": false
                },
                "VoiceMessages": {
                  "enabled": false
                },
                "VolumeBooster": {
                  "enabled": false
                },
                "WebContextMenus": {
                  "enabled": true
                },
                "WebKeybinds": {
                  "enabled": true
                },
                "WebRichPresence (arRPC)": {
                  "enabled": false
                },
                "WebScreenShareFixes": {
                  "enabled": true
                },
                "WhoReacted": {
                  "enabled": false
                },
                "XSOverlay": {
                  "enabled": false
                },
                "YoutubeAdblock": {
                  "enabled": false
                },
                "iLoveSpam": {
                  "enabled": false
                },
                "oneko": {
                  "enabled": false
                },
                "petpet": {
                  "enabled": false
                }
              },
              "themeLinks": [
                "https://codeberg.org/onelock/system-24-with-custom-pallete/raw/branch/main/system24.theme.css"
              ],
              "transparent": false,
              "uiElements": {
                "chatBarButtons": {},
                "messagePopoverButtons": {}
              },
              "useQuickCss": true,
              "winCtrlQ": false,
              "winNativeTitleBar": false
            }
          '';
      };
    };
}
