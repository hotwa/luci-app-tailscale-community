#!/bin/sh

set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
UCODE_FILE="$ROOT_DIR/luci-app-tailscale-community/root/usr/share/rpcd/ucode/tailscale.uc"
JS_FILE="$ROOT_DIR/luci-app-tailscale-community/htdocs/luci-static/resources/view/tailscale.js"
INIT_FILE="$ROOT_DIR/luci-app-tailscale-community/root/etc/init.d/tailscale-settings"

[ -f "$UCODE_FILE" ] || {
	echo "missing ucode file"
	exit 1
}

[ -f "$JS_FILE" ] || {
	echo "missing LuCI view file"
	exit 1
}

[ -f "$INIT_FILE" ] || {
	echo "missing init script"
	exit 1
}

grep -q "methods.get_runtime" "$UCODE_FILE" || {
	echo "missing get_runtime RPC method"
	exit 1
}

grep -q "methods.get_diagnostics" "$UCODE_FILE" || {
	echo "missing get_diagnostics RPC method"
	exit 1
}

grep -q "callGetRuntime" "$JS_FILE" || {
	echo "missing runtime RPC binding in LuCI"
	exit 1
}

grep -q "callGetDiagnostics" "$JS_FILE" || {
	echo "missing diagnostics RPC binding in LuCI"
	exit 1
}

grep -q "read_json_command('tailscale debug prefs')" "$UCODE_FILE" || {
	echo "missing tailscale debug prefs compatibility fallback in RPC runtime"
	exit 1
}

grep -q 'debug prefs 2>/dev/null' "$INIT_FILE" || {
	echo "missing tailscale debug prefs compatibility fallback in init script"
	exit 1
}

grep -q "config_get desired_disable_magic_dns settings disable_magic_dns '1'" "$INIT_FILE" || {
	echo "missing router-safe disable_magic_dns default"
	exit 1
}

grep -q "Recommended on routers so dnsmasq, mosdns, or other local DNS forwarders keep control." "$JS_FILE" || {
	echo "missing router-safe Disable MagicDNS guidance in LuCI"
	exit 1
}

grep -q "desired/runtime/diagnostics" "$JS_FILE" || {
	echo "missing desired/runtime/diagnostics health section"
	exit 1
}

echo "tailscale runtime smoke test passed"
