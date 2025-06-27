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
# 2025_06_27_20_44_29
# =======================================================⚡
# VERIFICAÇÃO DE ROOT COM SUPORTE A SUDO
# =======================================================⚡
# =======================================================⚡
# CONFIGURAÇÃO DE CORES
# =======================================================⚡
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

# =======================================================⚡
xtdc_exe() {
    # =======================================================⚡
    # VARIÁVEIS DE SCRIPT
    # =======================================================⚡
    local SCRIPT_NAME="xtdc"
    local BIN_DEST="/bin/xtdc"

    printf "${COLOR_HEADER}[XTDC] INSTALANDO COMANDO GLOBAL${COLOR_RESET}\n"
    printf "⚡=====================================================⚡\n"

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

# =======================================================⚡
xtdc_ppa() {
    # =======================================================⚡
    # DIRETÓRIOS E PATHS
    # =======================================================⚡
    local XTDC_DIR="/xtdc25"
    local BKP_DIR="${XTDC_DIR}/BKP"
    
    # =======================================================⚡
    # REPOSITÓRIOS EXTERNOS (PPAs)
    # =======================================================⚡
    declare -Ag PPAS=(
        ["afelinczak/ppa"]="Cliptit - Clipboard manager"
        ["cubic-wizard/release"]="Cubic Customizer"
        ["geany-dev/ppa"]="Geany IDE (versão mais recente)"
        ["inkscape.dev/stable"]="Inkscape (última versão estável)"
        ["maarten-baert/simplescreenrecorder"]="SimpleScreenRecorder"
        ["otto-kesselgulasch/gimp"]="GIMP (versões mais recentes)"
        ["team-xbmc/ppa"]="Kodi Media Center"
        ["kisak/kisak-mesa"]="Drivers AMD Ryzen 5 2400G with Radeon Vega Graphics"
    )

    printf "${COLOR_HEADER}[XTDC] CONFIGURANDO REPOSITÓRIOS PPA${COLOR_RESET}\n"
    printf "⚡=====================================================⚡\n"

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

# =======================================================⚡
xtdc_pkg() {
    # =======================================================⚡
    # DIRETÓRIOS E PATHS
    # =======================================================⚡
    local XTDC_DIR="/xtdc25"
    local BRAVE_EXT_DIR="/opt/brave.com/brave/extensions"
    
    # =======================================================⚡
    # PACOTES PARA INSTALAÇÃO
    # =======================================================⚡
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
        
        # aisleriot bluez* cheese deja-dup duplicity gnome-characters gnome-font-viewer gnome-initial-setup gnome-logs gnome-online-accounts gnome-mines gnome-sudoku gnome-mahjongg language-pack-de language-pack-de-base language-pack-en language-pack-en-base language-pack-es language-pack-es-base language-pack-fr language-pack-fr-base language-pack-gnome-de language-pack-gnome-de-base language-pack-gnome-en language-pack-gnome-en-base language-pack-gnome-es language-pack-gnome-es-base language-pack-gnome-fr language-pack-gnome-fr-base language-pack-gnome-it language-pack-gnome-it-base language-pack-gnome-ru-base language-pack-gnome-zh-hans language-pack-gnome-zh-hans-base language-pack-gnome-ru language-pack-it language-pack-it-base language-pack-ru language-pack-ru-base language-pack-zh-hans language-pack-zh-hans-base LibreOffice* openvpn* remmina rhythmbox totem cheese shotwell snapd gnome-software-plugin-snap thunderbird* ubuntu-docs usb-creator-gtk 
    )

    # =======================================================⚡
    # EXTENSÕES DO BRAVE
    # =======================================================⚡
    declare -Ag BRAVE_EXT=(
        ["ponfpcnoihfmfllpaingbgckeeldkhle"]="Enhancer for YouTube™"
        ["mnjggcdmjocbbbhaepdhchncahnbgone"]="SponsorBlock para YouTube"
        ["jiaopdjbehhjgokpphdfgmapkobbnmjp"]="Youtube-shorts block"
    )

    printf "${COLOR_HEADER}[XTDC] INSTALANDO PACOTES${COLOR_RESET}\n"
    printf "⚡=====================================================⚡\n"
    
    printf "➔ Atualizando lista de pacotes... "
    if apt-get update -qq; then
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
    else
        printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        return 1
    fi
    
    printf "\n➔ VERIFICANDO PACOTES DO REPOSITÓRIO\n"
    
    # 1. Verifica pacotes já instalados
    declare -a ja_instalados
    declare -a para_instalar
    
    for pkg in "${PKGS[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            ja_instalados+=("$pkg")
        else
            para_instalar+=("$pkg")
        fi
    done
    
    # 2. Instala os pacotes restantes de uma vez
    if [ ${#para_instalar[@]} -gt 0 ]; then
        printf "\n➔ INSTALANDO NOVOS PACOTES\n"
        printf "  ➔ Instalando ${#para_instalar[@]} pacotes... "
        
        if apt-get install -y --no-install-recommends "${para_instalar[@]}" >/dev/null 2>&1; then
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        else
            printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        fi
    
        # 3. Verifica resultados pós-instalação
        declare -a instalados_ok
        declare -a instalados_falha
        
        for pkg in "${para_instalar[@]}"; do
            if dpkg -l | grep -q "^ii  $pkg "; then
                instalados_ok+=("$pkg")
            else
                instalados_falha+=("$pkg")
            fi
        done
    else
        echo -e "  ✔ Todos os pacotes já estavam instalados"
    fi
    
    # MOSTRA TODOS OS RESULTADOS JUNTOS NO FINAL (sua versão modificada)
    printf "\n➔ RESUMO DA INSTALAÇÃO\n"
    
    if [ ${#ja_instalados[@]} -gt 0 ]; then
        echo -e "  ✔ ${COLOR_SUCCESS}JÁ INSTALADOS:${COLOR_RESET}"
        for pkg in "${ja_instalados[@]}"; do
            echo -e "     ‣ ${COLOR_SUCCESS}$pkg${COLOR_RESET}"
        done
    fi
    
    if [ ${#instalados_ok[@]} -gt 0 ]; then
        echo -e "\n  ✔ ${COLOR_SUCCESS}INSTALADOS COM SUCESSO:${COLOR_RESET}"
        for pkg in "${instalados_ok[@]}"; do
            echo -e "     ‣ ${COLOR_SUCCESS}$pkg${COLOR_RESET}"
        done
    fi
    
    if [ ${#instalados_falha[@]} -gt 0 ]; then
        echo -e "\n  ✖ ${COLOR_ERROR}FALHA NA INSTALAÇÃO:${COLOR_RESET}"
        for pkg in "${instalados_falha[@]}"; do
            echo -e "     ‣ ${COLOR_ERROR}$pkg${COLOR_RESET}"
        done
    fi

    printf "\n➔ INSTALANDO APLICATIVOS EXTERNOS\n"

    # Verifica e instala Rclone apenas se não estiver instalado
    printf "  ➔ Rclone... "
    if command -v rclone >/dev/null 2>&1; then
        printf "${COLOR_INFO}JÁ INSTALADO${COLOR_RESET}\n"
    else
        if curl -fsSL https://rclone.org/install.sh | bash >/dev/null 2>&1; then
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        else
            printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        fi
    fi

    # Verifica e instala Brave apenas se não estiver instalado
    printf "  ➔ Brave Browser... "
    if [ -f /usr/bin/brave-browser ] || [ -f /opt/brave.com/brave/brave ]; then
        printf "${COLOR_INFO}JÁ INSTALADO${COLOR_RESET}\n"
    else
        if curl -fsSL https://dl.brave.com/install.sh | bash >/dev/null 2>&1; then
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        else
            printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        fi
    fi

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

# =======================================================⚡
xtdc_limpeza() {
    # =======================================================⚡
    # PACOTES PARA REMOÇÃO (limpeza)
    # =======================================================⚡
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
    printf "⚡=====================================================⚡\n"

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

# =======================================================⚡
xtdc_download() {
    # =======================================================⚡
    # CONFIGURAÇÕES
    # =======================================================⚡
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

    # =======================================================⚡
    # DEPENDÊNCIAS
    # =======================================================⚡
    if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
        printf "${COLOR_ERROR}✖ Erro: Instale 'curl' ou 'wget' primeiro.${COLOR_RESET}\n"
        return 1
    fi

    # =======================================================⚡
    # FUNÇÃO DE DOWNLOAD (COM BARRA DE PROGRESSO)
    # =======================================================⚡
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

    # =======================================================⚡
    # EXECUÇÃO PRINCIPAL
    # =======================================================⚡
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

    # =======================================================⚡
    # RESUMO FINAL
    # =======================================================⚡
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

# =======================================================⚡
xtdc_tema() {
    # =======================================================⚡
    # DIRETÓRIOS E PATHS
    # =======================================================⚡
    local XTDC_DIR="/xtdc25"
    local LIGHTDM_CONF_DIR="/usr/share/lightdm/lightdm-gtk-greeter.conf.d"
    
    # =======================================================⚡
    # ARQUIVOS DE TEMA
    # =======================================================⚡
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

# =======================================================⚡
xtdc_limpa_atalhos() {
    # Remove arquivo específico
    rm -rf /usr/share/xubuntu/applications/xfhelp4.desktop 2>/dev/null
    
    local desktop_files=($(find /usr/share/applications -name "*.desktop"))
    
    for file in "${desktop_files[@]}"; do
        sed -i \
            -e '/NoDisplay=/d; $a NoDisplay=true' \
            -e '/Name\[/d; /Comment\[/d; /Icon\[/d; /Keywords\[/d; /GenericName/d' \
            -e '/^$/d' \
            -e '/^[[:blank:]]*#/d; s/#.*//' "$file"
    done
}

# =======================================================⚡
xtdc_ata() {
    declare -A APPS=(
        # INTERNET ===========================================================⚡
        ['google-chrome']="[Desktop Entry]
Name=Google Chrome
Comment=Acesse a Internet
Exec=/usr/bin/google-chrome-stable %U
Icon=google-chrome
Terminal=false
Type=Application
Categories=Network;
Keywords=navegador;web;internet;
MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;

[Desktop Action new-window]
Name=Nova janela
Exec=/usr/bin/google-chrome-stable

[Desktop Action new-private-window]
Name=Nova janela anônima
Exec=/usr/bin/google-chrome-stable --incognito"

        ['google-chrome-incognito']="[Desktop Entry]
Name=Google Chrome ANÔNIMO
Comment=Navegar na internet sem deixar rastros
Exec=/usr/bin/google-chrome-stable --incognito
Icon=/usr/share/icons/xtdc_icons/apps/google-chrome-incognito.svg
Terminal=false
Type=Application
Categories=Network;"

        ['brave-browser']="[Desktop Entry]
Version=1.0
Name=Navegador Brave
Comment=Mais seguro que o Chrome
Exec=/usr/bin/brave-browser-stable %U
Icon=brave-browser
Terminal=false
Type=Application
Categories=Network;
Keywords=navegador;web;internet;
MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;

[Desktop Action new-window]
Name=Nova Janela
Exec=/usr/bin/brave-browser-stable

[Desktop Action new-private-window]
Name=Brave ANÔNIMO
Exec=/usr/bin/brave-browser-stable --incognito
Icon=/usr/share/icons/xtdc_icons/apps/google-chrome-incognito.svg"

        ['rclone-browser']="[Desktop Entry]
Name=Rclone Browser
Comment=Gerenciador de contas Dropbox, Google Drive
Exec=/usr/bin/rclone-browser
Icon=rclone-browser.png
Terminal=false
Type=Application
Categories=Network
Keywords=nuvem;drive;dropbox;"

        ['transmission-gtk']="[Desktop Entry]
Name=Transmission
Comment=Cliente BitTorrent
Exec=transmission-gtk %U
Icon=transmission
Terminal=false
Type=Application
Categories=Network
Keywords=torrent;
MimeType=application/x-bittorrent;x-scheme-handler/magnet;"

        # MULTIMÍDIA ===========================================================⚡
        ['smplayer']="[Desktop Entry]
Name=SMPlayer
Comment=Player de vídeo e música
Exec=smplayer %U
Icon=smplayer
Terminal=false
Type=Application
Categories=AudioVideo;
Keywords=vídeo;video;filme;mp4;música;mp3;áudio;audio;
MimeType=video/*;audio/*;"
        ['kodi']="[Desktop Entry]
Version=1.0
Name=Kodi
Comment=Central de Vídeos, Filmes, Séries (TV BOX ou Net Gato)
Exec=kodi
Icon=kodi
Terminal=false
Type=Application
Categories=ÁudioVídeo;
Keywords=Mídia;Filmes;Séries;TV;"

        # ESCRITÓRIO ===========================================================⚡
        ['libreoffice']="[Desktop Entry]
Name=LibreOffice
Comment=Suite Office Completa
Exec=/xtdc25/AppImages/LibreOffice-fresh.standard-x86_64.AppImage
Icon=libreoffice
Terminal=false
Type=Application
Categories=Office;
Keywords=office;word;excel;powerpoint;doc;xls;ppt;
MimeType=application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/msword;application/vnd.ms-excel;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/vnd.ms-powerpoint;application/rtf;text/csv;"

        ['evince']="[Desktop Entry]
Name=Visualizador de documentos PDF
Comment=Visualizador de documentos PDF
Exec=evince %U
Icon=evince
Terminal=false
Type=Application
Categories=Office
MimeType=application/pdf;application/x-bzpdf;application/x-gzpdf;application/x-xzpdf;application/x-ext-pdf;application/postscript;application/x-bzpostscript;application/x-gzpostscript;image/x-eps;image/x-bzeps;image/x-gzeps;application/x-ext-ps;application/x-ext-eps;application/illustrator;application/x-dvi;application/x-bzdvi;application/x-gzdvi;application/x-ext-dvi;image/vnd.djvu+multipage;application/x-ext-djv;application/x-ext-djvu;image/tiff;application/x-cbr;application/x-cbz;application/x-cb7;application/x-cbt;application/x-ext-cbr;application/x-ext-cbz;application/vnd.comicbook+zip;application/x-ext-cb7;application/x-ext-cbt;application/oxps;application/vnd.ms-xpsdocument;"

        # GRÁFICOS ===========================================================⚡
        ['eog']="[Desktop Entry]
Name=Visualizador de imagens
Comment=Visualizador Simples de imagens 
Exec=eog %U
Icon=eog
Terminal=false
Type=Application
Categories=Graphics
MimeType=image/bmp;image/gif;image/jpeg;image/jpg;image/pjpeg;image/png;image/tiff;image/x-bmp;image/x-gray;image/x-icb;image/x-ico;image/x-png;image/x-portable-anymap;image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/x-xbitmap;image/x-xpixmap;image/x-pcx;image/svg+xml;image/svg+xml-compressed;image/vnd.wap.wbmp;"

        ['shotwell']="[Desktop Entry]
Name=Organizador de fotos
Comment=Organizador de fotos
Keywords=foto;album;ãlbum,photo,imagem,imagens,png,gif,jpg
Exec=shotwell %U
Icon=shotwell
Terminal=false
Type=Application
MimeType=x-content/image-dcf;
Categories=Graphics;
X-GIO-NoFuse=true"

        # ACESSÓRIOS ===========================================================⚡
        ['baobab']="[Desktop Entry]
Name=Analisador de uso de disco
Comment=Verifique o tamanho de pastas e o espaço disponível em disco
Keywords=armazenamento;espaço;limpeza;
Exec=baobab
Icon=baobab
Terminal=false
Type=Application
Categories=Utility;"

        ['speedcrunch']="[Desktop Entry]
Name=Calculadora
Comment=Calculadora
Exec=speedcrunch
Icon=speedcrunch
Terminal=false
Type=Application
Categories=Utility;"
        ['gnome-disks']="[Desktop Entry]
Name=Discos
Comment=Gerencie unidades de disco e mídias
Exec=gnome-disks
Icon=org.gnome.DiskUtility
Terminal=false
Type=Application
Categories=Utility;
Keywords=disco;drive;hdd;disc;"
        ['gnome-system-monitor']="[Desktop Entry]
Name=Monitor do Sistema
Comment=Visualize processos e monitore o estado do sistema
Exec=gnome-system-monitor
Icon=utilities-system-monitor
Terminal=false
Type=Application
Categories=Utility;
Keywords=Monitor;Sistema;Processos;CPU;Memória;Rede;Desempenho;"
        ['gparted']="[Desktop Entry]
Name=GParted
Comment=Crie, reorganize e exclua partições
Exec=gparted %f
Icon=gparted
Terminal=false
Type=Application
Categories=Utility;
Keywords=Partição;Disco;HDD;SSD;"
        # CONFIGURAÇÕES ===========================================================⚡
        ['xfce4-appearance-settings']="[Desktop Entry]
Name=Aparência
Comment=Configuração de ícones e temas
Exec=xfce4-appearance-settings
Icon=preferences-desktop-theme
Terminal=false
Type=Application
Categories=Settings;"
    )

    # ASSOCIAÇÕES PADRÃO
    DEFAULTS="[Default Applications]
application/pdf=evince.desktop
text/html=google-chrome.desktop
inode/directory=thunar.desktop
audio/*=smplayer.desktop
video/*=smplayer.desktop
application/vnd.openxmlformats-officedocument.wordprocessingml.document=libreoffice.desktop
application/msword=libreoffice.desktop
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=libreoffice.desktop"

    # CRIA OS ATALHOS (sem criar o diretório pois já existe)
    for app in "${!APPS[@]}"; do
        echo "${APPS[$app]}" > "$HOME/.local/share/applications/${app}.desktop"
        echo "Atalho criado: ${app}.desktop"
    done

    # CRIA AS ASSOCIAÇÕES
    echo "$DEFAULTS" > /usr/share/applications/defaults.list
    echo "Associações padrão configuradas"

    # ATUALIZA O BANCO DE DADOS
    update-desktop-database $HOME/.local/share/applications
    echo "Banco de dados de atalhos atualizado"
}

#FIM

# =======================================================⚡
xtdc_menu() {
    # =======================================================⚡
    # CONFIGURAÇÃO DO MENU
    # =======================================================⚡
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

    # =======================================================⚡
    # FUNÇÃO PARA EXIBIR MENU
    # =======================================================⚡
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

    # =======================================================⚡
    # FUNÇÃO PARA EXECUTAR TODAS AS TAREFAS
    # =======================================================⚡
    executar_todas() {
        # Cabeçalho
        printf "%s▶ Ordem de execução:%s\n" "${COLOR_HEADER}" "${COLOR_RESET}"
        
        # Lista as funções numeradas (corrigido o problema aritmético)
        local contador=1
        for funcao in "${ORDEM_PADRAO[@]}"; do
            printf "%s%d. %s%s\n" "${COLOR_INFO}" "$contador" "$funcao" "${COLOR_RESET}"
            ((contador++))
        done
        
        # Confirmação
        printf "\n%sConfirmar execução? [s/N]: %s" "${COLOR_WARNING}" "${COLOR_RESET}"
        read -r confirmacao
        [[ "$confirmacao" != [sS]* ]] && return 1
        
        # Execução
        printf "%s▶ Iniciando execução completa...%s\n" "${COLOR_HEADER}" "${COLOR_RESET}"
        
        local contador=1
        for funcao in "${ORDEM_PADRAO[@]}"; do
            printf "%sExecutando %d/%d: %s%s\n" "${COLOR_INFO}" "$contador" "${#ORDEM_PADRAO[@]}" "$funcao" "${COLOR_RESET}"
            printf "%s----------------------------------------%s\n" "${COLOR_INFO}" "${COLOR_RESET}"
            
            if declare -f "$funcao" >/dev/null; then
                if "$funcao"; then
                    printf "%s✔ %s concluído com sucesso%s\n" "${COLOR_SUCCESS}" "$funcao" "${COLOR_RESET}"
                else
                    local status=$?
                    printf "%s✖ %s falhou (código %d)%s\n" "${COLOR_ERROR}" "$funcao" "$status" "${COLOR_RESET}"
                    printf "%sContinuar mesmo assim? [s/N]: %s" "${COLOR_WARNING}" "${COLOR_RESET}"
                    read -r resposta
                    [[ "$resposta" != [sS]* ]] && return "$status"
                fi
            else
                printf "%sFunção %s não encontrada!%s\n" "${COLOR_ERROR}" "$funcao" "${COLOR_RESET}"
                return 1
            fi
            
            printf "\n"
            ((contador++))
        done
        
        printf "%s✅ Todas as %d tarefas foram concluídas!%s\n" "${COLOR_SUCCESS}" "${#ORDEM_PADRAO[@]}" "${COLOR_RESET}"
        return 0
    }

    # =======================================================⚡
    # FUNÇÃO PARA CONFIGURAR ORDEM
    # =======================================================⚡
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

    # =======================================================⚡
    # LOOP PRINCIPAL DO MENU
    # =======================================================⚡
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
xtdc_criatudo() {
    # Limpeza segura do arquivo de saída
    : > tudo.txt

    first_file=true
    for file in *.desktop; do
        # Verifica se o arquivo existe e não está vazio (proteção extra)
        if [ ! -s "$file" ]; then
            echo "[AVISO] Arquivo $file vazio ou não encontrado, pulando..." >&2
            continue
        fi

        # Adiciona linhas em branco entre entradas (exceto primeira)
        if ! $first_file; then
            printf '\n\n' >> tudo.txt  # Mais eficiente que dois 'echo'
        fi
        
        # Processamento do conteúdo com segurança:
        content=$(
            # 1. Escapa aspas internas
            # 2. Remove espaços no final das linhas
            # 3. Remove linhas totalmente vazias no final (opcional)
            sed -e 's/"/\\"/g' \
                -e 's/[[:blank:]]*$//' \
                -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$file"
        )

        # Gravação formatada (à prova de erros)
        {
            printf "['%s']=\"" "$file"
            printf '%s' "$content"
            echo '"'
        } >> tudo.txt  # Redirecionamento único para melhor performance

        first_file=false
    done

    echo "Processamento concluído! Resultado salvo em 'tudo.txt'"
}
xtdc_cria_ata() {
    nome_atalho="[Desktop Entry]
Name=teste
Comment=bliu
Exec=bliu
Icon=bliu
Terminal=false
Type=Application
Categories=;
Keywords=;
MimeType=;"
    echo "$nome_atalho" > /usr/share/applications/nome-do-atalho.desktop
    #update-desktop-database ~/.local/share/applications/
}
