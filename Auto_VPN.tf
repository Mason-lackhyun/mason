
resource "aws_vpc" "dev" {
  cidr_block                       = "172.32.0.0/16"
  instance_tenancy                 = "default"
  tags = {
    Name    = "DEV-VPC"
   }
}
resource "aws_subnet" "sub-a" {
  vpc_id = "${aws_vpc.dev.id}"
  cidr_block = "172.32.0.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "DEV-PUB-A"
  }
 }
resource "aws_security_group" "ssh" {
  vpc_id = "${aws_vpc.dev.id}"
  tags = {
    Name    = "Ext to GW"
   }
  name = "DEV-SG"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "auto_vpn" {
  ami             = "ami-08c64544f5cfcddd0"
  instance_type   = "t2.micro"
  key_name        = "mason"
  subnet_id       = "${aws_subnet.sub-a.id}"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  associate_public_ip_address = true
    root_block_device {
        volume_size = "20"
        volume_type = "gp3"
    }
    user_data = <<EOF
    #!/bin/bash
    cwd=/home/ec2-user
    cd $cwd

    #OpenVPN 설치
    sudo yum update -y

    wget https://swupdate.openvpn.org/commun ity/releases/openvpn-2.5.4.tar.gz
    tar -xvf openvpn-2.5.4.tar.gz

    cd openvpn-2.5.4

    sudo yum install -y gcc openssl-devel lzo-devel lz4-devel pam-devel systemd-devel

    sudo ./configure --enable-systemd && sudo make && sudo make install

    ver=$(openvpn --version | grep "2.5.4" | awk '{print $2}')
    if [[ $ver != 2.5.4 ]]; then
	    echo "openvpn is not installed"
	    exit
    fi

    #EasyRSA 설치
    OWD=/etc/openvpn/
    cd $cwd

    sudo amazon-linux-extras install epel -y
    sudo yum install -y easy-rsa

    sudo mkdir -p $OWD/easy-rsa
    sudo mkdir -p $OWD/keys
    sudo mkdir -p $OWD/server

    path=$(ls -al /usr/share/doc | grep easy | awk '{print $9}'| cut -c 10-14)

    if [[ ! -d /usr/share/easy-rsa ]]; then
        echo "easy-rsa is not installed"
        exit
    fi

    sudo cp -Rv /usr/share/easy-rsa/$path/* /etc/openvpn/easy-rsa/
    cd $OWD/easy-rsa
    sudo ./easyrsa init-pki
    sudo ./easyrsa --batch build-ca nopass
    sudo ./easyrsa --batch gen-req server nopass
    sudo ./easyrsa --batch sign-req server server

    sudo cp $OWD/easy-rsa/pki/ca.crt $dd/keys/
    sudo cp $OWD/easy-rsa/pki/issued/server.crt $dd/keys/
    sudo cp $OWD/easy-rsa/pki/private/server.key $dd/keys/

    cd $OWD/keys
    sudo $(which openvpn) --genkey --secret ta.key
    sudo openssl dhparam -out dh2048.pem 2048

    cd $OWD/server

    #서버 컨피그 파일 설정
    cat | sudo tee server.conf << XXX
    port 1194
    proto tcp
    dev tun
    ca /etc/openvpn/keys/ca.crt
    cert /etc/openvpn/keys/server.crt
    key /etc/openvpn/keys/server.key
    dh /etc/openvpn/keys/dh2048.pem
    topology subnet
    server 10.8.0.0 255.255.255.0
    ifconfig-pool-persist /etc/openvpn/server/ipp.txt
    push "route 172.31.0.0 255.255.0.0"
    client-to-client
    keepalive 5 10
    tls-auth /etc/openvpn/keys/ta.key 0
    cipher AES-256-GCM
    comp-lzo
    max-clients 100
    persist-key
    persist-tun
    status /etc/openvpn/openvpn-status.log
    log-append /var/log/openvpn.log
    verb 3
    plugin /usr/local/lib/openvpn/plugins/openvpn-plugin-auth-pam.so /etc/pam.d/login
    verify-client-cert none
    username-as-common-name
    XXX

    sudo chmod 664 server.conf

    cd $cwd

    cat > bridge_on.sh << XXX
    #!/bin/bash
    br=br0
    tap=tap0

    eth=eth0
    eth_ip=$(ifconfig $eth | grep broad | awk '{print $2}')
    eth_netmask=$(ifconfig $eth | grep broad | awk '{print $4}')
    eth_brodcast=$(ifconfig $eth | grep broad | awk '{print $6}')

    sudo /usr/local/sbin/openvpn --mktun --dev $tap

    sudo brctl addbr $br
    sudo brctl addif $br $eth
    sudo brctl addif $br $tap
    sudo ifconfig $tap 0.0.0.0 promisc up
    sudo ifconfig $eth 0.0.0.0 promisc up
    sudo ifconfig $br $eth_ip netmask $eth_netmask broadcast $eth_brodcast
    XXX

    sudo chmod +X bridge_on.sh

    #OpenVPN 실행
    sudo systemctl start openvpn-server@server
    sudo systemctl enable openvpn-server@server

    EOF
    tags = {
        Name = "auto_vpn"
    }
}
