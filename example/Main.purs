module Main where

import Prelude

import Bucketchain (createServer, listen)
import Bucketchain.CSRF (withCSRFProtection)
import Bucketchain.Http (requestMethod, requestURL)
import Bucketchain.Middleware (Middleware)
import Bucketchain.ResponseBody (body)
import Control.Monad.Reader (ask)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Node.HTTP (ListenOptions, Server)

main :: Effect Unit
main = server >>= listen opts

server :: Effect Server
server = createServer $ middleware1 <<< middleware2

opts :: ListenOptions
opts =
  { hostname: "127.0.0.1"
  , port: 3000
  , backlog: Nothing
  }

middleware1 :: Middleware
middleware1 = withCSRFProtection
  { host: "localhost:3000"
  , origins: [ "http://localhost:3000" ]
  }

middleware2 :: Middleware
middleware2 next = do
  http <- ask
  case requestMethod http, requestURL http of
    "POST", "/test" ->
      liftEffect $ Just <$> body "This is test."
    "GET", "/" ->
      liftEffect $ Just <$> body "html"
    _, _ ->
      next
