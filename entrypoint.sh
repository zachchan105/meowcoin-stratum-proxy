#!/bin/bash
set -e

# Set default values if not provided
RPC_HOST=${RPC_HOST:-127.0.0.1}
RPC_PORT=${RPC_PORT:-9766}
RPC_USER=${RPC_USER:-rpcuser}
RPC_PASS=${RPC_PASS:-rpcpass}
VERBOSE=${VERBOSE:-false}
ADDRESS=${ADDRESS:-0.0.0.0}
PORT=${PORT:-54321}

# Build command arguments
CMD_ARGS=(
    "--address" "$ADDRESS"
    "--port" "$PORT"
    "--rpcip" "$RPC_HOST"
    "--rpcport" "$RPC_PORT"
    "--rpcuser" "$RPC_USER"
    "--rpcpass" "$RPC_PASS"
)

# Add optional flags
if [ "$VERBOSE" = "true" ]; then
    CMD_ARGS+=("--verbose")
    CMD_ARGS+=("--jobs")
fi

echo "Starting Meowcoin Stratum Proxy with configuration:"
echo "  RPC Host: $RPC_HOST:$RPC_PORT"
echo "  Stratum Address: $ADDRESS:$PORT"
echo "  Verbose: $VERBOSE"
echo "  Command: python meowcoin-stratum-proxy.py ${CMD_ARGS[*]}"

# Execute the proxy
exec python meowcoin-stratum-proxy.py "${CMD_ARGS[@]}" 