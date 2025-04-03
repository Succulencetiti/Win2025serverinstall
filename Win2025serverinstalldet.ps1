# Vérifier les privilèges administratifs
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Ce script doit être exécuté avec des privilèges administratifs." -ForegroundColor Red
    Exit
}

# 1. Renommer la machine
$NewComputerName = "NomServeurAD"
Rename-Computer -NewName $NewComputerName -Force -Restart

# Pause pour permettre le redémarrage
Write-Host "La machine redémarre pour appliquer le nouveau nom. Relancez le script après redémarrage." -ForegroundColor Yellow
Exit

# 2. Vérifier si l'IP est fixe
$IPConfig = Get-NetIPConfiguration
If ($IPConfig.IPv4DefaultGateway -eq $null) {
    Write-Host "La machine n'a pas d'IP fixe. Veuillez configurer une IP fixe avant de poursuivre." -ForegroundColor Red
    Exit
} Else {
    Write-Host "L'IP est déjà fixe." -ForegroundColor Green
}

# 3. Installer le rôle ADDS
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 4. Promouvoir le serveur en contrôleur de domaine
$DomainName = "votre.domaine.local"
$SafeModePassword = ConvertTo-SecureString "MotDePasseSafeMode" -AsPlainText -Force

Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModePassword -Force

# 5. Créer des OUs
$OUList = @(
    "OU=IT,DC=votre,DC=domaine,DC=local",
    "OU=Finance,DC=votre,DC=domaine,DC=local",
    "OU=HR,DC=votre,DC=domaine,DC=local"
)

foreach ($OU in $OUList) {
    New-ADOrganizationalUnit -Name $OU.Split(",")[0].Split("=")[1] -Path $OU.Substring(OU.IndexOf(",") + 1)
}

