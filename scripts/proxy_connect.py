import os, sys, socket, base64, urllib.parse, select
proxy_url=os.environ.get("HTTPS_PROXY","")
u=urllib.parse.urlparse(proxy_url)
auth=base64.b64encode(f"{u.username}:{u.password}".encode()).decode()
host=sys.argv[1]; port=sys.argv[2]
s=socket.create_connection((u.hostname, 3130), timeout=20)
s.sendall(f"CONNECT {host}:{port} HTTP/1.1\r\nHost: {host}:{port}\r\nProxy-Authorization: Basic {auth}\r\n\r\n".encode())
data=b""
while b"\r\n\r\n" not in data:
    chunk=s.recv(4096)
    if not chunk: sys.exit(1)
    data+=chunk
if b"200" not in data.split(b"\r\n")[0]:
    sys.stderr.write(data.decode(errors='ignore')); sys.exit(1)
s.setblocking(False)
while True:
    r,_,_=select.select([s, sys.stdin], [], [], 300)
    if not r:
        continue
    if s in r:
        try: d=s.recv(8192)
        except: break
        if not d: break
        sys.stdout.buffer.write(d); sys.stdout.buffer.flush()
    if sys.stdin in r:
        try: d=sys.stdin.buffer.read1(8192)
        except: break
        if not d: break
        s.sendall(d)
