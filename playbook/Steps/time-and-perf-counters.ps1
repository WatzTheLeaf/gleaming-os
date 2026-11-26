# config-time
Start-Service -Name 'w32time' -ErrorAction SilentlyContinue
Invoke-Program 'w32tm' '/config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"'
Invoke-Program 'w32tm' '/config /update'
Invoke-Program 'w32tm' '/resync' -IgnoreErrors

# rebuild-perf-counters
Invoke-Program 'lodctr' '/r'
Invoke-Program 'lodctr' '/r'
Invoke-Program 'winmgmt' '/resyncperf'
