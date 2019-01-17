#!/bin/bash
#
# Title:      PlexGuide (Reference Title File)
# Author(s):  Admin9705
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################

# FUNCTIONS BELOW ##############################################################
mainbanner () {
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press                            📓 Reference: pgpress.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NOTE: Use only for testing. A Final PG update will be set to exempt
WordPress Containers from the other Containers.

[1] WordPress: Deploy a New Site
[2] WordPress: View Deployed Sites
[3] WordPress: Backup & Restore        [NOT READY]
[4] WordPress: Set a Top Level Domain  [NOT READY]
[5] WordPress: Destroy a Website
[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

read -p 'Type a Selection | Press [ENTER] ' typed < /dev/tty

case $typed in
    1 )
        deploywp
        mainbanner ;;
    2 )
        viewcontainers
        mainbanner ;;
    4 )
        tldportion
        mainbanner ;;
    5 )
        destroycontainers
        mainbanner ;;
    z )
        exit ;;
    Z )
        exit ;;
    * )
        mainbanner ;;
esac
}

deploywp () {

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Setting a WordPress ID / SubDomain
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Type the name for the subdomain wordpress instance. Instance can later be
turned to operate at the TLD (Top Level Domain). Keep it all lowercase and
with no breaks in space.

EOF

read -p '↘️  Type Subdomain | Press [ENTER]: ' subdomain < /dev/tty

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Setting a Port
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What port do you want your server to utilize? Type a 5 digit port that is
greater than 10000, but less than 60000. Ensure the port is not blocked
and/or is not in use!

EOF

read -p '↘️  Type a Port Number | Press [ENTER]: ' port < /dev/tty

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Deploying WordPress Instance: $subdomain
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

echo "$subdomain" > /tmp/wp_id
echo "$port" > /tmp/wp_port

ansible-playbook /opt/pgpress/db.yml
ansible-playbook /opt/pgpress/wordpress.yml

}

viewcontainers () {

docker ps --format '{{.Names}}' | grep "wp-" > /var/plexguide/tmp.containerlist

file="/var/plexguide/tmp.format.containerlist"
if [ ! -e "$file" ]; then rm -rf /var/plexguide/tmp.format.containerlist; fi
touch /var/plexguide/tmp.format.containerlist
cat /var/plexguide/tmp.format.containerlist | cut -c 2- > /var/plexguide/tmp.format.containerlist

num=0
while read p; do
  p="${p:3}"
  echo -n $p >> /var/plexguide/tmp.format.containerlist
  echo -n " " >> /var/plexguide/tmp.format.containerlist
  num=$[num+1]
  if [ "$num" == 7 ]; then
    num=0
    echo " " >> /var/plexguide/tmp.format.containerlist
  fi
done </var/plexguide/tmp.containerlist

containerlist=$(cat /var/plexguide/tmp.format.containerlist)

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press                            📓 Reference: pgpress.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 WP Containers Detected Running

$containerlist

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

read -p '💬 Done Viewing? | Press [ENTER] ' typed < /dev/tty
}

destroycontainers () {

docker ps --format '{{.Names}}' | grep "wp-" > /var/plexguide/tmp.containerlist

file="/var/plexguide/tmp.format.containerlist"
if [ ! -e "$file" ]; then rm -rf /var/plexguide/tmp.format.containerlist; fi
touch /var/plexguide/tmp.format.containerlist
cat /var/plexguide/tmp.format.containerlist | cut -c 2- > /var/plexguide/tmp.format.containerlist

num=0
while read p; do

  p="${p:3}"
  echo -n $p >> /var/plexguide/tmp.format.containerlist
  echo -n " " >> /var/plexguide/tmp.format.containerlist
  num=$[num+1]
  if [ "$num" == 7 ]; then
    num=0
    echo " " >> /var/plexguide/tmp.format.containerlist
  fi
done </var/plexguide/tmp.containerlist

containerlist=$(cat /var/plexguide/tmp.format.containerlist)

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press                            📓 Reference: pgpress.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 WP Containers Detected Running

$containerlist

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💬 Quitting? TYPE > exit
EOF

read -p '💬 Destory Which Container? | Press [ENTER]: ' typed < /dev/tty

if [[ "$typed" == "exit" ]]; then mainbanner; fi

destroycheck=$(echo $containerlist | grep "$typed")

if [[ "$destroycheck" == "" ]]; then
echo
read -p '💬 WordPress Contanier Does Not Exist! | Press [ENTER] ' typed < /dev/tty
destroycontainers; fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press - Destroying the WordPress Instance - $typed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

docker stop "wp-${typed}/mysql"
docker stop "wp-${typed}"
docker rm "wp-${typed}/mysql"
docker rm "wp-${typed}"
rm -rf "/opt/appdata/wordpress/${typed}"

echo
read -p "💬 WordPress Instance $typed Removed! | Press [ENTER] " abc < /dev/tty
mainbanner
}

tldportion () {

docker ps --format '{{.Names}}' | grep "wp-" > /var/plexguide/tmp.containerlist

file="/var/plexguide/tmp.format.containerlist"
if [ ! -e "$file" ]; then rm -rf /var/plexguide/tmp.format.containerlist; fi
touch /var/plexguide/tmp.format.containerlist
cat /var/plexguide/tmp.format.containerlist | cut -c 2- > /var/plexguide/tmp.format.containerlist

num=0
while read p; do
  p="${p:3}"
  echo -n $p >> /var/plexguide/tmp.format.containerlist
  echo -n " " >> /var/plexguide/tmp.format.containerlist
  num=$[num+1]
  if [ "$num" == 7 ]; then
    num=0
    echo " " >> /var/plexguide/tmp.format.containerlist
  fi
done </var/plexguide/tmp.containerlist

containerlist=$(cat /var/plexguide/tmp.format.containerlist)

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press - Set Top Level Domain     📓 Reference: pgpress.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 WP Containers Detected Running

$containerlist

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

read -p '💬 Done Viewing? | Press [ENTER] ' typed < /dev/tty

if [ "$typed" == "exit" ]; then exit; fi

tcheck=$(echo $running | grep "\<$typed\>")
if [ "$tcheck" == "" ]; then
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔️ WARNING! - Type an Application Name! Case Senstive! Restarting!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
bash /opt/plexguide/menu/traefik/tld.sh
exit
fi

if [ "$typed" == "" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔️ WARNING! - The TLD Application Name Cannot Be Blank!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
bash /opt/plexguide/menu/traefik/tld.sh
exit
else
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️  PASS: TLD Application Set
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

# Prevents From Repeating
cat /var/plexguide/tld.program > /var/plexguide/old.program
echo "$typed" > /var/plexguide/tld.program

sleep 3
fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🍖  NOM NOM - Rebuilding Your Old App & New App Containers!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

sleep 2
old=$(cat /var/plexguide/old.program)
new=$(cat /var/plexguide/tld.program)

if [[ "$old" != "$new" && "$old" != "NOT-SET" ]]; then ansible-playbook /opt/plexguide/containers/$old.yml; fi

ansible-playbook /opt/plexguide/containers/$new.yml
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️ TLD Containers are Rebuilt!  Process Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2

# Goes Back to Main Banner AutoMatically
}

mainbanner
