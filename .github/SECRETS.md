# GitHub Secrets Configuration Guide

This document lists all the secrets needed for the deployment workflow.

## 🎯 Flexible Server Configuration

The workflow **automatically detects** how many servers you have configured:

- **1 Server**: Deploy to single server only
- **2+ Servers**: Deploy to all servers with zero-downtime (one at a time)
- **Up to 4 servers** supported (easily extendable)

**You only need to configure secrets for the servers you actually use!**

## Required Secrets

### SSH Configuration

#### Server 1 (Required - at least one server)

- `SERVER1_HOST` - IP address or hostname of server 1 (e.g., `192.168.1.100` or `server1.example.com`)
- `SERVER1_USER` - SSH username (e.g., `deploy` or `root`)
- `SERVER1_PORT` - SSH port (optional, default: `22`)
- `SERVER1_APP_PATH` - Application path on server (optional, default: `/var/www/budgetly`)

#### Server 2 (Optional - only if you have 2+ servers)

- `SERVER2_HOST` - IP address or hostname of server 2
- `SERVER2_USER` - SSH username
- `SERVER2_PORT` - SSH port (optional, default: `22`)
- `SERVER2_APP_PATH` - Application path on server (optional, default: `/var/www/budgetly`)

#### Server 3 (Optional - for future scaling)

- `SERVER3_HOST` - IP address or hostname
- `SERVER3_USER` - SSH username
- `SERVER3_PORT` - SSH port (optional, default: `22`)
- `SERVER3_APP_PATH` - Application path (optional, default: `/var/www/budgetly`)

#### Server 4 (Optional - for future scaling)

- `SERVER4_HOST` - IP address or hostname
- `SERVER4_USER` - SSH username
- `SERVER4_PORT` - SSH port (optional, default: `22`)
- `SERVER4_APP_PATH` - Application path (optional, default: `/var/www/budgetly`)

#### SSH Key (Required - shared across all servers)

- `SSH_PRIVATE_KEY` - Private SSH key for authentication (shared across all servers)

## How to Set Up

### 1. Generate SSH Key (if not exists)

```bash
# On your local machine
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_deploy

# Copy public key
cat ~/.ssh/github_deploy.pub
```

### 2. Add Public Key to Servers

```bash
# SSH to each server and add the public key
ssh user@server1.example.com
echo "your-public-key-content" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Repeat for server2
```

### 3. Add Secrets to GitHub

Go to: `https://github.com/YOUR_USERNAME/budgetly/settings/secrets/actions`

Click **"New repository secret"** and add each secret:

#### Example Values:

**For Single Server Setup:**

```
SSH_PRIVATE_KEY:
-----BEGIN OPENSSH PRIVATE KEY-----
your-private-key-content-here
-----END OPENSSH PRIVATE KEY-----

SERVER1_HOST: 192.168.1.100
SERVER1_USER: deploy
```

**For Multi-Server Setup (Load Balancer):**

```
SSH_PRIVATE_KEY:
-----BEGIN OPENSSH PRIVATE KEY-----
your-private-key-content-here
-----END OPENSSH PRIVATE KEY-----

SERVER1_HOST: 192.168.1.100
SERVER1_USER: deploy
SERVER1_PORT: 22
SERVER1_APP_PATH: /var/www/budgetly

SERVER2_HOST: 192.168.1.101
SERVER2_USER: deploy
SERVER2_PORT: 22
SERVER2_APP_PATH: /var/www/budgetly
```

> 💡 **Tip**: Only add secrets for servers you actually have. The workflow will automatically detect and deploy to configured servers only.

## Testing SSH Connection

```bash
# Test connection to server1
ssh -i ~/.ssh/github_deploy deploy@192.168.1.100

# Test connection to server2
ssh -i ~/.ssh/github_deploy deploy@192.168.1.101
```

## Security Best Practices

1. **Use dedicated deploy user** - Don't use root

    ```bash
    # On each server
    sudo adduser deploy
    sudo usermod -aG docker deploy
    ```

2. **Restrict SSH key permissions**

    ```bash
    chmod 600 ~/.ssh/github_deploy
    ```

3. **Use SSH key passphrase** (optional but recommended)

4. **Limit SSH key access** - Add to `~/.ssh/authorized_keys`:
    ```
    from="140.82.112.0/20,143.55.64.0/20,185.199.108.0/22,192.30.252.0/22" ssh-ed25519 AAAAC3...
    ```
    (GitHub Actions IP ranges)

## Troubleshooting

### Connection refused

```bash
# Check SSH service
sudo systemctl status sshd

# Check firewall
sudo ufw status
sudo ufw allow 22/tcp
```

### Permission denied

```bash
# Check SSH key permissions on server
ls -la ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Docker permission denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```
