{ pkgs, mutableDirectory }:

pkgs.writeShellScriptBin "hm-mutable-selftest" ''
  set -euo pipefail

  mutable_root="${mutableDirectory}/store"
  fail=0

  check_link_prefix() {
    local path="$1"
    local prefix="$2"
    local target

    if [[ ! -L "$path" ]]; then
      echo "FAIL: $path is not a symlink"
      fail=1
      return
    fi

    target="$(readlink -f "$path")"
    if [[ "$target" != "$prefix"* ]]; then
      echo "FAIL: $path points to $target (expected prefix $prefix)"
      fail=1
    else
      echo "OK:   $path -> $target"
    fi
  }

  check_writable() {
    local path="$1"
    if [[ ! -w "$path" ]]; then
      echo "FAIL: $path is not writable"
      fail=1
    fi
  }

  check_not_writable() {
    local path="$1"
    if [[ -w "$path" ]]; then
      echo "FAIL: $path is writable (expected read-only)"
      fail=1
    fi
  }

  check_store_target_readonly() {
    local path="$1"
    local target
    if [[ ! -L "$path" ]]; then
      echo "FAIL: $path is not a symlink"
      fail=1
      return
    fi
    target="$(readlink -f "$path")"
    if [[ "$target" != /nix/store/* ]]; then
      echo "FAIL: $path points to $target (expected /nix/store)"
      fail=1
      return
    fi
    check_not_writable "$target"
  }

  echo "Test 0: immutable link and read-only target..."
  check_store_target_readonly "$HOME/test/immutable.txt"

  echo "Checking immutable file..."
  check_link_prefix "$HOME/test/immutable.txt" "/nix/store/"

  echo "Checking mutable files..."
  check_link_prefix "$HOME/test/mutable-seed.txt" "$mutable_root/"
  check_link_prefix "$HOME/test/mutable-force.txt" "$mutable_root/"

  check_writable "$HOME/test/mutable-seed.txt"
  check_writable "$HOME/test/mutable-force.txt"

  echo "Checking recursive seed directory..."
  if [[ -d "$HOME/test/recursive-seed" ]]; then
    while IFS= read -r -d $'\\0' f; do
      check_link_prefix "$f" "$mutable_root/"
      check_writable "$f"
    done < <(find "$HOME/test/recursive-seed" -type f -print0)
  else
    echo "FAIL: recursive seed dir not found"
    fail=1
  fi

  echo "Checking recursive force directory..."
  if [[ -d "$HOME/test/recursive-force" ]]; then
    while IFS= read -r -d $'\\0' f; do
      check_link_prefix "$f" "$mutable_root/"
      check_writable "$f"
    done < <(find "$HOME/test/recursive-force" -type f -print0)
  else
    echo "FAIL: recursive force dir not found"
    fail=1
  fi

  if [[ "$fail" -eq 0 ]]; then
    echo "PASS: all checks succeeded"
  else
    echo "FAIL: one or more checks failed"
    exit 1
  fi
''
