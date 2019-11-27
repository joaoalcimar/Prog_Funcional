module Parser
(
    getJSON,
    loadDb
) where

import qualified Data.ByteString.Lazy as B  
import Data.Aeson
import Data.Maybe
import Transacao

jsonFile :: FilePath
jsonFile = "db/transactions.json"

getJSON :: IO B.ByteString
getJSON = B.readFile jsonFile

loadDb :: IO [Transacao]
loadDb = do
    transations <- (decode <$> getJSON) :: IO (Maybe [Transacao])
    return (fromJust transations)
