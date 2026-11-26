# Apply HypnotizeHUD customization options to an installed HUD tree.
def main [--root: path, --config: path]: nothing -> nothing {
    let cfg = open $config

    select-base ($root | path join "customizations/health_styles.res") $cfg.health
    select-base ($root | path join "customizations/damage.res") $cfg.damage
    select-base ($root | path join "customizations/scoreboards.res") $cfg.scoreboard
    select-base ($root | path join "customizations/team_status.res") $cfg.teamStatus
    select-base ($root | path join "customizations/pausemenu_background.res") $cfg.pauseMenuBackground

    select-base ($root | path join "customizations/alternative_fonts.res") $cfg.font

    select-base ($root | path join "customizations/speedometer.res") (if $cfg.speedometer { "speedometer.res" } else { null })
    select-base ($root | path join "customizations/transparent_viewmodels.res") (if $cfg.transparentViewmodels { "transparent_viewmodels.res" } else { null })

    patch-colors ($root | path join "customizations/colors.res") $cfg.colors

    (patch-block-key
        ($root | path join "resource/ui/basechat.res")
        "HudChat"
        "xpos"
        $cfg.chat.xpos
    )
    (patch-block-key
        ($root | path join "resource/ui/basechat.res")
        "HudChat"
        "ypos"
        $cfg.chat.ypos
    )
    if $cfg.chat.background != null {
        (patch-block-key
            ($root | path join "resource/ui/basechat.res")
            "HudChat"
            "bgcolor_override"
            $cfg.chat.background
        )
    }

    if $cfg.favoriteServer != null {
        (patch-block-key
            ($root | path join "resource/gamemenu.res")
            "HomeServer"
            "command"
            $"engine ($cfg.favoriteServer)"
        )
    }

    if $cfg.mainMenuBackground != null {
        for destination in [
            "materials/console/background_upward.vtf"
            "materials/console/background_upward_widescreen.vtf"
        ] {
            cp $cfg.mainMenuBackground ($root | path join $destination)
        }
        (patch-block-key
            ($root | path join "resource/ui/mainmenuoverride.res")
            "BackgroundCustom"
            "wide"
            "0"
        )
    }

    (generate-crosshairs
        ($root | path join "customizations/crosshairs_and_hitmarker.res")
        $cfg.crosshair
        $cfg.hitmarker
    )
    (generate-animation
        (
            $root
            | path join "customizations/crosshairs_and_hitmarker_animation.txt"
        )
        $cfg.crosshair
        $cfg.hitmarker
    )

    if $cfg.fontFamily != null {
        configure-font-family ($root | path join "resource/scheme/fonts.res") $cfg.fontFamily
    }

    select-resolution ($root | path join "customizations/resolutions") $cfg.resolution
    configure-streamer-mode ($root | path join "customizations") $cfg.streamerMode
}

def fail [message: string] {
    error make {msg: $"hypnotizehud: ($message)"}
}

def save-lines [file: path, lines: list<string>]: nothing -> nothing {
    let text = ($lines | str join "\n") + "\n"
    $text | save --force --raw $file
}

def select-base [file: path, selected]: nothing -> nothing {
    mut output = []
    mut matched = 0

    for line in (open --raw $file | lines) {
        let parsed = $line | parse --regex '^(?P<indent>\s*)(?://)?(?P<directive>#base\s+"(?P<path>[^"]+)")(?P<rest>.*)$'
        if ($parsed | is-empty) {
            $output = $output | append $line
            continue
        }

        let row = $parsed | first
        let target = $row.path | path basename
        if $selected != null and $target == $selected {
            $matched = $matched + 1
            $output = $output | append $"($row.indent)($row.directive)($row.rest)"
        } else {
            $output = $output | append $"($row.indent)//($row.directive)($row.rest)"
        }
    }

    if $selected != null and $matched != 1 {
        fail $"($file): expected exactly one #base for '($selected)', found ($matched)"
    }

    save-lines $file $output
}

def validate-color [name: string, value: string]: nothing -> nothing {
    let parts = $value | split row " "
    let valid = ($parts | length) == 4 and ($parts | all {|part|
        $part =~ '^\d+$' and ($part | into int) in 0..255
    })
    if not $valid {
        fail $"color '($name)' must be four space-separated integers between 0 and 255, got '($value)'"
    }
}

