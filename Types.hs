module Types where

-- | Posicio al tauler (fila, columna), base 0
type Posicio = (Int, Int)

-- | Orientació del nucli
data Orientacio
  = Vertical      -- de peu (1 cel·la)
  | HoritzontalEW -- estirat d'est a oest (h cel·les en fila)
  | HoritzontalNS -- estirat de nord a sud (h cel·les en columna)
  deriving (Eq, Ord, Show)

-- | Nucli: posicio de la unitat "cap" i orientació
data Nucli = Nucli Posicio Orientacio
  deriving (Eq, Ord, Show)

-- | Cel.la del tauler
data Cella = Buit | Plataforma | Inici | Reactor
  deriving (Eq, Show)

-- | Tauler de l'estació
data Tauler = Tauler
  { cel    :: [[Cella]]
  , alcada :: Int       -- alçada del nucli (llegida del fitxer)
  , pInici :: Posicio   -- posicio de la casella S
  , pFinal :: Posicio   -- posicio de la casella G
  }

-- | Estat complet del joc
data Estat = Estat
  { tauler    :: Tauler
  , nucli     :: Nucli
  , historial :: [Direccio]  -- moviments fets fins ara
  }

-- | Direccions de moviment
data Direccio = Nord | Sud | Est | Oest
  deriving (Eq, Ord, Show)

-- | Mode de joc
data Mode = Pilot | IA
  deriving (Eq, Show)
