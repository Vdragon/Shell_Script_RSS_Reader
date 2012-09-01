#!/bin/sh

rm -r ~/.feed
mkdir ~/.feed

cp fetchRSS.pl ~/.feed
# cd to the Data directory
cd ~/.feed

# default subscriptionss
echo "http://feeds.feedburner.com/xxddite?format=xml" >> subscription
echo "http://feeds.feedburner.com/vgod/blog?format=xml" >> subscription
echo "http://feeds.feedburner.com/jserv?format=xml" >> subscription

echo "XDDite" >> who
echo "vgod" >> who
echo "jserv" >> who


# using my Perl script to update somethong
./fetchRSS.pl

# welcome msg
dialog --title "Welcome" --msgbox "Hello world!" 5 40



# main manu
menu () {

  dialog --title "Main Menu" --menu "Choose Action" 12 45 5 \
    R "Read - read subscribed feeds" \
    S "Subscrib - new subscription" \
    D "Delete - delete subscription" \
    U "Update - update subscription" \
    Q "Bye~" 2>/tmp/menuitem
  menuitem=`cat /tmp/menuitem`
  rm /tmp/menuitem

  if [ -z $menuitem ] ; then
    exit 1
  fi

  case $menuitem in
    R ) return 1 ;;
    S ) return 2 ;;
    D ) return 3 ;;
    U ) return 4 ;;
    Q ) return 5 ;;
  esac
}



# read articles
Read () {

  # choose whitch subscription to read
  dialog --title "Read" --menu "choose subscription" 12 45 5 `cat who | awk '{print NR" "$1}'` 2>/tmp/menuitem
  menuitem=`cat /tmp/menuitem`
  rm /tmp/menuitem

  if [ -z $menuitem ] ; then
    return 1
  fi

  # the directory of the subscription
  dir=$menuitem

  # dark method, it works but sucks
  # make a little script for the title menu
  echo "dialog --title \"Read\" --menu \"choose feed to read\" 20 65 10 \\" > foo
  cat $menuitem/titles | awk '{print NR" \""$0"\" \\"}' >> foo
  echo "2>/tmp/menuitem" >> foo

  # give it perms to run
  chmod +x foo
  ./foo
  menuitem=`cat /tmp/menuitem`
  rm /tmp/menuitem

  if [ -z $menuitem ] ; then
    return 1
  fi

  # run it twice for DEMO time....  LOL
  # because we need to go back to title menu after read an article XD
  dialog --msgbox "`cat $dir/$menuitem | sed -e 's/<[^>]*>//g'`" 25 110
  ./foo
  rm foo
  menuitem=`cat /tmp/menuitem`
  rm /tmp/menuitem

  dialog --msgbox "`cat $dir/$menuitem | sed -e 's/<[^>]*>//g'`" 25 110
}



# update RSS feeds
Update () {

  # in fact, it just a foolish animation XD
  # while user choose n articles, it will sleep n seconds and show a stupid bar

  dialog --title "Update" --checklist "choose list to update" 20 60 10 `cat who | awk '{print NR" "$1" off"}'` 2>/tmp/select
  n=`cat /tmp/select | wc -w | xargs`

  for i in `cat /tmp/select | xargs -n1 | awk '{print NR}'` 
  do
    p=$(( 100*$i/$n ))
    echo -n "$p" | xargs | dialog --title "updating" --gauge "Please wait" 7 70 
    sleep 1 
  done
  rm /tmp/select
}



# subscrib new feed
Subscrib () {

  #get url and name
  dialog --title "Subscrib" --inputbox "Enter feed url" 8 60 2>/tmp/url
  url=`cat /tmp/url`
  rm /tmp/url
  
  dialog --title "Subscrib" --inputbox "Enter feed name" 8 60 2>/tmp/name
  name=`cat /tmp/name`
  rm /tmp/name


  # avoid null strings
  if [ -z "$url"]  ; then
    dialog --title "Subscrib" --msgbox "url: no input!" 5 40
    return 1;
  elif [ -z "$name"] ; then
    dialog --title "Subscrib" --msgbox "name: no input!" 5 40
    return 1;
  else
    echo $name >> who
    echo $url >> subscription
  fi
  
  # fetch it again, the real 'update' function XD
  ./fetchRSS.pl 
  dialog --title "Subscrib" --msgbox "OK!" 5 40

}


# delete a subscription
Delete () {

  dialog --title "Delete" --menu "choose subscription" 12 45 5 `cat who | awk '{print NR" "$1}'` 2>/tmp/menuitem
  menuitem=`cat /tmp/menuitem`
  rm /tmp/menuitem
  rm -r $menuitem

  cat subscription | awk -v m=$menuitem '{if ( NR == m ) ; else print $0}' > s
  cat who | awk -v m=$menuitem '{if (NR == m) ; else print $0}' > w

  rm subscription
  rm who
  mv s subscription
  mv w who

  # we update out data here
  ./fetchRSS.pl 
  dialog --title "Delete" --msgbox "OK!" 5 40

}


# this is an infinity loop
while [ 1 ] ; do
  menu
  m=$? 
  case $m in
      1 ) Read;;
      2 ) Subscrib;;
      3 ) Delete ;;
      4 ) Update ; Read;;
      5 ) exit 0;;
  esac
done
