#!/bin/bash

#MODO DEPURACAO
DBG_MODE=0

#ARQUIVO
FILENAME=$1	
#CONTADOR DE LINHAS
ini_line=1 
end_line=1

#COLETANDO NUMERRO DE LUGARES(p) e TRANSICOES(t)
p=$(awk -v iL=$ini_line -v eL=$end_line -F" " 'NR>=iL&&NR<=eL {print $1}' $FILENAME)
t=$(awk -v iL=$ini_line -v eL=$end_line -F" " 'NR>=iL&&NR<=eL {print $2}' $FILENAME)

#AVANCANDO CONTADORES(saltos do tamanho de $p) 
ini_line=$(($ini_line+1))
end_line=$(($end_line+$p))

#COLETANDO MARCACOES DE ENTRADAS
I=()  
I=($(awk -v iL=$ini_line -v eL=$end_line -F" " 'NR>=iL&&NR<=eL {print}' $FILENAME | sed 's/ //g'))

#AVANCANDO CONTADORES
ini_line=$(($end_line+1))
end_line=$(($end_line+$p))

#COLETANDO MARCADORES DE SAÍDA
O=() #OUTPUT	
O=($(awk -v iL=$ini_line -v eL=$end_line -F" " 'NR>=iL&&NR<=eL {print}' $FILENAME | sed 's/ //g'))

#TRANSFORMANDO COLUNAS DE MARCADORES DE ENTRADA/SAÍDA EM PALAVRAS
IT=()
OT=()
for i in $(seq 0 $(($t-1)))	#number of transitions
do
	for j in $(seq 0 $(($p-1))) #number of places
	do
		IT[$i]+=${I[$j]:$i:1}
		OT[$i]+=${O[$j]:$i:1}
	done
done

#AVANCANDO CONTADORES
ini_line=$(($end_line+1))
MARKS=($(awk -v iL=$ini_line -F" " 'NR>=iL {print}' $FILENAME |sed 's/ //g'))
	
#VERIFICA SE PADRÃO DE MARCAÇÃO EXISTE PARA ATIVAR A TRANSIÇÂO
#0-transição nao ativa
#1-transicao ativa
pattern_match(){
	local A=$1 #pattern
	local B=$2 #string
	for i in $(seq 0 $((${#A}-1)))
	do
		if [ ${A:$i:1} != 0 ]
		then
			if [ $((${B:$i:1}-${A:$i:1})) -lt 0 ]
			then
				return 0
			fi
		fi
	done
	return 1
}

#CALCULA A PROXIMA MARCACAO
#consome tokens (padrão atual - padroa que ativa transicao)
#insere tokens (resultado da subtracao + tokens de saída da transicao)
calculate_mark(){
	local A=$1 #pattern to find
	local B=$2 #string 
	local C=$3 #output tokens
	local TMP=""
	for i in $(seq 0 $((${#A}-1)))
	do
		local token="0"
		if [ ${A:$i:1} != 0 ]
		then
			token=$((${B:$i:1}-${A:$i:1}))
		else
			token=${B:$i:1}
		fi 
		TMP=${TMP}$((${token} + ${C:$i:1}))
	done
	echo $TMP
}

#VERIFICA SE MARCACAO JÁ FOI VISITADA
visitedMarkup(){
	local A=$1
	local count=0;
	for i in $@
	do
		if [ $count -gt 0 ] && [ $i == $A ]
		then
			return 1
		fi
		count=$(($count+1))
	done
	return 0
}


#VERIFICA SE MARCACAO É VALIDA
#marcacao inicial, marcacao final, lista de marcacoes visitadas
#0 - marcacao invalida
#1 - marcacao válida

model_check(){
	local A=$1	#marcacao inicial
	local B=$2	#marcaco final
	local V=()
	local count=0;

	for i in $@	#coleta lista de marcacoes visitadas 
	do
		#se não for primeiro e segundo parametros
		if [ $count -gt 1 ]; then V+=($i); fi 
		count=$(($count+1))
	done

	#marcacao foi contrada?
	if [ $A == $B ];then return 1; fi 

	#verifica se marcacao já foi visitada
	visitedMarkup $A ${V[@]}
	if [ $? -eq 1 ]
	then 
		if [ $DBG -eq 1 ]; then echo "Caminho $A errado, backtracking..."; fi
		 return 0;	
	fi

	#verifica se alguma transição está ativa
	for i in $(seq 0 $((${#IT[@]}-1)))
	do
		local iIT=${IT[$i]}
		local iOT=${OT[$i]}

		pattern_match $iIT $A
		if [ $? -eq 1 ]
		then
			local nextmark=$(calculate_mark ${iIT} $A ${iOT})
			V+=($A)

			if [ $DBG -eq 1 ]
			then
				echo "INI:$A END:$B NEXT:$nextmark - VISITED:${V[@]}"
			fi
			model_check $nextmark $B ${V[@]}
			if [ $? -eq 1 ]
			then
				return 1
			fi
		fi
	done
	return 0
}


count=0;

#DEFINIR MODO DETALHADO
while true; do
	read -p "MODO DETALHADO?(s/n)" yn
	case $yn in
	[Ss]* ) DBG=1; break;;
	[Nn]* ) DBG=0; break;;
	* ) echo "Digite 's' para SIM, ver passo a passo ou 'n' para apenas exibir os resultados"
	esac
done
echo -e "\n\n"

#LOOP PARA VERIFICAR MARCACOES DE ENTRADA
for i in $(seq 0 2 $(( ${#MARKS[@]}-1))) 
do
	INI=${MARKS[$i]}
	FIN=${MARKS[$i+1]}
	if [ $INI -ne -1 ] && [ $FIN -ne -1 ]
	then
		echo "Entradas: $INI e $FIN"
		model_check $INI $FIN
		if [ $? -eq 1 ]
		then 
			echo "Resultado: SIM"
		else
			echo "Resultado: NAO"
		fi
		if [ $DBG -eq 1 ]; then read -p "Pressione para continuar...";	echo ""; fi
	fi
done
