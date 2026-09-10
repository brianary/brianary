@{ # usage: Install-PSResource -TrustRepository -RequiredResourceFile ./security.psd1
    CertAdmin = @{ repository = 'PSGallery' }
    ModernConveniences = @{ repository = 'PSGallery' }
    Networkhorse = @{ repository = 'PSGallery' }
    Pretendpoint = @{ repository = 'PSGallery' }
    'Microsoft.PowerShell.SecretManagement' = @{ repository = 'PSGallery' }
    'Microsoft.PowerShell.SecretStore' = @{ repository = 'PSGallery' }
    Secrecy = @{ repository = 'PSGallery' }
}
