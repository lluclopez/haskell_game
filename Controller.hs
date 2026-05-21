module Controller (Input(..), parseInput, parseMode) where

import Data.Char (toLower)
import Types     (Direccio(..), Mode(..))

-- | Input que pot donar l'usuari durant la partida
data Input
  = Moure Direccio   -- mou el nucli
  | CambiaMode       -- canvia de Pilot a IA
  | Sortir           -- tanca el programa
  | Invalid          -- entrada no reconeguda
  deriving Show

parseInput :: String -> Input
parseInput s = case map toLower (filter (/= '\n') s) of
  "w" -> Moure Nord
  "s" -> Moure Sud
  "d" -> Moure Est
  "a" -> Moure Oest
  "n" -> Moure Nord    -- vi-keys alternatius
  "s" -> Moure Sud
  "e" -> Moure Est
  "o" -> Moure Oest
  "m" -> CambiaMode
  "q" -> Sortir
  _   -> Invalid

parseMode :: String -> Maybe Mode
parseMode s = case map toLower s of
  "pilot" -> Just Pilot
  "ia"    -> Just IA
  "auto"  -> Just IA
  _       -> Nothing
