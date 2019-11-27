 {-# LANGUAGE DeriveGeneric #-}

module GregorianCalendar( GregorianCalendar, year, month, dayOfMonth ) where
import Data.Aeson
import GHC.Generics

data GregorianCalendar = GregorianCalendar {year :: Int, month :: Int, dayOfMonth :: Int} deriving (Generic, Show)

instance ToJSON GregorianCalendar
instance FromJSON GregorianCalendar
