We show how to setup Ipython parallel in GWDG Clusters. 
Adapted from [ipyparallel docs](https://ipyparallel.readthedocs.io/en/latest/process.html#using-ipcluster-in-pbs-mode).

# Setup
To setup, specify a profile name at `setup.sh`:
```bash
PROFILENAME=<chosen name>
``` 

Then run the shell script:
```bash
bash setup.sh install
```

# Starting `ipyparallel`
```bash
# start the cluster
ipcluster start --profile=<profilename> -n 10

# Start parallel computation with IPyparallel
$ ipython
In [1]: import ipyparallel as ipp
In [2]: c = ipp.Client(profile=<profilename>)
In [3]: c.ids
```

# Uninstalling a profile
```bash
bash setup.sh uninstall
```
