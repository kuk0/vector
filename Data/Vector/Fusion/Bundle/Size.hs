-- |
-- Module      : Data.Vector.Fusion.Bundle.Size
-- Copyright   : (c) Roman Leshchinskiy 2008-2010
-- License     : BSD-style
--
-- Maintainer  : Roman Leshchinskiy <rl@cse.unsw.edu.au>
-- Stability   : experimental
-- Portability : portable
-- 
-- Size hints for streams.
--

module Data.Vector.Fusion.Bundle.Size (
  Size(..), smaller, larger, toMax, upperBound
) where

import Data.Vector.Fusion.Util ( delay_inline )

-- | Size hint
data Size = Exact Int          -- ^ Exact size
          | Max   Int          -- ^ Upper bound on the size
          | Unknown            -- ^ Unknown size
        deriving( Eq, Show )

instance Num Size where
  Exact m + Exact n = Exact (m+n)
  Exact m + Max   n = Max   (m+n)

  Max   m + Exact n = Max   (m+n)
  Max   m + Max   n = Max   (m+n)

  _       + _       = Unknown


  Exact m - Exact n = Exact (m-n)
  Exact m - Max   n = Max   m

  Max   m - Exact n = Max   (m-n)
  Max   m - Max   n = Max   m
  Max   m - Unknown = Max   m

  _       - _       = Unknown


  fromInteger n     = Exact (fromInteger n)

  (*)    = error "vector: internal error * for Bundle.size isn't defined"
  abs    = error "vector: internal error abs for Bundle.size isn't defined"
  signum = error "vector: internal error signum for Bundle.size isn't defined"


-- | Minimum of two size hints
smaller :: Size -> Size -> Size
{-# INLINE smaller #-}
smaller (Exact m) (Exact n) = Exact (delay_inline min m n)
smaller (Exact m) (Max   n) = Max   (delay_inline min m n)
smaller (Exact m) Unknown   = Max   m
smaller (Max   m) (Exact n) = Max   (delay_inline min m n)
smaller (Max   m) (Max   n) = Max   (delay_inline min m n)
smaller (Max   m) Unknown   = Max   m
smaller Unknown   (Exact n) = Max   n
smaller Unknown   (Max   n) = Max   n
smaller Unknown   Unknown   = Unknown

-- | Maximum of two size hints
larger :: Size -> Size -> Size
{-# INLINE larger #-}
larger (Exact m) (Exact n)             = Exact (delay_inline max m n)
larger (Exact m) (Max   n) | m >= n    = Exact m
                           | otherwise = Max   n
larger (Max   m) (Exact n) | n >= m    = Exact n
                           | otherwise = Max   m
larger (Max   m) (Max   n)             = Max   (delay_inline max m n)
larger _         _                     = Unknown

-- | Convert a size hint to an upper bound
toMax :: Size -> Size
toMax (Exact n) = Max n
toMax (Max   n) = Max n
toMax Unknown   = Unknown

-- | Compute the minimum size from a size hint
lowerBound :: Size -> Int
lowerBound (Exact n) = n
lowerBound _         = 0

-- | Compute the maximum size from a size hint if possible
upperBound :: Size -> Maybe Int
upperBound (Exact n) = Just n
upperBound (Max   n) = Just n
upperBound Unknown   = Nothing

