# Variáveis de configuração
$varProxyOffice = '111.11.111.11:80'
$varProxyVPNLib = '22.222.2.222:80'

# A lista de sub-redes do escritório (4 - cabo rede | 12 e 13 wi-fi)
$varSubnetOffices = '22.222.4','22.222.12','22.222.13'

# Inicialmente, o proxy padrão é o da VPN, caso nenhuma sub-rede do escritório seja encontrada
$varMyProxy = $varProxyVPNLib

# Obtém todos os endereços IP IPv4 da máquina
$varIPs = Get-NetIPAddress -AddressFamily IPv4

# Itera por cada um dos IPs encontrados
foreach ($ip in $varIPs) {
    # Extrai os primeiros 9 caracteres do IP para obter a sub-rede
    $mySubnet = $ip.IPAddress.Substring(0,9)
    
    # Verifica se a sub-rede obtida está na lista de sub-redes do escritório
    # O operador "-in" é uma forma limpa de verificar se um item existe em uma lista
    if ($mySubnet -in $varSubnetOffices) {
        # Se um IP do escritório for encontrado, define o proxy correto
        $varMyProxy = $varProxyOffice
        
        # Sai do loop imediatamente, pois já encontramos a rede correta
        break
    }
}

# Exibe o proxy selecionado no final do script
Write-Host "Proxy selecionado para esta rede: $varMyProxy`n"

## Aplicar Proxy no Git

# Adiciona as novas configurações de proxy no Git
git config --global http.proxy $varMyProxy
git config --global https.proxy $varMyProxy

# Validação e Mensagem para o Git
$gitProxy = git config --global --get http.proxy
if ($gitProxy -eq $varMyProxy) {
    Write-Host "✅ Git: Proxy configurado com sucesso para $varMyProxy" -ForegroundColor Green
} else {
    Write-Host "❌ Git: Falha ao configurar o proxy." -ForegroundColor Red
}

## Aplicar Proxy no Conda

# Seta o caminho do arquivo .condarc
$condaConfigPath = Join-Path $env:USERPROFILE ".condarc"

# A base da instalação do Anaconda está em AppData\Local
$condaInstallPath = Join-Path $env:USERPROFILE "AppData\Local\anaconda3"

# O executável do Conda está em Scripts\conda.exe
$condaExePath = Join-Path $condaInstallPath "Scripts\conda.exe"

# Verifica se o executável do Conda existe
if (Test-Path -Path $condaExePath) {
    # Remove e adiciona as novas configurações
    & "$condaExePath" config --file "$condaConfigPath" --remove-key proxy_servers
    & "$condaExePath" config --file "$condaConfigPath" --set proxy_servers.http "$varMyProxy"
    & "$condaExePath" config --file "$condaConfigPath" --set proxy_servers.https "$varMyProxy"

    # Validação e Mensagem para o Conda
    $condaProxy = & "$condaExePath" config --show-sources --get proxy_servers.http | Select-String -Pattern "$varMyProxy"
    if ($condaProxy) {
        Write-Host "✅ Conda: Proxy configurado com sucesso para $varMyProxy" -ForegroundColor Green
    } else {
        Write-Host "❌ Conda: Falha ao configurar o proxy." -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Conda: Executável não encontrado. Nenhuma alteração feita." -ForegroundColor Yellow
}

## Aplicar Proxy no VS Code

# Caminho para o arquivo settings.json do VS Code no Windows
$vsCodeSettingsPath = Join-Path $env:APPDATA "Code\User\settings.json"

# Cria um objeto base com o proxy, que será usado em caso de falha.
$baseSettings = [PSCustomObject] @{
    "http.proxy" = $varMyProxy
}

# Verifica se o arquivo settings.json existe
if (Test-Path -Path $vsCodeSettingsPath) {
    $settingsObject = $null
    $fileContent = Get-Content -Raw -Path $vsCodeSettingsPath

    # Tenta converter o conteúdo do arquivo para um objeto JSON
    try {
        if (-not [string]::IsNullOrEmpty($fileContent)) {
            $settingsObject = $fileContent | ConvertFrom-Json -ErrorAction Stop
        }
    }
    catch {
        # Em caso de falha, $settingsObject continuará nulo.
        Write-Host "⚠️ VS Code: O settings.json está corrompido ou vazio. Criando um novo arquivo." -ForegroundColor Yellow
    }

    # Se a conversão falhou ou o resultado não é um objeto válido, usa o objeto base.
    if ($null -eq $settingsObject -or -not ($settingsObject -is [PSCustomObject])) {
        $settingsObject = $baseSettings
    } else {
        # Se a conversão funcionou, apenas atualiza a propriedade.
        $settingsObject.'http.proxy' = $varMyProxy
    }

    # Converte o objeto final para JSON
    $updatedSettingsJson = $settingsObject | ConvertTo-Json -Depth 10 -Compress

    # Salva as mudanças de volta no arquivo settings.json
    Set-Content -Path $vsCodeSettingsPath -Value $updatedSettingsJson

    # Validação e Mensagem para o VS Code
    $finalContent = Get-Content -Raw -Path $vsCodeSettingsPath
    $finalObject = $finalContent | ConvertFrom-Json
    
    if ($finalObject.'http.proxy' -eq $varMyProxy) {
        Write-Host "✅ VS Code: Proxy configurado com sucesso para $varMyProxy" -ForegroundColor Green
    } else {
        Write-Host "❌ VS Code: Falha ao configurar o proxy." -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ VS Code: Arquivo settings.json não encontrado. Nenhuma alteração feita." -ForegroundColor Yellow
}