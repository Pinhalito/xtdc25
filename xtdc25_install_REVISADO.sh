#!/bin/bash

#######################
#    ^...^  `^...^´   #
#   / o,o \ / O,O \   #
#   |):::(| |):::(|   #
# ====" "=====" "==== #
#         TdC         #
#      1998-2025      #
#######################
# Toca das Corujas
# Códigos Binários,
# Funções de Onda e
# Teoria do Orbital Molecular Inc.
# Unidade Barão Geraldo CX
#
# 2025_06_25_21_58_46


# ==========================================⚡
# VERIFICAÇÃO DE ROOT COM SUPORTE A SUDO
# ==========================================⚡
 # ==========================================⚡
 # CONFIGURAÇÃO DE CORES
 # ==========================================⚡
COLOR_HEADER="\e[104m"
COLOR_SUCCESS="\e[1;32m"
COLOR_WARNING="\e[0;35m"
COLOR_ERROR="\e[1;31m"
COLOR_INFO="\e[1;36m"
COLOR_RESET="\033[0m"


if [ "$(id -u)" -ne 0 ]; then
    printf "${COLOR_WARNING}Este script requer privilégios de root.${COLOR_RESET}\n"
    printf "${COLOR_WARNING}Por favor insira a senha quando solicitado...${COLOR_RESET}\n"

    sudo "$0" "$@"
    exit $?
fi

printf "${COLOR_SUCCESS}✓ Privilégios de root confirmados.${COLOR_RESET}\n"


# ==========================================⚡
xtdc_exe() {
    # ==========================================⚡
    # VARIÁVEIS DE SCRIPT
    # ==========================================⚡
    local SCRIPT_NAME="xtdc"
    local BIN_DEST="/bin/xtdc"

    printf "${COLOR_HEADER}[XTDC] INSTALANDO COMANDO GLOBAL${COLOR_RESET}\n"
    printf "⚡====================================⚡\n"

    if [[ ! -f "./$SCRIPT_NAME" ]]; then
        printf "${COLOR_ERROR}✖ Erro: Arquivo '$SCRIPT_NAME' não encontrado${COLOR_RESET}\n" >&2
        return 1
    fi

    printf "➔ Instalando... "
    if mv "./$SCRIPT_NAME" "$BIN_DEST" && chmod 755 "$BIN_DEST"; then
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        printf "${COLOR_SUCCESS}✔ Comando 'xtdc' disponível globalmente${COLOR_RESET}\n"
    else
        printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n" >&2
        return 1
    fi
}

# ==========================================⚡
xtdc_ppavelho() {
    # ==========================================⚡
    # DIRETÓRIOS E PATHS
    # ==========================================⚡
    local XTDC_DIR="/xtdc25"
    local BKP_DIR="${XTDC_DIR}/BKP"
    
    # ==========================================⚡
    # REPOSITÓRIOS EXTERNOS (PPAs)
    # ==========================================⚡
    declare -Ag PPAS=(
        ["afelinczak/ppa"]="Cliptit - Clipboard manager"
        ["cubic-wizard/release"]="Cubic Customizer"
        ["geany-dev/ppa"]="Geany IDE (versão mais recente)"
        ["inkscape.dev/stable"]="Inkscape (última versão estável)"
        ["maarten-baert/simplescreenrecorder"]="SimpleScreenRecorder"
        ["otto-kesselgulasch/gimp"]="GIMP (versões mais recentes)"
        ["team-xbmc/ppa"]="Kodi Media Center"
    )

    printf "${COLOR_HEADER}[XTDC] CONFIGURANDO REPOSITÓRIOS PPA${COLOR_RESET}\n"
    printf "⚡====================================⚡\n"

    # Criar diretório de backup se não existir
    [ -d "$BKP_DIR" ] || mkdir -p "$BKP_DIR"

    # Gerar timestamp para o backup
    local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    local BKP_FILE="${BKP_DIR}/ppa_backup_${TIMESTAMP}.txt"

    # Backup dos PPAs atuais ANTES de instalar novos
    printf "➔ Criando backup dos PPAs atuais... "
    grep -rh "^deb.*ppa.launchpad.net" /etc/apt/sources.list /etc/apt/sources.list.d/ >"$BKP_FILE" 2>/dev/null
    printf "${COLOR_SUCCESS}OK${COLOR_RESET} (Salvo em ${BKP_FILE})\n"
    printf "----------------------------------------\n"

    # Verificar e instalar PPAs
    for ppa in "${!PPAS[@]}"; do
        printf "➔ ${PPAS[$ppa]}... "

        # Verificar se o PPA já está instalado
        if grep -q "^deb.*ppa.launchpad.net/$ppa" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
            printf "${COLOR_INFO}JÁ INSTALADO${COLOR_RESET}\n"
            continue
        fi

        # Adicionar PPA
        add-apt-repository -y "ppa:$ppa" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        else
            printf "${COLOR_ERROR}FALHOU${COLOR_RESET}\n"
        fi
    done

    # Atualizar apenas se algum PPA foi adicionado
    if [ "$(grep -c "^deb" "$BKP_FILE")" -lt "$(grep -rh -c "^deb.*ppa.launchpad.net" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null | awk '{sum =$1} END{print sum}')" ]; then
        apt-get update -qq
        printf "${COLOR_SUCCESS}✔ Novos PPAs instalados com sucesso!${COLOR_RESET}\n"
    else
        printf "${COLOR_INFO}✔ Nenhum novo PPA foi adicionado.${COLOR_RESET}\n"
    fi
}

