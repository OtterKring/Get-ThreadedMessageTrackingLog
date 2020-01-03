function Get-ThreadedMessageTrackingLog {
    param (
        [Parameter(Mandatory)]
        $Credential,                    # the credentials to open a session on exchange
        $DomainController,
        $End,
        $EventId,
        $InternalMessageId,
        $MessageId,
        $MessageSubject,
        $NetworkMessageId,
        $Recipients,
        $Reference,
        $ResultSize,
        $Sender,
        $Server,
        $Source,
        $Start
    )

    # Check Powershell Version (7+ required for foreach -parallel)
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        # check Exchange availabitity base on our required cmdlet
        if (Get-Command Get-TransportService) {

            # query exchange transport servers/-ices and iterate parallelized
            Get-TransportService `
            | ForEach-Object -Parallel {

                # import new exchange session for the thread
                $psex = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$($_.Name)/PowerShell/" -Authentication Kerberos -Credential $using:Credential
                # we only import the Get-MessageTrackingLog cmdlet, nothing else required
                $null = Import-PSSession $psex -DisableNameChecking -CommandName Get-MessageTrackingLog

                # prepare splatting hash with the name of the server to query
                $Trackparams =  @{
                    Server = $_.Name
                }
                # save parameters of parent thread and remove "Credential", because it is not used in Get-MessageTrackingLog
                $parentparams = $using:PSBoundParameters
                $null = $parentparams.Remove('Credential')
                # complete the splatting hash with the rest of the given parameters
                foreach ($param in $parentparams.Keys) {
                        $Trackparams.Add($param,$parentparams.$param)
                }
                # QUERY THE LOG
                Get-MessageTrackingLog @Trackparams

                # remove the exchange session
                Remove-PSSession $psex
            }            
        } else {
            Throw 'Exchange cmdlets not available. Please import a exchange session.'
        }
    } else {
        Throw 'Powershell version 7 required.'
    }

}