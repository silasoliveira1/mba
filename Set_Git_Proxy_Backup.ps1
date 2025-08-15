# Detecta a rede e configura o proxy automaticamente
$varProxyOffice = '111.11.111.11:80'
$varProxyVPNLib = '11.111.1.111:80'
$varSubnetOffices = '11.111.11','11.111.12'
$varNetworkOffice = '11.111'
$varMyIPSubnet = $null

# Obtém o IP atual
$varIPs = Get-NetIPAddress -AddressFamily IPv4 | Select-Object IPaddress
foreach ($varIP in $varIPs) {
    if ($varIP.IPaddress.Substring(0,6) -eq $varNetworkOffice) {
        $varMyIPSubnet = $varIP.IPaddress.Substring(0,9)
        break
    }
}

# Verifica o range de IP para definir o proxy
$varMyProxy = $varProxyVPNLib
foreach ($varSubnetOffice in $varSubnetOffices) {
    if ($varMyIPSubnet -eq $varSubnetOffice) {
        $varMyProxy = $varProxyOffice            
        break
    }
}

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

# Verifica se o arquivo settings.json existe
if (Test-Path -Path $vsCodeSettingsPath) {
    # Lê o conteúdo do arquivo
    $fileContent = Get-Content -Raw -Path $vsCodeSettingsPath
    
    # Converte o conteúdo para um objeto JSON
    $settingsObject = $fileContent | ConvertFrom-Json
    
    # Adiciona ou atualiza a propriedade 'http.proxy'
    # Esta abordagem é mais robusta, pois sempre cria a propriedade se ela não existir
    $settingsObject.'http.proxy' = $varMyProxy

    # Converte o objeto de volta para JSON e formata
    $updatedSettingsJson = $settingsObject | ConvertTo-Json -Depth 10 -Compress
    
    # Salva as mudanças de volta no arquivo settings.json
    Set-Content -Path $vsCodeSettingsPath -Value $updatedSettingsJson

    # Validação e Mensagem para o VS Code
    # Lê novamente o arquivo para validar o conteúdo salvo
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