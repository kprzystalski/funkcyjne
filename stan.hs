import Control.Monad.State
import Control.Monad (replicateM)

type Rand a = State Int a   -- state = current seed

-- One step of a simple LCG
nextRand :: Rand Int
nextRand = do
  seed <- get
  let a   = 1103515245
      c   = 12345
      m   = 2147483648      -- 2^31
      seed' = (a * seed + c) `mod` m
  put seed'
  return seed'

randList :: Int -> Rand [Int]
randList n = replicateM n nextRand

runRandList :: Int -> Int -> [Int]
runRandList seed n =
  evalState (randList n) seed

main :: IO ()
main = do
  let xs = runRandList 42 5
  print xs
