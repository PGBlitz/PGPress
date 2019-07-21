#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################

# FUNCTIONS BELOW ##############################################################
mainbanner() {

  touch /var/plexguide/auth.bypass

  a7=$(cat /var/plexguide/auth.bypass)
  if [[ "$a7" != "good" ]]; then domaincheck7; fi
  echo good >/var/plexguide/auth.bypass

  if [[ "$a7" != "good" ]]; then domaincheck7; fi
  echo good >/var/plexguide/auth.bypass

  tld=$(cat /var/plexguide/tld.program)
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press                            📓 Reference: pgpress.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💬 PG Press is a Mass WordPress Management System managed by PGBlitz!

[1] WordPress: Deploy a New Site
[2] WordPress: View Deployed Sites
[3] WordPress: Backup & Restore
[4] WordPress: Set a Top Level Domain - [$tld]
[5] WordPress: Destroy a Website

[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

  read -p 'Type a Selection | Press [ENTER] ' typed </dev/tty

  case $typed in
  1)
    deploywp
    mainbanner
    ;;
  2)
    viewcontainers
    mainbanner
    ;;
  3)

    # Checks to That RClone Works
    file=$()
    if [ ! -d "/mnt/gdrive/plexguide/backup/wordpress" ]; then

      # Makes a Test Directory for Checks
      rclone mkdir --config /opt/appdata/plexguide/rclone.conf gdrive:/plexguide/backup/wordpress
      rclonecheck=$(rclone lsd --config /opt/appdata/plexguide/rclone.conf gdrive:/plexguide/backup/ | grep wordpress)
      sleep 1

      # Conducts a Check Again; if fails; then exits
      if [ "$rclonecheck" == "" ]; then
        echo
        echo "💬  Unable to find - /mnt/gdrive/plexguide/backup/wordpress"
        echo ""
        echo "1. Did You Deploy PGClone?"
        echo "2. Test by typing ~ ls -la /mnt/gdrive"
        echo ""
        read -p 'Confirm Info | Press [ENTER] ' typed </dev/tty
        mainbanner
      fi
    fi

    bash /opt/pgpress/pgvault/pgvault.sh
    mainbanner
    ;;
  4)
    tldportion
    mainbanner
    ;;
  5)
    destroycontainers
    mainbanner
    ;;
  z)
    exit
    ;;
  Z)
    exit
    ;;
  *)
    mainbanner
    ;;
  esac
}

