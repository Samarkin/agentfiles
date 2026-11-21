#!/bin/bash
# Claude Code status line
# Shows: dir basename | model | thinking effort | context usage | rate limits

input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir')
if [ "${#dir}" -gt 50 ]; then
  dir="…${dir: -50}"
fi
model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '.effort.level // empty')
thinking=$(echo "$input" | jq -r '.thinking.enabled // false')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# rate_limits is absent for API users and on the first render of a session;
# five_hour and seven_day can also go missing independently.
rl_5h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_5h_rst=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rl_7d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rl_7d_rst=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ANSI colors, as literal bytes so no data is ever reinterpreted
RESET=$'\033[0m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
RED=$'\033[31m'
BLUE=$'\033[34m'

now=$(date +%s)

# LC_ALL=C so a comma-decimal locale can't choke on "23.5"
round() { LC_ALL=C printf '%.0f' "$1" 2>/dev/null; }

# $2 overrides the <50% color; context uses green, rate limits use blue
pct_color() {
  local low=${2:-$GREEN}
  if [ "$1" -ge 80 ]; then printf '%s' "$RED"
  elif [ "$1" -ge 50 ]; then printf '%s' "$YELLOW"
  else printf '%s' "$low"
  fi
}

# percentage -> harvey ball, one cell, inherits the segment's ANSI color
pct_ball() {
  if [ "$1" -ge 70 ]; then printf '●'
  elif [ "$1" -ge 50 ]; then printf '◕'
  elif [ "$1" -ge 30 ]; then printf '◑'
  elif [ "$1" -ge 10 ]; then printf '◔'
  else printf '○'
  fi
}

# token count -> "200k" / "1M" / "1.5M"
fmt_size() {
  local n=$1
  case $n in ''|*[!0-9]*) return 1 ;; esac
  if [ "$n" -ge 1000000 ]; then
    if [ $(( n % 1000000 )) -eq 0 ]; then printf '%dM' $(( n / 1000000 ))
    else printf '%d.%dM' $(( n / 1000000 )) $(( (n % 1000000) / 100000 ))
    fi
  elif [ "$n" -ge 1000 ]; then printf '%dk' $(( n / 1000 ))
  else printf '%d' "$n"
  fi
}

# epoch seconds -> "3d17h" / "2h14m" / "25m"
fmt_reset() {
  local d=$(( $1 - now ))
  [ "$d" -lt 0 ] && d=0
  local days=$(( d / 86400 ))
  local hours=$(( (d % 86400) / 3600 ))
  local mins=$(( (d % 3600) / 60 ))
  if [ "$days" -gt 0 ]; then printf '%dd%dh' "$days" "$hours"
  elif [ "$hours" -gt 0 ]; then printf '%dh%dm' "$hours" "$mins"
  else printf '%dm' "$mins"
  fi
}

# icon, label, percentage, resets_at -> appends a colored segment to $out
rl_segment() {
  local icon=$1 label=$2 pct=$3 rst=$4 int seg
  [ -z "$pct" ] && return
  int=$(round "$pct") || return
  [ -z "$int" ] && return
  seg="${icon} ${label} $(pct_ball "$int") ${int}%"
  [ -n "$rst" ] && seg="${seg} ($(fmt_reset "$rst"))"
  out="${out}  $(pct_color "$int" "$BLUE")${seg}${RESET}"
}

out="${CYAN}📁 ${dir}${RESET}"
model_seg="🤖 ${model}"
if [ -n "$ctx_size" ] && size_h=$(fmt_size "$ctx_size"); then
  model_seg="${model_seg} (${size_h})"
fi
out="${out}  ${MAGENTA}${model_seg}${RESET}"

if [ -n "$effort" ]; then
  out="${out}  ${YELLOW}🧠 ${effort}${RESET}"
elif [ "$thinking" = "true" ]; then
  out="${out}  ${YELLOW}🧠 thinking${RESET}"
fi

if [ -n "$used" ]; then
  used_int=$(round "$used") || used_int=""
fi
if [ -n "$used_int" ]; then
  out="${out}  $(pct_color "$used_int")⚡ ctx $(pct_ball "$used_int") ${used_int}%${RESET}"
fi

rl_segment "⏳" "5h" "$rl_5h_pct" "$rl_5h_rst"
rl_segment "📅" "7d" "$rl_7d_pct" "$rl_7d_rst"

printf '%s\n' "$out"
