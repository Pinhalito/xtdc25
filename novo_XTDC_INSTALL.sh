#!/bin/bash

#######################
#    ^...^  `^...^´   #
#   / o,o \ / O,O \   #
#   |):::(| |):::(|   #
# ====" "=====" "==== #
#         TdC         #
#      1998-2025      #
#######################
#
# Toca das Corujas
# Códigos Binários,
# Funções de Onda e
# Teoria do Orbital Molecular Inc.
# Unidade Barão Geraldo CX
#
# 2025_07_09_12_58_41
#
# =============================================================================
# VERIFICAÇÃO DE PRIVILÉGIOS DE ROOT COM SUPORTE A SUDO
# CONFIGURAÇÃO DE CORES PARA SAÍDA NO TERMINAL
# =============================================================================
# Definindo códigos de cores para melhorar a visualização das mensagens:
COLOR_HEADER="\e[104m"       # Azul claro (fundo)
COLOR_SUCCESS="\e[1;32m"     # Verde brilhante
COLOR_WARNING="\e[0;35m"     # Roxo
COLOR_ERROR="\e[1;31m"       # Vermelho brilhante
COLOR_INFO="\e[1;36m"        # Ciano brilhante
COLOR_RESET="\033[0m"        # Resetar cor

# Verifica se o usuário atual tem privilégios de root (UID = 0)
if [ "$(id -u)" -ne 0 ]; then
    # Mensagem amigável informando sobre a necessidade de privilégios
    printf "${COLOR_WARNING}Este script requer privilégios de root.${COLOR_RESET}\n"
    printf "${COLOR_WARNING}Por favor insira a senha quando solicitado...${COLOR_RESET}\n"
    
    # Reexecuta o script com sudo, passando todos os argumentos originais
    sudo "$0" "$@"
    
    # Encerra a instância atual do script (sem privilégios)
    exit $?
fi

# Confirmação de que o script agora está sendo executado com privilégios
printf "${COLOR_SUCCESS}✓ Privilégios de root confirmados.${COLOR_RESET}\n"


# =============================================================================
# FUNÇÃO DE DOWNLOAD DE ARQUIVOS SIMPLIFICADA
# =============================================================================

# ==========⚡
xtdc_download() {
    # Instala o curl automaticamente
    apt install -y curl > /dev/null 2>&1
    
    # Configurações básicas
    local GH_URL="https://github.com/Pinhalito/xtdc25/raw/main"
    local DOWNLOAD_DIR="/xtdc"
    
    # Cria a pasta base se não existir (comando único)
    mkdir -p "$DOWNLOAD_DIR" || {
        printf "${COLOR_ERROR}✖ Falha ao criar diretório ${DOWNLOAD_DIR}${COLOR_RESET}\n"
        return 1
    }
    
    # Lista de arquivos para download
    declare -a FILE_LIST=(
        "xtdc_painel.tar.gz" 
        "xtdc_icons.tar.gz"
        "xtdc_theme.tar.gz"
        "xtdc_ttf.tar.gz"
        "xtdc_skel.tar.gz"
        "xtdc"
    )

    # Download dos arquivos
    printf "${COLOR_HEADER}📦 Iniciando downloads...${COLOR_RESET}\n"
    for file in "${FILE_LIST[@]}"; do
        printf "${COLOR_INFO}➔ Baixando ${file}...${COLOR_RESET}\n"
        curl -sL "${GH_URL}/${file}" -o "${DOWNLOAD_DIR}/${file}" || {
            printf "${COLOR_ERROR}✖ Falha no download de ${file}${COLOR_RESET}\n"
            continue
        }
        printf "${COLOR_SUCCESS}✔ ${file} baixado com sucesso!${COLOR_RESET}\n"
    done

    # Ajusta permissões
    chmod -R 777 "$DOWNLOAD_DIR" > /dev/null 2>&1
    printf "${COLOR_SUCCESS}✅ Downloads concluídos!${COLOR_RESET}\n"
}


