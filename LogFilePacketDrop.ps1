param(
    [Parameter(Mandatory=$True)]
    [string]$IPAddr,
    [Parameter(Mandatory=$True)]
    [string]$Time
)

Function PingTarget
    {
        Param(
            [parameter(position=0)]
            $Addr
         )
        $countint = CalculateTime
        $job = Test-Connection $Addr -Delay 1 -Count $countint -AsJob
        if ($job.jobStateInfo.State -ne "Running")
            {
                $results = Receive-Job $job
                return $results 
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
        PingTarget $IPAddr
        $successcount = 0
        $errorcount = 0
        while ($i = 0, $i -lt $packets.Count)
            {
                foreach ($packet in $packets)
                    {
                        if ($packet[$i] -like "Reply from*")
                            {
                                $successcount += 1
                            }
                        else
                            {
                                $errorcount += 1
                            }
                        $i += 1    
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

#CheckPacketDrop($results)

PingTarget $IPAddr