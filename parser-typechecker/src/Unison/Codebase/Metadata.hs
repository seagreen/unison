module Unison.Codebase.Metadata where

import Data.Foldable (toList)
import Data.Map (Map)
import Data.Set (Set)
import Data.List (foldl')
import Unison.Reference (Reference)
import Unison.Util.Star3 (Star3)
import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Unison.Util.Star3 as Star3
import Unison.Util.Relation (Relation)

type Type = Reference
type Value = Reference

-- keys can be terms or types
type Metadata = Map Type (Set Value)

type Star a n = Star3 a n Type (Type, Value)

inserts :: (Ord a, Ord n) => [(a, Type, Value)] -> Star a n -> Star a n
inserts tups s = foldl' (flip insert) s tups

insertWithMetadata
  :: (Ord a, Ord n) => (a, Metadata) -> Star a n -> Star a n
insertWithMetadata (a, md) =
  inserts [ (a, ty, v) | (ty, vs) <- Map.toList md, v <- toList vs ]

insert :: (Ord a, Ord n) => (a, Type, Value) -> Star a n -> Star a n
insert (a, ty, v) = Star3.insertD23 (a, ty, (ty,v))

delete :: (Ord a, Ord n) => (a, Type, Value) -> Star a n -> Star a n
delete (a, ty, v) = Star3.deleteD23 (a, ty, (ty,v))

-- parallel composition - commutative and associative
merge :: Metadata -> Metadata -> Metadata
merge = Map.unionWith (<>)

-- sequential composition, right-biased
append :: Metadata -> Metadata -> Metadata
append = Map.unionWith (flip const)

empty :: Metadata
empty = mempty

singleton :: Type -> Value -> Metadata
singleton ty v = Map.singleton ty (Set.singleton v)

toRelation :: Star a n -> Relation a n
toRelation = Star3.d1