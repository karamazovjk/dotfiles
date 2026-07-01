#!/bin/bash
# ╔══════════════════════════════════════════╗
# ║         arch-cleanup.sh                  ║
# ║  Script de limpeza — Arch + Hyprland     ║
# ║  github.com/karamazovjk                  ║
# ╚══════════════════════════════════════════╝

set -uo pipefail
# (removido o "-e" do set original: ele matava o script todo vez que
#  um comando "não achei nada pra fazer" retornava código != 0,
#  ex: pacman -Qtdq sem órfãos, flatpak sem runtime não usado etc.
#  Agora cada seção trata seu próprio erro individualmente.)

# ─── Modo automático (--yes pula todas as confirmações) ─────
AUTO_YES=false
[[ "${1:-}" == "--yes" ]] && AUTO_YES=true

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

separator() { echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

header() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "  ██████╗██╗     ███████╗ █████╗ ███╗   ██╗"
    echo " ██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║"
    echo " ██║     ██║     █████╗  ███████║██╔██╗ ██║"
    echo " ██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║"
    echo " ╚██████╗███████╗███████╗██║  ██║██║ ╚████║"
    echo "  ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝"
    echo -e "${NC}"
    echo -e "${BOLD}  Arch Linux System Cleanup${NC}"
    echo -e "  $(date '+%d/%m/%Y %H:%M')"
    $AUTO_YES && echo -e "  ${CYAN}(modo automático --yes)${NC}"
    separator
}

section() { echo -e "\n${YELLOW}▶ $1${NC}"; }
ok()      { echo -e "  ${GREEN}✓${NC} $1"; }
info()    { echo -e "  ${CYAN}i${NC} $1"; }

# Pergunta de confirmação centralizada — respeita --yes
confirm_action() {
    if $AUTO_YES; then return 0; fi
    echo -e "${YELLOW}  $1 [s/N]${NC} \c"
    read -r confirm
    [[ "$confirm" =~ ^[Ss]$ ]]
}

# ─── Espaço e tempo antes ────────────────────────────────────
before=$(df / | awk 'NR==2 {print $3}')
start_time=$(date +%s)

header

# ─── 1. Cache do pacman ─────────────────────────────────────
section "Cache do pacman"
if command -v paccache &>/dev/null; then
    sudo paccache -rk1 -q || true
    sudo paccache -ruk0 -q || true
    ok "Cache do pacman aparado (mantida 1 versão por pacote)"
else
    info "paccache não encontrado — instale pacman-contrib"
fi

# ─── 2. Orphans do pacman ───────────────────────────────────
section "Pacotes órfãos"
orphans=$(pacman -Qtdq 2>/dev/null || true)
if [ -n "$orphans" ]; then
    echo "$orphans"
    if confirm_action "Remover os órfãos acima?"; then
        sudo pacman -Rns $orphans --noconfirm
        ok "Órfãos removidos"
    else
        info "Pulado"
    fi
else
    ok "Nenhum órfão encontrado"
fi

# ─── 3. Lixeira ─────────────────────────────────────────────
section "Lixeira"
trash_size=$(du -sh ~/.local/share/Trash/ 2>/dev/null | cut -f1)
info "Tamanho atual: ${trash_size:-0}"
rm -rf ~/.local/share/Trash/* 2>/dev/null || true
ok "Lixeira esvaziada"

# ─── 4. Cache do usuário ────────────────────────────────────
section "Cache do usuário (~/.cache)"
cache_size=$(du -sh ~/.cache/ 2>/dev/null | cut -f1)
info "Tamanho atual: ${cache_size:-0}"
if confirm_action "Limpar ~/.cache?"; then
    rm -rf ~/.cache/* 2>/dev/null || true
    ok "Cache limpo"
else
    info "Pulado"
fi

# ─── 5. Cache do pip ─────────────────────────────────────────
section "Cache do pip"
if command -v pip &>/dev/null; then
    pip_size=$(du -sh ~/.cache/pip 2>/dev/null | cut -f1)
    info "Tamanho: ${pip_size:-0}"
    pip cache purge -q 2>/dev/null && ok "Cache do pip limpo" || info "Nada pra limpar"
else
    info "pip não encontrado"
fi

# ─── 6. Flatpak orphans ─────────────────────────────────────
section "Runtimes órfãos do Flatpak"
if command -v flatpak &>/dev/null; then
    if flatpak uninstall --unused -y &>/tmp/flatpak-cleanup.log; then
        ok "Runtimes não utilizados removidos"
    else
        info "Nada pra remover"
    fi
else
    info "Flatpak não instalado"
fi

# ─── 7. Logs do systemd ─────────────────────────────────────
section "Logs do systemd"
log_size=$(journalctl --disk-usage 2>/dev/null | awk '{print $NF}')
info "Tamanho atual: ${log_size:-desconhecido}"
sudo journalctl --vacuum-time=7d -q || true
ok "Logs com mais de 7 dias removidos"

# ─── 8. Cache do uv (Python) ────────────────────────────────
section "Cache do uv (Python)"
if [ -d ~/.local/share/uv/cache ]; then
    uv_size=$(du -sh ~/.local/share/uv/cache 2>/dev/null | cut -f1)
    info "Tamanho: ${uv_size}"
    if confirm_action "Limpar cache do uv?"; then
        rm -rf ~/.local/share/uv/cache
        ok "Cache do uv limpo"
    else
        info "Pulado"
    fi
else
    ok "Nenhum cache do uv encontrado"
fi

# ─── 9. TRIM do armazenamento ────────────────────────────────
section "TRIM do armazenamento"
if command -v fstrim &>/dev/null; then
    if sudo fstrim -av &>/tmp/fstrim.log; then
        ok "TRIM executado (ajuda a performance em eMMC/SSD ao longo do tempo)"
    else
        info "TRIM não suportado neste dispositivo — ver /tmp/fstrim.log"
    fi
else
    info "fstrim não encontrado"
fi

# ─── Resultado final ─────────────────────────────────────────
separator
after=$(df / | awk 'NR==2 {print $3}')
freed=$(( (before - after) / 1024 ))
used_pct=$(df / | awk 'NR==2 {print $5}')
elapsed=$(( $(date +%s) - start_time ))

echo -e "\n${BOLD}  Resultado:${NC}"
echo -e "  ${GREEN}✓ Espaço liberado: ~${freed} MB${NC}"
echo -e "  ${CYAN}i Disco usado: ${used_pct}${NC}"
echo -e "  ${CYAN}i Tempo total: ${elapsed}s${NC}"
echo -e "  ${CYAN}i RAM: $(free -h | awk 'NR==2{print $3"/"$2" ("$3/$2*100"%)"}' 2>/dev/null || free -h | awk 'NR==2{print $3"/"$2}')${NC}"
separator
echo ""
