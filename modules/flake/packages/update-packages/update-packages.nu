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

  let results = $packages | par-each {|package|
    let result = update-package $package
    if not $json { print (summary $result) }
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

def summary [result: record]: nothing -> string {
  if $result.failed {
    $"(ansi red)✗(ansi reset) ($result.package)"
  } else if $result.changed {
    $"(ansi green)✓(ansi reset) ($result.package) (ansi grey)($result.before) → ($result.after)(ansi reset)"
  } else {
    $"(ansi green)✓(ansi reset) ($result.package) (ansi grey)Up to date(ansi reset)"
  }
}

def report [failures: list<record>]: nothing -> nothing {
  let log_dir = mktemp --directory --tmpdir update-packages-XXXXXX
  print --stderr $"($failures | length) package\(s\) failed:"

  for failure in $failures {
    let log = $log_dir | path join $"($failure.package).log"
    $failure.log | save $log

    print --stderr $"(ansi attr_bold)── ($failure.package) ──(ansi reset)"
    print --stderr $failure.log
    print --stderr $"(ansi grey)log: ($log)(ansi reset)"
  }
}
