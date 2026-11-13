# Run the update script of each package in this flake that has one
def main [
  --json # Print structured JSON instead of progress lines
  ...packages: string # The packages to update (default: every updatable package)
]: nothing -> nothing {
  let updatable = nix eval --json --impure --expr 'builtins.mapAttrs (_: package: package ? passthru.updateScript) (builtins.getFlake (toString ./.)).packages.${builtins.currentSystem}' | from json
  let packages = if ($packages | is-empty) { $updatable | columns | where {|package| $updatable | get $package } } else { $packages }

  let problems = $packages | each {|package|
    match ($updatable | get --optional $package) {
      null => $"package ($package) is not a package in this flake"
      false => $"package ($package) has no update script"
    }
  }
  if ($problems | is-not-empty) {
    $problems | each { print --stderr $"(ansi red)✗(ansi reset) ($in)" }
    exit 1
  }

  if not $json { print $"(ansi grey)Updating ($packages | length) package\(s\)…(ansi reset)\n" }

  let width = $packages | each { str length } | math max
  let results = $packages | par-each {|package|
    let result = update-package $package
    if not $json { print (summary $result $width) }
    $result
  }

  if $json { print ($results | to json) }

  let failures = $results | where failed
  if ($failures | is-not-empty) {
    report $failures
    exit 1
  }
}

def nix-eval [package: string attribute: string]: nothing -> any {
  let result = nix eval --raw $".#($package).($attribute)" | complete
  if $result.exit_code == 0 { $result.stdout | str trim }
}

def update-package [package: string]: nothing -> record {
  let before = nix-eval $package version
  if $before == null {
    return (outcome $package --log $"could not evaluate ($package).version before update")
  }

  let result = nix-update --flake --use-update-script $package | complete
  if $result.exit_code != 0 {
    return (outcome $package --before $before --log ($result.stdout + $result.stderr))
  }

  let after = nix-eval $package version
  if $after == null {
    return (outcome $package --before $before --log $"could not evaluate ($package).version after update")
  }

  let homepage = nix-eval $package meta.homepage | default ""
  outcome $package --before $before --after $after --homepage $homepage
}

def outcome [
  package: string
  --before: string = ""
  --after: string = ""
  --homepage: string = ""
  --log: string
]: nothing -> record {
  {
    package: $package
    before: $before
    after: $after
    homepage: $homepage
    changed: ($before != $after)
    failed: ($log != null)
    log: $log
  }
}

def summary [result: record width: int]: nothing -> string {
  let padding = '' | fill --width ($width - ($result.package | str length))
  let name = if ($result.homepage | is-empty) {
    $result.package
  } else {
    $result.homepage | ansi link --text $result.package
  }

  let detail = if $result.failed {
    $"(ansi red)($result.log | reason)(ansi reset)"
  } else if $result.changed {
    $"(ansi grey)($result.before) → (ansi reset)(ansi green_bold)($result.after)(ansi reset)"
  } else {
    $"(ansi grey)($result.after)(ansi reset)"
  }

  let mark = if $result.failed {
    $"(ansi red)✗"
  } else if $result.changed {
    $"(ansi green_bold)↑"
  } else {
    $"(ansi grey)✓"
  }

  $"  ($mark)(ansi reset) ($name)($padding)  ($detail)"
}

# The last non-empty line of a log, which is usually the error.
def reason []: string -> string {
  let line = $in | lines | str trim | where { is-not-empty } | last | default "failed"
  if ($line | str length) > 80 { $"($line | str substring 0..<79)…" } else { $line }
}

def report [failures: list<record>]: nothing -> nothing {
  let log_dir = mktemp --directory --tmpdir update-packages-XXXXXX

  for failure in $failures {
    let log = $log_dir | path join $"($failure.package).log"
    $failure.log | save $log

    print --stderr $"\n(ansi red_bold)✗ ($failure.package)(ansi reset) (ansi grey)($log)(ansi reset)"
    $failure.log | lines | last 15 | each { print --stderr $"(ansi grey)│(ansi reset) ($in)" }
  }
}
