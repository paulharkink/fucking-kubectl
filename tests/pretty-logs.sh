#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
please="$repo_root/bin/please"

strip_ansi() {
  sed -E $'s/\x1b\\[[0-9;]*m//g'
}

run_pretty() {
  "$please" pretty | strip_ansi
}

assert_eq() {
  local name="$1"
  local expected="$2"
  local actual="$3"

  if [ "$actual" != "$expected" ]; then
    printf 'not ok - %s\n' "$name" >&2
    printf 'expected:\n%s\n' "$expected" >&2
    printf 'actual:\n%s\n' "$actual" >&2
    exit 1
  fi

  printf 'ok - %s\n' "$name"
}

assert_contains() {
  local name="$1"
  local needle="$2"
  local haystack="$3"

  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'not ok - %s\n' "$name" >&2
    printf 'missing: %s\n' "$needle" >&2
    printf 'actual:\n%s\n' "$haystack" >&2
    exit 1
  fi

  printf 'ok - %s\n' "$name"
}

message_cases=$(
  cat <<'CASES' | run_pretty
{"level":"INFO","message":"message field"}
{"level":"INFO","msg":"msg field"}
{"level":"INFO","body":"body field"}
{"level":"INFO","Body":"Body field"}
{"level":"INFO","text":"text field"}
{"level":"INFO","log":"log field"}
{"level":"INFO","error":{"message":"nested error message"}}
{"level":"INFO","error.message":"dotted error message"}
{"level":"INFO","exception":{"message":"nested exception message"}}
{"level":"INFO","exception.message":"dotted exception message"}
{"level":"INFO","err":{"message":"nested err message"}}
{"level":"INFO","err.message":"dotted err message"}
{"level":"INFO","error":"plain error field"}
{"level":"INFO","event":{"original":"nested event original"}}
{"level":"INFO","event.original":"dotted event original"}
{"level":"INFO","log":{"original":"nested log original"}}
{"level":"INFO","log.original":"dotted log original"}
CASES
)

assert_contains "message field" "INFO  message field" "$message_cases"
assert_contains "msg field" "INFO  msg field" "$message_cases"
assert_contains "body field" "INFO  body field" "$message_cases"
assert_contains "Body field" "INFO  Body field" "$message_cases"
assert_contains "text field" "INFO  text field" "$message_cases"
assert_contains "log field" "INFO  log field" "$message_cases"
assert_contains "nested error message" "INFO  nested error message" "$message_cases"
assert_contains "dotted error message" "INFO  dotted error message" "$message_cases"
assert_contains "nested exception message" "INFO  nested exception message" "$message_cases"
assert_contains "dotted exception message" "INFO  dotted exception message" "$message_cases"
assert_contains "nested err message" "INFO  nested err message" "$message_cases"
assert_contains "dotted err message" "INFO  dotted err message" "$message_cases"
assert_contains "plain error field" "INFO  plain error field" "$message_cases"
assert_contains "nested event original" "INFO  nested event original" "$message_cases"
assert_contains "dotted event original" "INFO  dotted event original" "$message_cases"
assert_contains "nested log original" "INFO  nested log original" "$message_cases"
assert_contains "dotted log original" "INFO  dotted log original" "$message_cases"

priority_case=$(printf '%s\n' '{"level":"INFO","message":"summary","event":{"original":"raw duplicate"}}' | run_pretty)
assert_eq "message wins over original fields" "INFO  summary" "$priority_case"

stack_cases=$(
  cat <<'CASES' | run_pretty
{"level":"ERROR","message":"logstash stack","stack_trace":"java.lang.RuntimeException: boom\n\tat example.Service.run(Service.java:10)"}
{"level":"ERROR","msg":"zap stack","stacktrace":"main.main\n\t/app/main.go:12"}
{"level":"ERROR","message":"winston stack","stack":"Error: bad\n    at app.js:10:1"}
{"level":"ERROR","message":"ecs stack","error":{"stack_trace":"Error: ecs\n    at service.js:1"}}
{"level":"ERROR","message":"ecs dotted stack","error.stack_trace":"Error: dotted ecs\n    at service.js:2"}
{"level":"ERROR","message":"otel stack","exception":{"stacktrace":"Exception: otel\n    at worker.py:3"}}
{"level":"ERROR","message":"otel dotted stack","exception.stacktrace":"Exception: dotted otel\n    at worker.py:4"}
{"level":"ERROR","message":"python stack","exception":{"stack":"Traceback (most recent call last):\n  File \"app.py\", line 1"}}
{"level":"ERROR","message":"python dotted stack","exception.stack":"Traceback dotted\n  File \"app.py\", line 2"}
{"level":"ERROR","message":"err stack","err":{"stack":"Error: err\n    at err.js:1"}}
{"level":"ERROR","message":"err dotted stack","err.stack":"Error: dotted err\n    at err.js:2"}
{"level":"ERROR","message":"serilog exception","Exception":"System.InvalidOperationException: bad\n   at Worker.Run()"}
{"level":"ERROR","message":"serilog compact","@x":"System.Exception: compact\n   at Worker.Run()"}
{"level":"ERROR","message":"array stack","stack_trace":["java.lang.IllegalStateException: array","at example.Array.run(Array.java:10)"]}
CASES
)

assert_contains "stack_trace rendered" $'ERROR  logstash stack\njava.lang.RuntimeException: boom\n\tat example.Service.run(Service.java:10)' "$stack_cases"
assert_contains "stacktrace rendered" $'ERROR  zap stack\nmain.main\n\t/app/main.go:12' "$stack_cases"
assert_contains "stack rendered" $'ERROR  winston stack\nError: bad\n    at app.js:10:1' "$stack_cases"
assert_contains "nested ECS stack rendered" $'ERROR  ecs stack\nError: ecs\n    at service.js:1' "$stack_cases"
assert_contains "dotted ECS stack rendered" $'ERROR  ecs dotted stack\nError: dotted ecs\n    at service.js:2' "$stack_cases"
assert_contains "nested OTel stack rendered" $'ERROR  otel stack\nException: otel\n    at worker.py:3' "$stack_cases"
assert_contains "dotted OTel stack rendered" $'ERROR  otel dotted stack\nException: dotted otel\n    at worker.py:4' "$stack_cases"
assert_contains "nested Python stack rendered" $'ERROR  python stack\nTraceback (most recent call last):\n  File "app.py", line 1' "$stack_cases"
assert_contains "dotted Python stack rendered" $'ERROR  python dotted stack\nTraceback dotted\n  File "app.py", line 2' "$stack_cases"
assert_contains "nested err stack rendered" $'ERROR  err stack\nError: err\n    at err.js:1' "$stack_cases"
assert_contains "dotted err stack rendered" $'ERROR  err dotted stack\nError: dotted err\n    at err.js:2' "$stack_cases"
assert_contains "Serilog Exception rendered" $'ERROR  serilog exception\nSystem.InvalidOperationException: bad\n   at Worker.Run()' "$stack_cases"
assert_contains "Serilog compact @x rendered" $'ERROR  serilog compact\nSystem.Exception: compact\n   at Worker.Run()' "$stack_cases"
assert_contains "array stack rendered" $'ERROR  array stack\njava.lang.IllegalStateException: array\nat example.Array.run(Array.java:10)' "$stack_cases"

message_from_error=$(printf '%s\n' '{"level":"ERROR","error":{"message":"connection failed","stack_trace":"Error: connection failed\n    at net.js:7"}}' | run_pretty)
assert_contains "error message combines with error stack" $'ERROR  connection failed\nError: connection failed\n    at net.js:7' "$message_from_error"