xtdc_ppa() {
    # ==========================================⚡
    # DIRETÓRIOS E PATHS
    # ==========================================⚡
    local XTDC_DIR="/xtdc25"
    local BKP_DIR="${XTDC_DIR}/BKP"
    
    # ==========================================⚡
    # REPOSITÓRIOS EXTERNOS (PPAs)
    # ==========================================⚡
    declare -Ag PPAS=(
        ["afelinczak/ppa"]="Cliptit - Clipboard manager"
        ["cubic-wizard/release"]="Cubic Customizer"
        ["geany-dev/ppa"]="Geany IDE (versão mais recente)"
        ["inkscape.dev/stable"]="Inkscape (última versão estável)"
        ["maarten-baert/simplescreenrecorder"]="SimpleScreenRecorder"
        ["otto-kesselgulasch/gimp"]="GIMP (versões mais recentes)"
        ["team-xbmc/ppa"]="Kodi Media Center"
    )

    printf "${COLOR_HEADER}[XTDC] CONFIGURANDO REPOSITÓRIOS PPA${COLOR_RESET}\n"
    printf "⚡====================================⚡\n"

    # Configurações iniciais
    [ -d "$BKP_DIR" ] || mkdir -p "$BKP_DIR"
    local BKP_FILE="${BKP_DIR}/ppa_backup_$(date +"%Y%m%d_%H%M%S").list"
    local NEEDS_UPDATE=0

    # 1. Backup completo
    printf "➔ Criando backup dos PPAs... "
    grep -rhE "^deb.*ppa.launchpad.net" /etc/apt/sources.list /etc/apt/sources.list.d/ >"$BKP_FILE"
    printf "${COLOR_SUCCESS}OK${COLOR_RESET} (${BKP_FILE})\n"

    # 2. Remoção de duplicados (única passagem)
    printf "\n🔍 Verificando duplicados:\n"
    for source_file in /etc/apt/sources.list /etc/apt/sources.list.d/*; do
        [ -f "$source_file" ] || continue

        local temp_file=$(mktemp)
        awk '!seen[$0]++' "$source_file" >"$temp_file"

        local original_count=$(wc -l <"$source_file")
        local unique_count=$(wc -l <"$temp_file")

        if [ "$original_count" -gt "$unique_count" ]; then
            printf "  ➔ ${COLOR_WARNING}Removidos $((original_count - unique_count)) duplicado(s) de:${COLOR_RESET} $(basename "$source_file")\n"
            mv "$temp_file" "$source_file"
            chmod 644 "$source_file"
            NEEDS_UPDATE=1
        fi
        rm -f "$temp_file"
    done

    # 3. Instalação de novos PPAs
    printf "\n📥 Instalando novos PPAs:\n"
    for ppa in "${!PPAS[@]}"; do
        printf "  ➔ ${PPAS[$ppa]}... "

        if grep -rq "ppa.launchpad.net/$ppa" /etc/apt/sources.list /etc/apt/sources.list.d/; then
            printf "${COLOR_INFO}JÁ INSTALADO${COLOR_RESET}\n"
        else
            if add-apt-repository -y "ppa:$ppa" >/dev/null 2>&1; then
                printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
                NEEDS_UPDATE=1
            else
                printf "${COLOR_ERROR}FALHOU${COLOR_RESET}\n"
            fi
        fi
    done

    # 4. Atualização condicional
    if [ "$NEEDS_UPDATE" -eq 1 ]; then
        printf "\n🔄 Atualizando lista de pacotes...\n"
        apt-get update -qq
    fi

    printf "${COLOR_SUCCESS}✔ Processo concluído!${COLOR_RESET}\n"
}

<<'GUIA_RESTAURACAO'
=⚡= COMO REVERTER OS PPAs =⚡=
1. Localize o backup mais recente em:
   - "$XTDC_DIR/BKP/ppa_backup_*.txt"

2. Execute manualmente:
   rm /etc/apt/sources.list.d/*ppa*
   mv /caminho/do/seu/backup.txt /etc/apt/sources.list.d/
   apt update
GUIA_RESTAURACAO

# ==========================================⚡
xtdc_pkg() {
    # ==========================================⚡
    # DIRETÓRIOS E PATHS
    # ==========================================⚡
    local XTDC_DIR="/xtdc25"
    local BRAVE_EXT_DIR="/opt/brave.com/brave/extensions"
    
    # ==========================================⚡
    # PACOTES PARA INSTALAÇÃO
    # ==========================================⚡
    declare -a PKGS=(
        # Navegadores e Internet
        rclone-browser transmission
        # Multimídia (Players e Editores)
        smplayer simplescreenrecorder
        # Visualizadores de Imagem
        eog shotwell
        # Produtividade e Acessórios
        baobab clipit file-roller catfish menulibre
        # Utilitários do Sistema
        curl bleachbit evince geany gnome-disk-utility
        gnome-system-monitor gnome-system-tools gparted
        # Ferramentas de Arquivo/Compactação
        p7zip-full rar unrar thunar-archive-plugin
        # Utilitários Diversos
        speedcrunch synaptic tree xfpanel-switch zenity xclip
        # Localização (Português)
        language-pack-gnome-pt language-pack-gnome-pt-base
        language-pack-pt language-pack-pt-base
        # Redes e Backends
        fusesmb gvfs-backends gvfs-fuse samba-libs
    )

    # ==========================================⚡
    # EXTENSÕES DO BRAVE
    # ==========================================⚡
    declare -Ag BRAVE_EXT=(
        ["ponfpcnoihfmfllpaingbgckeeldkhle"]="Enhancer for YouTube™"
        ["mnjggcdmjocbbbhaepdhchncahnbgone"]="SponsorBlock para YouTube"
        ["jiaopdjbehhjgokpphdfgmapkobbnmjp"]="Youtube-shorts block"
    )

    printf "${COLOR_HEADER}[XTDC] INSTALANDO PACOTES${COLOR_RESET}\n"
    printf "⚡====================================⚡\n"

    printf "➔ Atualizando repositórios... "
    if apt-get update -qq; then
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
    else
        printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        return 1
    fi

    printf "\n➔ INSTALANDO PACOTES DO REPOSITÓRIO\n"
    printf "  ➔ Pacotes principais... "
    if apt-get install -y --no-install-recommends "${PKGS[@]}" >/dev/null 2>&1; then
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
    else
        printf "${COLOR_WARNING}ALGUNS PACOTES NÃO INSTALADOS${COLOR_RESET}\n"
    fi

    printf "\n➔ INSTALANDO APLICATIVOS EXTERNOS\n"
    printf "  ➔ Rclone... "
    curl https://rclone.org/install.sh | bash >/dev/null 2>&1 &&
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n" || printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"

    printf "  ➔ Brave Browser... "
    curl -fsSL https://dl.brave.com/install.sh | bash >/dev/null 2>&1 &&
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n" || printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"

    printf "\n➔ CONFIGURANDO EXTENSÕES DO BRAVE\n"
    [ -d "$BRAVE_EXT_DIR" ] || mkdir -p "$BRAVE_EXT_DIR"

    for ext_id in "${!BRAVE_EXT[@]}"; do
        printf "  ➔ ${BRAVE_EXT[$ext_id]}... "
        echo '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }' |
            tee "${BRAVE_EXT_DIR}/${ext_id}.json" >/dev/null &&
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n" || printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
    done

    printf "\n${COLOR_SUCCESS}✔ Instalação de pacotes concluída!${COLOR_RESET}\n"
}

# ==========================================⚡
xtdc_limpeza() {
    # ==========================================⚡
    # PACOTES PARA REMOÇÃO (limpeza)
    # ==========================================⚡
    declare -a PACOTES_REMOVER=(
        # Pacotes essenciais
        snapd apport apport-symptoms thunderbird aspell
        # LibreOffice (completo)
        libreoffice-*
        # Jogos e extras GNOME
        gnome-mahjongg gnome-sudoku gnome-mines
        # Serviços desnecessários
        bluetooth cups-browsed printer-driver-*
        # Zeitgeist (rastreamento de atividades)
        zeitgeist*
    )

    printf "${COLOR_HEADER}\n[XTDC] LIMPEZA DO SISTEMA INICIADA${COLOR_RESET}\n"
    printf "⚡====================================⚡\n"

    if ! command -v apt-get >/dev/null || ! command -v dpkg >/dev/null; then
        printf "${COLOR_ERROR}Erro: apt-get ou dpkg não encontrados!${COLOR_RESET}\n" >&2
        return 1
    fi

    printf "➔ Atualizando lista de pacotes... "
    if apt-get update -qq >/dev/null 2>&1; then
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
    else
        printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        return 1
    fi

    printf "\n${COLOR_HEADER}REMOVENDO PACOTES:${COLOR_RESET}\n"
    for pkg in "${PACOTES_REMOVER[@]}"; do
        printf "  ➔ $pkg... "
        if apt-get purge -y "$pkg" >/dev/null 2>&1; then
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        else
            printf "${COLOR_WARNING}NÃO REMOVIDO${COLOR_RESET}\n"
        fi
    done

    if dpkg -l snapd 2>/dev/null | grep -q '^ii'; then
        printf "➔ Removendo Snap completamente... "
        systemctl stop snapd.socket snapd.service 2>/dev/null
        apt-get purge -y snapd gnome-software-plugin-snap >/dev/null 2>&1 &&
            rm -rf /snap /var/snap /var/lib/snapd ~/snap 2>/dev/null &&
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n" ||
            printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
    fi

    printf "\n${COLOR_HEADER}LIMPANDO RESÍDUOS:${COLOR_RESET}\n"
    printf "➔ Removendo pacotes órfãos... "
    apt-get autoremove -y --purge >/dev/null 2>&1 &&
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n" ||
        printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"

    printf "➔ Limpando cache... "
    apt-get clean >/dev/null 2>&1 &&
        rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* 2>/dev/null &&
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n" ||
        printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"

    printf "\n${COLOR_SUCCESS}✔ Limpeza concluída!${COLOR_RESET}\n"
    printf "${COLOR_WARNING}Recomenda-se reiniciar o sistema.${COLOR_RESET}\n"
}

# ==========================================⚡
xtdc_tema() {
    # ==========================================⚡
    # DIRETÓRIOS E PATHS
    # ==========================================⚡
    local XTDC_DIR="/xtdc25"
    local LIGHTDM_CONF_DIR="/usr/share/lightdm/lightdm-gtk-greeter.conf.d"
    
    # ==========================================⚡
    # ARQUIVOS DE TEMA
    # ==========================================⚡
    declare -a THEME_FILES=(
        "xtdc_icons.tar.gz"
        "xtdc_theme.tar.gz"
        "xtdc_ttf.tar.gz"
        "xtdc_painel.tar.gz"
        "xtdc_skel.tar.gz"
    )

    local RAIZ="$PWD"

    if [ ! -d "$RAIZ" ]; then
        printf "${COLOR_ERROR}Erro: Diretório atual inválido!${COLOR_RESET}\n" >&2
        return 1
    fi

    for arquivo in "${THEME_FILES[@]}"; do
        if [ ! -f "${RAIZ}/${arquivo}" ]; then
            printf "${COLOR_ERROR}Erro: Arquivo ${arquivo} não encontrado no diretório atual!${COLOR_RESET}\n" >&2
            return 1
        fi
    done

    printf "${COLOR_HEADER}Criando backups dos arquivos do sistema...${COLOR_RESET}\n"
    #    cp -a /usr/share/icons /usr/share/icons.bak 2>/dev/null || true
    #    cp -a /usr/share/themes /usr/share/themes.bak 2>/dev/null || true
    #    cp -a /usr/share/fonts/truetype /usr/share/fonts/truetype.bak 2>/dev/null || true
    #    cp -a /etc/skel /etc/skel.bak 2>/dev/null || true

    printf "${COLOR_HEADER}Instalando ícones personalizados...${COLOR_RESET}\n"
    if ! tar xzf "${RAIZ}/xtdc_icons.tar.gz" -C /usr/share/icons; then
        printf "${COLOR_ERROR}Erro ao extrair ícones!${COLOR_RESET}\n" >&2
        return 1
    fi
    find /usr/share/icons -type d -exec chmod 755 "{}" \;
    cp -f /usr/share/icons/xtdc_icons/meus_icones/{xubuntu-logo.png,xubuntu-logo-menu.png,xubuntu-logo.svg} /usr/share/pixmaps/ 2>/dev/null || true

    printf "${COLOR_HEADER}Instalando tema GTK...${COLOR_RESET}\n"
    if ! tar xzf "${RAIZ}/xtdc_theme.tar.gz" -C /usr/share/themes; then
        printf "${COLOR_ERROR}Erro ao extrair tema GTK!${COLOR_RESET}\n" >&2
        return 1
    fi
    find /usr/share/themes -type d -exec chmod 755 "{}" \;

    printf "${COLOR_HEADER}Instalando fontes TrueType...${COLOR_RESET}\n"
    if ! tar xzf "${RAIZ}/xtdc_ttf.tar.gz" -C /usr/share/fonts/truetype; then
        printf "${COLOR_ERROR}Erro ao extrair fontes!${COLOR_RESET}\n" >&2
        return 1
    fi
    find /usr/share/fonts/truetype -type d -exec chmod 755 "{}" \;
    fc-cache -fv >/dev/null

    printf "${COLOR_HEADER}Configurando painel XFCE...${COLOR_RESET}\n"
    if [ -d "/usr/share/xfce4-panel-profiles/layouts" ]; then
        cp "${RAIZ}/xtdc_painel.tar.gz" "/usr/share/xfce4-panel-profiles/layouts/" || true
    else
        printf "${COLOR_WARNING}Aviso: Diretório de layouts do XFCE não encontrado!${COLOR_RESET}\n" >&2
    fi

    printf "${COLOR_HEADER}Configurando skel...${COLOR_RESET}\n"
    if ! tar xzf "${RAIZ}/xtdc_skel.tar.gz" -C /etc; then
        printf "${COLOR_ERROR}Erro ao extrair configurações de usuário!${COLOR_RESET}\n" >&2
        return 1
    fi

    printf "${COLOR_HEADER}Configurando regional...${COLOR_RESET}\n"
    if [ -f "/usr/share/i18n/locales/pt_BR" ]; then
        sed '/^END LC_TIME.*/i first_weekday 2' -i /usr/share/i18n/locales/pt_BR
        locale-gen
    else
        printf "${COLOR_WARNING}Aviso: Arquivo de localização pt_BR não encontrado!${COLOR_RESET}\n" >&2
    fi

    printf "${COLOR_HEADER}Configurando plano de fundo...${COLOR_RESET}\n"
    rm -rf /usr/share/backgrounds/xfce/* /usr/share/xfce4/backdrops/* 2>/dev/null || true

    printf "${COLOR_HEADER}Configurando LightDM...${COLOR_RESET}\n"
    if [ -d "/usr/share/lightdm" ]; then
        mkdir -p "${LIGHTDM_CONF_DIR}"
        chmod 755 "${LIGHTDM_CONF_DIR}"

        cat <<EOF | tee "${LIGHTDM_CONF_DIR}/01_ubuntu.conf" >/dev/null
[greeter]
background=#000000
theme-name=xtdc_theme
icon-theme-name=xtdc_icons
font-name=Ubuntu 11
indicators=~host;~spacer;~session;~language;~a11y;~clock;~power;
clock-format=%d %b, %H:%M
EOF

        cat <<EOF | tee "${LIGHTDM_CONF_DIR}/30_xubuntu.conf" >/dev/null
[greeter]
background=#000000
theme-name=xtdc_theme
icon-theme-name=xtdc_icons
font-name=Noto Sans 9
keyboard=onboard
screensaver-timeout=60
EOF

        chmod 644 "${LIGHTDM_CONF_DIR}"/*.conf 2>/dev/null || true
    else
        printf "${COLOR_WARNING}Aviso: Diretório LightDM não encontrado!${COLOR_RESET}\n" >&2
    fi

    printf "${COLOR_SUCCESS}✔ Configuração de tema concluída com sucesso!${COLOR_RESET}\n"
    return 0
}

xtdc_menu() {
    # ==========================================⚡
    # CONFIGURAÇÃO DO MENU
    # ==========================================⚡
    local ORDEM_PADRAO=("xtdc_exe" "xtdc_ppa" "xtdc_pkg" "xtdc_limpeza" "xtdc_tema")
    local OPCOES=(
        "1) Instalar comando XTDC (xtdc_exe)"
        "2) Configurar repositórios PPA (xtdc_ppa)"
        "3) Instalar pacotes (xtdc_pkg)"
        "4) Limpeza do sistema (xtdc_limpeza)"
        "5) Aplicar temas (xtdc_tema)"
        "6) Executar TODAS as funções na ordem atual"
        "7) Configurar ordem de execução"
        "8) Sair"
    )

    # ==========================================⚡
    # FUNÇÃO PARA EXIBIR MENU
    # ==========================================⚡
    mostrar_menu() {
        clear
        printf "${COLOR_HEADER}╔══════════════════════════════════╗${COLOR_RESET}\n"
        printf "${COLOR_HEADER}║          MENU XTDC v1.1          ║${COLOR_RESET}\n"
        printf "${COLOR_HEADER}╚══════════════════════════════════╝${COLOR_RESET}\n"
        printf "${COLOR_INFO}Ordem atual: ${ORDEM_PADRAO[*]}${COLOR_RESET}\n"
        printf "\n"

        for opcao in "${OPCOES[@]}"; do
            printf "${COLOR_INFO}$opcao${COLOR_RESET}\n"
        done

        printf "\n"
        printf "${COLOR_WARNING}Selecione uma opção [1-8]: ${COLOR_RESET}"
    }

    # ==========================================⚡
    # FUNÇÃO PARA EXECUTAR TODAS AS TAREFAS
    # ==========================================⚡
    executar_todas() {
        printf "${COLOR_HEADER}▶ Ordem de execução:${COLOR_RESET}\n"
        for i in "${!ORDEM_PADRAO[@]}"; do
            printf "${COLOR_INFO}$((i+1)). ${ORDEM_PADRAO[i]}${COLOR_RESET}\n"
        done
        
        printf "\n"
        printf "${COLOR_WARNING}Confirmar execução? [s/N]: ${COLOR_RESET}"
        read -r confirmacao
        [[ "$confirmacao" != [sS]* ]] && return 1
        
        printf "${COLOR_HEADER}▶ Iniciando execução completa...${COLOR_RESET}\n"
        
        for funcao in "${ORDEM_PADRAO[@]}"; do
            printf "${COLOR_INFO}Executando: $funcao${COLOR_RESET}\n"
            printf "----------------------------------------\n"
            
            if command -v "$funcao" >/dev/null; then
                if $funcao; then
                    printf "${COLOR_SUCCESS}✔ $funcao concluído com sucesso${COLOR_RESET}\n"
                else
                    printf "${COLOR_ERROR}✖ $funcao falhou (código $?)${COLOR_RESET}\n"
                    printf "${COLOR_WARNING}Continuar mesmo assim? [s/N]: ${COLOR_RESET}"
                    read -r resposta
                    [[ "$resposta" != [sS]* ]] && return 1
                fi
            else
                printf "${COLOR_ERROR}Função $funcao não encontrada!${COLOR_RESET}\n"
                return 1
            fi
            
            printf "\n"
        done
        
        printf "${COLOR_SUCCESS}✅ Todas as tarefas foram concluídas!${COLOR_RESET}\n"
        return 0
    }

    # ==========================================⚡
    # FUNÇÃO PARA CONFIGURAR ORDEM
    # ==========================================⚡
    configurar_ordem() {
        while true; do
            clear
            printf "${COLOR_HEADER}╔══════════════════════════════════╗${COLOR_RESET}\n"
            printf "${COLOR_HEADER}║     CONFIGURAR ORDEM DE EXECUÇÃO  ║${COLOR_RESET}\n"
            printf "${COLOR_HEADER}╚══════════════════════════════════╝${COLOR_RESET}\n"
            printf "${COLOR_INFO}Ordem atual: ${ORDEM_PADRAO[*]}${COLOR_RESET}\n"
            printf "\n"
            printf "Funções disponíveis:\n"
            printf "1) xtdc_exe\n"
            printf "2) xtdc_ppa\n"
            printf "3) xtdc_pkg\n"
            printf "4) xtdc_limpeza\n"
            printf "5) xtdc_tema\n"
            printf "6) Voltar ao menu principal\n"
            printf "\n"
            printf "${COLOR_WARNING}Digite os números na nova ordem (ex: 2 1 3 5 4):${COLOR_RESET}\n"
            printf "> "
            
            read -r -a nova_ordem
            
            # Verificar se o usuário quer voltar
            [[ "${nova_ordem[0]}" == "6" ]] && return 0
            
            local temp_ordem=()
            local erro=false
            
            # Verificar se todos os números foram fornecidos
            if [ "${#nova_ordem[@]}" -ne 5 ]; then
                printf "%b❌ Você deve especificar todos os 5 números!%b\n" "${COLOR_ERROR}" "${COLOR_RESET}"
                erro=true
            fi
            
            # Processar nova ordem
            for num in "${nova_ordem[@]}"; do
                case $num in
                    1) temp_ordem+=("xtdc_exe") ;;
                    2) temp_ordem+=("xtdc_ppa") ;;
                    3) temp_ordem+=("xtdc_pkg") ;;
                    4) temp_ordem+=("xtdc_limpeza") ;;
                    5) temp_ordem+=("xtdc_tema") ;;
                    *) printf "${COLOR_ERROR}Número inválido: $num${COLOR_RESET}\n"; erro=true ;;
                esac
            done
            
            # Verificar duplicatas
            if [ "$(printf '%s\n' "${temp_ordem[@]}" | sort | uniq -d | wc -l)" -gt 0 ]; then
                printf "${COLOR_ERROR}❌ Não pode haver funções duplicadas!${COLOR_RESET}\n"
                erro=true
            fi
            
            if ! $erro; then
                ORDEM_PADRAO=("${temp_ordem[@]}")
                printf "${COLOR_SUCCESS}✔ Nova ordem definida: ${ORDEM_PADRAO[*]}${COLOR_RESET}\n"
                sleep 2
                return 0
            else
                printf "${COLOR_WARNING}Pressione ENTER para tentar novamente...${COLOR_RESET}"
                read -r
            fi
        done
    }

    # ==========================================⚡
    # LOOP PRINCIPAL DO MENU
    # ==========================================⚡
    while true; do
        mostrar_menu
        read -r opcao
        
        case $opcao in
            1) xtdc_exe ;;
            2) xtdc_ppa ;;
            3) xtdc_pkg ;;
            4) xtdc_limpeza ;;
            5) xtdc_tema ;;
            6) executar_todas ;;
            7) configurar_ordem ;;
            8) break ;;
            *) printf "${COLOR_ERROR}Opção inválida!${COLOR_RESET}\n"; sleep 1 ;;
        esac
        
        printf "\n"
        printf "${COLOR_WARNING}Pressione ENTER para continuar...${COLOR_RESET}"
        read -r
    done
    
    printf "${COLOR_SUCCESS}✔ Menu encerrado${COLOR_RESET}\n"
    return 0
}

xtdc_download() {
    # ==========================================⚡
    # CONFIGURAÇÕES
    # ==========================================⚡
    local GH_URL="https://github.com/Pinhalito/xtdc25/raw/main"
    local DOWNLOAD_DIR="/xtdc25/tmp"
    declare -a FILE_LIST=(
        "xtdc_painel.tar.gz"
        "xtdc_icons.tar.gz"
        "xtdc_theme.tar.gz"
        "xtdc_ttf.tar.gz"
        "xtdc_skel.tar.gz"
        "xtdc"
    )

    # Cores
    COLOR_ERROR="\033[1;31m"
    COLOR_INFO="\033[1;36m"
    COLOR_SUCCESS="\033[1;32m"
    COLOR_WARNING="\033[1;33m"
    COLOR_HEADER="\033[1;36m"
    COLOR_RESET="\033[0m"
#\033[1;32m
    # ==========================================⚡
    # DEPENDÊNCIAS
    # ==========================================⚡
    if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
        printf "${COLOR_ERROR}✖ Erro: Instale 'curl' ou 'wget' primeiro.${COLOR_RESET}\n"
        return 1
    fi

    # ==========================================⚡
    # FUNÇÃO DE DOWNLOAD (COM BARRA DE PROGRESSO)
    # ==========================================⚡
    download_file() {
        local file_url="$1"
        local dest_file="$2"
        local file_name="${file_url##*/}"
        
        # Verifica se o arquivo já existe
        if [[ -f "$dest_file" ]]; then
            printf "${COLOR_INFO}ℹ ${file_name} já existe (${COLOR_SUCCESS}$(du -sh "$dest_file" | cut -f1)${COLOR_INFO}), pulando...${COLOR_RESET}\n"
            return 0
        fi
        
        printf "${COLOR_INFO}➔ Baixando ${file_name}...${COLOR_RESET}\n"
        
        if command -v curl &>/dev/null; then
            curl -# -L --fail --progress-bar "$file_url" -o "$dest_file" || {
                printf "${COLOR_ERROR}✖ Falha no download de ${file_name}${COLOR_RESET}\n"
                return 1
            }
        else
            wget --show-progress -q --progress=bar:force -O "$dest_file" "$file_url" || {
                printf "${COLOR_ERROR}✖ Falha no download de ${file_name}${COLOR_RESET}\n"
                return 1
            }
        fi
        return 0
    }

    # ==========================================⚡
    # EXECUÇÃO PRINCIPAL
    # ==========================================⚡
    printf "${COLOR_HEADER}📦 INICIANDO DOWNLOADS${COLOR_RESET}\n"
    mkdir -p "$DOWNLOAD_DIR" || {
        printf "${COLOR_ERROR}✖ Falha ao criar diretório de downloads${COLOR_RESET}\n"
        return 1
    }

    local download_errors=0
    local skipped_files=0
    for file in "${FILE_LIST[@]}"; do
        local url="${GH_URL}/${file}"
        local dest="${DOWNLOAD_DIR}/${file}"
        
        if [[ -f "$dest" ]]; then
            ((skipped_files++))
            continue
        fi
        
        if download_file "$url" "$dest"; then
            printf "${COLOR_SUCCESS}✔ ${file} baixado com sucesso (${COLOR_INFO}$(du -sh "$dest" | cut -f1)${COLOR_SUCCESS})${COLOR_RESET}\n"
        else
            ((download_errors++))
        fi
    done

    # ==========================================⚡
    # RESUMO FINAL
    # ==========================================⚡
    printf "\n${COLOR_HEADER}📋 RESUMO${COLOR_RESET}\n"
    printf "${COLOR_INFO}• Diretório: ${DOWNLOAD_DIR}${COLOR_RESET}\n"
    printf "${COLOR_SUCCESS}• Baixados: $((${#FILE_LIST[@]} - download_errors - skipped_files))${COLOR_RESET}\n"
    printf "${COLOR_INFO}• Pulados: ${skipped_files}${COLOR_RESET}\n"
    printf "${COLOR_WARNING}• Falhas: ${download_errors}${COLOR_RESET}\n"

    if [ "$download_errors" -eq 0 ]; then
        printf "\n${COLOR_SUCCESS}✅ Concluído${COLOR_RESET}\n"
    else
        printf "\n${COLOR_WARNING}⚠ Alguns arquivos falharam no download. Verifique sua conexão ou URL do arquivo.${COLOR_RESET}\n"
    fi

    return "$download_errors"
    chmod 777 -R /xtdc25
}

#FIM