deploywp() {

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Setting a WordPress ID / SubDomain
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Type the name for the subdomain wordpress instance. Instance can later be
turned to operate at the TLD (Top Level Domain). Keep it all lowercase and
with no breaks in space.

[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
  read -p '↘️  Type Subdomain | Press [ENTER]: ' subdomain </dev/tty

  if [[ "$subdomain" == "exit" || "$subdomain" == "Exit" || "$subdomain" == "EXIT" || "$subdomain" == "z" || "$subdomain" == "Z" ]]; then mainbanner; fi
  if [ "$subdomain" == "" ]; then deploywp; fi

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Deploying WordPress Instance: $subdomain
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

  echo "$subdomain" >/tmp/wp_id

  ansible-playbook /opt/pgpress/db.yml
  ansible-playbook /opt/pgpress/wordpress.yml

  wpdomain=$(cat /var/plexguide/server.domain)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Site Deployed! Visit - $subdomain.$wpdomain
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

  read -p '💬 Done? | Press [ENTER] ' typed </dev/tty

}

viewcontainers() {

  docker ps --format '{{.Names}}' | grep "wp-" >/var/plexguide/tmp.containerlist

  file="/var/plexguide/tmp.format.containerlist"
  if [ ! -e "$file" ]; then rm -rf /var/plexguide/tmp.format.containerlist; fi
  touch /var/plexguide/tmp.format.containerlist
  cat /var/plexguide/tmp.format.containerlist | cut -c 2- >/var/plexguide/tmp.format.containerlist

  num=0
  while read p; do
    p="${p:3}"
    echo -n $p >>/var/plexguide/tmp.format.containerlist
    echo -n " " >>/var/plexguide/tmp.format.containerlist
    num=$((num + 1))
    if [ "$num" == 7 ]; then
      num=0
      echo " " >>/var/plexguide/tmp.format.containerlist
    fi
  done </var/plexguide/tmp.containerlist

  containerlist=$(cat /var/plexguide/tmp.format.containerlist)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press                            📓 Reference: pgpress.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 WP Containers Detected Running

$containerlist

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  read -p '💬 Done Viewing? | Press [ENTER] ' typed </dev/tty
}

destroycontainers() {

  docker ps --format '{{.Names}}' | grep "wp-" >/var/plexguide/tmp.containerlist

  file="/var/plexguide/tmp.format.containerlist"
  if [ ! -e "$file" ]; then rm -rf /var/plexguide/tmp.format.containerlist; fi
  touch /var/plexguide/tmp.format.containerlist
  cat /var/plexguide/tmp.format.containerlist | cut -c 2- >/var/plexguide/tmp.format.containerlist

  num=0
  while read p; do

    p="${p:3}"
    echo -n $p >>/var/plexguide/tmp.format.containerlist
    echo -n " " >>/var/plexguide/tmp.format.containerlist
    num=$((num + 1))
    if [ "$num" == 7 ]; then
      num=0
      echo " " >>/var/plexguide/tmp.format.containerlist
    fi
  done </var/plexguide/tmp.containerlist

  containerlist=$(cat /var/plexguide/tmp.format.containerlist)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press                            📓 Reference: pgpress.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 WP Containers Detected Running

$containerlist

[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

  read -p '💬 Destory Which Container? | Press [ENTER]: ' typed </dev/tty

  if [[ "$typed" == "exit" || "$typed" == "Exit" || "$typed" == "EXIT" || "$typed" == "z" || "$typed" == "Z" ]]; then mainbanner; fi
  if [[ "$typed" == "" ]]; then destroycontainers; fi

  destroycheck=$(echo $containerlist | grep "$typed")

  if [[ "$destroycheck" == "" ]]; then
    echo
    read -p '💬 WordPress Contanier Does Not Exist! | Press [ENTER] ' typed </dev/tty
    destroycontainers
  fi

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
  read -p "💬 WordPress Instance $typed Removed! | Press [ENTER] " abc </dev/tty
  mainbanner
}

tldportion() {

  docker ps --format '{{.Names}}' | grep "wp-" >/var/plexguide/tmp.containerlist

  file="/var/plexguide/tmp.format.containerlist"
  if [ ! -e "$file" ]; then rm -rf /var/plexguide/tmp.format.containerlist; fi
  touch /var/plexguide/tmp.format.containerlist
  cat /var/plexguide/tmp.format.containerlist | cut -c 2- >/var/plexguide/tmp.format.containerlist

  num=0
  while read p; do
    p="${p:3}"
    echo -n $p >>/var/plexguide/tmp.format.containerlist
    echo -n " " >>/var/plexguide/tmp.format.containerlist
    num=$((num + 1))
    if [ "$num" == 7 ]; then
      num=0
      echo " " >>/var/plexguide/tmp.format.containerlist
    fi
  done </var/plexguide/tmp.containerlist

  containerlist=$(cat /var/plexguide/tmp.format.containerlist)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press - Set Top Level Domain     📓 Reference: pgpress.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 WP Containers Detected Running

$containerlist

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Press - Set Top Level Domain     📓 Reference: pgpress.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 WP Containers Detected Running

$containerlist

[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

  read -p '💪 Type WordPress Site for Top Level Domain | Press [ENTER]: ' typed </dev/tty

  if [[ "$typed" == "exit" || "$typed" == "Exit" || "$typed" == "EXIT" || "$typed" == "z" || "$typed" == "Z" ]]; then mainbanner; fi

  destroycheck=$(echo $containerlist | grep "$typed")

  if [[ "$destroycheck" == "" ]]; then
    echo
    read -p '💬 WordPress Contanier Does Not Exist! | Press [ENTER] ' typed </dev/tty
    tldportion
  fi

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️  PASS: TLD Application Set
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  sleep 1.5

  # Sets Old Top Level Domain
  cat /var/plexguide/tld.program >/var/plexguide/old.program
  echo "$typed" >/var/plexguide/tld.program

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🍖  NOM NOM - Rebuilding Your Old App & New App Containers!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  sleep 1.5

  old=$(cat /var/plexguide/old.program)
  new=$(cat /var/plexguide/tld.program)

  touch /var/plexguide/tld.type
  tldtype=$(cat /var/plexguide/tld.type)

  if [[ "$old" != "$new" && "$old" != "NOT-SET" ]]; then

    if [[ "$tldtype" == "standard" ]]; then
      ansible-playbook /opt/plexguide/containers/$old.yml
    elif [[ "$tldtype" == "wordpress" ]]; then
      echo "$old" >/tmp/wp_id
      ansible-playbook /opt/pgpress/wordpress.yml
      echo "$typed" >/tmp/wp_id
    fi
  fi

  # Repair this to Recall Port for It
  echo "$new" >/tmp/wp_id
  #echo "$port" > /tmp/wp_port

  ansible-playbook /opt/pgpress/wordpress.yml

  # Notifies that TLD is WordPress
  echo "wordpress" >/var/plexguide/tld.type

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️  Top Level Domain Container is Rebuilt!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

  read -p 'Press [ENTER] ' typed </dev/tty

  # Goes Back to Main Banner AutoMatically
}

domaincheck7() {
  domaincheck=$(cat /var/plexguide/server.domain)
  touch /var/plexguide/server.domain
  touch /tmp/portainer.check
  rm -r /tmp/portainer.check
  wget -q "https://portainer.${domaincheck}" -O /tmp/portainer.check
  domaincheck=$(cat /tmp/portainer.check)
  if [ "$domaincheck" == "" ]; then
    echo
    echo "💬  Unable to reach your Subdomain for Portainer!"
    echo ""
    echo "1. Forget to enable Traefik?"
    echo "2. Valdiate if Subdomain is Working?"
    echo "3. Validate Portainer is Deployed?"
    echo "4. Did you forget to put * wildcare in your DNS?"
    echo ""
    read -p 'Confirm Info | Press [ENTER] ' typed </dev/tty
    exit
  fi
}

mainbanner
