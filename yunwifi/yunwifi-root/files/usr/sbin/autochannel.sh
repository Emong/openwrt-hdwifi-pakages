find_good_channel() {
x=$(dd bs=1 count=6 if=/dev/random 2>/dev/null);
seed=$(echo $x|md5sum |cut -b 1-4 |awk '{print "0x"$1}' |awk '{printf("%d\n",$1)}')
awk 'BEGIN{
myseed="'$seed'";
for(i=1;i<=11;i++)
    {
        channel[i]=-200;
    }
    srand(myseed);
}
{
     if(channel[$1]<$2)
     {
         channel[$1]=$2;
     }
}
END{
    good=int(rand()*100%11 +1);
    j=1;
    for(j=0;j<100;j++)
    {
         i=int(rand()*100%11 +1);
         if(channel[i]==-200)
         {
             good=i;
             break;
         }
         if(channel[i]<-90)
         {
             good=i;
             break;
         }
    }
    print good
                     
}
'
}

PHY=$1
[ "$PHY" = "" ] && exit 1
iw phy $PHY interface add wlan100 type managed
ifconfig wlan100 up
#iw wlan100 scan | grep 'freq\|signal'  |awk '{if(NR%2==1)printf("%d ",($2-2407)/5);if(NR%2==0)print $2}'  |awk '{print $2 " " $1}' |sort -nr|head -1 |awk '{print $2}'
iw wlan100 scan | grep 'freq\|signal'  |awk '{if(NR%2==1)printf("%d ",($2-2407)/5);if(NR%2==0)print $2}'  | find_good_channel
iw dev wlan100 del

