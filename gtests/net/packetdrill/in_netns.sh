#!/bin/sh
#
# Execute a subprocess in a network namespace

set -e

readonly NETNS="ns-$(mktemp -u XXXXXX)"

TCPDUMP_PID=

setup() {
	ip netns add "${NETNS}"
	ip -netns "${NETNS}" link set lo up
	if [ -n "${TCPDUMP_OUTPUT}" ]; then
		ip netns exec "${NETNS}" tcpdump -i any -s 150 -w "${TCPDUMP_OUTPUT}" &
		TCPDUMP_PID=$!
		sleep 1
	fi
}

cleanup() {
	if [ -n "${TCPDUMP_PID}" ]; then
		kill "${TCPDUMP_PID}"
		wait "${TCPDUMP_PID}" 2>/dev/null || true
	fi
	ip netns del "${NETNS}"
}

trap cleanup EXIT
setup

ip netns exec "${NETNS}" "$@"
exit "$?"
