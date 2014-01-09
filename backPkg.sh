#!/bin/bash
PKG=$1
PKGFILE="/var/log/packages/"`ls /var/log/packages |grep "^$PKG\-"`
TMP="/tmp/repkg"

if [ `echo $PKGFILE | wc -l` -gt 1 ]
then
  echo "there are many packages for $PKG pattern: $PKGFILE"
fi

if [ ! -f $PKGFILE ]
then
  echo "package ${PKG} not found!"
  exit 1
fi
  
PKGNAME=`basename $PKGFILE`
echo "Process package \"$PKGNAME\"..."

if [ ! -f $TMP ]
then
  mkdir $TMP
fi

PKGTMP="$TMP/$PKGNAME"

if [ -f $PKGTMP ]
then
  rm -rf $PKGTMP
fi

mkdir $PKGTMP
LASTSTR=`cat $PKGFILE | tail -n 1|sed 's|/|\\\/|g'`
LINES=`cat $PKGFILE  |awk "/FILE LIST/,/$LASTSTR/"|grep -v 'FILE LIST:'| grep -v '^./$'`
for LINE in $LINES
do
  if [ -d /$LINE ]
  then
    mkdir "$PKGTMP/$LINE"
    continue
  fi

  if [ -f /$LINE ]
  then
    cp "/$LINE" "$PKGTMP/`dirname $LINE`"
    continue
  fi
  echo "/$LINE not found!"
done

mkdir $PKGTMP/install

if [ -f /var/log/scripts/$PKGNAME ]
then
  cat /var/log/scripts/$PKGNAME >> $PKGTMP/install/doinst.sh
fi  

echo "REPACKED pkg $PKG ">> $PKGTMP/install/slack-desc 
echo "from $PKGNAME " >> $PKGTMP/install/slack-desc 


cd $PKGTMP
makepkg -c n /tmp/${PKGNAME}_re.txz

rm -rf $PKGTMP

if [ `ls $TMP |wc -l` -eq 0 ]
then
  rm -rf $TMP
fi
