#!/bin/bash
# Edition : Stable Edition V3.0
# Auther  : Geo Project
# (C) Copyright 2023
# =========================================
# // Export Color & Information
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'
grenbo="\e[92;1m"
NC='\033[0m'

# // Export Banner Status Information
export EROR="[${RED} EROR ${NC}]"
export INFO="[${YELLOW} INFO ${NC}]"
export OKEY="[${GREEN} OKEY ${NC}]"
export PENDING="[${YELLOW} PENDING ${NC}]"
export SEND="[${YELLOW} SEND ${NC}]"
export RECEIVE="[${YELLOW} RECEIVE ${NC}]"
clear
date
echo ""
MYIP=$(wget -qO- ipinfo.io/ip);
clear
domain=$(cat /root/domain)
echo -e "[ ${GREEN}INFO${NC} ] Checking... "
echo ""
echo -e "[ ${GREEN}INFO${NC} ] install iptables iptables-persistent... "
apt install iptables iptables-persistent -y >/dev/null 2>&1
echo -e "[ ${GREEN}INFO${NC} ] install install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release... "
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y  >/dev/null 2>&1
sleep 1
echo -e "[ ${GREEN}INFO$NC ] Setting ntpdate"
echo ""
echo -e "[ ${GREEN}INFO${NC} ] install socat cron bash-completion ntpdate... "
apt install socat cron bash-completion ntpdate -y >/dev/null 2>&1
ntpdate pool.ntp.org
sleep 1
echo -e "[ ${GREEN}INFO$NC ] Enable chronyd"
echo ""
echo -e "[ ${GREEN}INFO$NC ] install chrony"
apt -y install chrony >/dev/null 2>&1
timedatectl set-ntp true
sleep 1
echo -e "[ ${GREEN}INFO$NC ] Enable chrony"
systemctl enable chronyd && systemctl restart chronyd
systemctl enable chrony && systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
sleep 1
echo -e "[ ${GREEN}INFO$NC ] Setting chrony tracking"
chronyc sourcestats -v
chronyc tracking -v
date
sleep 1
# / / Ambil Xray Core Version Terbaru
latest_version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"

# / / Installation Xray Core
xraycore_link="https://github.com/XTLS/Xray-core/releases/download/v$latest_version/xray-linux-64.zip"

# / / Make Main Directory
mkdir -p /usr/bin/xray
mkdir -p /etc/xray

# / / Unzip Xray Linux 64
cd `mktemp -d`
curl -sL "$xraycore_link" -o xray.zip
unzip -q xray.zip && rm -rf xray.zip
mv xray /usr/local/bin/xray
chmod +x /usr/local/bin/xray

# Make Folder XRay
mkdir -p /var/log/xray/

echo -e "[ ${red}WARNING${NC} ] Detected port 80" 
systemctl stop ws-epro >/dev/null 2>&1
sleep 2
echo -e "[ ${GREEN}INFO${NC} ] Processing to stop xray " 
sleep 1
echo -e "[ ${GREEN}INFO${NC} ] Starting renew cert... " 
sleep 2
echo -e "[ ${GREEN}INFO$NC ] Getting acme for cert"
wget https://juniartieka.github.io/project/mantap/acme.sh >/dev/null 2>&1
bash acme.sh --install >/dev/null 2>&1
bash acme.sh --register-account -m admin@geolstore.net
wget https://get.acme.sh >/dev/null 2>&1 | sh -s email=admin@geolstore.net
/root/.acme.sh/acme.sh --upgrade --auto-upgrade >/dev/null 2>&1
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt >/dev/null 2>&1
/root/.acme.sh/acme.sh --issue -d $domain --standalone --force --keylength ec-256
/root/.acme.sh/acme.sh --installcert -d $domain --ecc --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key
echo -e "[ ${GREEN}INFO${NC} ] Renew cert done... "
sleep 5
rm acme.sh >/dev/null 2>&1
#echo -e "[ ${GREEN}INFO${NC} ] Renew cert done... "

service squid start
clear
uuid=$(cat /proc/sys/kernel/random/uuid)
sleep 1
echo -e "[ ${GREEN}INFO$NC ] Setting config xray/vmess"
# // Certificate File
path_crt="/etc/xray/xray.crt"
path_key="/etc/xray/xray.key"
path_log="/var/log/xray/v2ray-login.log"
path_error="/var/log/xray/v2ray-error.log"
path_loglevel="info"
ppath_log="/var/log/xray/vless-login.log"
ppath_error="/var/log/xray/vless-error.log"
ppath_loglevel="info"
pppath_log="/var/log/xray/trojan-login.log",
pppath_error="/var/log/xray/trojan-error.log"
pppath_loglevel="info"
clear
# Buat Config Xray TLS
cat > /etc/xray/v2ray-tls.json << END
{
  "log": {
    "access": "${path_log}",
    "error": "${path_error}",
    "loglevel": "${path_loglevel}"
  },
  "inbounds": [
    {
      "port": 8443,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
#xray-v2ray-tls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}"
            }
          ]
        },
        "wsSettings": {
          "path": "/worryfree",
          "headers": {
            "Host": ""
          }
         },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "domain": "$domain"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END
