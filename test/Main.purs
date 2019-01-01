module Test.Main where

import Prelude

import Bucketchain.Test (request)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Options ((:=))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, runAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (Error, message)
import Foreign.Object (fromFoldable)
import Main (server)
import Node.HTTP (Server, listen, close)
import Node.HTTP.Client as C
import Test.Assert (assert)

main :: Effect Unit
main = do
  s <- server
  listen s opts $ runAff_ (handleAff s) do
    testWrongHost
    testWithoutXFrom
    testUnpermittedOrigin
    testCorrectRequest
  where
    opts =
      { hostname: "localhost"
      , port: 3000
      , backlog: Nothing
      }

handleAff :: Server -> Either Error Unit -> Effect Unit
handleAff _ (Left err) = do
  log $ message err
  assert false
handleAff s _ = close s $ pure unit

testWrongHost :: Aff Unit
testWrongHost = do
  res <- request opts
  liftEffect $ assert $ C.statusCode res == 403
  where
    opts = C.port := 3000
        <> C.method := "POST"
        <> C.path := "/test"
        <> C.headers := headers
    headers = C.RequestHeaders $ fromFoldable
      [ Tuple "Host" "localhost:3002"
      , Tuple "Origin" "http://localhost:3001"
      , Tuple "X-From" "http://localhost:3001"
      ]

testWithoutXFrom :: Aff Unit
testWithoutXFrom = do
  res <- request opts
  liftEffect $ assert $ C.statusCode res == 403
  where
    opts = C.port := 3000
        <> C.method := "POST"
        <> C.path := "/test"
        <> C.headers := headers
    headers = C.RequestHeaders $ fromFoldable
      [ Tuple "Host" "localhost:3000"
      , Tuple "Origin" "http://localhost:3001"
      ]

testUnpermittedOrigin :: Aff Unit
testUnpermittedOrigin = do
  res <- request opts
  liftEffect $ assert $ C.statusCode res == 403
  where
    opts = C.port := 3000
        <> C.method := "POST"
        <> C.path := "/test"
        <> C.headers := headers
    headers = C.RequestHeaders $ fromFoldable
      [ Tuple "Host" "localhost:3000"
      , Tuple "Origin" "http://localhost:3002"
      , Tuple "X-From" "http://localhost:3001"
      ]

testCorrectRequest :: Aff Unit
testCorrectRequest = do
  res <- request opts
  liftEffect $ assert $ C.statusCode res == 200
  where
    opts = C.port := 3000
        <> C.method := "POST"
        <> C.path := "/test"
        <> C.headers := headers
    headers = C.RequestHeaders $ fromFoldable
      [ Tuple "Host" "localhost:3000"
      , Tuple "Origin" "http://localhost:3001"
      , Tuple "X-From" "http://localhost:3001"
      ]
