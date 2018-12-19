dotool-help(){
  echo "
  dotool version 18.12

  dotool is as collection os Bash functions making 
  Digital Ocean's command line doctl tool easier to use.

  Digital Ocean API key goes here:
       ~/snap/doctl/current/.config/doctl/config.yml

  See Digital Ocean's doctl documentation here:

  https://www.digitalocean.com/community/tutorials/
  how-to-use-doctl-the-official-digitalocean-command-line-client
"
}

dotool-info(){
  echo "API key stored in .config/doctl/config.yaml"
  doctl account get
}

dotool-list-keys(){
  doctl compute ssh-key list
}

dotool-list(){
  doctl compute droplet list \
      --format "ID,Name,Memory,Disk,Region,Features,Volumes"
}

dotool-create(){
  doctl compute droplet create $1 \
        --size 512mb  \
        --image ubuntu-16-04-x64 \
        --region sfo2 \
        --ssh-keys $2
}

dotool-delete(){
  doctl compute droplet delete $1
}

dotool-id-to-ip(){
  local id=$1
  doctl compute droplet get $id\
      --no-header \
      --format "Public IPv4"
}

dotool-name-to-ip(){
  local id=$(dotool-list | grep $1 | awk '{print $1}')
  echo $(dotool-id-to-ip $id)
}

dotool-login(){
  ssh $1@$(dotool-name-to-ip $2)
}

dotool-cp(){
  scp $1 root@$(dotool-name-to-ip $2):$3
}

dotool-config(){
  dotool-cp $1 $2 $1 # $1=config-file $2=droplet-name
  ssh root@$(dotool-name-to-ip $2) "\
      source $1 && \
      config-init
"
}

dotool-status(){
  ssh root@$(dotool-name-to-ip $1) '\
  echo ""
  echo "vm stat -s"
  echo "----------"
  vmstat -s
  echo ""
  df
'
}

dotool-upgrade(){
  ssh root@$(dotool-name-to-ip $1) "\
      apt -y update
      apt -y upgrade
"
}
dotool-possibilites(){
  echo ""
  echo "All private and public images available to clone"
  echo "------------------------------------------------"
  doctl compute image list --public --format "ID,Name"
  echo ""
  echo "All available locations"
  echo "-----------------------"
  doctl compute region list
}
