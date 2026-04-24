#!/data/data/com.termux/files/usr/bin/bash

# ================= CONFIGURAÇÕES =================
DIRETORIO_LOGS="logs"
mkdir -p "$DIRETORIO_LOGS"

# ================= FUNÇÕES =================

expandir_range() {
    local entrada="$1"
    if [[ "$entrada" =~ ^([0-9]+\.[0-9]+\.[0-9]+\.)([0-9]+)-([0-9]+)$ ]]; then
        local prefixo="${BASH_REMATCH[1]}"
        local inicio="${BASH_REMATCH[2]}"
        local fim="${BASH_REMATCH[3]}"
        for ((i=inicio; i<=fim; i++)); do echo "${prefixo}${i}"; done
    else
        echo "$entrada"
    fi
}

validar_e_limpar_ip() {
    local entrada=$(echo "$1" | tr -cd '0-9.a-zA-Z-')
    [[ -n "$entrada" ]] && echo "$entrada" && return 0
    return 1
}

testar_ip() {
    local alvo="$1"
    local data=$(date '+%d/%m/%Y %H:%M:%S')
    local arquivo_ip="${DIRETORIO_LOGS}/host_$(echo "$alvo" | tr '.' '_').log"

    if [ ! -f "$arquivo_ip" ]; then
        {
            echo "======================================================================="
            echo "       RELATÓRIO INFOSAT (NATIVO) - ALVO: $alvo"
            echo "======================================================================="
            printf "%-20s | %-13s | %-7s | %-10s\n" "DATA/HORA" "STATUS" "PERDA" "MÉDIA"
            echo "-----------------------------------------------------------------------"
        } > "$arquivo_ip"
    fi

    # Ping nativo (5 envios)
    local resultado=$(ping -c 5 -q "$alvo" 2>/dev/null)
    
    if [ $? -ne 0 ] && [ -z "$resultado" ]; then
        status="QUEDA TOTAL"
        perda="100%"
        avg="0.0"
        cor="\033[31m"
    else
        # Extração de dados usando apenas awk (nativo)
        local perda=$(echo "$resultado" | awk '/packet loss/ {for(i=1;i<=NF;i++) if($i~/%/) print $i}')
        local avg=$(echo "$resultado" | tail -1 | awk -F '/' '{print $5}')
        [[ -z "$avg" ]] && avg="0.0"
        
        # Lógica de status usando apenas Shell (sem bc)
        local perda_num=${perda%%%*}
        if [ "$perda_num" -eq 0 ]; then
            status="EXCELENTE"
            cor="\033[32m"
        elif [ "$perda_num" -lt 100 ]; then
            status="INSTÁVEL"
            cor="\033[33m"
        else
            status="DESCONECTADO"
            cor="\033[31m"
        fi
    fi

    printf "%-20s | %-13s | %-7s | %-10s\n" "$data" "$status" "$perda" "${avg}ms" >> "$arquivo_ip"
    echo -e "[$data] ALVO: $alvo | Status: ${cor}$status\033[0m | Média: ${avg}ms | Perda: $perda"
}

gerar_resumo_final() {
    for ip in "${IPS[@]}"; do
        local arquivo_ip="${DIRETORIO_LOGS}/host_$(echo "$ip" | tr '/' '_').log"
        [[ ! -f "$arquivo_ip" ]] && continue

        # Resumo final usando awk para cálculos
        {
            echo "-----------------------------------------------------------------------"
            echo "                      RESUMO FINAL DO MONITORAMENTO"
            echo "-----------------------------------------------------------------------"
            awk -F'|' '
                BEGIN {sum=0; count=0; max_p=0}
                /ms/ {
                    gsub(/[ ms]/,"",$4); sum+=$4; count++;
                    gsub(/[ %]/,"",$3); if($3>max_p) max_p=$3;
                }
                END {
                    printf "MÉDIA GERAL DE LATÊNCIA : %.2fms\n", (count>0 ? sum/count : 0);
                    printf "MAIOR PERDA REGISTRADA  : %d%%\n", max_p;
                    printf "STATUS FINAL DO ALVO    : %s\n", (max_p < 5 ? "APROVADO ✅" : "REVISAR CONEXÃO ⚠️");
                }
            ' "$arquivo_ip"
            echo "======================================================================="
        } >> "$arquivo_ip"
    done
}

# ================= LOOP PRINCIPAL =================

while true; do
    clear
    echo -e "=========================================================="
    echo -e "      INFOSAT TERMUX - MONITOR.SH (100% NATIVO)"
    echo -e "=========================================================="

    read -p "Limpar logs? (s/n): " LIMPAR
    [[ "$LIMPAR" == "s" ]] && rm -f "$DIRETORIO_LOGS"/*.log

    echo -e "\n1) Manual | 2) Range"
    read -p "Opção: " MODO

    IPS=()
    while true; do
        read -p "IP ou Range (ou 'sair'): " ENTRADA
        [[ "$ENTRADA" == "sair" ]] && break
        
        ALVOS=$(expandir_range "$ENTRADA")
        for a in $ALVOS; do
            VALIDO=$(validar_e_limpar_ip "$a")
            if [ $? -eq 0 ]; then IPS+=("$VALIDO"); echo -e "[+] $VALIDO"; fi
        done
        read -p "Mais? (s/n): " OP
        [[ "$OP" != "s" ]] && break
    done

    [[ ${#IPS[@]} -eq 0 ]] && continue
    read -p "Minutos: " MINUTOS
    [[ ! "$MINUTOS" =~ ^[0-9]+$ ]] && MINUTOS=1
    
    TOTAL_SEG=$((MINUTOS * 60))
    INICIO=$SECONDS

    echo -e "\n--- Monitorando ---\n"
    while [ $((SECONDS - INICIO)) -lt $TOTAL_SEG ]; do
        for ip in "${IPS[@]}"; do testar_ip "$ip" & done
        wait
        sleep 5
    done

    gerar_resumo_final
    echo -e "\nConcluído! Relatórios em ./logs"
    read -p "ENTER para voltar..."
done
