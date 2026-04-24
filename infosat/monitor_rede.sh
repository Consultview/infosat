#!/bin/bash

# ================= CONFIGURAÇÕES =================
DIRETORIO_LOGS="logs"
mkdir -p "$DIRETORIO_LOGS"
PARALELISMO=5

# ================= FUNÇÕES =================

expandir_range() {
    local entrada="$1"

    if [[ "$entrada" =~ ^([0-9]+\.[0-9]+\.[0-9]+\.)([0-9]+)-([0-9]+)$ ]]; then
        local prefixo="${BASH_REMATCH[1]}"
        local inicio="${BASH_REMATCH[2]}"
        local fim="${BASH_REMATCH[3]}"

        if ((inicio < 0 || inicio > 255 || fim < 0 || fim > 255 || inicio > fim)); then
            echo "ERRO"
            return 1
        fi

        for ((i=inicio; i<=fim; i++)); do
            echo "${prefixo}${i}"
        done
    else
        echo "$entrada"
    fi
}

validar_e_limpar_ip() {
    local ip="$1"
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
        for o in $o1 $o2 $o3 $o4; do
            ((o < 0 || o > 255)) && return 1
        done
        return 0
    fi
    return 1
}

controlar_jobs() {
    while (( $(jobs -r | wc -l) >= PARALELISMO )); do
        sleep 0.3
    done
}

testar_ip() {
    local alvo="$1"
    local data=$(date '+%d/%m/%Y %H:%M:%S')
    local arquivo_ip="${DIRETORIO_LOGS}/host_$(echo "$alvo" | tr '/' '_').log"

    if [ ! -f "$arquivo_ip" ]; then
        {
            echo "======================================================================="
            echo "           RELATÓRIO DE MONITORAMENTO INFOSAT - $alvo"
            echo "======================================================================="
            printf "%-20s | %-13s | %-7s | %-10s | %s\n" "DATA/HORA" "STATUS" "PERDA" "MÉDIA" "INSTAB. (StDev)"
            echo "-----------------------------------------------------------------------"
        } > "$arquivo_ip"
    fi

    local resultado=$(mtr -r -w -c 5 -n "$alvo" 2>/dev/null | grep -E "^[ ]*[0-9]+" | tail -n 1)

    local status="FALHA REDE"
    local perda="100%"
    local avg="0.0"
    local stdev="0.0"
    local cor="\033[31m"

    if [[ -z "$resultado" ]]; then
        status="DESCONECTADO"
    else
        perda=$(echo "$resultado" | awk '{print $3}')
        avg=$(echo "$resultado" | awk '{print $6}')
        stdev=$(echo "$resultado" | awk '{print $9}')

        [[ -z "$perda" ]] && perda="100%"
        [[ -z "$avg" ]] && avg="0.0"

        local perda_num=$(echo "$perda" | tr -d '%')

        if (( $(echo "$perda_num == 0" | bc -l 2>/dev/null || echo 0) )); then
            status="EXCELENTE"
            cor="\033[32m"
        elif (( $(echo "$perda_num < 100" | bc -l 2>/dev/null || echo 0) )); then
            status="INSTÁVEL"
            cor="\033[33m"
        else
            status="QUEDA TOTAL"
            cor="\033[31m"
        fi
    fi

    printf "%-20s | %-13s | %-7s | %-10s | %s\n" "$data" "$status" "$perda" "${avg}ms" "$stdev" >> "$arquivo_ip"

    echo -e "[$data] ALVO: $alvo | Status: ${cor}$status\033[0m | Média: ${avg}ms | Perda: $perda"
}

