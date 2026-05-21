module Game
  ( estatInicial
  , localitzaNucli
  , esPlataforma
  , esSegur
  , succionat
  , connectatAlReactor
  , maniobra
  , reinicia
  , soluciona
  ) where

import Control.Monad.State
import Data.Maybe           (mapMaybe)
import qualified Data.Set as Set

import Types

-- ---------------------------------------------------------------------------
-- Estat inicial
-- ---------------------------------------------------------------------------

estatInicial :: Tauler -> Estat
estatInicial t = Estat
  { tauler    = t
  , nucli     = Nucli (pInici t) Vertical
  , historial = []
  }

-- ---------------------------------------------------------------------------
-- Consultes sobre el tauler i el nucli
-- ---------------------------------------------------------------------------

-- | Retorna totes les posicions que ocupa el nucli
localitzaNucli :: Estat -> [Posicio]
localitzaNucli (Estat t (Nucli (f, c) ori) _) = case ori of
  Vertical      -> [(f + i, c) | i <- [0 .. h - 1]]
  HoritzontalEW -> [(f, c + i) | i <- [0 .. h - 1]]
  HoritzontalNS -> [(f + i, c) | i <- [0 .. h - 1]]
  where h = alcada t

-- | Hi ha plataforma en una posicio?
esPlataforma :: Tauler -> Posicio -> Bool
esPlataforma t (f, c)
  | f < 0 || c < 0  = False
  | f >= nf          = False
  | c >= nc          = False
  | otherwise        = cel t !! f !! c /= Buit
  where
    nf = length (cel t)
    nc = if null (cel t) then 0 else length (head (cel t))

-- | Totes les unitats del nucli estan sobre plataforma?
esSegur :: Estat -> Bool
esSegur est = all (esPlataforma (tauler est)) (localitzaNucli est)

-- | El nucli ha caigut al buit?
succionat :: Estat -> Bool
succionat = not . esSegur

-- | El nucli és vertical?
estaDret :: Nucli -> Bool
estaDret (Nucli _ Vertical) = True
estaDret _                  = False

-- | El nucli ha arribat al reactor en posicio vertical?
connectatAlReactor :: Estat -> Bool
connectatAlReactor est@(Estat t n _) =
  estaDret n && nucliPos n == pFinal t
  where nucliPos (Nucli p _) = p

-- ---------------------------------------------------------------------------
-- Maniobra i reinici — monada State
-- ---------------------------------------------------------------------------

-- | Mou el nucli en la direccio indicada (actualitza Estat via State)
maniobra :: Direccio -> State Estat ()
maniobra dir = modify $ \est ->
  let h  = alcada (tauler est)
      n' = mouNucli (nucli est) h dir
  in est { nucli = n', historial = historial est ++ [dir] }

-- | Torna el nucli a la posicio inicial i neteja l'historial
reinicia :: State Estat ()
reinicia = modify $ \est ->
  est { nucli = Nucli (pInici (tauler est)) Vertical, historial = [] }

-- | Calcula la nova posicio del nucli donada una direccio
mouNucli :: Nucli -> Int -> Direccio -> Nucli
mouNucli (Nucli (f, c) Vertical) h dir = case dir of
  Nord -> Nucli (f - h, c) Vertical
  Sud  -> Nucli (f + h, c) Vertical
  Oest -> Nucli (f, c - h) HoritzontalEW
  Est  -> Nucli (f, c + 1) HoritzontalEW
mouNucli (Nucli (f, c) HoritzontalEW) h dir = case dir of
  Nord -> Nucli (f - 1, c) Vertical
  Sud  -> Nucli (f + 1, c) Vertical
  Oest -> Nucli (f, c - 1) HoritzontalEW
  Est  -> Nucli (f, c + h) HoritzontalEW
mouNucli (Nucli (f, c) HoritzontalNS) h dir = case dir of
  Nord -> Nucli (f - 1, c) HoritzontalNS
  Sud  -> Nucli (f + h, c) HoritzontalNS
  Oest -> Nucli (f, c - 1) Vertical
  Est  -> Nucli (f, c + 1) Vertical

-- ---------------------------------------------------------------------------
-- Solucio automatica: BFS
-- ---------------------------------------------------------------------------

-- | BFS des de l'estat actual; retorna el cami mes curt o Nothing
soluciona :: Estat -> Maybe [Direccio]
soluciona est0 = bfs [(nucli est0, [])] Set.empty
  where
    t    = tauler est0
    h    = alcada t
    dirs = [Nord, Sud, Est, Oest]

    bfs [] _ = Nothing
    bfs ((n, cami) : cua) visitats
      | connectatAlReactor (est0 { nucli = n }) = Just cami
      | n `Set.member` visitats                 = bfs cua visitats
      | otherwise =
          let visitats' = Set.insert n visitats
              veins     = mapMaybe (prova n cami) dirs
          in bfs (cua ++ veins) visitats'

    prova n cami dir =
      let n'   = mouNucli n h dir
          est' = est0 { nucli = n' }
      in if esSegur est' then Just (n', cami ++ [dir]) else Nothing
