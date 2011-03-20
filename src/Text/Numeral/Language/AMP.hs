{-# LANGUAGE NoImplicitPrelude, OverloadedStrings, UnicodeSyntax #-}

{-|
[@ISO639-1@]        -

[@ISO639-2@]        -

[@ISO639-3@]        amp

[@Native name@]     -

[@English name@]    Alamblak
-}

module Text.Numeral.Language.AMP
    ( cardinal
    , struct
    , cardinalRepr
    ) where


-------------------------------------------------------------------------------
-- Imports
-------------------------------------------------------------------------------

-- from base:
import Control.Monad ( (>=>) )
import Data.Function ( ($), const, fix )
import Data.Maybe    ( Maybe(Just) )
import Data.Monoid   ( Monoid )
import Data.String   ( IsString )
import Prelude       ( Integral )

-- from containers:
import qualified Data.Map as M ( fromList, lookup )

-- from numerals:
import Text.Numeral
import qualified Text.Numeral.Exp.Classes as C


-------------------------------------------------------------------------------
-- AMP
-------------------------------------------------------------------------------

{-
Sources:
  http://www.sf.airnet.ne.jp/~ts/language/number/alamblak.html
-}

cardinal ∷ (Monoid s, IsString s, Integral α) ⇒ α → Maybe s
cardinal = struct >=> cardinalRepr

-- TODO: representation for "yohtt" (exact)
-- 20 = Exact (Lit 20)
-- 22 = Exact (Lit 20) `Add` Lit 2

struct ∷ (Integral α, C.Lit β, C.Add β, C.Mul β) ⇒ α → Maybe β
struct = checkPos
       $ fix
       $ findRule ( 1, lit       )
                [ ( 3, add  2 R  )
                , ( 5, lit       )
                , ( 6, add  5 R  )
                , (10, mul  5 R R)
                , (20, lit       )
                , (21, add 20 R  )
                , (40, mul 20 R R)
                ]
                  399

cardinalRepr ∷ (Monoid s, IsString s) ⇒ Exp → Maybe s
cardinalRepr = textify defaultRepr
               { reprValue = \n → M.lookup n symMap
               , reprAdd   = (⊞)
               , reprMul   = \_ _ → Just " "
               }
    where
      Lit 2 ⊞ Lit _ = Just "i"
      _     ⊞ _     = Just "i "

      symMap = M.fromList
               [ (1,  const "rpat")
               , (2,  const "hosf")
               , (5,  \c → case c of
                             CtxMulL {} → "tir"
                             _          → "tir yohtt"
                 )
               , (20, \c → case c of
                             CtxMulL {} → "yima"
                             _          → "yima yohtt"
                 )
               ]
