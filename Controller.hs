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
  "n" -> Moure Nord
  "s" -> Moure Sud
  "e" -> Moure Est
  "o" -> Moure Oest
  "k" -> Moure Nord    -- vi-keys alternatius
  "j" -> Moure Sud
  "l" -> Moure Est
  "h" -> Moure Oest
  "m" -> CambiaMode
  "q" -> Sortir
  _   -> Invalid

parseMode :: String -> Maybe Mode
parseMode s = case map toLower s of
  "pilot" -> Just Pilot
  "ia"    -> Just IA
  "auto"  -> Just IA
  _       -> Nothing
