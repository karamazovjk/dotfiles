# my dotfiles
Arch Linux · Hyprland · Samsung NP530XBB

Configurações pessoais do meu setup Arch Linux com Hyprland. Migrei do Windows em 2025 em uma decisão impulsiva mas sem arrependimentos. O setup roda em um Samsung NP530XBB (Celeron N4000, 4GB RAM) — prova de que dá pra fazer um rice decente em hardware modesto.

## 📦 Estrutura do repo

```
dotfiles/
├── hypr/           # Hyprland — WM, keybinds, gestures, animações
├── waybar/         # Barra de status customizada
├── rofi/           # Launcher de aplicativos
├── kitty/          # Emulador de terminal (Wayland nativo)
├── zsh/            # Shell — oh-my-zsh + Powerlevel10k
├── nvim/           # Editor de código — Neovim + NvChad
├── hyprpanel/      # Painel/widgets do Hyprland
├── swaylock/       # Lockscreen
├── fastfetch/      # Fetch do sistema customizado
├── spotify-player/ # Player Spotify TUI leve
├── sysctl/         # Otimizações do kernel (swappiness)
├── systemd/        # Configuração zram
├── scripts/
│   └── arch-cleanup.sh   # Script de limpeza do sistema
└── install.sh      # Backup e restore das configs
```

## 🛠️ Apps principais

| App | Função | Pacote |
|-----|--------|--------|
| Hyprland | Window manager (Wayland) | hyprland |
| Waybar | Barra de status | waybar |
| Rofi | Launcher de apps | rofi |
| Kitty | Terminal | kitty |
| Neovim + NvChad | Editor de código | neovim |
| Brave | Navegador | brave-bin |
| Joplin | Notas | joplin |
| spotify-player | Player Spotify TUI | spotify-player |
| btop | Monitor do sistema | btop |
| fastfetch | System fetch | fastfetch |
| HyDE | Framework de theming | hyde-cli-git |
| hyprpanel | Painel/widgets | hyprpanel |
| swaylock | Lockscreen | swaylock-effects-git |
| ProtonVPN | VPN | proton-vpn-gtk-app |
| Flatpak | Apps sandboxed | flatpak |
| zsh | Shell | zsh |
| oh-my-zsh | Framework zsh | oh-my-zsh-git |
| Powerlevel10k | Tema do prompt | zsh-theme-powerlevel10k-git |
| yay | AUR helper | yay |
| paccache | Limpeza do cache pacman | pacman-contrib |

## 🎨 Theming

| Componente | Tema |
|-----------|------|
| Terminal (Kitty) | MonaLisa |
| Neovim | NvChad + Obsidian Amber |
| GTK | Gruvbox Dark |
| Hyprland borders | Transparente |

## ⚡ Otimizações (4GB RAM)

- **zram** — swap comprimido em RAM com zstd, tamanho = RAM/2
- **swappiness=10** — kernel usa swap só quando necessário
- `kactivitymanagerd` desativado (daemon KDE desnecessário no Hyprland)

## 🚀 Como usar

Fazer backup das suas configs atuais:
```bash
git clone https://github.com/karamazovjk/dotfiles
cd dotfiles
./install.sh backup
git add -A && git commit -m "chore: backup $(date +%d/%m/%Y)"
git push
```

Restaurar em uma instalação nova:
```bash
git clone https://github.com/karamazovjk/dotfiles
cd dotfiles
./install.sh restore
hyprctl reload
```

Ver status das configs:
```bash
./install.sh status
```

## 🧹 Script de limpeza

O repo inclui um script de manutenção do sistema em `scripts/arch-cleanup.sh`:

**arch-cleanup.sh**  
Limpa: cache do pacman, órfãos, lixeira, cache do usuário, runtimes Flatpak não usados, logs antigos e cache do uv (Python).

---
Arch Linux · Hyprland · NvChad · Samsung NP530XBB · Est. 2025
