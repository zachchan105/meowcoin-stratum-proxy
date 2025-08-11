# Meowcoin Stratum Proxy - Docker Setup

This document describes how to deploy the Meowcoin Stratum Proxy using Docker and Kubernetes.

## Quick Start with Docker Compose

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd meowcoin-stratum-proxy
   ```

2. **Configure environment variables:**
   Edit `docker-compose.yml` and update the environment variables:
   ```yaml
   environment:
     - RPC_HOST=127.0.0.1      # Your Meowcoin node IP
     - RPC_PORT=9766            # Your Meowcoin RPC port (mainnet)
     - RPC_USER=rpcuser         # Your RPC username
     - RPC_PASS=rpcpass         # Your RPC password
     - TESTNET=false            # Set to true for testnet
     - VERBOSE=false            # Set to true for debug logging
   ```

3. **Start the service:**
   ```bash
   docker compose up -d
   ```

4. **Check logs:**
   ```bash
   docker compose logs -f meowcoin-stratum-proxy
   ```

## Docker Run Command

```bash
docker run -d \
  --name meowcoin-stratum-proxy \
  -p 54321:54321 \
  -e RPC_HOST=127.0.0.1 \
  -e RPC_PORT=9766 \
  -e RPC_USER=rpcuser \
  -e RPC_PASS=rpcpass \
  -e TESTNET=false \
  -e VERBOSE=false \
  zachprice105/meowcoin-stratum-proxy:main
```

## Network Configuration

The proxy supports both mainnet and testnet modes:

### **Mainnet Configuration:**
```yaml
environment:
  - RPC_PORT=9766
  - TESTNET=false
```

### **Testnet Configuration:**
```yaml
environment:
  - RPC_PORT=19766
  - TESTNET=true
```

**Important**: Both the port AND the `TESTNET=true` flag are required for testnet mode.

## Kubernetes Deployment

1. **Update the deployment manifest:**
   Edit `k8s-deployment.yaml` and update the environment variables with your Meowcoin node details.

2. **Deploy to Kubernetes:**
   ```bash
   kubectl apply -f k8s-deployment.yaml
   ```

3. **Check deployment status:**
   ```bash
   kubectl get pods -l app=meowcoin-stratum-proxy
   kubectl logs -l app=meowcoin-stratum-proxy
   ```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RPC_HOST` | `127.0.0.1` | Meowcoin node IP address |
| `RPC_PORT` | `9766` | Meowcoin RPC port (mainnet: 9766, testnet: 19766) |
| `RPC_USER` | `rpcuser` | RPC username |
| `RPC_PASS` | `rpcpass` | RPC password |
| `TESTNET` | `false` | Enable testnet mode (requires both flag and port) |
| `VERBOSE` | `false` | Enable verbose logging |

## Ports

- **54321**: Stratum protocol port for miners to connect

## Health Checks

The container includes health checks that verify the stratum service is responding. You can monitor health with:

```bash
docker inspect meowcoin-stratum-proxy | grep Health -A 10
```

## Building Locally

```bash
docker build -t meowcoin-stratum-proxy .
docker run -p 54321:54321 meowcoin-stratum-proxy
```

## CI/CD with GitHub Actions

The repository includes GitHub Actions workflows that automatically build and push Docker images to DockerHub on:

- Push to main/master branch
- New version tags
- Pull requests (build only, no push)

### Required Secrets

Set these secrets in your GitHub repository:

- `DOCKERHUB_USERNAME`: Your DockerHub username
- `DOCKERHUB_TOKEN`: Your DockerHub access token

## Troubleshooting

### Common Issues

1. **Connection refused to RPC:**
   - Verify your Meowcoin node is running
   - Check RPC_HOST and RPC_PORT are correct
   - Ensure RPC is enabled in meowcoin.conf

2. **Permission denied:**
   - The container runs as non-root user (UID 1000)
   - Ensure proper file permissions

3. **Port already in use:**
   - Change the port mapping in docker-compose.yml
   - Or stop any existing services using port 54321

4. **Module import errors:**
   - The container includes all necessary build dependencies
   - Uses Python 3.11 with optimized package versions
   - SHA3 functionality uses built-in hashlib.sha3_256()

5. **Testnet not working:**
   - Ensure both `TESTNET=true` AND correct port (19766) are set
   - Check that the `--testnet` flag is being passed to the proxy

### Logs

```bash
# Docker Compose
docker compose logs -f meowcoin-stratum-proxy

# Docker
docker logs -f meowcoin-stratum-proxy

# Kubernetes
kubectl logs -f deployment/meowcoin-stratum-proxy
```

## Security Notes

- The container runs as a non-root user (meowcoin:meowcoin)
- RPC credentials are passed as environment variables
- Consider using Kubernetes secrets for production deployments
- The stratum service binds to 0.0.0.0 by default (accessible from any IP)
- Health checks verify service availability

## Technical Details

- **Base Image**: Python 3.11-slim
- **Build Tools**: Includes gcc, g++, make, python3-dev for package compilation
- **Dependencies**: aiohttp, aiorpcX, requests, base58, coloredlogs
- **SHA3 Implementation**: Uses Python's built-in hashlib.sha3_256() for compatibility
- **User**: Runs as UID 1000 (meowcoin user) for security
- **Testnet Support**: Requires both environment variable and command-line flag 