# ==========⚡
xtdc_exe() {
    # ===========================================================⚡
    # VARIÁVEIS DE SCRIPT
    # ===========================================================⚡
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

# ==========⚡
xtdc_ppa() {
    # =========================================================================
    # LISTA DE PPAS A SEREM ADICIONADOS
    # =========================================================================
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

    printf "${COLOR_HEADER}⚡ INSTALANDO REPOSITÓRIOS PPA ⚡${COLOR_RESET}\n\n"

    # =========================================================================
    # INSTALAÇÃO DOS PPAS
    # =========================================================================
    local NEEDS_UPDATE=0
    
    for ppa in "${!PPAS[@]}"; do
        printf "➔ ${PPAS[$ppa]}... "
        
        if ! grep -rq "ppa.launchpad.net/$ppa" /etc/apt/sources.list /etc/apt/sources.list.d/; then
            if add-apt-repository -y "ppa:$ppa" >/dev/null 2>&1; then
                printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
                NEEDS_UPDATE=1
            else
                printf "${COLOR_ERROR}FALHOU${COLOR_RESET}\n"
            fi
        else
            printf "${COLOR_INFO}JÁ INSTALADO${COLOR_RESET}\n"
        fi
    done

    # =========================================================================
    # ATUALIZAÇÃO FINAL (SE NECESSÁRIO)
    # =========================================================================
    if [ "$NEEDS_UPDATE" -eq 1 ]; then
        printf "\n${COLOR_INFO}🔄 Atualizando lista de pacotes...${COLOR_RESET}\n"
        apt-get update -qq
    fi

    printf "\n${COLOR_SUCCESS}✔ PPAs configurados com sucesso!${COLOR_RESET}\n"
}

# ==========⚡
xtdc_pkg() {
    # =========================================================================
    # CONFIGURAÇÕES INICIAIS
    # =========================================================================
    local BRAVE_EXT_DIR="/opt/brave.com/brave/extensions"
    
    # =========================================================================
    # LISTA DE PACOTES PARA INSTALAÇÃO (um por linha para melhor legibilidade)
    # =========================================================================
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

    # =========================================================================
    # EXTENSÕES DO BRAVE (ID: Nome da Extensão)
    # =========================================================================
    declare -Ag BRAVE_EXT=(
        ["ponfpcnoihfmfllpaingbgckeeldkhle"]="Enhancer for YouTube™"
        ["mnjggcdmjocbbbhaepdhchncahnbgone"]="SponsorBlock para YouTube"
    )

    # =========================================================================
    # INÍCIO DA INSTALAÇÃO
    # =========================================================================
    printf "${COLOR_HEADER}⚡ INSTALANDO PACOTES E APLICATIVOS ⚡${COLOR_RESET}\n\n"
    
    # Atualização inicial dos repositórios
    printf "➔ Atualizando repositórios... "
    if apt-get update -qq; then
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
    else
        printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        return 1
    fi
    
    # =========================================================================
    # INSTALAÇÃO DE PACOTES DO REPOSITÓRIO
    # =========================================================================
    printf "\n➔ VERIFICANDO PACOTES DO REPOSITÓRIO\n"
    
    # Separa pacotes já instalados dos que precisam ser instalados
    declare -a installed_pkgs
    declare -a to_install
    
    for pkg in "${PKGS[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            installed_pkgs+=("$pkg")
        else
            to_install+=("$pkg")
        fi
    done
    
    # Instalação em lote dos pacotes faltantes
    if [ ${#to_install[@]} -gt 0 ]; then
        printf "\n➔ INSTALANDO %d PACOTES\n" "${#to_install[@]}"
        
        if apt-get install -y --no-install-recommends "${to_install[@]}" >/dev/null; then
            printf "  ✔ ${COLOR_SUCCESS}Pacotes instalados com sucesso${COLOR_RESET}\n"
        else
            printf "  ✖ ${COLOR_ERROR}Erro na instalação de alguns pacotes${COLOR_RESET}\n"
        fi
    else
        printf "  ✔ ${COLOR_INFO}Todos os pacotes já estão instalados${COLOR_RESET}\n"
    fi
    
    # =========================================================================
    # INSTALAÇÃO DE APLICATIVOS EXTERNOS
    # =========================================================================
    printf "\n➔ APLICATIVOS EXTERNOS\n"
    
    # Instalação do Rclone
    printf "  ➔ Rclone... "
    if ! command -v rclone >/dev/null; then
        if curl -fsSL https://rclone.org/install.sh | bash >/dev/null; then
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        else
            printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        fi
    else
        printf "${COLOR_INFO}JÁ INSTALADO${COLOR_RESET}\n"
    fi
    
    # Instalação do Brave Browser
    printf "  ➔ Brave Browser... "
    if ! [ -f /usr/bin/brave-browser ] && ! [ -f /opt/brave.com/brave/brave ]; then
        if curl -fsSL https://dl.brave.com/install.sh | bash >/dev/null; then
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        else
            printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        fi
    else
        printf "${COLOR_INFO}JÁ INSTALADO${COLOR_RESET}\n"
    fi
    
    # =========================================================================
    # CONFIGURAÇÃO DAS EXTENSÕES DO BRAVE
    # =========================================================================
    printf "\n➔ EXTENSÕES DO BRAVE\n"
    mkdir -p "$BRAVE_EXT_DIR" 2>/dev/null
    
    for ext_id in "${!BRAVE_EXT[@]}"; do
        printf "  ➔ ${BRAVE_EXT[$ext_id]}... "
        if echo '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }' \
            > "${BRAVE_EXT_DIR}/${ext_id}.json" 2>/dev/null
        then
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        else
            printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        fi
    done
    
    printf "\n${COLOR_SUCCESS}✔ Instalação concluída com sucesso!${COLOR_RESET}\n"
}

# ==========⚡
xtdc_limpeza() {
    # =========================================================================
    # LISTA DE PACOTES PARA REMOÇÃO (organizada por categorias)
    # =========================================================================
    declare -a PACOTES_REMOVER=(
        # Pacotes essenciais para remoção
        snapd apport apport-symptoms thunderbird aspell
        
        # Suíte LibreOffice completa
        libreoffice-*
        
        # Jogos e extras GNOME
        gnome-mahjongg gnome-sudoku gnome-mines aisleriot
        
        # Serviços desnecessários
        bluetooth bluez* cups-browsed printer-driver-*
        
        # Rastreamento de atividades
        zeitgeist*
        
        # Aplicativos diversos
        cheese deja-dup duplicity gnome-characters gnome-font-viewer
        gnome-initial-setup gnome-logs gnome-online-accounts
        gnome-software-plugin-snap openvpn* remmina rhythmbox
        totem shotwell ubuntu-docs usb-creator-gtk
        
        # Pacotes de idiomas desnecessários (mantendo apenas português)
        language-pack-de language-pack-de-base language-pack-en 
        language-pack-en-base language-pack-es language-pack-es-base 
        language-pack-fr language-pack-fr-base language-pack-gnome-de 
        language-pack-gnome-de-base language-pack-gnome-en 
        language-pack-gnome-en-base language-pack-gnome-es 
        language-pack-gnome-es-base language-pack-gnome-fr 
        language-pack-gnome-fr-base language-pack-gnome-it 
        language-pack-gnome-it-base language-pack-gnome-ru-base 
        language-pack-gnome-zh-hans language-pack-gnome-zh-hans-base 
        language-pack-gnome-ru language-pack-it language-pack-it-base 
        language-pack-ru language-pack-ru-base language-pack-zh-hans 
        language-pack-zh-hans-base
    )

    # =========================================================================
    # INÍCIO DA LIMPEZA
    # =========================================================================
    printf "${COLOR_HEADER}⚡ LIMPEZA DO SISTEMA ⚡${COLOR_RESET}\n\n"
    
    # Verifica comandos essenciais
    if ! command -v apt-get &>/dev/null || ! command -v dpkg &>/dev/null; then
        printf "${COLOR_ERROR}✖ Erro: Sistema de pacotes não encontrado!${COLOR_RESET}\n"
        return 1
    fi

    # Atualização inicial
    printf "➔ Atualizando lista de pacotes... "
    if apt-get update -qq &>/dev/null; then
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
    else
        printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        return 1
    fi

    # =========================================================================
    # REMOÇÃO DE PACOTES
    # =========================================================================
    printf "\n${COLOR_HEADER}REMOVENDO PACOTES DESNECESSÁRIOS:${COLOR_RESET}\n"
    
    # Remove pacotes em lote para maior eficiência
    for pkg in "${PACOTES_REMOVER[@]}"; do
        printf "  ➔ ${pkg%%\*}... "
        if dpkg -l | grep -q "^ii.*${pkg%%\*}"; then
            if apt-get purge -y "$pkg" &>/dev/null; then
                printf "${COLOR_SUCCESS}REMOVIDO${COLOR_RESET}\n"
            else
                printf "${COLOR_WARNING}FALHOU${COLOR_RESET}\n"
            fi
        else
            printf "${COLOR_INFO}NÃO INSTALADO${COLOR_RESET}\n"
        fi
    done

    # =========================================================================
    # REMOÇÃO COMPLETA DO SNAP
    # =========================================================================
    if dpkg -l snapd &>/dev/null; then
        printf "\n➔ Removendo Snap completamente... "
        systemctl stop snapd.{socket,service} &>/dev/null
        if apt-get purge -y snapd gnome-software-plugin-snap &>/dev/null; then
            rm -rf /snap /var/snap /var/lib/snapd ~/snap &>/dev/null
            printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
        else
            printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
        fi
    fi

    # =========================================================================
    # LIMPEZA FINAL DO SISTEMA
    # =========================================================================
    printf "\n${COLOR_HEADER}LIMPANDO RESÍDUOS DO SISTEMA:${COLOR_RESET}\n"
    
    printf "➔ Removendo pacotes órfãos... "
    if apt-get autoremove -y --purge &>/dev/null; then
        printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"
    else
        printf "${COLOR_ERROR}FALHA${COLOR_RESET}\n"
    fi
    
    printf "➔ Limpando cache... "
    apt-get clean &>/dev/null
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* &>/dev/null
    printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"

    # =========================================================================
    # CONCLUSÃO
    # =========================================================================
    printf "\n${COLOR_SUCCESS}✔ Limpeza concluída com sucesso!${COLOR_RESET}\n"
    printf "${COLOR_WARNING}⚠ Recomenda-se reiniciar o sistema.${COLOR_RESET}\n"
}

# ==========⚡
xtdc_limpeza_ttflang() {
    # =========================================================================
    # CONFIGURAÇÕES INICIAIS
    # =========================================================================
    local FONTES_DIR="/usr/share/fonts"
    local LOCALE_DIR="/usr/share/locale"
    local LOCALE_GEN="/etc/locale.gen"
    local KEEP_LOCALES=("pt_BR" "en_US")  # pt_BR primeiro, depois en_US como fallback
    local KEEP_FONTS=(
        "arial" "dejavu" "droid" "freefont" "liberation" 
        "noto" "opensymbol" "roboto" "ubuntu" "cantarell"
    )

    printf "${COLOR_HEADER}⚡ LIMPEZA DE FONTES E IDIOMAS ⚡${COLOR_RESET}\n\n"

    # =========================================================================
    # VERIFICA PRIVILÉGIOS
    # =========================================================================
    if [ "$(id -u)" -ne 0 ]; then
        printf "${COLOR_ERROR}✖ Este script requer privilégios de root.${COLOR_RESET}\n"
        return 1
    fi

    # =========================================================================
    # 1. LIMPEZA DE ARQUIVOS DE IDIOMA
    # =========================================================================
    printf "${COLOR_HEADER}➔ REMOVENDO IDIOMAS DESNECESSÁRIOS:${COLOR_RESET}\n"
    
    # Gera lista de locais instalados
    local installed_locales=$(locale -a 2>/dev/null)
    local total_removed=0

    # Remove locais não desejados
    for locale in $installed_locales; do
        local keep=0
        
        # Verifica se o local deve ser mantido
        for keep_locale in "${KEEP_LOCALES[@]}"; do
            if [[ "$locale" == "$keep_locale"* ]]; then
                keep=1
                break
            fi
        done

        if [ $keep -eq 0 ]; then
            printf "  ➔ ${locale}... "
            locale-gen --purge "$locale" &>/dev/null
            localectl set-locale LANG="pt_BR.UTF-8" &>/dev/null  # Alterado para pt_BR como padrão
            printf "${COLOR_SUCCESS}REMOVIDO${COLOR_RESET}\n"
            ((total_removed++))
        fi
    done

    # Atualiza configuração de locais
    printf "\n➔ Atualizando configuração de locais... "
    locale-gen &>/dev/null
    update-locale LANG=pt_BR.UTF-8 LANGUAGE=pt_BR:en_US &>/dev/null  # pt_BR primeiro, en_US como fallback
    printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"

    # =========================================================================
    # 2. LIMPEZA DE FONTES TTF
    # =========================================================================
    printf "\n${COLOR_HEADER}➔ LIMPANDO FONTES DESNECESSÁRIAS:${COLOR_RESET}\n"
    
    # Encontra e remove fontes não essenciais
    find "$FONTES_DIR" -type f -name "*.ttf" | while read -r font; do
        local font_name=$(basename "$font" | tr '[:upper:]' '[:lower:]')
        local delete=1

        # Verifica se a fonte deve ser mantida
        for keep_font in "${KEEP_FONTS[@]}"; do
            if [[ "$font_name" == *"$keep_font"* ]]; then
                delete=0
                break
            fi
        done

        if [ $delete -eq 1 ]; then
            printf "  ➔ ${font_name%.*}... "
            rm -f "$font" &>/dev/null
            printf "${COLOR_SUCCESS}REMOVIDO${COLOR_RESET}\n"
            ((total_removed++))
        fi
    done

    # Atualiza cache de fontes
    printf "\n➔ Atualizando cache de fontes... "
    fc-cache -fv &>/dev/null
    printf "${COLOR_SUCCESS}OK${COLOR_RESET}\n"

    # =========================================================================
    # 3. LIMPEZA DE PACOTES DE IDIOMA
    # =========================================================================
    printf "\n${COLOR_HEADER}➔ REMOVENDO PACOTES DE IDIOMA:${COLOR_RESET}\n"
    
    declare -a lang_pkgs=(
        language-pack-* language-pack-gnome-* language-pack-kde-*
        language-selector-* ibus-mozc mozc-* fcitx-* 
    )

    for pkg in "${lang_pkgs[@]}"; do
        if dpkg -l | grep -q "^ii.*$pkg"; then
            # Verifica se é um pacote que deve ser mantido
            local pkg_name=$(dpkg -l | grep "^ii.*$pkg" | awk '{print $2}')
            local remove=1

            for keep_locale in "${KEEP_LOCALES[@]}"; do
                if [[ "$pkg_name" == *"$keep_locale"* ]]; then
                    remove=0
                    break
                fi
            done

            if [ $remove -eq 1 ]; then
                printf "  ➔ ${pkg_name}... "
                apt-get purge -y "$pkg_name" &>/dev/null
                printf "${COLOR_SUCCESS}REMOVIDO${COLOR_RESET}\n"
                ((total_removed++))
            fi
        fi
    done

    # =========================================================================
    # CONCLUSÃO
    # =========================================================================
    printf "\n${COLOR_SUCCESS}✔ Limpeza concluída!${COLOR_RESET}\n"
    printf "${COLOR_INFO}Total de itens removidos: ${total_removed}${COLOR_RESET}\n"
    printf "${COLOR_WARNING}⚠ Reinicie o sistema para aplicar todas as alterações.${COLOR_RESET}\n"
}

# ==========⚡
xtdc_kernel_cleanup() {
    printf "${COLOR_HEADER}⚡ LIMPEZA DE KERNELS ANTIGOS ⚡${COLOR_RESET}\n\n"
    
    # Lista todos os kernels instalados (exceto o atual)
    current_kernel=$(uname -r)
    installed_kernels=$(dpkg -l | awk '/^ii  linux-image-/{print $2}' | grep -v "$current_kernel" | grep -v "linux-image-generic")
    
    if [ -z "$installed_kernels" ]; then
        printf "${COLOR_INFO}✔ Nenhum kernel antigo encontrado para remover.${COLOR_RESET}\n"
        return 0
    fi
    
    printf "${COLOR_WARNING}Os seguintes kernels antigos foram encontrados:${COLOR_RESET}\n"
    printf "%s\n" "$installed_kernels"
    
    read -p "Deseja remover estes kernels? [s/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        printf "\n${COLOR_INFO}➔ Removendo kernels antigos...${COLOR_RESET}\n"
        apt-get purge -y $installed_kernels >/dev/null
        
        # Limpa pacotes órfãos
        apt-get autoremove -y --purge >/dev/null
        
        printf "${COLOR_SUCCESS}✔ Kernels antigos removidos com sucesso!${COLOR_RESET}\n"
    else
        printf "${COLOR_INFO}✖ Operação cancelada pelo usuário.${COLOR_RESET}\n"
    fi
}