cat > /etc/xray/v2ray-nontls.json << END
{
  "log": {
    "access": "${path_log}",
    "error": "${path_error}",
    "loglevel": "${path_loglevel}"
  },
  "inbounds": [
    {
      "port": 8880,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
#xray-v2ray-nontls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/worryfree",
          "headers": {
            "Host": ""
          }
         },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "domain": "$domain"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END
cat > /etc/xray/vless-tls.json << END
{
  "log": {
    "access": "${ppath_log}",
    "error": "${ppath_error}",
    "loglevel": "${ppath_loglevel}"
  },
  "inbounds": [
    {
      "port": 2083,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}"
#xray-vless-tls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}"
            }
          ]
        },
        "wsSettings": {
          "path": "/worryfree/",
          "headers": {
            "Host": ""
          }
         },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END
cat > /etc/xray/vless-nontls.json << END
{
  "log": {
    "access": "${ppath_log}",
    "error": "${ppath_error}",
    "loglevel": "${ppath_loglevel}"
  },
  "inbounds": [
    {
      "port": 2095,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}"
#xray-vless-nontls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/worryfree/",
          "headers": {
            "Host": ""
          }
         },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "domain": "$domain"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END
cat > /etc/xray/trojan.json <<END
{
  "log": {
    "access": "${pppath_log}",
    "error": "${pppath_error}",
    "loglevel": "${pppath_loglevel}"
  },
  "inbounds": [
    {
      "port": 2087,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid}"
#xray-trojan
          }
        ],
        "fallbacks": [
          {
            "dest": 80
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}"
            }
          ],
          "alpn": [
            "http/1.1"
          ]
        },
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "domain": "$domain"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
END

# / / Installation V2Ray Service
cat > /etc/systemd/system/xray@.service << END
[Unit]
Description=Xray Service ( %i ) By geovpn
Documentation=https://t.me/geovpn
After=network.target nss-lookup.target

[Service]
Type=simple
StandardError=journal
PIDFile=/etc/xray/xray.pid
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /etc/xray/%i.json
ExecStop=/usr/local/bin/xray
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
END


# // Enable & Start Service
# Accept port Xray
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8880 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8880 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2083 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2083 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2095 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2095 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2087 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2087 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl stop xray@v2ray-tls
systemctl stop xray@v2ray-nontls
systemctl stop xray@vless-tls
systemctl stop xray@vless-nontls
systemctl stop xray@trojan
systemctl start xray@v2ray-tls 
systemctl start xray@v2ray-nontls 
systemctl start xray@vless-tls 
systemctl start xray@vless-nontls 
systemctl start xray@trojan 
systemctl enable xray@v2ray-tls
systemctl enable xray@v2ray-nontls
systemctl enable xray@vless-tls
systemctl enable xray@vless-nontls
systemctl enable xray@trojan
systemctl restart xray@v2ray-tls
systemctl restart xray@v2ray-nontls
systemctl restart xray@vless-tls
systemctl restart xray@vless-nontls
systemctl restart xray@trojan

# Install Trojan Go
latest_version="$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases" | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
trojango_link="https://github.com/p4gefau1t/trojan-go/releases/download/v${latest_version}/trojan-go-linux-amd64.zip"
mkdir -p "/usr/bin/trojan-go"
mkdir -p "/etc/trojan-go"
cd `mktemp -d`
curl -sL "${trojango_link}" -o trojan-go.zip
unzip -q trojan-go.zip && rm -rf trojan-go.zip
mv trojan-go /usr/local/bin/trojan-go
chmod +x /usr/local/bin/trojan-go
mkdir /var/log/trojan-go/
touch /etc/trojan-go/akun.conf
touch /etc/trojan-go/trojan-go.pid
touch /var/log/trojan-go/trojan-go.log

# Buat Config Trojan Go
cat > /etc/trojan-go/config.json << END
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 2053,
  "remote_addr": "127.0.0.1",
  "remote_port": 89,
  "log_level": 1,
  "log_file": "/var/log/trojan-go/trojan-go.log",
  "password": [
      "$uuid"
  ],
  "disable_http_check": true,
  "udp_timeout": 60,
  "ssl": {
    "verify": false,
    "verify_hostname": false,
    "cert": "/etc/xray/xray.crt",
    "key": "/etc/xray/xray.key",
    "key_password": "",
    "cipher": "",
    "curves": "",
    "prefer_server_cipher": false,
    "sni": "$domain",
    "alpn": [
      "http/1.1"
    ],
    "session_ticket": true,
    "reuse_session": true,
    "plain_http_response": "",
    "fallback_addr": "127.0.0.1",
    "fallback_port": 0,
    "fingerprint": "firefox"
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "prefer_ipv4": true
  },
  "mux": {
    "enabled": false,
    "concurrency": 8,
    "idle_timeout": 60
  },
  "websocket": {
    "enabled": true,
    "path": "/trgo",
    "host": "$domain"
  },
    "api": {
    "enabled": false,
    "api_addr": "",
    "api_port": 0,
    "ssl": {
      "enabled": false,
      "key": "",
      "cert": "",
      "verify_client": false,
      "client_cert": []
    }
  }
}
END

# Installing Trojan Go Service
cat > /etc/systemd/system/trojan-go.service << END
[Unit]
Description=Trojan-Go Service By geovpn
Documentation=https://t.me/geovpn
Documentation=https://github.com/geovpn/geovpn
After=network.target nss-lookup.target

[Service]
Type=simple
StandardError=journal
PIDFile=/etc/trojan-go/trojan-go.pid
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
END

# Trojan Go Uuid
cat > /etc/trojan-go/uuid.txt << END
$uuid
END

# restart
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 2053 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 2053 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl stop trojan-go
systemctl start trojan-go
systemctl enable trojan-go
systemctl restart trojan-go

cd
cp /root/domain /etc/xray