gerar_resumo_final() {
    for ip in "${IPS[@]}"; do
        local arquivo_ip="${DIRETORIO_LOGS}/host_$(echo "$ip" | tr '/' '_').log"
        [[ ! -f "$arquivo_ip" ]] && continue

        local media_lat=$(grep "|" "$arquivo_ip" | awk -F'|' '$4 ~ /[0-9]/ {gsub(/ms/,"",$4); sum+=$4; count++} END {if (count>0) printf "%.2f", sum/count; else print "0.00"}')
        local pior_p=$(grep "|" "$arquivo_ip" | awk -F'|' '$3 ~ /[0-9]/ {gsub(/%/,"",$3); print $3}' | sort -nr | head -n1)
        [[ -z "$pior_p" ]] && pior_p="0"

        {
            echo "-----------------------------------------------------------------------"
            echo "                      RESUMO FINAL DO MONITORAMENTO"
            echo "-----------------------------------------------------------------------"
            echo "MÉDIA GERAL DE LATÊNCIA : ${media_lat}ms"
            echo "MAIOR PERDA REGISTRADA  : ${pior_p}%"
            echo "STATUS FINAL DO ALVO    : $( (( $(echo "$pior_p < 5" | bc -l 2>/dev/null || echo 0) )) && echo "APROVADO ✅" || echo "NECESSITA REVISÃO ⚠️" )"
            echo "======================================================================="
        } >> "$arquivo_ip"
    done
}

# ================= LOOP PRINCIPAL =================

while true; do
    clear
    echo -e "\033[36m==========================================================\033[0m"
    echo -e "\033[36m      SISTEMA INFOSAT - MONITORAMENTO GLOBAL MTR\033[0m"
    echo -e "\033[36m==========================================================\033[0m"

    read -rp "Deseja limpar logs anteriores? (s/n): " LIMPAR
    [[ "$LIMPAR" =~ ^[sS]$ ]] && rm -f "$DIRETORIO_LOGS"/*.log && echo -e "\033[33mLogs limpos!\033[0m"

    echo -e "\n1) Manual(192.168.0.1) |\n2) Range (Ex: 192.168.15.10-20)"
    read -p "Opção: " MODO

    IPS=()

    while true; do
        read -rp "Digite o IP  (ou enter para sair): " ENTRADA
        [[ -z "$ENTRADA" ]] && break

        ALVOS=$(expandir_range "$ENTRADA")

        if [[ "$ALVOS" == "ERRO" ]]; then
            echo -e "\033[31m[!] Range inválido\033[0m"
            continue
        fi

        for a in $ALVOS; do
            if validar_e_limpar_ip "$a"; then
                IPS+=("$a")
                echo -e "\033[32m[+] $a\033[0m"
            else
                echo -e "\033[31m[!] IP inválido: $a\033[0m"
            fi
        done

        while true; do
            read -rp "Adicionar mais? (s/n): " OP
            case "$OP" in
                [sS]) break ;;
                [nN]) break 2 ;;
                *) echo -e "\033[31mDigite apenas 's' ou 'n'\033[0m" ;;
            esac
        done
    done

    [[ ${#IPS[@]} -eq 0 ]] && continue

    read -rp "Minutos de teste: " MINUTOS
    if ! [[ "$MINUTOS" =~ ^[0-9]+$ ]] || ((MINUTOS <= 0)); then
        echo -e "\033[33mTempo inválido, usando 1 minuto\033[0m"
        MINUTOS=1
    fi

    TOTAL_SEG=$((MINUTOS * 60))
    INICIO=$SECONDS

    echo -e "\n--- Iniciando Ciclos. Verifique ./$DIRETORIO_LOGS ---\n"

    while (( SECONDS - INICIO < TOTAL_SEG )); do
        for ip in "${IPS[@]}"; do
            controlar_jobs
            testar_ip "$ip" &
        done
        wait
        sleep 5
    done

    echo -e "\n\033[33m--- Finalizando e consolidando resumos... ---\033[0m"
    gerar_resumo_final
    echo -e "\033[32mConcluído com sucesso!\033[0m"
    read -rp "Pressione ENTER para voltar ao menu..."
done
