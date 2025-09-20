# WSL Dev Bootstrap

Automated bootstrap script to set up a complete **WSL development environment** with:

- **Nushell** + **Starship prompt**  
- **Kotlin**, **Gradle**, **JDK 21**  
- **Docker**, **k3d**, **kubectl**, **Helm**, **ArgoCD**  
- **Terraform**, **GitHub CLI**, **Ngrok**, **Hetzner CLI**  
- **Databases**: **PostgreSQL**, **Redis**

This script is designed for **fresh WSL installations** and sets up aliases, shell configuration, and a version-check table (`bsv`) for all installed tools.

---

## Resetting WSL (Manual)

If you want a completely fresh WSL environment before running the bootstrap script, follow these steps:

1. **List all WSL distributions**:

```powershell
wsl --list --verbose
```
Example Output:
```
NAME            STATE           VERSION
Ubuntu          Running         2
docker-desktop  Stopped         2
```
2. **Unregister your Ubuntu distro** (this deletes all files, configs, and installed packages):
```powershell
wsl --unregister Ubuntu
```

3. **Reinstall Ubuntu**:
```powershell
wsl --install -d Ubuntu
```

4. Open the new WSL terminal and follow the prompts to set your UNIX username and password.

---

## Running the Bootstrap Script

1. **Clone the repository** inside WSL:

```bash
git clone https://github.com/bvrple/wsl-bootstrap.git
cd wsl-bootstrap
```

2. **Make the script executable**:
```
chmod +x bootstrap.sh
```

3. **Run the bootstrap script**:
```bash
./bootstrap.sh
```

---

## Post-Installation Steps

1. Open **Nushell** and initialize Starship:
```nu
$env.PATH = ($env.PATH | split row (char esep) | prepend /home/linuxbrew/.linuxbrew/bin)
starship init nu | save -f ~/.cache/starship/init.nu
```

2. **Restart Nushell** to see Starship prompt
3. Verify all tools are installed:
```nu
bsv
```

This will display a Nushell table with all installed tool versions.

---

## Nushell Aliases

| Alias | Command                                      |
| ----- | -------------------------------------------- |
| `acd` | argocd                                       |
| `bsv` | Run `versions.nu` to check all tool versions |
| `d`   | docker                                       |
| `dc`  | docker-compose                               |
| `gw`  | ./gradlew                                    |
| `hc`  | hcloud                                       |
| `k`   | kubectl                                      |
| `rc`  | redis-cli                                    |
| `rs`  | redis-server                                 |
| `t`   | terraform                                    |

---

## Notes
- All databases (Postgres, MongoDB, Redis) start as services automatically.
- The bsv alias runs the versions.nu script to show versions of all installed tools.
- Starship must be initialized once inside Nushell after first opening.
