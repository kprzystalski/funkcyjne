trait RNG {
    def nextInt: (Int, RNG)
}

case class SimpleRNG(seed: Int) extends RNG {
  def nextInt: (Int, RNG) = {
    val newSeed = scala.util.Random.between(0, 10001)
    val nextRNG = SimpleRNG(newSeed)
    (newSeed, nextRNG)	
  }
}

def randomPair1(rng: RNG): (Int, Int) = {
    val (i1, _) = rng.nextInt
    val (i2, _) = rng.nextInt
    (i1,i2)
}

def randomPair2(rng: RNG): ((Int,Int), RNG) = {
  val (i1,rng2) = rng.nextInt
  val (i2,rng3) = rng2.nextInt	
   ((i1,i2), rng3)	
}

val rng = new SimpleRNG(42)

print(randomPair1(rng))
print(randomPair1(rng))
print(randomPair2(rng))