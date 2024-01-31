#!/bin/bash
scp $1 pi@192.168.1.146:to_print.pdf
ssh  pi@192.168.1.146 -e 'lp to_print.pdf'
