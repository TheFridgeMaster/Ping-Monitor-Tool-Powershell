param(
    [Parameter(Mandatory=$True)]
    [string]$IPAddr,
    [Parameter(Mandatory=$True)]
    [string]$Time
)

$results = New-Object -TypeName psobject

Function PingTarget
    {
        Param(
            [parameter(position=0)]
            $Addr
         )
        $countint = CalculateTime
        $global:results += & 'c:\windows\SysWOW64\PING.EXE' $Addr -n $countint
        for ($i=0; $i -lt $countint; $i++)
            {
                CheckPacketDrop $global:results
            }
    }

Function CalculateTime
    {
        $seconds = ""  
        $SplitTime = $Time.Split(":") | % {iex $_}
        If ($SplitTime[0] -gt 0)
            {
                $seconds += 60 * 60 * $SplitTime[0]
            }
        If ($SplitTime[1] -gt 0)
            {
                $seconds += 60 * $SplitTime[1]
            } 
        If ($SplitTime[2] -gt 0)
            {
                $seconds += $SplitTime[2]
            }
        return $seconds  
    }

Function CheckPacketDrop
    {
        Param(
            [parameter(position=0)]
            $packets
         )
        $successcount = 0
        $errorcount = 0
        for ($i = 1; $i -lt $packets.Count; $i++)
            {
                foreach ($packet in $packets)
                    {
                        if ($packet -like "Reply from*")
                            {
                                $successcount += 1
                            }
                        else
                            {
                                $errorcount += 1
                            }    
                    }
            }
        Write-Output $successcount
        Write-Output $errorcount
    }

Function CheckStatus
    {
        $errorpercentage = $errorcount / $successcount * 100
        Write-Host "$targetname`: "
        Write-Host "$successcount successful packets"
        Write-Host "`r`n"
        Write-Host  "$errorcount failed packets"
        Write-Host "`r`n"
        Write-Host "A packet loss of $errorpercentage%"
        Write-Host "`r`n"
        if ($errorpercentage -gt 1)
            {
                Write-Host "`r`n"
                Write-Host "WARNING: Packet loss is over 1%"
                Write-Host "`r`n"
            }
    }

PingTarget $IPAddr