function pybossa_url {
	PYBOSSA_PORT=$(kubectl get service pybossa-webservers -o jsonpath='{.spec.ports[0].nodePort}')
	PYBOSSA_IP=$(minikube ip)
	echo "http://$PYBOSSA_IP:$PYBOSSA_PORT"
}

function run_poller {
	PYBOSSA_URL=$(pybossa_url)
	mkdir -p logs
	while true; do
		RESPONSE_CODE=$(curl \
			-i \
			--connect-timeout 0.1 \
			-H "Content-Type:application/json" \
			${PYBOSSA_URL}${2} |
			head -n 1)
		if test -z "$RESPONSE_CODE"; then
			RESPONSE_CODE="UNREACHABLE"
		fi
		echo "$(date +"%T.%N") - $RESPONSE_CODE"
		sleep 0.1
	done 2>/dev/null 1>logs/$1.log &
	echo $!
}

