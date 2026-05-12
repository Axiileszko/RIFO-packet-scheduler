#!/usr/bin/env python3
from scapy.all import Ether, IP, ShortField, XShortField, Packet, bind_layers, sniff

class Rifo(Packet):
    name = "Rifo"
    fields_desc = [ ShortField("rank", 0),
                    XShortField("etherType", 0x0800) ]

bind_layers(Ether, Rifo, type=0x1234)
bind_layers(Rifo, IP, etherType=0x0800)

def handle_packet(packet):
    # Ellenőrizzük, hogy van-e benne RIFO fejléc
    if packet.haslayer(Rifo):
        rank_val = packet[Rifo].rank
        print(f"[+] Csomag megérkezett! RIFO Rank: {rank_val}")
    else:
        print("[!] Egyéb csomag érkezett.")

def main():
    iface = "eth0"
    print(f"[*] Figyelés indítása a(z) {iface} interfészen...")
    
    # Csak azokat a csomagokat figyeljük, amiben van RIFO fejléc (EtherType 0x1234)
    sniff(iface=iface, filter="ether proto 0x1234", prn=handle_packet)

if __name__ == '__main__':
    main()