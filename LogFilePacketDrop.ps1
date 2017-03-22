param(
    [Parameter(Mandatory=$True)]
    [string]$IPAddr
)

$packets

Function CheckPacketDrop
    {
        Param(
            [parameter(position=0)]
            $packets,
            [parameter(position=1)]
            $targetname
         )
        $successcount = 0
        $errorcount = 0
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
        $dlinkswitch = get-content "C:\Users\Kyleb\dlink.log"
        $hpswitch = get-content "C:\Users\Kyleb\hp.log"
        CheckPacketDrop $dlinkswitch "Primary DLink"
        CheckPacketDrop $hpswitch "Primary HP PoE"
    }
