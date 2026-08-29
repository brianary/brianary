<#
.SYNOPSIS
Writes repository details to the profile readme.
#>

#Requires -Version 7
[CmdletBinding()] Param()
Begin
{
    filter Format-PowerShellRepo
    {
        [CmdletBinding()] Param(
        [Parameter(ValueFromPipelineByPropertyName=$true)][string] $Name,
        [Parameter(ValueFromPipelineByPropertyName=$true)][uri] $Url,   
        [Parameter(ValueFromPipelineByPropertyName=$true)][int] $Starred,
        [Parameter(ValueFromPipelineByPropertyName=$true)][string[]] $Topics
        )
        $shields = 'https://img.shields.io'
        $brianary = 'https://github.com/brianary'
        $package = "https://www.powershellgallery.com/packages/$Name/"
        $continuous = "$brianary/$Name/actions/workflows/continuous.yml"
        $fsharp = " [![F#]($shields/badge/F%23-378BBA?logo=fsharp&logoColor=fff)](${brianary}?tab=repositories&q=fsharp)"
        # see https://github.com/inttter/md-badges#-programming-language
        return @(

            "| [$Name]($Url)" + ($Topics -contains 'fsharp' ? $fsharp : '')
            "$Starred"
            "[![GitHub Issues]($shields/github/issues/brianary/$Name)]($brianary/$Name/issues)"
            "[![PowerShell Gallery Version]($shields/powershellgallery/v/$Name)]($package)"
            "[![PowerShell Gallery]($shields/powershellgallery/dt/$Name)]($package)"
            "[![Actions Status]($continuous/badge.svg)]($continuous) |"
        ) -join ' | '
    }

    function Format-PowerShellTable
    {
        [CmdletBinding()] Param()
        $list = gh repo list brianary --topic powershell-module --json 'name,url,stargazerCount,repositoryTopics' `
            -q '.[]|{"Name":.name,"Url":.url,"Starred":.stargazerCount,"Topics":[.repositoryTopics.[].name]}' |
            ConvertFrom-Json |
            Sort-Object Name
        $Local:OFS = "`r`n"
        return @"

PowerShell modules
------------------

| Repository | :star: | Issues | Version | Downloads | Test  |
|------------|-------:|-------:|---------|-----------|-------|
$($list |Format-PowerShellRepo)

[:package: Resource files](https://learn.microsoft.com/powershell/module/microsoft.powershell.psresourceget/about/about_psresourceget#searching-by-required-resources "a manifest of multiple modules for Install-PSResource"):
&emsp;
[:books: all @brianary](brianary.psd1 "all of my modules") :small_blue_diamond:
[:books: data](data.psd1 "modules for working with data formats") :small_blue_diamond:
[:books: security](security.psd1 "modules for managing certificates, passwords, and other security concerns") :small_blue_diamond:
[:books: server admin](server-admin.psd1 "modules for managing servers")
"@
    }

    filter Format-PerlRepo
    {
        [CmdletBinding()] Param(
        [Parameter(ValueFromPipelineByPropertyName=$true)][string] $Name,
        [Parameter(ValueFromPipelineByPropertyName=$true)][uri] $Url,
        [Parameter(ValueFromPipelineByPropertyName=$true)][int] $Starred,
        [Parameter(ValueFromPipelineByPropertyName=$true)][string[]] $Topics
        )
        $perlName = $Name -replace '-','::'
        # see https://github.com/inttter/md-badges#-programming-language
        return @(

            "| [$perlName]($Url)"
            "$Starred"
            "[![GitHub Issues](https://img.shields.io/github/issues/brianary/$Name)](https://github.com/brianary/$Name/issues)"
            "[![CPAN Version](https://img.shields.io/cpan/v/$Name)](https://metacpan.org/pod/$perlName)"
        ) -join ' | '
    }

    function Format-PerlTable
    {
        [CmdletBinding()] Param()
        $list = gh repo list brianary --topic perl-module --json 'name,url,stargazerCount,repositoryTopics' `
            -q '.[]|{"Name":.name,"Url":.url,"Starred":.stargazerCount,"Topics":[.repositoryTopics.[].name]}' |
            ConvertFrom-Json |
            Sort-Object Name
        $Local:OFS = "`r`n"
        return @"

Perl modules
------------

| Repository | :star: | Issues | Version |
|------------|-------:|-------:|---------|
$($list |Format-PerlRepo)
"@
    }

    function Out-Readme
    {
        [CmdletBinding()] Param()
        $readme = ((Get-Content README.md -Raw) -split '(?m)^---$',2)[0].Trim()
        $readme |Out-File README.md utf8BOM
        '','---' |Out-File README.md -Append
        Format-PowerShellTable |Out-File README.md -Append
        Format-PerlTable |Out-File README.md -Append
    }
}
Process
{
    Out-Readme
}
