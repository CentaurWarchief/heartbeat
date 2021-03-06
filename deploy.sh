#!/usr/bin/env bash
if [ "$1" == "pi" ]; then
  make beat-arm
  tar -czvf beat.tar.gz beat/beat.sh dist/beat_arm
  scp beat.tar.gz pi@$2:/home/pi
  rm -rf beat.tar.gz
  ssh pi@$2 <<'C'
rm -rf ./beat
tar -zxvf beat.tar.gz
rm -f beat.tar.gz
mv dist/beat_arm beat_arm && sudo mv beat/beat.sh /etc/init.d/beat
rm -rf dist/ beat/
mv beat_arm beat
sudo chmod 755 /etc/init.d/beat
sudo update-rc.d beat defaults
C
  rm -rf dist/beat_arm
  exit
fi

make build
tar -czvf heartbeat.tar.gz dist/heartbeat
rsync -azv heartbeat.tar.gz root@centaurwarchief.com:/home/ubuntu/heartbeat.centaurwarchief.com
rm -rf dist/heartbeat
rm -rf heartbeat.tar.gz
ssh root@centaurwarchief.com <<'C'
  cd /home/ubuntu/heartbeat.centaurwarchief.com
  tar -zxvf heartbeat.tar.gz
  mv dist/heartbeat heartbeat
  rm -rf dist
  rm -f heartbeat.tar.gz
  docker stop heartbeat.centaurwarchief.com |xargs docker rm >/dev/null 2>&1
  docker run \
    -d \
    --name heartbeat.centaurwarchief.com \
    --net=host \
    -v `pwd`:/heartbeat \
    -w /heartbeat \
    busybox:latest ./heartbeat
C
