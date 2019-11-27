module Printer( exibeFluxoDeCaixa, exibeTabelaTransacoes, slice ) where

import Transacao
import GregorianCalendar
import TipoTransacao

exibeTabelaTransacoes :: [Transacao] -> IO ()
exibeTabelaTransacoes transacoes = do 
    putStrLn cabecalho
    printLinha
    exibeTransacoes transacoes

exibeTransacoes :: [Transacao] -> IO ()
exibeTransacoes [] = printLinha
exibeTransacoes (x:xs) = do 
    putStrLn $ imprimeTransacao x
    exibeTransacoes xs

cabecalho =
    espacamento 15 "+Data+" ++ "  " ++
    espacamento 35 "   +Id+" ++ "  " ++
    espacamento 20 "   +Valor+" ++ "  " ++
    espacamento 20 "   +Descricao+" ++ "  " ++
    espacamento 30 "   +No do documento+" ++ "  " ++
    espacamento 30 "   +Tipos de transacoes+"

printLinha = putStrLn $ replicate 175 '='

imprimeTransacao :: Transacao -> String
imprimeTransacao (Transacao d v ti desc ndoc tipos) =
    espacamento 10 ( formataData $ d) ++ "  " ++
    espacamento 20 (ti) ++ "  " ++
    espacamentoAux 30 ( show $ v) ++ "         " ++
    espacamento 30 ( desc) ++ "  " ++
    espacamentoAux 12 ( ndoc) ++ "  " ++
    ( show $ tipos)

formataData :: GregorianCalendar -> String
formataData g = show (dayOfMonth g)++ "/"++ show (month g) ++"/"++ show (year g)

slice :: Int -> Int -> [a] -> [a]
slice start stop xs = fst $ splitAt (stop - start) (snd $ splitAt start xs)

espacamento :: Int -> String  -> String
espacamento esp str  
    | length str > esp = slice 0 (esp - 3) str ++ "..."
    | otherwise = str ++ replicate (esp - length str) ' '

espacamentoAux :: Int -> String  -> String
espacamentoAux esp str  
    | length str > esp = slice 0 (esp - 3) str ++ "..."
    | otherwise = replicate (esp - length str) ' ' ++ str 


exibeFluxoDeCaixa [] = do
    printLinha
exibeFluxoDeCaixa (x:xs) = do
    putStrLn (show $ x)
    exibeFluxoDeCaixa xs
