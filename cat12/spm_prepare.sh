#!/bin/bash
#
 
date

func=$1
ref=$2
source=$3
other=$4
nargs=$#

echo "${nargs} arguments passed"
echo "reference is ${ref}"
echo "source is ${source}"

if [[ -z "${source// }" ]] ; then
        echo "There are no source images" 
        source=''
else
        echo "source are ${source}"
fi

if [[ -z "${other// }" ]] ; then 
	echo "There are no other images" 
	other=''
else 
	echo "other are ${other}"
fi

#INCLUDE MATLAB CALL

#We may have to include -nojvm or there is a memory error
#-nodesktop -nosplash -nodisplay -nojvm together work
#Some Matlab functions like gzip require java so cannot
#use -nojvm option
/usr/local/Cluster-Apps/matlab/R2020b/bin/matlab <<EOF
addpath('/rds/project/rds-k1PgZFWfeZY/applications/spm/spm12_7771')
addpath('/rds/project/rds-k1PgZFWfeZY/applications/spm/spm12_7771/toolbox/cat12')
[pa,af,~]=fileparts('${func}');
addpath(pa);
disp(['Path is ' pa])
disp(['Function is ' af])
disp([af,'(''','${ref}',''',''','${source}',''')'])
%af('${ref}','${source}','${other}')
%coregister('${ref}','${source}','${other}')
%THIS WORKS
%dofunc=sprintf('%s(''%s'')',af,'${source}')
%dofunc=sprintf('%s(''%s'')',af,'${ref}')
switch '${nargs}'
	case '1'
		dofunc=sprintf('%s',af)
	case '2'	
		dofunc=sprintf('%s(''%s'')',af,'${ref}')
	case '3' 
		dofunc=sprintf('%s(''%s'',''%s'')',af,'${ref}','${source}')
	case '4' 
		dofunc=sprintf('%s(''%s'',''%s'',''%s'')',af,'${ref}','${source}','${other}')
	otherwise
		disp(['More than 3 arguments passed to function. Try editing the script'])
end

eval(dofunc)
%cat_segment('${ref}')
;exit
EOF
