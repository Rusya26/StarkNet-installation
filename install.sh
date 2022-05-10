#!/bin/bash

# https://github.com/eqlabs/pathfinder

# pwd: .
apt update
apt upgrade
apt install curl git python3 python3-venv python3-dev build-essential libgmp-dev pkg-config libssl-dev

# https://www.rust-lang.org/tools/install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

git clone https://github.com/eqlabs/pathfinder.git

# pwd: pathfinder
cd pathfinder
git checkout v0.1.8-alpha

# pwd: pathfinder/py
cd py/
# Create the virtual environment and activate it
python3 -m venv .venv
source .venv/bin/activate
# Next install the python tooling and dependencies
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt
# This should run the tests (and they should pass).
pytest

# pwd: pathfinder
cd ..

# You should now be able to compile pathfinder by running:
cargo build --release --bin pathfinder

mv ~/pathfinder/target/release/pathfinder /usr/local/bin/

# pwd: .
cd ..

echo "[Unit]
Description=StarkNet
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$PWD/pathfinder/py
ExecStart=/bin/bash -c \"source $PWD/pathfinder/py/.venv/bin/activate && /usr/local/bin/pathfinder --http-rpc=\"0.0.0.0:9545\" --ethereum.url $ALCHEMY\"
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/

systemctl daemon-reload
systemctl enable starknetd
systemctl restart starknetd
