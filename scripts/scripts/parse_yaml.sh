#!/bin/sh
# This is the usual file used, but it doesn't allow groups of settings to be selected: https://gist.githubusercontent.com/pkuczynski/8665367/raw/f81e1c9a2e23b302e9246a0820c0210bfe82ee81/parse_yaml.sh
# So I used: https://github.com/mrbaseman/parse_yaml/blob/master/src/parse_yaml.sh


function parse_yaml {
   local prefix=$2
   local separator=${3:-_}
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=${fs:-$(echo @|tr @ '\034')} i=${i:-  }
   cat $1 | \
   awk -F$fs "{multi=0;
       if(match(\$0,/$s\|$s\$/)){multi=1; sub(/$s\|$s\$/,\"\");}
       if(match(\$0,/$s>$s\$/)){multi=2; sub(/$s>$s\$/,\"\");}
       while(multi>0){
           str=\$0; gsub(/^$s/,\"\", str);
           indent=index(\$0,str);
           indentstr=substr(\$0, 0, indent-1) \"$i\";
           obuf=\$0;
           getline;
           while(index(\$0,indentstr)){
               obuf=obuf substr(\$0, length(indentstr)+1);
               if (multi==1){obuf=obuf \"\\\\n\";}
               if (multi==2){
                   if(match(\$0,/^$s\$/))
                       obuf=obuf \"\\\\n\";
                       else obuf=obuf \" \";
               }
               getline;
           }
           sub(/$s\$/,\"\",obuf);
           print obuf;
           multi=0;
           if(match(\$0,/$s\|$s\$/)){multi=1; sub(/$s\|$s\$/,\"\");}
           if(match(\$0,/$s>$s\$/)){multi=2; sub(/$s>$s\$/,\"\");}
       }
   print}" | \
   sed  -e "s|^\($s\)?|\1-|" \
       -ne "s|^$s#.*||;s|$s#[^\"']*$||;s|^\([^\"'#]*\)#.*|\1|;t1;t;:1;s|^$s\$||;t2;p;:2;d" | \
   sed -ne "s|,$s\]$s\$|]|" \
        -e ":1;s|^\($s\)\($w\)$s:$s\(&$w\)\?$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: \3[\4]\n\1$i- \5|;t1" \
        -e "s|^\($s\)\($w\)$s:$s\(&$w\)\?$s\[$s\(.*\)$s\]|\1\2: \3\n\1$i- \4|;" \
        -e ":2;s|^\($s\)-$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1- [\2]\n\1$i- \3|;t2" \
        -e "s|^\($s\)-$s\[$s\(.*\)$s\]|\1-\n\1$i- \2|;p" | \
   sed -ne "s|,$s}$s\$|}|" \
        -e ":1;s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1$i\3: \4|;t1" \
        -e "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1$i\2|;" \
        -e ":2;s|^\($s\)\($w\)$s:$s\(&$w\)\?$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1\2: \3 {\4}\n\1$i\5: \6|;t2" \
        -e "s|^\($s\)\($w\)$s:$s\(&$w\)\?$s{$s\(.*\)$s}|\1\2: \3\n\1$i\4|;p" | \
   sed  -e "s|^\($s\)\($w\)$s:$s\(&$w\)\(.*\)|\1\2:\4\n\3|" \
        -e "s|^\($s\)-$s\(&$w\)\(.*\)|\1- \3\n\2|" | \
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\(---\)\($s\)||" \
        -e "s|^\($s\)\(\.\.\.\)\($s\)||" \
        -e "s|^\($s\)-$s[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p;t" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p;t" \
        -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\?\(.*\)$s\$|\1$fs\2$fs\3|" \
        -e "s|^\($s\)[\"']\?\([^&][^$fs]\+\)[\"']$s\$|\1$fs$fs$fs\2|" \
        -e "s|^\($s\)[\"']\?\([^&][^$fs]\+\)$s\$|\1$fs$fs$fs\2|" \
        -e "s|$s\$||p" | \
   awk -F$fs "{
      gsub(/\t/,\"        \",\$1);
      if(NF>3){if(value!=\"\"){value = value \" \";}value = value  \$4;}
      else {
        if(match(\$1,/^\&/)){anchor[substr(\$1,2)]=full_vn;getline};
        indent = length(\$1)/length(\"$i\");
        vname[indent] = \$2;
        value= \$3;
        for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
        if(length(\$2)== 0){  vname[indent]= ++idx[indent] };
        vn=\"\"; for (i=0; i<indent; i++) { vn=(vn)(vname[i])(\"$separator\")}
        vn=\"$prefix\" vn;
        full_vn=vn vname[indent];
        if(vn==\"$prefix\")vn=\"$prefix$separator\";
        if(vn==\"_\")vn=\"__\";
      }
      assignment[full_vn]=value;
      if(!match(assignment[vn], full_vn))assignment[vn]=assignment[vn] \" \" full_vn;
      if(match(value,/^\*/)){
         ref=anchor[substr(value,2)];
         for(val in assignment){
            if(index(val, ref)==1){
               tmpval=assignment[val];
               sub(ref,full_vn,val);
               if(match(val,\"$separator\$\")){
                  gsub(ref,full_vn,tmpval);
               } else if (length(tmpval) > 0) {
                  printf(\"%s=\\\"%s\\\"\n\", val, tmpval);
               }
               assignment[val]=tmpval;
            }
         }
      } else if (length(value) > 0) {
         printf(\"%s=\\\"%s\\\"\n\", full_vn, value);
      }
   }END{
      asorti(assignment,sorted);
      for(val in sorted){
         if(match(sorted[val],\"$separator\$\"))
            printf(\"%s=\\\"%s\\\"\n\", sorted[val], assignment[sorted[val]]);
      }
   }"
}
#echo "passing $1"
ocy=$(find "$(dirname "$2")" -name $1)
if [ -z "$ocy"  ]
  then
  echo "Could not find $1. Aborting."
  exit 1
fi
#now find backup if it exists and set update if diff.
ocyb=$(find "$(dirname "$2")" -name "$1.bk")
if [ -z "$ocyb"  ]
  then
  cp $ocy "$ocy.bk"
  update_config="n"
  else
  cmp --silent $ocy $ocyb || update_config="y"
fi
if [ $update_config == "y" ]
then
echo "Config changed, updating"
  cp $ocy "$ocy.bk"
#else
# echo "Config not changed. Not updating."
fi


eval "$(parse_yaml $ocy | sed 's/~/$HOME/g')"


