param(
    [Parameter(Mandatory=$True)]
    [string]$IPAddr,
    [Parameter(Mandatory=$True)]
    [string]$Time
)

$results = New-Object -TypeName Win32_PingStatus

Function PingTarget
    {
        Param(
            [parameter(position=0)]
            $Addr
         )
        $job = Test-Connection $Addr -Delay 1 -Count CalculateTime -AsJob
        if ($job.jobStateInfo.State -ne "Running")
            {
                $global:results = Receive-Job $job
            }
    }

Function CalculateTime
    {
        $seconds = ""  
        [int]$SplitTime = $Time.Split(":")
        If ($SplitTime[0] > 1)
            {
                $seconds += 60 * 60 * $SplitTime[0]
            }
        If ($SplitTime[1] > 1)
            {
                $seconds += 60 * $SplitTime[1]
            } 
        If ($SplitTime[2] > 1)
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

while ($true)
    {
        CheckPacketDrop($results)
    }
