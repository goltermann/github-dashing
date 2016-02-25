# prereqs:
#   create GCE VM, using Debian Jessie
#   create static IP if wanted
#   open up port tcp:3030 in GCE firewall
# pull down github repo
#   sudo apt-get -y install git
#   git clone https://github.com/goltermann/github-dashing.git
#   cd github-dashing
# run this script
#   ./gce.sh
sudo apt-get -y install rubygems
sudo apt-get -y install ruby-dev
sudo apt-get -y install build-essential
sudo gem install dashing
sudo gem install bundler
bundle install
sudo apt-get install nodejs
sudo dashing start
