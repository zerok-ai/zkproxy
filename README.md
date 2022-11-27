# zkproxy

## Repo
This repo contains EchoRelayApp as a submodule. To clonse this repo, use:
```sh
git clone --recurse-submodules git@github.com:zerok-ai/zkproxy.git
```

## Installation
Run the following scripts to run the initial setup [It requires sudo permission]:
```sh
sudo sh ./zkutils.sh
```

After this, edit the file /etc/sudoers on your system as root. Add the following line to the end of the file:
```sh
ALL ALL=NOPASSWD: /sbin/pfctl -s state
```

## Whats Next?
Once the installation is done. Do the following:
- Use the zkutils.sh to start the application (service 1). It will start on port 9091
- Use the zkreplay.sh to start the zkproxy in egress replay or igress replay mode. Please check below for more details

     

---

# Documentation

## zkutils.sh
It does the following implicitly:
- Creates a user called _zerok  - Used to run the target applictaion
- Creates a user called _zerokc - Used to run the zk-proxy
- Copies the EchoRelayApp to the '_zerok' user's workspace
- Copies the replay files to the '_zerokc' user's workspace
- Sets up the proxy related things in your system

Additional Operations: You can pass the following arguments for additional features:
| Argument | What it does |
| ------ | ------ |
| -a | Starts the EchoRelayApp from the user '_zerok' |
| -va | Opens the EchoRelayApp in VS Code from the user '_zerok' |

## zkreplay.sh
It can do the following:
| Argument | Default | What it does |
| ------ | ------ | ------ |
| -f | 0 | [OPTIONAL] Pass the replay id. Corresponding egress and ingress files will be used for replaying in proxy mode  |
| -i | NA | Starts the zkproxy in isolation/egress mode using the passed/default replay id  |
| -r | NA | Starts the zkproxy in ingress mode using the passed/default replay id  |
| -k | NA | Kills the zkproxy in isolation/egress |
| -h | NA | Prints the help menu |
