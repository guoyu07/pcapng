#!/bin/bash

##################################
#
# I'm a little bored
#
##################################

# section header block
echo -n "0a 0d 0d 0a" | xxd -p -r
echo -n "1c 00 00 00" | xxd -p -r
echo -n "4d 3c 2b 1a" | xxd -p -r
echo -n "01 00 00 00" | xxd -p -r
echo -n "ff ff ff ff" | xxd -p -r
echo -n "00 00 00 00" | xxd -p -r
echo -n "1c 00 00 00" | xxd -p -r


# interface description block
echo -n "01 00 00 00" | xxd -p -r
echo -n "14 00 00 00" | xxd -p -r
echo -n "01 00 00 00" | xxd -p -r
# tcpdump: snaplen of 0 rejects all packets
echo -n "ff ff ff ff" | xxd -p -r
echo -n "14 00 00 00" | xxd -p -r

# pkt len in hex
# following data, 4 Bytes per line
# e.g.
# 0x8
# 01 02 03 04
# 0a 0b 0c 0d

while read ln; do
	# simple packet block
	echo -n "03 00 00 00" | xxd -p -r

	((pktlen=ln+0))
	((totlen=pktlen+16))
	((totlen=(totlen+3)&(~3)))

	# block len
	printf "%08x" $totlen | xxd -p -r | xxd -c1 -p  | tac | tr -d '\n' | xxd -p -r

	# orig packet len
	printf "%08x" $pktlen | xxd -p -r | xxd -c1 -p  | tac | tr -d '\n' | xxd -p -r

	# packet data
	((count=0))
	while test $count -lt $pktlen; do 
		read ln
		echo -n "$ln" | xxd -p -r
		# if bytes of the last line < 4, count will be larger than pktlen
		((count+=4))
	done
	# in case count > pktlen
	((count=pktlen))

	# padding with 00 if needed
	((pktlen=totlen-16))
	while test $count -lt $pktlen; do
		echo -n "00" | xxd -p -r
		((count++))
	done

	# block len, again
	printf "%08x" $totlen | xxd -p -r | xxd -c1 -p  | tac | tr -d '\n' | xxd -p -r
done
