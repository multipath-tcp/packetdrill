#!/bin/bash
# Check MPTCP socket info via ss(8).
# Usage: check_mptcp_info.sh <field> <expected>
#   field: subflows (extra subflows) or subflows_total
# Environment: OPT_BIND_PORT (default 8080) from packetdrill.

field=$1
expected=$2
port=${OPT_BIND_PORT:-8080}

if ! out="$(ss -inmHM "sport = :${port}")"; then
	echo "Error with the 'ss' command" >&2
	exit 1
fi

val=$(echo "${out}" | grep '^ESTAB' | head -1 |
	sed -n "s/.*${field}:\([0-9]*\).*/\1/p")

if [ "${val:-0}" != "${expected}" ]; then
	echo "expected ${field}=${expected}, got ${val}" >&2
	echo "${out}" >&2
	exit 1
fi