def patch-colors [file: path, colors: record]: nothing -> nothing {
    let names = $colors | columns
    mut output = []
    mut matched = {}

    for name in $names {
        validate-color $name ($colors | get $name)
    }

    for line in (open --raw $file | lines) {
        let parsed = $line | parse --regex '^(?P<indent>\s*)"(?P<name>[^"]+)"(?P<space>\s+)"(?P<value>[^"]*)"(?P<rest>.*)$'
        if ($parsed | is-empty) {
            $output = $output | append $line
            continue
        }

        let row = $parsed | first
        if $row.name in $names {
            $matched = $matched | upsert $row.name (($matched | get --optional $row.name | default 0) + 1)
            $output = $output | append $"($row.indent)\"($row.name)\"($row.space)\"($colors | get $row.name)\"($row.rest)"
        } else {
            $output = $output | append $line
        }
    }

    for name in $names {
        let count = $matched | get --optional $name | default 0
        if $count != 1 {
            fail $"($file): expected one color '($name)', found ($count)"
        }
    }

    save-lines $file $output
}

def patch-block-key [
    file: path
    block: string
    key: string
    value: string
]: nothing -> nothing {
    let pattern = ('^(?P<indent>\s*)"' + $key + '"(?P<space>\s+)"[^"]*"(?P<rest>.*)$')
    mut output = []
    mut in_block = false
    mut depth = 0
    mut matched = 0

    for line in (open --raw $file | lines) {
        let trimmed = $line | str trim

        if not $in_block {
            if $trimmed == $"\"($block)\"" {
                $in_block = true
            }
            $output = $output | append $line
            continue
        }

        if $trimmed == "{" {
            $depth = $depth + 1
            $output = $output | append $line
            continue
        }

        if $trimmed == "}" {
            $depth = $depth - 1
            $output = $output | append $line
            if $depth == 0 {
                $in_block = false
            }
            continue
        }

        if $depth == 1 {
            let parsed = $line | parse --regex $pattern
            if ($parsed | is-not-empty) {
                let row = $parsed | first
                $matched = $matched + 1
                $output = $output | append $"($row.indent)\"($key)\"($row.space)\"($value)\"($row.rest)"
                continue
            }
        }

        $output = $output | append $line
    }

    if $matched != 1 {
        fail $"($file): expected one '($key)' in block '($block)', found ($matched)"
    }

    save-lines $file $output
}

def generate-crosshairs [file: path, crosshair: record, hitmarker: record]: nothing -> nothing {
    let crosshair_visible = if $crosshair.enable { "1" } else { "0" }
    let shadow_visible = if $crosshair.enable and $crosshair.shadow { "1" } else { "0" }
    let crosshair_outline = if $crosshair.outline { "ON" } else { "OFF" }
    let hitmarker_outline = if $hitmarker.outline { "ON" } else { "OFF" }
    let crosshair_font = $"Size:($crosshair.size) | Outline:($crosshair_outline)"
    let shadow_font = $"Size:($crosshair.size) | Blur:ON"
    let hitmarker_font = $"Size:($hitmarker.size) | Outline:($hitmarker_outline)"

    let lines = [
        '"Resource/Crosshairs and Hitmarkers.res"'
        "{"
        '    "CustomCrosshair"'
        "    {"
        '        "ControlName" "CExLabel"'
        '        "fieldName" "CustomCrosshair"'
        '        "enabled" "1"'
        $"        \"visible\" \"($crosshair_visible)\""
        '        "zpos" "0"'
        '        "wide" "f0"'
        '        "tall" "f0"'
        '        "textAlignment" "center"'
        $"        \"labelText\" \"($crosshair.type)\""
        $"        \"font\" \"($crosshair_font)\""
        $"        \"xpos\" \"($crosshair.xpos)\""
        $"        \"ypos\" \"($crosshair.ypos)\""
        '        "fgcolor" "Crosshair"'
        "    }"
        ""
        '    "CustomCrosshairBlurShadow"'
        "    {"
        '        "ControlName" "CExLabel"'
        '        "fieldName" "CustomCrosshairBlurShadow"'
        '        "enabled" "1"'
        $"        \"visible\" \"($shadow_visible)\""
        '        "xpos" "0"'
        '        "ypos" "0"'
        '        "zpos" "-1"'
        '        "wide" "f0"'
        '        "tall" "f0"'
        '        "textAlignment" "center"'
        '        "pin_to_sibling" "CustomCrosshair"'
        $"        \"labelText\" \"($crosshair.type)\""
        $"        \"font\" \"($shadow_font)\""
        '        "fgcolor" "Crosshair_Shadow"'
        "    }"
        ""
        '    "HitMarker"'
        "    {"
        '        "ControlName" "CExLabel"'
        '        "fieldName" "HitMarker"'
        '        "enabled" "1"'
        '        "visible" "1"'
        '        "zpos" "0"'
        '        "wide" "f0"'
        '        "tall" "f0"'
        '        "textAlignment" "center"'
        '        "Alpha" "0"'
        $"        \"labelText\" \"($hitmarker.type)\""
        $"        \"font\" \"($hitmarker_font)\""
        $"        \"xpos\" \"($hitmarker.xpos)\""
        $"        \"ypos\" \"($hitmarker.ypos)\""
        '        "fgcolor" "HitMarker"'
        "    }"
        "}"
    ]

    save-lines $file $lines
}

