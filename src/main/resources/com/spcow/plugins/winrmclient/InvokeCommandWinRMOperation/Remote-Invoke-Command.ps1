function Remote-Invoke-Command
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,

        [ValidateNotNull()]
        $UserName,

        [ValidateNotNull()]
        $Password,
        
        [System.Management.Automation.Runspaces.AuthenticationMechanism]$Authentication = 'Default'
    )
	process
	{
        try
        {                
            $SessionParams = @{
                ComputerName   = $ComputerName
                Authentication = $Authentication
            }
            if (-not [string]::IsNullOrEmpty($UserName) -and -not [string]::IsNullOrEmpty($Password))
            {
                $SessionParams['Credential'] = New-Object System.Management.Automation.PSCredential(
                    $UserName, 
                    (ConvertTo-SecureString -AsPlainText -Force -String $Password)
                )
            }
            Write-Host "Connecting to remote host" $ComputerName "...."
            $Session = New-PSSession @SessionParams
            Write-Host "Connected to remote host."
            Write-Host "Executing commands..."
            Invoke-Command -Session $Session -FilePath $Path -Verbose -ErrorAction Stop
            Write-Host "Executing commands finished."
        }
        catch
        {
            Write-Host $_.Exception.Message
            exit 1
        }
        finally 
        {
            if ($null -ne $Session) 
            {
                Remove-PSSession -Session $Session
            }
        }
    }
}