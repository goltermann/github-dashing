# prereqs:
#   create GCE VM, using Debian Jessie
#   create static IP if wanted
#   open up port tcp:3030 in GCE firewall
# pull down github repo
#   sudo apt-get -y install git
#   git clone https://github.com/goltermann/github-dashing.git
#   cd github-dashing
# update .env file with GitHub user and OAUTH read repo token
# run this script
#   ./gce_setup.sh
# access at <static_ip>:3030
sudo apt-get -y install rubygems
sudo apt-get -y install ruby-dev
sudo apt-get -y install build-essential
sudo apt-get -y install nodejs
sudo gem install dashing
sudo gem install bundler
bundle install
sudo dashing start
