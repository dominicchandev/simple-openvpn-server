set-up:
	sudo apt-get update

#Uninstall Docker Engine
	for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Install Docker Engine
	sudo apt-get install ca-certificates curl gnupg
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Docker-Compose
	sudo apt install -y python3-pip3
	pip3 install docker-compose

export PUBIC_IP=$(shell wget -qO- http://ipecho.net/plain | xargs echo)
start:
	docker-compose run --rm openvpn-server ovpn_genconfig -u udp://${PUBIC_IP}
	docker-compose run --rm openvpn-server ovpn_initpki
	docker-compose up -d

export CLIENT_NAME?=
create-client:
	docker-compose run --rm openvpn-server easyrsa build-client-full ${CLIENT_NAME} nopass
	mkdir -p -m 700 client_keys
	docker-compose run --rm openvpn-server ovpn_getclient ${CLIENT_NAME} > client_keys/${CLIENT_NAME}.ovpn
	chmod 600 client_keys/${CLIENT_NAME}.ovpn

stop:
	docker-compose down