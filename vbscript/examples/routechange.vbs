option explicit

const HOSTS_COLLECTION = "192.168.1.1;www.localdomain.local;192.168.1.10"
const ERROR = 3
const MSG_PRIMARY = "Переход на основной канал связи"
const PRIMARY_GATE = "192.168.1.1"
const MSG_SECONDARY = "Переход на резервный канал связи"
const SECONDARY_GATE = "192.168.1.250"
const SUCCESS = 0

dim gateway

gateway = currentgateway()
if testping(HOSTS_COLLECTION) = ERROR then
   if gateway = PRIMARY_GATE then
      changegateway(SECONDARY_GATE)
      logevent SUCCESS,MSG_SECONDARY
   else
      changegateway(PRIMARY_GATE)
      logevent SUCCESS,MSG_PRIMARY
   end if 
end if

sub changegateway(gateway)

dim wshshell
dim return_code
dim cmd

cmd = "route change 0.0.0.0 mask 0.0.0.0 " & gateway 
set wshshell = createobject("wscript.shell")
return_code=wshshell.run(cmd,2,true)

end sub

function currentgateway()

dim objwmiservice
dim routetable, route
dim gw(100)
dim i

set objwmiservice = getobject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
set routetable = objwmiservice.execquery("Select * from Win32_IP4RouteTable")
i = 0
for each route in routetable
   gw(i) = route.nexthop
   i = i + 1
next
currentgateway = gw(0)
end function

function testping(strhosts)

dim wshshell
dim cmd
dim return_code
dim hosts
dim host
dim i

i = 0
hosts = split(strhosts, ";")
set wshshell = createobject("wscript.shell")
for each host in hosts
   cmd = "ping " & host
   return_code=wshshell.run(cmd,2,true)
   i = i + return_code
next
testping = i
end function