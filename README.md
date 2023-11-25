# setup

we are assuming you are running on macOS
a setup script that will install all required tools can be found under [setup](setup) directory 

```shell
cd setup
chmod +x setup.sh
./setup.sh
```


# install

if you need to start from a clean environment:

```shell
just reset-colima-kube-environment
```

To install from scratch on a clean environment

```shell
just install
```