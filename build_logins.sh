#  ./build_logins.sh 50
#
# * This creates 50 users named datafriend1, datafriend2, ...
# * The passwords are the same as the user names.


# Make new ones. (Specify the count on the comand line!)
for id in $(seq 1 $1); do
	adduser --disabled-password --gecos "" datafriend$id 
	echo "datafriend$id:datafriend$id"|chpasswd
	

done