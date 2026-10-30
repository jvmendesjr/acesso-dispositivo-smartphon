#!/data/data/com.termux/files/usr/bin/python3
import time, datetime, os
from zeroconf import Zeroconf, ServiceBrowser, ServiceListener
try:
    import ifaddr
except Exception:
    ifaddr = None
HOME = os.path.expanduser("~")
found = []
class L(ServiceListener):
    def add_service(self, zc, type_, name):
        info = zc.get_service_info(type_, name)
        if info and info.port:
            addrs = [a for a in info.parsed_addresses() if ":" not in a]
            found.append((name, info.port, addrs))
    def remove_service(self, zc, type_, name):
        pass
    def update_service(self, zc, type_, name):
        pass
def tailscale_ip():
    if not ifaddr:
        return "none"
    for ad in ifaddr.get_adapters():
        for ip in ad.ips:
            a = ip.ip
            if isinstance(a, str) and a.startswith("100."):
                return a
    return "none"
def main():
    zc = Zeroconf()
    ServiceBrowser(zc, "_adb-tls-connect._tcp.local.", L())
    time.sleep(20)
    zc.close()
    now = datetime.datetime.now().isoformat(timespec="seconds")
    if not found:
        with open(os.path.join(HOME, "adb-discover.log"), "a") as f:
            f.write(now + " NOT-FOUND mdns\n")
        print("NOT-FOUND")
        return 1
    name, port, addrs = found[0]
    wifi_ip = addrs[0] if addrs else "none"
    tip = tailscale_ip()
    endpoint_ip = tip if tip != "none" else wifi_ip
    endpoint = endpoint_ip + ":" + str(port)
    tmp = os.path.join(HOME, "adb-endpoint.txt.tmp")
    with open(tmp, "w") as f:
        f.write(endpoint + "\n")
    os.replace(tmp, os.path.join(HOME, "adb-endpoint.txt"))
    with open(os.path.join(HOME, "adb-status.txt"), "w") as f:
        f.write("updated=" + now + "\nservice=" + name + "\nport=" + str(port) + "\nwifi_ip=" + wifi_ip + "\ntailscale_ip=" + tip + "\nendpoint=" + endpoint + "\nsource=mdns\n")
    with open(os.path.join(HOME, "adb-discover.log"), "a") as f:
        f.write(now + " FOUND " + endpoint + " service=" + name + " wifi=" + wifi_ip + " tailscale=" + tip + "\n")
    print("FOUND " + endpoint)
    return 0
if __name__ == "__main__":
    raise SystemExit(main())
