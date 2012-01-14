#!/bin/sh

fastboot erase boot
fastboot flash boot c8500_boot.img
fastboot reboot


