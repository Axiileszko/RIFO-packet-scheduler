#include <core.p4>
#include <v1model.p4>

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

// RIFO fejléc
header rifo_t {
    bit<16> rank; // Pozitív egész szám (alacsonyabb -> magasabb prioritás)
    bit<16> etherType; // Következő protokoll típusa
}

struct headers {
    ethernet_t ethernet;
    rifo_t rifo;
}

struct metadata {}

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            0x1234: parse_rifo; // 0x1234 jelzi a RIFO fejlécet
            default: accept;
        }
    }

    state parse_rifo {
        packet.extract(hdr.rifo);
        transition accept;
    }
}

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    
    register<bit<16>>(1) threshold_reg;

    action drop() {
        mark_to_drop(standard_metadata);
    }

    action forward_simple() {
        if (standard_metadata.ingress_port == 1) {
            standard_metadata.egress_spec = 2;
        } else if (standard_metadata.ingress_port == 2) {
            standard_metadata.egress_spec = 1;
        }
    }

    apply {
        bit<16> threshold_val;
        threshold_reg.read(threshold_val, 32w0);

        if (hdr.rifo.isValid()) {
            
            if (hdr.rifo.rank > threshold_val) {
                drop();
            } else {
                forward_simple();
            }
            
        } else {
            forward_simple();
        }
    }
}

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.rifo);
    }
}

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;