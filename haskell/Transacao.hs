{-# LANGUAGE DeriveGeneric #-}

module Transacao( Transacao(..) )where
   
   import Data.Aeson
   import GHC.Generics
   import GregorianCalendar
   import TipoTransacao
   
   data Transacao = Transacao{datas :: GregorianCalendar, valor :: Double, textoIdentificador :: String, descricao :: String,
    numeroDOC :: String, tipos :: [TipoTransacao]} deriving (Generic)

   instance ToJSON Transacao
   instance FromJSON Transacao where 

   


