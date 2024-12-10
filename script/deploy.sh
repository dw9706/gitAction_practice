ports=("8080" "8081")
ip="127.0.0.1"
GREEN_PORT="none"

for port in "${ports[@]}";
do
  echo "http://$ip:$port/management/health_check"
  RESPONSE=$(curl -s http://$ip:$port/management/health_check)
  IS_ACTIVE=$(echo ${RESPONSE} | grep 'UP' | wc -l)

  if [[ $IS_ACTIVE -eq 1 && "$port" == "8080" ]];
  then
    BLUE_PORT="8080"
    GREEN_PORT="8081"
  elif [[ $IS_ACTIVE -eq 1 && "$port" == "8081" ]];
  then
    BLUE_PORT="8081"
    GREEN_PORT="8080"
  fi
done

if [[ $GREEN_PORT == "none" ]]
then
  echo "블루와 그린을 임의로 지정합니다.\n"
  BLUE_PORT="8080"
  GREEN_PORT="8081"
fi

RESPONSE=$(curl -s http://$ip:$GREEN_PORT/management/health_check)
IS_ACTIVE=$(echo ${RESPONSE} | grep 'UP' | wc -l)

if [ $IS_ACTIVE -eq 1 ]
then
  echo -e "그린의 모든 서버는 닫혀있어야 합니다. (포트번호 : $GREEN_PORT)"
  exit 0
fi
echo -e "그린($GREEN_PORT)과 블루($BLUE_PORT) 서버 헬스 체크 완료!"

nohup java -jar -Dserver.port=${GREEN_PORT} ~/target/gitAction_practice-0.0.1-SNAPSHOT.jar > log 2>&1 &

for retry in {1..10}
do
  RESPONSE=$(curl -s http://$ip:$GREEN_PORT/management/health_check)
  GREEN_HEALTH=$(echo ${RESPONSE} | grep 'UP' | wc -l)
  if [ $GREEN_HEALTH -eq 1 ]
  then
    break
  else
    echo -e "$ip:$GREEN_PORT가 켜져있지 않습니다. 10초 슬립하고 다시 헬스체크를 수행합니다."
    sleep 10
  fi
done

if [ $GREEN_HEALTH -eq 0 ]
then
  echo -e "$ip:$GREEN_PORT가 작동하지 않습니다."
  exit 0
else
  echo -e "$ip:$GREEN_PORT가 정상적으로 실행 중입니다."
fi

echo "set \$port $GREEN_PORT;" | sudo tee /etc/nginx/conf.d/port.inc
sudo nginx -s reload
fuser -s -k -TERM $BLUE_PORT/tcp
echo -e "$BLUE_PORT가 정상적으로 중지했습니다."