# lvscare release note
```
lvscare care --vs 10.103.97.12:6443 --rs 192.168.0.2:6443 --rs 192.168.0.3:6443 --rs 192.168.0.4:6443 \
--health-path / --health-schem http
```

# Test
Clean your environment:
```
ip link del dev sealyun-ipvs
ipvsadm -C
```

start some nginx as realserver
```
docker run -p 8081:80 --name nginx1 -d nginx
docker run -p 8082:80 --name nginx2 -d nginx
docker run -p 8083:80 --name nginx3 -d nginx
```
```
lvscare care --vs 10.103.97.12:6443 --rs 127.0.0.1:8081 --rs 127.0.0.1:8082 --rs 127.0.0.1:8083 \
--health-path / --health-schem http
```

check ipvs rules:
```
ipvsadm -Ln
[root@iZj6c9fiza9orwscdhate4Z ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.103.97.12:6443 rr
  -> 127.0.0.1:8081               Masq    1      0          0         
  -> 127.0.0.1:8082               Masq    1      0          0         
  -> 127.0.0.1:8083               Masq    1      0          0 
```
As you can see, all the real server added.
You can curl vip:
```
[root@iZj6c9fiza9orwscdhate4Z ~]# curl 10.103.97.12:6443 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
```

delete a nginx
```
[root@iZj6c9fiza9orwscdhate4Z ~]# docker stop nginx1
nginx1
[root@iZj6c9fiza9orwscdhate4Z ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.103.97.12:6443 rr
  -> 127.0.0.1:8082               Masq    1      0          0         
  -> 127.0.0.1:8083               Masq    1      0          1 
```

delete one more:
```
[root@iZj6c9fiza9orwscdhate4Z ~]# docker stop nginx2
nginx2
[root@iZj6c9fiza9orwscdhate4Z ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.103.97.12:6443 rr
  -> 127.0.0.1:8083               Masq    1      0          0 
```

your vip still accessable:
```
[root@iZj6c9fiza9orwscdhate4Z ~]# curl 10.103.97.12:6443 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
```

delete all the real server:
```
[root@iZj6c9fiza9orwscdhate4Z ~]# docker stop nginx3
nginx3
[root@iZj6c9fiza9orwscdhate4Z ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.103.97.12:6443 rr
[root@iZj6c9fiza9orwscdhate4Z ~]# curl 10.103.97.12:6443 
curl: (7) Failed connect to 10.103.97.12:6443; 拒绝连接
```
all ipvs destination removed

Add then back:
```
[root@iZj6c9fiza9orwscdhate4Z ~]# docker start nginx1 nginx2 nginx3
nginx1
nginx2
nginx3
[root@iZj6c9fiza9orwscdhate4Z ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.103.97.12:6443 rr
  -> 127.0.0.1:8081               Masq    1      0          0         
  -> 127.0.0.1:8082               Masq    1      0          0         
  -> 127.0.0.1:8083               Masq    1      0          0 
```
Welcom back!
