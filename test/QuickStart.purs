module Test.Quickstart where

import Prelude

import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toNullable)
import Effect (Effect)
import Effect.Class.Console (log)
import Foreign (ForeignError(..), F)
import Simple.JSON (E)
import Simple.JSON as JSON
import Test.Assert (assertEqual)

type MyRecordAlias =
  { apple :: String
  , banana :: Array Int
  }

testJSON1 :: String
testJSON1 = """
{ "apple": "Hello"
, "banana": [ 1, 2, 3 ]
}
"""

testJSON2 :: String
testJSON2 = """
{ "apple": false
, "banana": [ 1, 2, 3 ]
}
"""

type WithMaybe =
  { cherry :: Maybe Boolean
  }

testJSON3 :: String
testJSON3 = """
{ "cherry": true
}
"""

testJSON4 :: String
testJSON4 = """
{}
"""

type WithNullable =
  { cherry :: Nullable Boolean
  }

main :: Effect Unit
main = do
  case JSON.readJSON testJSON1 of
    Right (r :: MyRecordAlias) -> do
      assertEqual { expected: r.apple, actual: "Hello"}
      assertEqual { expected: r.banana, actual: [ 1, 2, 3 ] }
    Left e -> do
      assertEqual { expected: "failed", actual: show e }
  case JSON.readJSON testJSON2 of
    Right (r1 :: MyRecordAlias) -> do
      assertEqual { expected: "failed", actual: show r1 }
    Left e2 -> do
      let errors = Array.fromFoldable e2
      assertEqual { expected: [ErrorAtProperty "apple" (TypeMismatch "binary" "boolean")], actual: errors }
  let
    myValue =
      { apple: "Hi"
      , banana: [ 1, 2, 3 ]
      } :: MyRecordAlias

  log (JSON.writeJSON myValue) -- {"banana":[1,2,3],"apple":"Hi"}

  case JSON.readJSON testJSON3 of
    Right (r :: WithMaybe) -> do
      assertEqual { expected: Just true, actual: r.cherry }
    Left e -> do
      assertEqual { expected: "failed", actual: show e }

  case JSON.readJSON testJSON4 of
    Right (r :: WithMaybe) -> do
      assertEqual { expected: Nothing, actual: r.cherry }
    Left e -> do
      assertEqual { expected: "failed", actual: show e }

  let
    withJust =
      { cherry: Just true
      } :: WithMaybe
    withNothing =
      { cherry: Nothing
      } :: WithMaybe

  log (JSON.writeJSON withJust) -- {"cherry":true}
  log (JSON.writeJSON withNothing) -- {}

  case JSON.readJSON testJSON3 of
    Right (r :: WithNullable) -> do
      assertEqual { expected: toNullable (Just true), actual: r.cherry }
    Left e -> do
      assertEqual { expected: "failed", actual: show e }

  case JSON.readJSON testJSON4 of
    Right (r :: WithNullable) -> do
      assertEqual { expected: "failed", actual: show r }
    Left e -> do
      let errors = Array.fromFoldable e
      assertEqual { expected: [ErrorAtProperty "cherry" (TypeMismatch "Nullable boolean" "atom")], actual: errors }

  let
    withNullable =
      { cherry: toNullable Nothing
      } :: WithNullable
  log (JSON.writeJSON withNullable) -- {"cherry":null}
