f() {
	trees=0; x=0; dx=$1; y=0; dy=$2;
	while read l; do ((y++));
		!(($y % $dy)) && ((x+=$dx)) && \
		[[ ${l:$(($x % ${#l})):1} == "#" ]] && \
		((trees++));
	done < <(tail -n+2 input.txt);
	echo $trees;
}

echo $(f 3 1)
echo $(( $(f 1 1) * $(f 3 1) * $(f 5 1) * $(f 7 1) * $(f 1 2) ))
