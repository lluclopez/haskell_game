module Display (mostraTauler, showDir) where

import Types
import Game  (localitzaNucli)

-- | Retorna una representacio del tauler amb el nucli marcat com 'N'
mostraTauler :: Estat -> String
mostraTauler est =
  unlines
    [ concat [renderCel (f, c) | c <- [0 .. ncols - 1]]
    | f <- [0 .. nfiles - 1]
    ]
  where
    mat    = cel (tauler est)
    nfiles = length mat
    ncols  = if null mat then 0 else length (head mat)
    posNuc = localitzaNucli est

    renderCel pos
      | pos `elem` posNuc = "N"
      | otherwise = case mat !! fst pos !! snd pos of
          Buit       -> "0"
          Plataforma -> "1"
          Inici      -> "S"
          Reactor    -> "G"

-- | Mostra una direccio com a text
showDir :: Direccio -> String
showDir Nord = "amunt"
showDir Sud  = "avall"
showDir Est  = "dreta"
showDir Oest = "esquerra"
