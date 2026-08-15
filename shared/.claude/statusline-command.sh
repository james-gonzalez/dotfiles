#!/usr/bin/env bash
# Claude Code status line: dir, git branch, model, context usage, tokens, diff, cost

input=$(cat)

# --- single jq pass -----------------------------------------------------------
eval "$(printf '%s' "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // .cwd // "")",
  @sh "model=\(.model.display_name // "")",
  @sh "used_pct=\(.context_window.used_percentage // "")",
  @sh "in_tok=\(.context_window.current_usage.input_tokens // "")",
  @sh "out_tok=\(.context_window.current_usage.output_tokens // "")",
  @sh "cache_read=\(.context_window.current_usage.cache_read_input_tokens // 0)",
  @sh "added=\(.cost.total_lines_added // 0)",
  @sh "removed=\(.cost.total_lines_removed // 0)",
  @sh "total_cost=\(.cost.total_cost_usd // "")"
')"

# --- colors -------------------------------------------------------------------
C_DIR=$'\033[38;5;110m'    # blue-grey
C_GIT=$'\033[38;5;108m'    # green
C_DIRTY=$'\033[38;5;180m'  # amber
C_MODEL=$'\033[38;5;140m'  # purple
C_TOK=$'\033[38;5;245m'    # grey
C_ADD=$'\033[38;5;108m'
C_DEL=$'\033[38;5;167m'
C_COST=$'\033[38;5;179m'
C_DIM=$'\033[38;5;240m'
R=$'\033[0m'

hum() { # 18213 -> 18k
  awk -v n="$1" 'BEGIN{
    if (n=="" ) exit
    if (n>=1000000) printf "%.1fM", n/1000000
    else if (n>=1000) printf "%.1fk", n/1000
    else printf "%d", n
  }'
}

parts=()

# --- dir ----------------------------------------------------------------------
if [ -n "$cwd" ]; then
  short_dir=${cwd/#$HOME/\~}
  parts+=("${C_DIR}${short_dir##*/}${R}")
fi

# --- git ----------------------------------------------------------------------
FETCH_INTERVAL=300  # seconds between background `git fetch` refreshes, per repo

if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  branch=$(git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null \
        || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    git -C "$cwd" diff --quiet --ignore-submodules HEAD 2>/dev/null || dirty="*"

    # Ahead/behind reads the local origin/* ref, which only moves on fetch/pull/push.
    # Refresh it in the background (throttled) so it doesn't go stale between pushes
    # made in other sessions/terminals, without blocking this render on the network.
    repo_top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$repo_top" ]; then
      cache_dir="$HOME/.cache/claude-statusline"
      mkdir -p "$cache_dir" 2>/dev/null
      stamp_file="$cache_dir/$(printf '%s' "$repo_top" | cksum | cut -d' ' -f1).fetch"
      last=$(cat "$stamp_file" 2>/dev/null || echo 0)
      now=$(date +%s)
      if [ $((now - last)) -ge "$FETCH_INTERVAL" ]; then
        date +%s > "$stamp_file"
        (setsid timeout 10 git -C "$repo_top" fetch --quiet >/dev/null 2>&1 &) >/dev/null 2>&1
      fi
    fi

    ab=""
    counts=$(git -C "$cwd" rev-list --left-right --count @{u}...HEAD 2>/dev/null)
    if [ -n "$counts" ]; then
      behind=${counts%%[[:space:]]*}
      ahead=${counts##*[[:space:]]}
      [ "$ahead"  != "0" ] && ab="${ab}↑${ahead}"
      [ "$behind" != "0" ] && ab="${ab}↓${behind}"
    fi
    parts+=("${C_GIT}${branch}${C_DIRTY}${dirty}${ab}${R}")
  fi
fi

# --- model --------------------------------------------------------------------
[ -n "$model" ] && parts+=("${C_MODEL}${model}${R}")

# --- context bar --------------------------------------------------------------
if [ -n "$used_pct" ]; then
  filled=$(awk -v p="$used_pct" 'BEGIN{v=int(p/10+0.5); if(v>10)v=10; if(v<0)v=0; print v}')
  bar_color=$'\033[38;5;108m'
  awk -v p="$used_pct" 'BEGIN{exit !(p>=80)}' && bar_color=$'\033[38;5;167m'
  awk -v p="$used_pct" 'BEGIN{exit !(p>=60 && p<80)}' && bar_color=$'\033[38;5;179m'
  bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}▊"; done
  for ((i=filled; i<10; i++)); do bar="${bar}░"; done
  parts+=("${bar_color}${bar} $(printf '%.0f' "$used_pct")%${R}")
fi

# --- tokens -------------------------------------------------------------------
if [ -n "$in_tok" ] || [ -n "$out_tok" ]; then
  tok="⇅$(hum "${in_tok:-0}")/$(hum "${out_tok:-0}")"
  [ "${cache_read:-0}" != "0" ] && tok="${tok} ⚡$(hum "$cache_read")"
  parts+=("${C_TOK}${tok}${R}")
fi

# --- lines changed ------------------------------------------------------------
if [ "${added:-0}" != "0" ] || [ "${removed:-0}" != "0" ]; then
  parts+=("${C_ADD}+${added}${R}${C_DIM}/${R}${C_DEL}-${removed}${R}")
fi

# --- cost ---------------------------------------------------------------------
if [ -n "$total_cost" ]; then
  parts+=("${C_COST}\$$(awk -v c="$total_cost" 'BEGIN{printf "%.2f", c}')${R}")
fi

sep="${C_DIM} · ${R}"
out=""
for part in "${parts[@]}"; do
  [ -n "$out" ] && out="${out}${sep}"
  out="${out}${part}"
done
printf '%s\n' "$out"
