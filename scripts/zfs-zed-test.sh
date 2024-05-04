#!/bin/bash
TEST_FILENAME="/tmp/zed-test"
ZFS_SERVICE="zfs-zed.service"

echo "Test filename: ${TEST_FILENAME}"

zed_setup() {
    sed -i 's/ZED_NOTIFY_VERBOSE=.*$/ZED_NOTIFY_VERBOSE=1/g' /etc/zfs/zed.d/zed.rc
    systemctl restart "${ZFS_SERVICE}"
}

zed_teardown() {
    sed -i 's/ZED_NOTIFY_VERBOSE=.*$/ZED_NOTIFY_VERBOSE=0/g' /etc/zfs/zed.d/zed.rc
    systemctl restart "${ZFS_SERVICE}"
}

zpool_setup() {
    dd if=/dev/zero of="${TEST_FILENAME}" bs=1 count=0 seek=512M
    zpool create test "${TEST_FILENAME}" 
}

zpool_teardown() {
    zpool export test
    rm -fv "${TEST_FILENAME}"
}

zed_setup
zpool_setup

zpool scrub test

zpool_teardown

# Restarting zed too quickly suppresses the alert
sleep 5
zed_teardown
