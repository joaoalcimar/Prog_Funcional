let month = {"year": 2017, "month": 3,"day": 1};
let dados = [];
let filterType = "month";

fetch("http://150.165.15.10:8080/todasTransacoes",{method: 'POST'})
.then((response) => response.json())
.then((result) => {
	dados = result.map(translateDate);
	fluxo(dados);
	})
.catch((err) => { console.error(err); });


function translateDate(transactions){
	transactions.data = new Date(transactions.data.year + "-" + (transactions.data.month+1) + "-" + transactions.data.dayOfMonth);
	return transactions;
}

function yearEquals(transactions){
	return transactions.data.getFullYear() == this.year;
}

function monthEquals(transactions){
	return transactions.data.getFullYear() == this.year && transactions.data.getMonth() == this.month-1;
}

function getDateArray(month){
	return (Array.from(Array(new Date(month.year, month, 0).getDate()).keys())).map((x) => x+1);
}




//Funconalidade 1 e 2

function filterByYear(list, month){
	return list.filter(yearEquals,month);
}

function filterBymonth(list, month){
	return list.filter(monthEquals,month);
}





//Funconalidade 3 
function computeCreditsBymonth(list,month){
	return (filterBymonth(list,month).filter(isCredit)).reduce(function(a,b){ return a + b.valor;}, 0);
}




//Funconalidade 4
function computeDebitsBymonth(list,month){
	return (filterBymonth(list,month).filter(isDebit)).reduce(function(a,b){ return a + b.valor;}, 0);
}




//Funconalidade 5
function computeDCBymonth(list,month){
	return computeCreditsBymonth(list, month) + computeDebitsBymonth(list, month);
}



//Funconalidade 6
function computeBalance(list,month){
	return (filterTransactions(filterBymonth(list,month)).reduce(function(a,b){ return a + b.valor;}, 0));
}


//Funconalidade 7
function saldoMax(list,month){
	let balance = 0;
	let max = getInitialBalanceAtmonth(list,month);
	filterTransactions(filterBymonth(list,month)).map((action) => {
		balance+=action.valor;
		if (max < balance)
		max = balance;
	});
	return max;
}




// Funconalidade 8
function saldoMin(list,month){
	let balance = 0;
	let min = getInitialBalanceAtmonth(list,month);
	filterTransactions(filterBymonth(list,month)).map((action) => {
		balance+=action.valor;
		if (min > balance)
		min = balance;
	});
	return min;
}



//Funconalidade  9
function computeCreditMeansByYear(list,month){
	let filtered = list.filter(yearEquals,month).filter(isCredit);
	return (filtered).reduce(function(a,b){ return a + b.valor;}, 0) /filtered.length;
}



//Funconalidade 10
function computeDebitsMeansByYear(list,month){
	let filtered = list.filter(yearEquals,month).filter(isDebit);
	return (filtered).reduce(function(a,b){ return a + b.valor;}, 0) /filtered.length;
}



//Funconalidade 11
function computeDCMeans(list,month){
	let filtered = list.filter(yearEquals,month).filter(isDebitOrCredit);

	return (filtered).reduce(function(a,b){ return a + b.valor;}, 0) /filtered.length;
}




//Funconalidade 12 
function getCashFlow(list, month){
	let cashFlow = [];
	days = getDateArray(month.month);
	days.map(d => cashFlow.push([new Date(month.year,month.month-1,d),getBalanceAtmonthDay(list,{"year": month.year,"month":month.month,"day":d}).toFixed(2)]));
	return cashFlow;
}


function getBalanceAtmonthDay(list,month){
	let balance = 0;
	
	let days = getDateArray(month.month).filter(function(day){ return day<=month.day;});

	days.map( (day) => balance += computeBalanceDay(list,{"year": month.year,"month":month.month,"day":day}));
	
	return balance;
}

function computeCDByDay(list,month){
	return (list.filter(monthDayEquals,month).filter(isDebitOrCredit)).reduce(function(a,b){ return a + b.valor;}, 0);
}

function isDebitOrCredit(transactions){
	return !(transactions.tipos.includes("SALDO_CORRENTE")) && !(transactions.tipos.includes("APLICACAO")) && !(transactions.tipos.includes("VALOR_APLICACAO"));
}