def generate-animation [file: path, crosshair: record, hitmarker: record]: nothing -> nothing {
    let crosshair_prefix = if $crosshair.animate { "" } else { "//" }
    let hitmarker_prefix = if $hitmarker.enable { "" } else { "//" }

    let lines = [
        "// Generated by the hypnotizehud package."
        "event DamagedPlayer"
        "{"
        "\tStopEvent\tHitMarker\t\t\t\t0.0"
        "\tRunEvent\tHitMarker\t\t\t\t0.01"
        ""
        $"\t($crosshair_prefix)Animate\t\"CustomCrosshair\"\t\tFgColor\t\t\"Crosshair_Pulse\"\t\tLinear\t0.0\t\t0.00001"
        $"\t($crosshair_prefix)Animate\t\"CustomCrosshair\"\t\tFgColor\t\t\"Crosshair\"\t\t\t\tLinear\t0.10\t0.10001"
        ""
        $"\t($hitmarker_prefix)Animate\t\"Hitmarker\"\t\t\t\tAlpha\t\t\"255\"\t\t\t\t\tLinear\t0.0\t\t0.0"
        $"\t($hitmarker_prefix)Animate\t\"Hitmarker\"\t\t\t\tAlpha\t\t\"0\"\t\t\t\t\t\tLinear\t0.0\t\t0.35"
        "}"
    ]

    save-lines $file $lines
}

def configure-font-family [file: path, family: string]: nothing -> nothing {
    mut text = open --raw $file
    for source in ['"Rubik SemiBold"' '"Rubik Medium"'] {
        if not ($text | str contains $source) {
            fail $"($file): expected ($source), found none"
        }
        $text = $text | str replace --all $source ('"' + $family + '"')
    }
    $text | save --force --raw $file
}

def select-resolution [directory: path, selected: string]: nothing -> nothing {
    for name in ["4x3" "5x4" "16x10" "16x9"] {
        let active = $directory | path join $name
        let inactive = $"($active)_"
        if $name != $selected and ($active | path exists) {
            if ($inactive | path exists) {
                fail $"($directory): both ($name) and ($name)_ exist"
            }
            mv $active $inactive
        }
    }

    let active = $directory | path join $selected
    let inactive = $"($active)_"
    if ($inactive | path exists) {
        if ($active | path exists) {
            fail $"($directory): both ($selected) and ($selected)_ exist"
        }
        mv $inactive $active
    }

    if not ($active | path exists) {
        fail $"($directory): ($selected) could not be activated"
    }
}

def configure-streamer-mode [directory: path, enabled: bool]: nothing -> nothing {
    let active = $directory | path join "streamermode"
    let inactive = $"($active)_"

    if $enabled {
        if ($inactive | path exists) and ($active | path exists) {
            fail "customizations/streamermode and customizations/streamermode_ both exist"
        }
        if ($inactive | path exists) {
            mv $inactive $active
        }
        if not ($active | path exists) {
            fail "customizations/streamermode could not be activated"
        }
    } else if ($active | path exists) {
        mv $active $inactive
    }
}
