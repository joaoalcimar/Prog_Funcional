module Main where
import Parser
import Printer
import Transacao
import GregorianCalendar
import TipoTransacao
import Data.Time.Clock
import Data.Time.Calendar

main = do
--carrega bd
  db <- loadDb

--exemplos casos de uso  
  let testequestao1 = (filtraPorAno db 2019)
  let testequestao2 = (filtraPorAnoMes db 2019 2)
  let testequestao3 = (somaCreditosAnoMes db 2019 2)
  let testequestao4 = (somaDebitosAnoMes db 2019 2)
  let testequestao5 = (calculaSobraAnoMes db 2019 9)
  let testequestao6 = (calculaSaldoFinalAnoMes db 2019 2)
  let testequestao7 = (calculaSaldoMaxAnoMes db 2019 2)
  let testequestao8 = (calculaSaldoMinAnoMes db 2019 2)
  let testequestao9 = (mediaReceitaAno db 2019)
  let testequestao10 = (mediaDebitoAno db 2019)
  let testequestao11 = (mediaSobraAno db 2019)
  let testequestao12 = (fluxoCaixaAnoMes db 2019 2)
 
   
  putStrLn "Tabela de transacoes"
  exibeTabelaTransacoes testequestao1
  putStrLn ""
  
  putStrLn "Tabela de transacoes anual"
  exibeTabelaTransacoes testequestao2
  putStrLn ""
  
  putStrLn "Soma de creditos"
  print testequestao3
  putStrLn ""
  
  putStrLn "Soma de debitos"
  print testequestao4
  putStrLn ""
  
  putStrLn "Calculo das sobras"
  print testequestao5
  putStrLn ""
  
  putStrLn "Calculo do saldo final"
  print testequestao6
  putStrLn ""
  
  putStrLn "Calculo do saldo maximo"
  print testequestao7
  putStrLn ""
  
  putStrLn "Calculo do saldo minimo"
  print testequestao8
  putStrLn ""
  
  putStrLn "Media das receitas"
  print testequestao9
  putStrLn ""
  
  putStrLn "Media dos debitos"
  print testequestao10
  putStrLn ""
  
  putStrLn "Media das sobras"
  print testequestao11
  putStrLn ""
  
  putStrLn "Fluxo de caixa"
  exibeFluxoDeCaixa testequestao12
  putStrLn ""

--Implementacao casos de uso--

--Filtrar as transações
filtraTransacoes db = filter (ehCreditoDebitoOuBalanco) db


--Filtrar transações por ano.
filtraPorAno db y = filter (ehAnoIgual y) db


--Filtrar transações por ano e mês.
filtraPorAnoMes db y m = filter (ehAnoMesIgual y m) db


--Filtrar transações por ano, mês e dia.
filtraPorAnoMesDia db y m d = filter (ehAnoMesDiaIgual y m d) db


--Calcular o valor das receitas (créditos) em um determinado mês e ano.
somaCreditosAnoMes db y m = somaValores (filter (ehCredito) (filtraPorAnoMes db y m))


--Calcular o valor das despesas (débitos) em um determinado mês e ano.
somaDebitosAnoMes db y m = somaValores (filter (ehDebito) (filtraPorAnoMes db y m))


--Calcular a sobra (receitas - despesas) de determinado mês e ano
calculaSobraAnoMes db y m = (somaCreditosAnoMes db y m) + (somaDebitosAnoMes db y m) 


--Calcular o saldo final em um determinado ano e mês
calculaSaldoFinalAnoMes db y m = somaValores (filtraTransacoes (filtraPorAnoMes db y m))


--Calcular o saldo máximo atingido em determinado ano e mês
calculaSaldoMaxAnoMes [] _ _ = 0
calculaSaldoMaxAnoMes db y m = maximum (getSaldos db y m)
getSaldos db y m = (getSaldosAux (credDebAnoMes) (getValor (balanco) ))
 where 
 credDebAnoMes = filter (ehCreditoDebito) (filtraPorAnoMes db y m)
 balanco = head (filter (ehBalanco) ((filtraPorAnoMes db y m)))
getSaldosAux [] _ = []
getSaldosAux (t:ts) db = [db] ++ getSaldosAux ts ((getValor t)+db)


--Calcular o saldo mínimo atingido em determinado ano e mês
calculaSaldoMinAnoMes [] _ _ = 0
calculaSaldoMinAnoMes db y m = minimum (getSaldos db y m)

--Calcular a média das receitas em determinado ano
mediaReceitaAno db y = (somaValores filtrado) / (fromIntegral (length filtrado))
 where filtrado = (filter (ehCredito) (filtraPorAno db y))


--Calcular a média das despesas em determinado ano
mediaDebitoAno db y = (somaValores filtrado) / (fromIntegral (length filtrado))
 where filtrado = (filter (ehDebito) (filtraPorAno db y))


--Calcular a média das sobras em determinado ano
mediaSobraAno db y = (somaValores filtrado) / (fromIntegral (length filtrado))
 where filtrado = (filter (ehCreditoDebito) (filtraPorAno db y))


--Retornar o fluxo de caixa de determinado mês/ano. O fluxo de caixa nada mais é do que uma lista contendo pares (dia,saldoFinalDoDia). 
fluxoCaixaAnoMes db y m = fluxoCaixaAnoMesAux filtraAnoMes listaDeDias
 where 
 listaDeDias = monthDaysList (fromIntegral y) m
 filtraAnoMes = filtraTransacoes (filtraPorAnoMes db y m)

fluxoCaixaAnoMesAux _ [] = []
fluxoCaixaAnoMesAux db (d:ds) = [ ("Dia  " ++ show d ++ "             " ++ " Saldo ", somaValores [types | types <- db, (dayOfMonth(getData types)) <= d]) ] ++ fluxoCaixaAnoMesAux db ds
getData (Transacao date _ _ _ _ _) = date
somaValores [] = 0
somaValores (t:ts) = getValor t + somaValores ts
getValor (Transacao _ value _ _ _ _) = value

--Aux
ehCredito (Transacao _ v _ _ _ t) = (not (elem SALDO_CORRENTE t)) && (not (elem VALOR_APLICACAO t)) && (not (elem APLICACAO t))  && (v > 0)
ehDebito (Transacao _ v _ _ _ t) = (not (elem SALDO_CORRENTE t)) && (not (elem VALOR_APLICACAO t)) && (not (elem APLICACAO t)) && (v < 0)
ehBalanco (Transacao _ _ _ _ _ t) = (elem SALDO_CORRENTE t)
ehCreditoDebito (Transacao _ _ _ _ _ t) = (not (elem SALDO_CORRENTE t)) && (not (elem VALOR_APLICACAO t)) && (not (elem APLICACAO t)) 
ehCreditoDebitoOuBalanco (Transacao _ _ _ _ _ t) = (not (elem VALOR_APLICACAO t)) && (not (elem APLICACAO t)) 

ehAnoIgual ano (Transacao c _ _ _ _ _) = ano == year c
ehAnoMesIgual ano mes (Transacao c _ _ _ _ _) = ano == year c && mes == month c
ehAnoMesDiaIgual ano mes dia (Transacao c _ _ _ _ _) = ano == year c && mes == month c && dayOfMonth c == dia

monthDaysList ano mes = [1..gregorianMonthLength ano (mes+1)]