function isDebit(transactions){
	return transactions.valor < 0 && !(transactions.tipos.includes("SALDO_CORRENTE")) && !(transactions.tipos.includes("APLICACAO")) && !(transactions.tipos.includes("VALOR_APLICACAO"));
}

function isNotBalance(transactions){
	return !(transactions.tipos.includes("SALDO_CORRENTE"));
}


function isCredit(transactions){
	return transactions.valor > 0 && !(transactions.tipos.includes("SALDO_CORRENTE")) && !(transactions.tipos.includes("APLICACAO")) && !(transactions.tipos.includes("VALOR_APLICACAO"));
}

function isCreditOrDebitOrBalance(transactions){
	return !(transactions.tipos.includes("APLICACAO")) && !(transactions.tipos.includes("VALOR_APLICACAO"));
}

function filterTransactions(list){
	return list.filter(isCreditOrDebitOrBalance);
}

function getInitialBalanceAtmonth(list,month){	
	let balance = 0;
	(filterBymonth(list,month)).map(function (transactions) {
		if (transactions.tipos.includes("SALDO_CORRENTE"))
			balance = transactions.valor;
	});
	return balance;
}

function dateSort(obj1,obj2){
	return obj1.data - obj2.data;
}


//Interface
function selectDate(e){
	let date = e.target.value.split('-');
	month = {"year": Number(date[0]), "month": Number(date[1]),"day": Number(date[2])};
	update();
}
function select(e){
	filterType = e;
	update();
}

function update(){
	document.getElementById("receitaMensal").innerHTML = "Receita do Mês: R$  " + computeCreditsBymonth(dados,month).toFixed(2);
	document.getElementById("despesaMensal").innerHTML = "Despesa do Mês: R$ " + computeDebitsBymonth(dados,month).toFixed(2);
	document.getElementById("sobraMensal").innerHTML = "Sobra do Mês: R$ " + computeDCBymonth(dados,month).toFixed(2);
	document.getElementById("saldoMensal").innerHTML = "Saldo do Mês: R$ " + computeBalance(dados,month).toFixed(2);


	document.getElementById("saldoMaximo").innerHTML = "Saldo Maximo: R$ " + saldoMax(dados,month).toFixed(2);
	document.getElementById("saldoMinimo").innerHTML = "Saldo Minimo: R$ " + saldoMin(dados,month).toFixed(2);


	document.getElementById("receitaMediaAnual").innerHTML = "Receita Média do Ano: R$ " + computeCreditMeansByYear(dados,month).toFixed(2);
	document.getElementById("despesaMediaAnual").innerHTML = "Despesa Média do Ano: R$ " + computeDebitsMeansByYear(dados,month).toFixed(2);
	document.getElementById("sobraMediaAnual").innerHTML = "Sobra Média do Ano: R$ " + computeDCMeans(dados,month).toFixed(2);
	
	let filtered = dados;
	switch (filterType) {
	  	case "year": 			
	  		filtered = filterByYear(filtered,month); 	
	  	break;

	  	case "month": 		
	  		filtered = filterBymonth(filtered,month); 	
	  	break;
	  	
	}
	fluxo(filtered);	
}

function fluxo(list){
	let table = document.getElementById("main");
    table.innerHTML = "";
    let tr = document.createElement("tr");
    let descricao = document.createElement("th");
	let data = document.createElement("th");
    let valor = document.createElement("th");
    
    descricao.innerHTML = "Descrição" 
	data.innerHTML = "Data"
	valor.innerHTML = "Valor"
    
    tr.append(descricao);
	tr.append(data);
	tr.append(valor);

	table.append(tr);

	list.map(transaction=>{
		let tr = document.createElement("tr");
		let descricao = document.createElement("td");
		let data = document.createElement("td");
		let valor = document.createElement("td");

		descricao.innerHTML = transaction.textoIdentificador; 
		data.innerHTML = transaction.data.getDate() + "/" + (transaction.data.getMonth()+1) + "/"  + transaction.data.getFullYear() ; 
		valor.innerHTML = "R$ " +transaction.valor.toFixed(2); 
	
		tr.append(descricao);
		tr.append(data);
		tr.append(valor);

		table.append(tr);
	})
}

