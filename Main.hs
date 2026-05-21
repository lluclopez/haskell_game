module Main where

import Control.Monad.State
import System.Exit (exitSuccess)

import Types
import Parser      (parseInstance)
import Game
import Controller
import Display

-- ---------------------------------------------------------------------------
-- Punt d'entrada
-- ---------------------------------------------------------------------------

main :: IO ()
main = do
  putStr "Ruta del fitxer d'instancia (.txt): "
  path     <- getLine
  contingut <- readFile path
  let t    = parseInstance contingut
      est0 = estatInicial t

  putStrLn "\nEscull mode de joc:"
  putStrLn "  pilot -> controles tu el nucli"
  putStrLn "  ia    -> l'IA cerca la ruta optima (BFS)"
  mode <- demanaModeInicial

  juga mode est0

-- ---------------------------------------------------------------------------
-- Seleccio de mode
-- ---------------------------------------------------------------------------

demanaModeInicial :: IO Mode
demanaModeInicial = do
  putStr "Mode [pilot/ia]: "
  resp <- getLine
  case parseMode resp of
    Just m  -> return m
    Nothing -> putStrLn "Mode no valid." >> demanaModeInicial

-- ---------------------------------------------------------------------------
-- Dispatcher: tria el bucle correcte
-- ---------------------------------------------------------------------------

juga :: Mode -> Estat -> IO ()
juga Pilot = bucleHuma
juga IA    = bucleIA

-- ---------------------------------------------------------------------------
-- Mode Pilot: bucle interactiu amb State monad
-- ---------------------------------------------------------------------------

bucleHuma :: Estat -> IO ()
bucleHuma est = do
  putStrLn ""
  putStr   $ mostraTauler est
  if connectatAlReactor est
    then putStrLn "Sistema energetic estabilitzat!"
    else do
      putStr "Mou [n/s/e/o] | canvia mode [m] | surt [q]: "
      inp <- parseInput <$> getLine
      case inp of
        Sortir     -> putStrLn "Sortint..." >> exitSuccess

        CambiaMode -> do
          putStrLn "--> Canviant a mode IA des de l'estat actual..."
          juga IA est

        Moure dir  -> do
          let est' = execState (maniobra dir) est
          if succionat est'
            then do
              putStrLn "!! El nucli ha caigut al buit. Reiniciant..."
              bucleHuma (execState reinicia est')
            else
              bucleHuma est'

        Invalid    -> putStrLn "Entrada invalida." >> bucleHuma est

-- ---------------------------------------------------------------------------
-- Mode IA: BFS + reproduccio pas a pas
-- ---------------------------------------------------------------------------

bucleIA :: Estat -> IO ()
bucleIA est = do
  putStrLn "\nMode IA: cercant ruta optima (BFS)..."
  case soluciona est of
    Nothing   -> putStrLn "Col.lapse energetic a l'estacio Monad."
    Just dirs -> do
      putStrLn $ "Ruta: " ++ unwords (map showDir dirs)
      putStrLn ""
      reprodueix est dirs 0

reprodueix :: Estat -> [Direccio] -> Int -> IO ()
reprodueix est [] pas = do
  putStr $ mostraTauler est
  putStrLn $ show pas ++ " (final)"
  putStrLn "Sistema energetic estabilitzat!"
reprodueix est (d:ds) pas = do
  putStrLn $ show pas ++ " " ++ showDir d
  putStr   $ mostraTauler est
  reprodueix (execState (maniobra d) est) ds (pas + 1)
