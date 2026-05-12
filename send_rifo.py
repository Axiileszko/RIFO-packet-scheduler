#!/usr/bin/env python3
import time
from scapy.all import Ether, IP, ShortField, XShortField, Packet, bind_layers, sendp, get_if_hwaddr

class Rifo(Packet):
    name = "Rifo"
    fields_desc = [ ShortField("rank", 0),
                    XShortField("etherType", 0x0800) ]

bind_layers(Ether, Rifo, type=0x1234) # EtherType 0x1234 -> RIFO
bind_layers(Rifo, IP, etherType=0x0800) # EtherType 0x0800 -> IP

def main():
    iface = "eth0" # Mininet miatt, maybe nem kell
    my_mac = get_if_hwaddr(iface)

    print("Kezdődik a csomagok küldése (Rank: 1-10)...")
    
    for i in range(1, 11):
        print(f"[*] Küldés: Csomag Rank = {i}")
        
        # Csomag összeállítása: Ethernet/RIFO/IP/Payload
        pkt = Ether(src=my_mac, dst='00:00:00:00:00:02', type=0x1234) / Rifo(rank=i) / IP(dst='10.0.0.2') / f"Payload with rank {i}"
        
        sendp(pkt, iface=iface, verbose=False)
        time.sleep(1)

if __name__ == '__main__':
    main()