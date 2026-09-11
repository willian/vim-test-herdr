#!/usr/bin/env sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/herdr" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "$*" >> "$HERDR_LOG"
if [ "$2" = split ]; then
  printf '%s\n' '{"result":{"pane":{"pane_id":"test-pane"}}}'
fi
EOF
chmod +x "$tmp/herdr"

check() {
  editor=$1
  mode=--headless
  [ "$editor" = vim ] && mode=-es
  : > "$tmp/log"
  HERDR_ENV=1 HERDR_LOG="$tmp/log" PATH="$tmp:$PATH" "$editor" --clean "$mode" --cmd "set rtp^=$repo" \
    '+runtime plugin/vim-test-herdr.vim' \
    '+call assert_equal(1, exists("*HerdrStrategy")) | call assert_equal(2, exists(":HerdrCloseRunner")) | call assert_true(has_key(g:test#custom_strategies, "herdr"))' \
    '+call call(g:test#custom_strategies.herdr, ["true"]) | call call(g:test#custom_strategies.herdr, ["true"]) | HerdrCloseRunner' \
    '+if len(v:errors) | cquit | endif' +qa
  test "$(wc -l < "$tmp/log" | tr -d ' ')" = 5
}

check nvim
check vim
