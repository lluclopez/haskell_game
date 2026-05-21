module Parser (parseInstance) where

import Types

-- | Parseja el contingut d'un fitxer .txt i retorna el Tauler.
--   Format del fitxer:
--     Linia 1: alçada del nucli
--     Linia 2: nombre de files
--     Linia 3: nombre de columnes
--     Resta:   mapa (0=buit, 1=plataforma, S=inici, G=reactor)
parseInstance :: String -> Tauler
parseInstance contingut =
  let ls    = lines contingut
      alc   = read (ls !! 0) :: Int
      nf    = read (ls !! 1) :: Int
      _nc   = read (ls !! 2) :: Int   -- nombre de columnes (no necessari)
      mapa  = take nf (drop 3 ls)
      mat   = map (map parseCella) mapa
      (ini, fin) = trobaPositions mat
  in Tauler
       { cel    = mat
       , alcada = alc
       , pInici = ini
       , pFinal = fin
       }

parseCella :: Char -> Cella
parseCella '1' = Plataforma
parseCella 'S' = Inici
parseCella 'G' = Reactor
parseCella _   = Buit

trobaPositions :: [[Cella]] -> (Posicio, Posicio)
trobaPositions m = (cerca Inici, cerca Reactor)
  where
    tots  = [(c, (f, col)) | (f, fila) <- zip [0..] m
                            , (col, c)  <- zip [0..] fila]
    cerca t = snd . head $ filter (\(c,_) -> c == t) tots
