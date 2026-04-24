# ================= CONFIGURAÇÕES =================
$INTERVALO_CICLO = 1         # segundos entre pings
$PING_COUNT = 5               # quantidade de pings por ciclo
$PING_TIMEOUT = 1000          # timeout em milissegundos

# Diretório de logs (automaticamente junto ao script)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$DIRETORIO_LOGS = Join-Path $ScriptPath "logs"
if (!(Test-Path $DIRETORIO_LOGS)) { New-Item -Path $DIRETORIO_LOGS -ItemType Directory | Out-Null }

# ================= FUNÇÕES =================

# Expande ranges tipo 192.168.0.1-5
function Expandir-Range {
    param ($entrada)

    if ($entrada -match "^(\d+\.\d+\.\d+\.)(\d+)-(\d+)$") {
        $prefixo = $matches[1]
        $inicio = [int]$matches[2]
        $fim = [int]$matches[3]

        if ($inicio -gt 255 -or $fim -gt 255 -or $inicio -gt $fim) { return "ERRO" }

        return ($inicio..$fim | ForEach-Object { "$prefixo$_" })
    }

    return $entrada
}

# Valida IP
function Validar-IP {
    param ($ip)

    if ($ip -match "^(\d{1,3}\.){3}\d{1,3}$") {
        foreach ($o in ($ip -split "\.")) {
            if ([int]$o -lt 0 -or [int]$o -gt 255) { return $false }
        }
        return $true
    }

    return $false
}

# ================= FUNÇÃO DE PING =================
function Ping-Detalhado {
    param($ip, $arquivo, [ref]$contador)

    for ($i = 1; $i -le $PING_COUNT; $i++) {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $contador.Value++

        try {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $reply = $ping.Send($ip, $PING_TIMEOUT)
            $sw.Stop()

            $data = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
            $obs = ""

            if ($reply.Status -eq "Success") {
                $lat = [math]::Round($sw.Elapsed.TotalMilliseconds, 2)
                $ttl = $reply.Options.Ttl
                $status = "SUCCESS"
                $obs = "OK"
                Write-Host "[$ip] Teste #$($contador.Value) | $status | $lat ms | TTL $ttl" -ForegroundColor Green
            }
            elseif ($reply.Status -eq "TimedOut") {
                $lat = "-"
                $ttl = "-"
                $status = "TIMEOUT"
                $obs = "Timeout"
                Write-Host "[$ip] Teste #$($contador.Value) | $status | - | - " -ForegroundColor Yellow
            }
            else {
                $lat = "-"
                $ttl = "-"
                $status = "FAIL"
                $obs = "ICMP Fail"
                Write-Host "[$ip] Teste #$($contador.Value) | $status | - | - | $($reply.Status)" -ForegroundColor Red
            }
        }
        catch {
            $lat = "-"
            $ttl = "-"
            $status = "ERROR"
            $obs = "Erro de Sistema"
            Write-Host "[$ip] Teste #$($contador.Value) | $status | - | - | $_" -ForegroundColor Red
        }

        # grava sempre consistente
        $linha = "{0} | {1,5} | {2,-8} | {3,10} | {4,3} | {5}" -f $data, $contador.Value, $status, $lat, $ttl, $obs
        $linha | Out-File -FilePath $arquivo -Append -Encoding UTF8
    }
}

# ================= LOOP PRINCIPAL =================
while ($true) {

    Clear-Host
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host "  MONITORAMENTO WEG (ESTÁVEL)" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan

    $limpar = Read-Host "Limpar logs? (s/n)"
    if ($limpar -eq "s") {
        Remove-Item "$DIRETORIO_LOGS\*.log" -ErrorAction SilentlyContinue
        Write-Host "Logs limpos!" -ForegroundColor Yellow
    }

    # ===== INPUT IPs =====
    $IPS = @()
    while ($true) {
        $entrada = Read-Host "IP ou range (ENTER para iniciar)"
        if ([string]::IsNullOrWhiteSpace($entrada)) { break }

        $alvos = Expandir-Range $entrada
        if ($alvos -eq "ERRO") {
            Write-Host "Range inválido" -ForegroundColor Red
            continue
        }

        foreach ($ip in $alvos) {
            if (Validar-IP $ip) {
                $IPS += $ip
                Write-Host "[+] $ip adicionado" -ForegroundColor Green
            }
            else {
                Write-Host "IP inválido: $ip" -ForegroundColor Red
            }
        }
    }

    if ($IPS.Count -eq 0) { continue }

    # ===== TEMPO =====
    $min = Read-Host "Minutos de teste"
    if (-not ($min -match "^\d+$")) { $min = 1 }
    $fim = (Get-Date).AddMinutes($min)

    Write-Host "`n--- INICIANDO MONITORAMENTO ---`n" -ForegroundColor Cyan

    # ===== CRIA LOGS =====
    $contadorHost = @{} # contador cumulativo por host
    foreach ($ip in $IPS) {
        $contadorHost[$ip] = 0
        $arquivo = Join-Path $DIRETORIO_LOGS ("host_$($ip -replace '\.', '_').log")
        if (!(Test-Path $arquivo)) {
@"
================================================================================================================
RELATÓRIO DETALHADO DE PING - $ip
================================================================================================================
DATA/HORA           | TESTE # | STATUS   | LATÊNCIA(ms) | TTL | OBSERVAÇÃO
----------------------------------------------------------------------------------------------------------------
"@ | Out-File -FilePath $arquivo -Encoding UTF8 -Force
        }
    }

    # ===== LOOP PRINCIPAL =====
    while ((Get-Date) -lt $fim) {
        foreach ($ip in $IPS) {
            $arquivo = Join-Path $DIRETORIO_LOGS ("host_$($ip -replace '\.', '_').log")
            Ping-Detalhado -ip $ip -arquivo $arquivo -contador ([ref]$contadorHost[$ip])
        }
        Start-Sleep -Seconds $INTERVALO_CICLO
    }

    Write-Host "`n--- TESTE CONCLUÍDO ---" -ForegroundColor Cyan
    Read-Host "ENTER para reiniciar"
}